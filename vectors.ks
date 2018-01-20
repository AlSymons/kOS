//TARGET:POSITION is relative to ship.
//TARGET:POSITION:MAG to get distance to target.

function bearingClamp
{
	parameter x is 0.
	return MOD(ROUND(360 - x),360).
}

local p is 0.
local y is 0.
local r is 0.
local rot is 0.
	
UNTIL NOT SHIP:CONTROL:PILOTTOP = 0
{
	set rot to rot + 0.05. 

	set p to p + SHIP:CONTROL:PILOTPITCH * 10.//bearingClamp(p + SHIP:CONTROL:PILOTPITCH).
	set y to y + SHIP:CONTROL:PILOTYAW * 10.//bearingClamp(y + SHIP:CONTROL:PILOTYAW).
	set r to r + SHIP:CONTROL:PILOTROLL * 10.//bearingClamp(r + SHIP:CONTROL:PILOTROLL).
	
	//////////////////////////////////////
	
	SET bearingvec TO VECDRAW(
		  V(0,0,0), //start
		  VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR), //vector
		  RGB(1,0,0), //colour
		  "Ship bearing", //words
		  2.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

	SET forevec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:FACING:VECTOR, //vector
		  RGB(0.5,0.5,0.5), //colour
		  "SHIP:FACING", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

	SET upvec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:UP:VECTOR, //vector
		  RGB(0.5,0.5,0.5), //colour
		  "SHIP:UP", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).

	SET starvec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:FACING:STARVECTOR, //vector
		  RGB(0.5,0.5,0.5), //colour
		  "SHIP:FACING:STARVECTOR", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
		
	
	
	//////////////////////////////////////
	
	SET pilotVec TO VECDRAW(
	V(0,0,0),
	SHIP:FACING * R(p,y,r):VECTOR,
	RGB(0,0,1),
	"Pilot Vector: V(" + round(p,2) + "," + round(y,2) + "," + round(r,2) + ").",
	5.0,
	TRUE,
	0.1
	).
	
	/////////////////////////////////////
	
	
	SET pilotVecFlattened TO VECDRAW(
	V(0,0,0),
	VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING * R(p,y,r):VECTOR),
	RGB(0,1,0),
	"Pilot Vector with SHIP:UP excluded.",
	4.0,
	TRUE,
	0.1
	).
	
	
	////////////////////////////////////////
	
	
	if 0
	{
	
	//facing * pitch down
	SET rotvec1 TO VECDRAW( 
		  V(0,0,0), //start
		  SHIP:FACING * R(rot,0,0):VECTOR, //vector
		  RGB(1,0,0), //colour
		  "Ship facing * R(" + rot + ",0,0):VECTOR [pitch down]", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

	SET rotvec2 TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:FACING * R(0,rot,0):VECTOR, //vector
		  RGB(1,0,0), //colour
		  "Ship facing * R(0," + rot + ",0):VECTOR [yaw right]", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

	SET rotvec3 TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:FACING * R(0,0,rot):VECTOR, //vector
		  RGB(1,0,0), //colour
		  "Ship facing * R(0,0," + rot + "):VECTOR [roll left]", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

	//when combining directions, multiply them as directions
	//then turn the result into a vector if necessary
	SET shipfacingrot20 to SHIP:FACING * R(0,0,-20).//:VECTOR.
	SET rotvec4 TO VECDRAW(
		  V(0,0,0), //start
		  (shipfacingrot20 * R(-90,0,20)):VECTOR, //extra bracket unnecessary, for illustration
		  //shipfacingrot20 * R(-90,0,20):VECTOR is equivalent because of order of operation
		  RGB(1,0,0), //colour
		  "Ship facing * R(-90,0,0):VECTOR [up if facing horizontally, roll right 20]", //words
		  3.0, //scale
		  FALSE, //show
		  0.1 //width 
		).

	SET rotvec5 TO VECDRAW(
		V(0,0,0),
		SHIP:FACING * R(-90,0,0):VECTOR,
		RGB(1,1,1),
		"Up from ship facing, as opposed to ship:UP",
		3.0,
		FALSE,
		0.1
		).
	
		
	PRINT "ANGLE BETWEEN SHIP FACING AND UP: " + VANG(SHIP:FACING:FOREVECTOR, SHIP:UP:FOREVECTOR).
	}
	WAIT 0.1.
}
CLEARVECDRAWS().