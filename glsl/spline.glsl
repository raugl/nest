#version 330 core

struct Bezier {
    vec2 p0;
    vec2 p1;
    vec2 p2;
    vec2 p3;
};

vec2 bezier(Bezier b, float t) {
    float t2 = t * t;
    float t3 = t2 * t;
    const mat4 CHARACTERISTIC_MAT = mat4(1, 0, 0, 0, -3, 3, 0, 0, 3, -6, 3, 0, -1, 3, -3, 1);

    vec4 coefs = CHARACTERISTIC_MAT * vec4(1, t, t2, t3);
    return coefs.x * b.p0 + coefs.y * b.p1 + coefs.z * b.p2 + coefs.w * b.p3;
}

struct Spline {
    Bezier b[3];
};

// TODO: implement aabb checking
void main() {

}
