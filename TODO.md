## TODO:
* steal the input api from egui
* do I need negative padding?
* do I need clipping override?
* do I need percent sizing?
* do I need negative z indicies?
* grid layout
* grid gaps/borders
* maybe add scroll direction, maybe add that in a different way using the scroll offset
* sticky grid row

## Tailwind classes:
* local id:             id-{[id]}
* global id:            id-{[#id]}
* padding:              p-{n}[px]
                        p[b, t, l, r, x, y]-{n}[px]
* bg color:             bg-{tw_color}(transparent by default)
* corner radius:        rounded-{xs, sm, md, lg, xl, xl2, xl3, xl4, full},
                        rounded-{b, t, l, r, bl, br, tl, tr}-{xs, sm, md, lg, xl, xl2, xl3, xl4, full},
* layout direction:     dir-{row, col}
* border:               border-{px}
                        border-{t, b, l, r, x, y, between}-{px}
                        border-{tw_color}
                        child-border // TODO
* width:                w-fit (default)
                        w-grow
                        w-{n}[px, fr]
                        min-w-{n}[px]
                        max-w-{n}[px]
* height:               h-fit
                        h-grow
                        h-{n}[px, fr]
                        min-h-{n}[px]
                        max-h-{n}[px]
* alignment:            align-[center(default), left, right, top, bottom]
                        align-[t, b, l, r, tl, tr, bl, br]
                        align-[top-left, top-right, bottom-left, bottom-right]
* relative anchor:      relative-{center(default), left, right, bottom, top}
                        relative-{left, right, bottom, top]-[left, right, bottom, top}
                        relative-{t, b, l, r, tl, tr, bl, br}
                        relative-{parent(default), cursor, root, [id]}
* relative offset:      [-]top-{n}[px]
                        [-]left-{n}[px]
                        [-]right-{n}[px]
                        [-]bottom-{n}[px]
* child gap:            gap-{n}[px]
* z-index:              z-{layer}
* cursor shape:         cursor-{default, pointer, help, wait, progress, text, crosshair, move, grab, grabbing, no-drop, not-allowed, all-scroll}
                        cursor-resize-{t, b, l, r, tr, tl, br, bl, x, y, tlbr, trbl}

* flex wrap:            TODO
* overflow:             TODO
* scale:                TODO
* rotation:             TODO
* translation:          TODO
* shadow:               TODO
* consume input events: TODO
* take up space in relative parent: TODO
