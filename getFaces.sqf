// get vertices
private _dummies = allUnits;
private _vertices = _dummies apply {
    private _pos = getPosWorld _x;
    _pos set [2, 0];
    _pos set [3, _x];
    _pos
};

// sort vertices from left to right (and bottom to top)
_vertices sort true; // ascending
_dummies = _vertices apply {_x select 3};
_vertices = _vertices apply {_x select [0, 3]};

// get half-edges
private _halfEdges = [];

{
    private _x0 = _forEachIndex;
    private _connections = get3DENConnections _x select {_x param [0] isEqualTo "Sync"} apply {_dummies find (_x select 1)};

    {
        if (_x0 < _x) then {
            private _leftEdge = _vertices select _x0;
            private _rightEdge = _vertices select _x;
           _halfEdges pushBack [_x0, _x];
           _halfEdges pushBack [_x, _x0];
        };
    } forEach _connections;
} forEach _dummies;

// assign half-edges to vertices
private _vertexHalfEdges = _vertices apply {[]};

{
    _x params ["_source", "_target"];

    (_vertexHalfEdges select _source) pushBack _target;
} forEach _halfEdges;

// get next half-edge of each half-edge, counter-clockwise
private _halfEdgeNext = [];

{
    _x params ["_source", "_target"];

    private _nextHalfEdges = _vertexHalfEdges select _target;

    private _sourceVertex = _vertices select _source;
    private _targetVertex = _vertices select _target;

    private _angle = _targetVertex getDir _sourceVertex;
    private _sort = _nextHalfEdges apply {
        private _delta = (_targetVertex getDir (_vertices select _x)) - _angle + 360;

        if (_delta > 360) then { // don't mod, twin half-edge should be 360
            _delta = _delta - 360;
        };

        [_delta, _x]
    };
    _sort sort true; // ascending

    _halfEdgeNext pushBack (_sort select 0);
} forEach _halfEdges;

// find faces by traversing all half-edges
private _faces = [];
private _quene = +_halfEdges;

private _fnc_traverse = {
    params ["_source", "_target"];
    _halfEdgeNext select (_halfEdges find [_source, _target]) params ["_angle", "_next"];

    private _nextHalfEdge = [_target, _next];
    _quene deleteAt (_quene find _nextHalfEdge);

    _face set [0, (_face select 0) + _angle];
    if (_face pushBackUnique _nextHalfEdge != -1) then {
        _nextHalfEdge call _fnc_traverse;
    };
};

while {count _quene > 0} do {
    private _halfEdge = _quene deleteAt 0;

    private _face = [0, _halfEdge];
    _faces pushBack _face;

    _halfEdge call _fnc_traverse;
};

_faces select {
    private _angleSum = _x select 0;
    private _face = _x select [1, 1e7];

    round _angleSum == 180 * (count _face - 2) // filter infinite polygons
} apply {_x select [1, 1e7] apply {_vertices select (_x select 0)}} // return
