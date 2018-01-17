//Basic spaceplane runway takeoff program.
//This handles takeoff and then runs the larger ascent to orbit script.
//For some reason this dodges a bug that causes KSP to think the ship's status is landed at all times.


SAS ON.

STAGE.
TOGGLE AG3.
LOCK THROTTLE TO 1.

//Wait until SHIP:AIRSPEED > 130.
//SET SHIP:CONTROL:PITCH to 1.

//WAIT UNTIL ALT:RADAR > 3.
//SET SHIP:CONTROL:PITCH to 0.

//LOCK WHEELSTEERING TO 90. //old technique doesn't work any more, run off the end of the runway.
WAIT UNTIL ALT:RADAR > 10.

if SHIP:STATUS = "LANDED" and ALT:RADAR > 10 and KUniverse:CANREVERTTOLAUNCH
		KUniverse:REVERTTOLAUNCH().

UNLOCK ALL.
RUNPATH("0:/spaceplane.ks").
RUNPATH("0:/setboot.ks").