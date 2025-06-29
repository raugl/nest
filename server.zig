const std = @import("std");
const http = @import("httpz");
const oauth2 = @import("oauth2");

const GoogleProvider = oauth2.GoogleProvider;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() != .ok) @panic("Failed to deinitialize allocator");

    var oauth2_provider = try GoogleProvider.init(allocator, .{
        .client_id = "<google_client_id>",
        .client_secret = "<google_client_secret>",
        .redirect_uri = "http://localhost:3000/api/v1/oauth/google/callback",
    });
    defer oauth2_provider.deinit();

    var app = App{ .oauth = &oauth2_provider };
    var server = try http.Server(*App).init(allocator, .{ .port = 3000 }, &app);
    defer server.stop();
    defer server.deinit();

    var router = try server.router(.{});
    router.get("/api/v1/oauth/google", handleLogin, .{});
    router.get("/api/v1/oauth/google/callback", handleCallback, .{});

    try server.listen();
}

const App = struct {
    oauth: *GoogleProvider,
};

fn handleLogin(app: *App, _: *http.Request, res: *http.Response) !void {
    const state = try oauth2.generateStateOrCodeVerifier(res.arena);
    const code_verifier = try oauth2.generateStateOrCodeVerifier(res.arena);
    const url = try app.oauth.createAuthorizationUrl(res.arena, state, code_verifier, &.{ "email", "profile", "openid" });

    const cookie_conf = .{ .path = "/", .secure = true, .http_only = true, .max_age = 60 * 5 };
    try res.setCookie("example.gos", state, cookie_conf); // Google OAuth "State" cookie
    try res.setCookie("example.goc", code_verifier, cookie_conf); // Google OAuth "Code Verifier" cookie

    res.headers.add("Location", url);
    res.setStatus(.found);
}

fn handleCallback(app: *App, req: *http.Request, res: *http.Response) !void {
    const query = try req.query();

    if (query.get("error") != null) {
        std.debug.print("OAuth error: {s}\n", .{query.get("error").?});
        return res.setStatus(.internal_server_error);
    }

    const code = query.get("code") orelse return res.setStatus(.internal_server_error); // Missing code parameter
    const state = query.get("state") orelse return res.setStatus(.internal_server_error); // Missing state parameter
    const state_cookie = req.cookies().get("example_app.gos") orelse return res.setStatus(.bad_request); // Missing state cookie
    const code_verifier_cookie = req.cookies().get("example_app.goc") orelse return res.setStatus(.bad_request); // Missing code verifier cookie
    if (!std.mem.eql(u8, state, state_cookie)) return res.setStatus(.bad_request); // State mismatch

    const tokens = try app.oauth.validateAuthorizationCode(res.arena, code, code_verifier_cookie);
    const user_profile = try getUserProfile(res.arena, "https://www.googleapis.com/oauth2/v3/userinfo", tokens.access_token);
    defer user_profile.deinit();

    return res.json(user_profile.value, .{});
}

// An example of the Google Profile structure
const GoogleUserProfile = struct {
    sub: []const u8,
    email: []const u8,
    email_verified: bool,
    name: []const u8,
    given_name: []const u8,
    family_name: []const u8,
    picture: []const u8,
};

// Adding this helper function to reach out to Google using the provided bearer token (our access_token)
fn getUserProfile(allocator: std.mem.Allocator, url: []const u8, access_token: []const u8) !std.json.Parsed(GoogleUserProfile) {
    var http_client = std.http.Client{ .allocator = allocator };
    defer http_client.deinit();

    var response_storage = std.ArrayList(u8).init(allocator);
    defer response_storage.deinit();

    const response = try http_client.fetch(.{
        .location = .{ .url = url },
        .method = .GET,
        .headers = .{
            .authorization = .{ .override = try std.fmt.allocPrint(allocator, "Bearer {s}", .{access_token}) },
        },
        .extra_headers = &[_]std.http.Header{
            .{ .name = "User-Agent", .value = "oauth2.zig" },
            .{ .name = "Accept", .value = "application/json" },
        },
        .response_storage = .{ .dynamic = &response_storage },
    });

    if (response.status != .ok) return error.HttpError;

    return try std.json.parseFromSlice(GoogleUserProfile, allocator, response_storage.items, .{
        .allocate = .alloc_always,
        .ignore_unknown_fields = true,
    });
}
