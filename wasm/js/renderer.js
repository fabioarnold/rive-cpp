var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');

function makeMatrix(m2d) {
    var m = svg.createSVGMatrix();
    m.a = m2d.xx;
    m.b = m2d.xy;
    m.c = m2d.yx;
    m.d = m2d.yy;
    m.e = m2d.tx;
    m.f = m2d.ty;
    return m;
}

Module.onRuntimeInitialized = function () {
    const {
        RenderPaintStyle,
        RenderPath,
        RenderPaint,
        Renderer
    } = Module;

    const {
        Fill,
        Stroke
    } = RenderPaintStyle;

    var CanvasRenderPath = RenderPath.extend("CanvasRenderPath", {
        __construct: function () {
            this.__parent.__construct.call(this);
            this._path2D = new Path2D();
        },
        reset: function () {
            this._path2D = new Path2D();
        },
        addPath: function (path, m2d) {
            this._path2D.addPath(path._path2D, makeMatrix(m2d));
        },
        moveTo: function (x, y) {
            this._path2D.moveTo(x, y);
        },
        lineTo: function (x, y) {
            this._path2D.lineTo(x, y);
        },
        cubicTo: function (ox, oy, ix, iy, x, y) {
            this._path2D.bezierCurveTo(ox, oy, ix, iy, x, y);
        },
        close: function () {
            this._path2D.closePath();
        }
    });

    function _colorStyle(value) {
        return 'rgba(' + ((0x00ff0000 & value) >>>
                16) + ',' + ((0x0000ff00 &
                value) >>> 8) + ',' + ((0x000000ff & value) >>> 0) + ',' +
            (((0xff000000 & value) >>> 24) / 0xFF) + ')'
    }
    var CanvasRenderPaint = RenderPaint.extend("CanvasRenderPaint", {
        color: function (value) {
            this._value = _colorStyle(value);
        },
        thickness: function (value) {
            this._thickness = value;
        },
        style: function (value) {
            this._style = value;
        },
        linearGradient: function (sx, sy, ex, ey) {
            this._gradient = {
                sx,
                sy,
                ex,
                ey,
                stops: []
            };
        },
        radialGradient: function (sx, sy, ex, ey) {
            this._gradient = {
                sx,
                sy,
                ex,
                ey,
                stops: [],
                isRadial: true
            };
        },
        addStop: function (color, stop) {
            this._gradient.stops.push({
                color,
                stop
            });
        },

        completeGradient: function () {

        },

        draw: function (ctx, path) {
            let {
                _style,
                _value,
                _gradient
            } = this;

            if (_gradient != null) {
                const {
                    sx,
                    sy,
                    ex,
                    ey,
                    stops,
                    isRadial
                } = _gradient;

                if (isRadial) {
                    var dx = ex - sx;
                    var dy = ey - sy;
                    var radius = Math.sqrt(dx * dx + dy * dy);
                    _value = ctx.createRadialGradient(sx, sy, 0, sx, sy, radius);
                } else {
                    _value = ctx.createLinearGradient(sx, sy, ex, ey);
                }

                for ({
                        stop,
                        color
                    } of stops) {
                    _value.addColorStop(stop, _colorStyle(color));
                }
                this._value = _value;
                this._gradient = null;
            }
            switch (_style) {
                case Stroke:
                    ctx.strokeStyle = _value;
                    ctx.lineWidth = this._thickness;
                    ctx.stroke(path._path2D);
                    break;
                case Fill:
                    ctx.fillStyle = _value;
                    ctx.fill(path._path2D);
                    break;
            }
        }
    });

    Module.CanvasRenderer = Renderer.extend("Renderer", {
        __construct: function (ctx) {
            this.__parent.__construct.call(this);
            this._ctx = ctx;
        },
        save: function () {
            this._ctx.save();
        },
        restore: function () {
            this._ctx.restore();
        },
        translate: function (x, y) {
            this._ctx.translate(x, y);
        },
        transform: function (matrix) {
            this._ctx.transform(matrix.xx, matrix.xy, matrix.yx, matrix.yy, matrix.tx,
                matrix.ty);
        },
        drawPath: function (path, paint) {
            paint.draw(this._ctx, path);
        },
        clipPath: function (path) {
            // console.log("CLIP PATH", path);
        }
    });

    Module.renderFactory = {
        makeRenderPaint: function () {
            return new CanvasRenderPaint();
        },
        makeRenderPath: function () {
            return new CanvasRenderPath();
        }
    };
};