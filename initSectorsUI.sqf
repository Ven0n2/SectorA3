#include "sectorsConfig.hpp"
params ["_display"];

private _alpha = 0.5;
private _size = 0.4;
private _aspectRatio = 1/25;
private _width = _size * safezoneW;
private _height = _size * _aspectRatio * safezoneH * (getResolution#4);
private _left = 0.5 - _width/2;
private _top = safezoneY + _height * 0.1;

// total controlled sectors
private _textWidth = 1.5 * _width * _aspectRatio;
private _textHeight = 1.5 * _height;

private _controlledSectorsWest = _display ctrlCreate ["RscTextNoShadow", -1];
_controlledSectorsWest ctrlSetPosition [
    safezoneX + 2*_textWidth,
    _top,
    _textWidth,
    _height
];
_controlledSectorsWest ctrlCommit 0;
_controlledSectorsWest ctrlSetFontHeight _textHeight;
_controlledSectorsWest ctrlSetTextColor [
    profileNamespace getVariable ["Map_BLUFOR_R", 0],
    profileNamespace getVariable ["Map_BLUFOR_G", 1],
    profileNamespace getVariable ["Map_BLUFOR_B", 1],
    1
];

private _controlledSectorsEast = _display ctrlCreate ["RscTextNoShadow", -1];
_controlledSectorsEast ctrlSetPosition [
    safezoneX + 3*_textWidth,
    _top,
    _textWidth,
    _height
];
_controlledSectorsEast ctrlCommit 0;
_controlledSectorsEast ctrlSetFontHeight _textHeight;
_controlledSectorsEast ctrlSetTextColor [
    profileNamespace getVariable ["Map_OPFOR_R", 0],
    profileNamespace getVariable ["Map_OPFOR_G", 1],
    profileNamespace getVariable ["Map_OPFOR_B", 1],
    1
];

// timer
private _timer = _display ctrlCreate ["RscTextNoShadow", -1];
_timer ctrlSetPosition [
    safezoneX + 5*_textWidth,
    _top,
    2*_textWidth,
    _height
];
_timer ctrlCommit 0;
_timer ctrlSetFontHeight _textHeight;
_timer ctrlSetTextColor [1,1,1,1];

// border
private _borderScale = 1/10;
private _borderHeight = _height * _borderScale;
private _borderWidth = _width * _borderScale * _aspectRatio;

private _borderTop = _display ctrlCreate ["RscText", -1];
_borderTop ctrlSetPosition [
    _left,
    _top,
    _width,
    _borderHeight
];

private _borderBotom = _display ctrlCreate ["RscText", -1];
_borderBotom ctrlSetPosition [
    _left,
    _top + _height - _borderHeight,
    _width,
    _borderHeight
];

private _borderLeft = _display ctrlCreate ["RscText", -1];
_borderLeft ctrlSetPosition [
    _left,
    _top + _borderHeight,
    _borderWidth,
    _height - 2*_borderHeight
];

private _borderRight = _display ctrlCreate ["RscText", -1];
_borderRight ctrlSetPosition [
    _left + _width - _borderWidth,
    _top + _borderHeight,
    _borderWidth,
    _height - 2*_borderHeight
];

{
    _x ctrlCommit 0;
    _x ctrlSetBackgroundColor [0,0,0,_alpha];
} forEach [_borderTop, _borderBotom, _borderLeft, _borderRight];

// bars
private _scoreBarWest = _display ctrlCreate ["RscText", -1];
_scoreBarWest ctrlSetPosition [
    _left + _borderWidth,
    _top + _borderHeight,
    (_width - 2*_borderWidth)/2,
    _height - 2*_borderHeight
];
_scoreBarWest ctrlCommit 0;
_scoreBarWest ctrlSetBackgroundColor [
    profileNamespace getVariable ["Map_BLUFOR_R", 0],
    profileNamespace getVariable ["Map_BLUFOR_G", 1],
    profileNamespace getVariable ["Map_BLUFOR_B", 1],
    _alpha
];

private _scoreBarEast = _display ctrlCreate ["RscText", -1];
_scoreBarEast ctrlSetPosition [
    _left + _borderWidth + (_width - 2*_borderWidth)/2,
    _top + _borderHeight,
    (_width - 2*_borderWidth)/2,
    _height - 2*_borderHeight
];
_scoreBarEast ctrlCommit 0;
_scoreBarEast ctrlSetBackgroundColor [
    profileNamespace getVariable ["Map_OPFOR_R", 0],
    profileNamespace getVariable ["Map_OPFOR_G", 1],
    profileNamespace getVariable ["Map_OPFOR_B", 1],
    _alpha
];

private _position = [
    _left + _borderWidth,
    _top + _borderHeight,
    _width - 2*_borderWidth,
    _height - 2*_borderHeight
];

// update function
_display setVariable ["scoreBarData", [_controlledSectorsWest, _controlledSectorsEast, _timer, _scoreBarWest, _scoreBarEast, _position]];
uiNamespace setVariable ["commy_fnc_updateScoreBar", {
    private _display = uiNamespace getVariable ["RscDisplayMission", displayNull];
    private _controls = _display getVariable "scoreBarControls";
    _display getVariable "scoreBarData" params ["_controlledSectorsWest", "_controlledSectorsEast", "_timer", "_scoreBarWest", "_scoreBarEast", "_position"];
    _position params ["_left", "_top", "_width", "_height"];

    _controlledSectorsWest ctrlSetText format ["%1", commy_westSectorCount];
    _controlledSectorsEast ctrlSetText format ["%1", commy_eastSectorCount];

    params ["_score", "_fade"];

    if (_fade) then {
        {
            if (ctrlCommitted _x) then {
                _x ctrlSetFade 1;
                _x ctrlCommit 1;
            };
        } forEach _controls;
    } else {
        private _widthX = _width * (_score + (MAX_SCORE)) / (2*(MAX_SCORE));

        _scoreBarWest ctrlSetPosition [
            _left,
            _top,
            _widthX,
            _height
        ];

        _scoreBarEast ctrlSetPosition [
            _left + _widthX,
            _top,
            _width - _widthX,
            _height
        ];

        {
            if (ctrlCommitted _x) then {
                _x ctrlSetFade 0;
                _x ctrlCommit .2;
            };
        } forEach _controls;
    };

    private _timeLeft = floor ((MISSION_END_TIME) - CBA_missionTime/60) max 0;
    _timer ctrlSetText ([_timeLeft, "M:SS"] call CBA_fnc_formatElapsedTime);
}];

// middle, indicates draw
private _thresholdWest = _display ctrlCreate ["RscText", -1];
_thresholdWest ctrlSetPosition [
    _left + _width * (1 - ((MAX_SCORE) - (NEUTRAL_SCORE_THRESHOLD)) / (MAX_SCORE)),
    _top,
    _borderWidth,
    _height
];
_thresholdWest ctrlCommit 0;
_thresholdWest ctrlSetBackgroundColor [0,0,0,1];

private _thresholdEast = _display ctrlCreate ["RscText", -1];
_thresholdEast ctrlSetPosition [
    _left + _width * ((MAX_SCORE) - (NEUTRAL_SCORE_THRESHOLD)) / (MAX_SCORE),
    _top,
    _borderWidth,
    _height
];
_thresholdEast ctrlCommit 0;
_thresholdEast ctrlSetBackgroundColor [0,0,0,1];

_display setVariable ["scoreBarControls", [
    _scoreBarWest, _scoreBarEast,
    _borderTop, _borderBotom, _borderLeft, _borderRight,
    _thresholdWest, _thresholdEast
]];