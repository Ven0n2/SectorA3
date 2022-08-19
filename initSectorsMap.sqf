params ["_display"];
private _map = _display displayCtrl 51;

// draw sectors
_map ctrlAddEventHandler ["Draw", {
    params ["_map"];

    {
        private _polygon = _x getVariable "polygon";
        private _shape = _x getVariable "shape";
        private _color = _x getVariable "color";

        _map drawPolygon [_polygon, [0,0,0,1]];
        _map drawTriangle [_shape, _color, "#(rgb,1,1,1)color(1,1,1,0.25)"];
    } forEach commy_sectors;
}];