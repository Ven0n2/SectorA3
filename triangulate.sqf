private _polygon = +_this; // deep copy
private _triangles = [];

private _fnc_triangleHeight = { // height from v to uw
    params ["_u", "_v", "_w"];

    private _a = _v vectorDistance _u;
    private _b = _v vectorDistance _w;
    private _c = _u vectorDistance _w;

    private _s = (_a+_b+_c)/2;
    2/_c * sqrt (_s * (_s-_a) * (_s-_b) * (s-_c)) // return
};

private _fnc_splitTriangle = {
    private _polygon = _this;

    // already triangular
    if (count _polygon <= 3) exitWith {
        _triangles append _polygon;
    };

    // shift, so left most (and lowest) vertex is second
    private _sort = +_polygon;
    _sort sort true; // ascending
    private _leftBottomMostIndex = _polygon find (_sort select 0);
    _polygon = (_polygon select [_leftBottomMostIndex, 1e7]) + (_polygon select [0, _leftBottomMostIndex]);
    reverse _polygon;
    _polygon pushBack (_polygon deleteAt 0);
    reverse _polygon;

    // find rogue vertices in triangle uvw
    _polygon params ["_u", "_v", "_w"];

    private _triangle = [_u, _v, _w];
    private _rogues = (_polygon select [3, 1e7]) select {_x inPolygon _triangle};

    if (count _rogues isEqualTo 0) then {
        // lucky, split polygon with N vertices into a triangle plus a polygon with N-1 vertices
        _triangles append [_u, _v, _w];
        _polygon deleteAt 1; // remove middle vertex
        _polygon call _fnc_splitTriangle; // recursion with smaller polygon
    } else {
        // unlucky, find furthest vertex from uw
        private _sort = _rogues apply {[
            [_u, _x, _w] call _fnc_triangleHeight,
            _x
        ]};
        _sort sort false; // descending

        private _furthest = _sort select 0 select 1;

        // split polygon into two smaller polygons at vf axis and continue with both
        private _furthestIndex = _polygon find _furthest;

        private _polygon1 = [_u, _v] + (_polygon select [_furthestIndex, 1e7]);
        private _polygon2 = _polygon select [1, _furthestIndex];

        _polygon1 call _fnc_splitTriangle;
        _polygon2 call _fnc_splitTriangle;
    };
};

_polygon call _fnc_splitTriangle;
_triangles