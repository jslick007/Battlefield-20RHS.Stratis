GLX_Rel_Dir_To_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Relative Direction To Function
	// ////////////////////////////////////////////////////////////////////////////
	// By Andrew Barron
	// Optimised and Extended by =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_object","_position"];
	
	private	_direction = (_object getRelDir _position);
	
	_direction
};

GLX_Real_Pos_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Relative Position Function
	// ////////////////////////////////////////////////////////////////////////////
	// By Andrew Barron
	// Optimised by =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_position","_distance","_direction"];
	
	if (_position isEqualType objNull) exitWith
	{
		private _return = (_position getPos [_distance, _direction] select [0, 2] ) + [getPos _position select 2];
		
		_return
	};
	
	if (_position isEqualType [] ) exitWith
	{
		private _return = (_position getPos [_distance, _direction] select [0, 2] ) + ( [ [], [_position select 2] ] select (count _position > 2) );
		
		_return
	};
};

GLX_Enemy_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Enemy Function
	// ////////////////////////////////////////////////////////////////////////////
	// By =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_enemy","_group","_logic"];
	
	private _units = allUnits;
	
	private _leader = (leader _group);
	
	_units = _units select { ( (alive _x) && { (side _group getFriend side _x < 0.6) } ) };
	
	if (alive _enemy) then
	{
		_units = _units select { ( ( (_group knowsAbout vehicle _x) >= (_group knowsAbout vehicle _enemy) ) && { ( (_leader distance _x) < (_leader distance _enemy) ) } ) };
	};
	
	private "_unit";
	
	private _count = 0;
	
	for "_count" from _count to (count _units - 1) do
	{
		_unit = (_units select _count);
		
		if (_group knowsAbout vehicle _unit > 0 ) exitWith
		{
			_enemy = _unit;
			
			_logic setVariable ["GLX_Enemy", (group _enemy) ];
		};
	};
	
	_enemy
};

GLX_Assign_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Assign Function
	// ////////////////////////////////////////////////////////////////////////////
	// By =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_group"];
	
	private _leader = (leader _group);
	
	if (isNull objectParent _leader) then
	{
		private _objects = _leader nearEntities ["Car", 100];
		
		_objects = _objects select { ( (alive _x) && { (fuel _x > 0) } && { (canMove _x) } && { (crew _x isEqualTo [] ) } && { (_leader knowsAbout _x > 0) } ) };
		
		if (_objects isEqualTo [] ) exitWith {};
		
		private _units = (units _group);
		
		private _vehicle = (_objects select 0);
		
		_leader assignAsDriver _vehicle;
		
		_units deleteAt (_units find _leader);
		
		if (_vehicle emptyPositions "Gunner" > 0) then
		{
			private _unit = (_units select 0);
			
			_unit assignAsGunner _vehicle;
			
			_units deleteAt (_units find _unit);
		};
		
		{_x assignAsCargo _vehicle} count _units;
	};
	
	True
};

GLX_Visible_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Visible Function
	// ////////////////////////////////////////////////////////////////////////////
	// By =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_enemy","_group"];
	
	private _time = 0;
	
	private _value = 1;
	
	private _array = [];
	
	private _random = 5;
	
	private _bool = True;
	
	private _knowledge = 0;
	
	private _units = (units _group);
	
	private _leader = (leader _group);
	
	private _tweak = (GLX_IQ select 0);
	
	private _value = (_value + _tweak);
	
	_random = (_random * _value);
	
	_units = _units select { ( (alive _x) && { (_x knowsAbout vehicle _enemy > 0) } ) };
	
	private ["_unit","_knowledge","_time"];
	
	private _count = 0;
	
	for "_count" from _count to (count _units - 1) do
	{
		_unit = (_units select _count);
		
		_knowledge = (_unit targetKnowledge vehicle _enemy) select 2;
		
		if (_knowledge < 0) then
		{
			_knowledge = (_unit targetKnowledge vehicle _enemy) select 3;
		};
		
		if (_knowledge > 0) then
		{
			_time = (time - _knowledge);
			
			if (_time < _random) then
			{
				_bool = False;
				
				_array pushBack _unit;
				
				// player sideChat format ["GLX_Visible_F > Knowledge > %1 > %2 > %3", _unit, _time, _random];
			};
		};
	};
	
	if (_bool) then
	{
		if (behaviour _leader isEqualTo "COMBAT") then
		{
			_units = (units _group);
			
			{_x disableAI "AUTOCOMBAT"} count _units;
			
			_group setBehaviour "AWARE";
			
			{_x forceSpeed -1; _x setUnitPos "AUTO"} count _units;
			
			// player sideChat format ["GLX_Visible_F > Move > %1", _group];
		};
		
		_random = 15;
		
		_random = (_random * _value);
		
		if (_time > _random) then
		{
			_group forgetTarget _enemy;
			
			// player sideChat format ["GLX_Visible_F > Forget > %1", _group];
		};
		
		// player sideChat format ["GLX_Visible_F > Forget > %1", _group];
	}
	else
	{
		if (behaviour _leader isEqualTo "AWARE") then
		{
			{_x enableAI "AUTOCOMBAT"} count _units;
			
			// player sideChat format ["GLX_Visible_F > Stop > %1", _group];
		};
	};
	
	_array
};

GLX_Spawn_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Spawn Function
	// ////////////////////////////////////////////////////////////////////////////
	// By =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_groups","_bool"];
	
	private _array = ["GLX_Init","GLX_Move","GLX_Request","GLX_Reinforcement"];
	
	private ["_group","_side","_leader","_playable","_objects","_units"];
	
	private _count = 0;
	
	for "_count" from _count to (count _groups - 1) do
	{
		_group = (_groups select _count);
		
		_side = (side leader _group);
		
		if (_side in (GLX_System select 1) ) then
		{
			_leader = (leader _group);
			
			if (_leader in GLX_Players) exitWith
			{
				if (GLX_Debug select 1) then
				{
					[_leader] spawn (GLX_Marker_F select 1);
				};
				
				// player sideChat format ["GLX_Extension_F > GLX_Spawn_F > Player > %1", _group];
			};
			
			_objects = [];
			
			{_objects append (synchronizedObjects _x) } count units _group;
			
			_objects = (_objects arrayIntersect _objects);
			
			if (isNil { (_group getVariable "GLX_Disable") } ) then
			{
				_group setVariable ["GLX_Disable", ""];
				
				// if (_objects isEqualTo [] ) exitWith {};
				
				// [_group, _array, _objects] call GLX_Trigger_F;
			};
			
			[_group, _objects] call GLX_Location_F;
			
			[_group, _array, _objects] call GLX_Trigger_F;
			
			if (_bool) then
			{
				private _count = 0;
				
				while { (_count < count units _group) } do
				{
					sleep 1;
					
					_count = _count + 1;
				};
				
				[_group, 0] setWaypointPosition [_leader, 0];
			};
			
			if (True) then
			{
				if (local _leader) exitWith {};
				
				_group setGroupOwner 2;
			};
			
			_group allowFleeing 0;
			
			_units = (units _group);
			
			{_x disableAI "TARGET";
			
			if (GLX_Debug select 1) then
			{
				[_x] spawn (GLX_Marker_F select 1);
			};
			
			// _x addEventHandler ["FiredMan", {_this call (GLX_EH_Fired_F select 0) } ];
			
			} forEach _units;
			
			(GLX_Groups select 0) pushBack _group;
		};
	};
	
	True
};

GLX_DayTime_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Daytime Function
	// ////////////////////////////////////////////////////////////////////////////
	// By Karel Moricky
	// Modified by Killzone_Kid
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_date"];
	
	private _return = True;
	
	private _equinox = (360 * dateToNumber _date) - (360 * 81 / 365);
	private _inc = asin (sin 23.44 * sin _equinox);
	private _latitude = - getNumber (configFile >> "cfgWorlds" >> worldName >> "latitude");
	
	private _angle = -tan _latitude * tan _inc;
	
	private _value = (acos _angle / 15);
	
	private _day = 11 - _value;
	
	_day = (round _day);
	
	if (dayTime < _day) then
	{
		_return = False;
	}
	else
	{
		_day = 13 + _value;
		
		_day = (round _day);
		
		if (dayTime > _day) then
		{
			_return = False;
		};
	};
	
	_return
};

GLX_Exist_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Exist Function
	// ////////////////////////////////////////////////////////////////////////////
	// Exist
	// By Killzone_Kid
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_file"];
	
	private _return = False;
	
	disableSerialization;
	
	private _ctrl = findDisplay 0 ctrlCreate ["RscHTML", -1];
	
	_ctrl htmlLoad _file;
	
	private _bool = ctrlHTMLLoaded _ctrl;
	
	if (_bool) then
	{
		_return = True;
	};
	
	_return
};

GLX_Building_Pos_F =

	// ////////////////////////////////////////////////////////////////////////////
	// Building Position Function
	// ////////////////////////////////////////////////////////////////////////////
	// By =\SNKMAN/=
	// ////////////////////////////////////////////////////////////////////////////
	{params ["_building"];
	
	private _index = 0;
	
	while { (True) } do
	{
		if (_building buildingPos _index isEqualTo [0,0,0] ) exitWith
		{
			_index = _index - 1;
		};
		
		_index = _index + 1;
	};
	
	_index
};