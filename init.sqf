////THE FOLLOWING LINE IS NEEDED FOR GRIMES SIMPLE REVIVE INIT BEFORE {PLAYER == PLAYER}
//[] execVM "G_Revive_init.sqf";
////

////THE FOLLOWING LINE IS NEEDED FOR TCL
/*
TCL_Path = "TCL_System\";

call compile preprocessFileLineNumbers (TCL_Path+"TCL_Preprocess.sqf");
TCL_Debug = [False, False, False, False, False, False, False];
TCL_Initialize = True;
*/
////

////THE FOLLOWING LINE IS NEEDED FOR GLX
/*
GLX_Path="GLX_System"
execVM (GLX_Path+"GLX_Initialize.sqf");
*/
////

////THE FOLLOWING LINE IS NEEDED FOR VCOMAI
[] spawn VCM_fnc_VcomInit;
////

// Run evannex gamemode
execVM "core\evannexInit.sqf";
// Enable friendly markers
execVM "core\client\QS_icons.sqf";
