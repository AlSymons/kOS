set rot to 0.

//TARGET:POSITION is relative to ship.
//TARGET:POSITION:MAG to get distance to target.

UNTIL NOT SHIP:CONTROL:PILOTTOP = 0
{
	set rot to rot + 0.05. 

	SET facevec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:FACING:FOREVECTOR, //vector
		  RGB(0,0,1), //colour
		  "SHIP:FACING:FOREVECTOR", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
		
	SET upvec TO VECDRAW(
		  V(0,0,0), //start
		  SHIP:UP:FOREVECTOR, //vector
		  RGB(0,1,0), //colour
		  "SHIP:UP:FOREVECTOR", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
	
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
		  TRUE, //show
		  0.1 //width 
		).

	SET rotvec5 TO VECDRAW(
		V(0,0,0),
		SHIP:FACING * R(-90,0,0):VECTOR,
		RGB(1,1,1),
		"Up from ship facing, as opposed to ship:UP",
		3.0,
		TRUE,
		0.1
		).

	PRINT "ANGLE BETWEEN SHIP FACING AND UP: " + VANG(SHIP:FACING:FOREVECTOR, SHIP:UP:FOREVECTOR).

	WAIT 0.05.
}
CLEARVECDRAWS().