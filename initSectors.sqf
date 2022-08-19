#include "sectorsConfig.hpp"

// GLOBAL
if (isNil "commy_westSectorCount") then {
    commy_westSectorCount = 0;
};

if (isNil "commy_eastSectorCount") then {
    commy_eastSectorCount = 0;
};

// CLIENT
if (hasInterface) then {
    [{
        private _unit = [] call CBA_fnc_currentUnit;
        private _sector = _unit getVariable ["commy_sector", objNull];
        private _score = _sector getVariable ["score", 0];

        [_score, isNull _sector] call (uiNamespace getVariable "commy_fnc_updateScoreBar");
    }, 1] call CBA_fnc_addPerFrameHandler;
};

// SERVER
if (isServer) then {
    private _sectors = SECTORS;

    commy_sectors = [];

    {
        private _polygon = _x;

        // calculate the center
        private _center = [0,0,0];

        {
            _center = _center vectorAdd _x;
        } forEach _polygon;

        _center = _center vectorMultiply (1/count _polygon);

        // calculate the distance from the center to the furthest edge
        private _radius = 0;

        {
            _x set [2, 0];
            _radius = _radius max (_center vectorDistance _x);
        } forEach _polygon;

        // create shape for drawTriangle
        private _shape = _polygon call {
            #include "triangulate.sqf"
        };

        // create logic
        private _sector = true call CBA_fnc_createNamespace;
        _sector setVariable ["polygon", _polygon, true]; // public
        _sector setVariable ["shape", _shape, true]; // public
        _sector setVariable ["center", _center];
        _sector setVariable ["radius", _radius];
        _sector setVariable ["score", 0, true]; // public
        _sector setVariable ["lastUpdateTime", CBA_missionTime];
        _sector setVariable ["units", []];
        _sector getVariable ["cleanupQuene", []];
        _sector setVariable ["side", sideUnknown];
        _sector setVariable ["color", [1,1,1,1], true]; // public

        commy_sectors pushBack _sector;
    } forEach _sectors;

    publicVariable "commy_sectors";

    // update
    [{
        (_this select 0) params ["_iterator"];
        // pick one sector to update every frame
        if (_iterator >= count commy_sectors) then {
            _iterator = 0;
        };

        private _sector = commy_sectors select _iterator;
        (_this select 0) set [0, _iterator + 1];

        // update sector
        private _polygon = _sector getVariable "polygon";
        private _center = _sector getVariable "center";
        private _radius = _sector getVariable "radius";
        private _score = _sector getVariable "score";
        private _lastUpdateTime = _sector getVariable "lastUpdateTime";
        private _previousUnitsInSector = _sector getVariable "units";
        private _cleanupQuene = _sector getVariable "cleanupQuene";

        private _deltaT = (CBA_missionTime - _lastUpdateTime)/60; // in minutes
        if (_deltaT == 0) exitWith {};
        _sector setVariable ["lastUpdateTime", CBA_missionTime];

        private _unitsInSector = allUnits inAreaArray [_center, _radius, _radius, 0, false] select {
            getPosWorld _x inPolygon _polygon
        };

        // handle unit's sector info
        _sector setVariable ["units", _unitsInSector];

        private _arrivedUnits = _unitsInSector - _previousUnitsInSector;
        private _departedUnits = _previousUnitsInSector - _unitsInSector;

        {
            _x setVariable ["commy_sector", _sector, true];
        } forEach _arrivedUnits;

        {
            if (_x getVariable ["commy_sector", objNull] isEqualTo _sector) then {
                _x setVariable ["commy_sector", objNull, true];
            };
        } forEach (_cleanupQuene - _arrivedUnits);

        _sector setVariable ["cleanupQuene", _departedUnits];

        // calc new sector score
        {
            private _side = side group _x;

            if (_side isEqualTo west) then {
                _score = _score + _deltaT;
            } else {
                if (_side isEqualTo east) then {
                    _score = _score - _deltaT;
                };
            };
        } forEach _unitsInSector;

        _score = (_score min (MAX_SCORE)) max -(MAX_SCORE);
        _sector setVariable ["score", _score, true];

        // synchronize changes
        private _side = sideUnknown;
        private _color = [1,1,1,1];

        if (abs _score > (NEUTRAL_SCORE_THRESHOLD)) then {
            if (_score >= 0) then {
                _side = west;
                _color = [
                    profileNamespace getVariable ["Map_BLUFOR_R", 0],
                    profileNamespace getVariable ["Map_BLUFOR_G", 1],
                    profileNamespace getVariable ["Map_BLUFOR_B", 1],
                    1
                ];
            } else {
                _side = east;
                _color = [
                    profileNamespace getVariable ["Map_OPFOR_R", 0],
                    profileNamespace getVariable ["Map_OPFOR_G", 1],
                    profileNamespace getVariable ["Map_OPFOR_B", 1],
                    1
                ];
            };
        };

        private _previousSide = _sector getVariable "side";

        if (_side != _previousSide) then {
            if (_side == west) then {
                missionNamespace setVariable ["commy_westSectorCount", commy_westSectorCount + 1, true];
            };

            if (_side == east) then {
                missionNamespace setVariable ["commy_eastSectorCount", commy_eastSectorCount + 1, true];
            };

            if (_previousSide == west) then {
                missionNamespace setVariable ["commy_westSectorCount", commy_westSectorCount - 1, true];
            };

            if (_previousSide == east) then {
                missionNamespace setVariable ["commy_eastSectorCount", commy_eastSectorCount - 1, true];
            };

            _sector setVariable ["side", _side];
            _sector setVariable ["color", _color, true]; // public
        };
    }, 1/(CHECK_SECTOR_FREQUENCY), [0]] call CBA_fnc_addPerFrameHandler;
};