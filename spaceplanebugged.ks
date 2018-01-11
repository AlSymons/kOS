//Basic spaceplane takeoff and ascent to orbit program
//causes KSP to think the ship's state is 'landed' permanently.
//initially I thought this only happened on the version of the craft with a 'Mk1 Cargo Bay CRG-50-1',
//but after a few mutations of the script and tidying up the code it seems to be consistent across all versions of the craft.


SAS ON.

STAGE.
TOGGLE AG3.
LOCK THROTTLE TO 1.

Wait until SHIP:AIRSPEED > 130.
//SET SHIP:CONTROL:PITCH to 1.

WAIT UNTIL ALT:RADAR > 3.
//SET SHIP:CONTROL:PITCH to 0.

FUNCTION WaitUntilTopSpeed
{
	DECLARE PARAMETER minAccel IS 0.01.
	SET topspeed TO SHIP:AIRSPEED.
	WAIT 3.
	UNTIL FALSE
	{
		set topspeed to SHIP:AIRSPEED.
		WAIT 1.
		IF SHIP:AIRSPEED - topspeed < minAccel
			BREAK.
	}
}

SAS OFF.
GEAR OFF.

lock steering to heading(90,15).
lock targetspeed to max(200,altitude / 10).
lock throttle to targetspeed / SHIP:AIRSPEED.

wait until altitude > 2500.
set warp to 1.

wait until altitude > 8000.
set warp to 2.

wait until altitude > 12000.
lock steering to heading(90,5).

Toggle ag2. // Afterburner
WaitUntilTopSpeed.

set warp to 0.

lock steering to heading (90, 18).
Toggle ag3. //Rocket engine

SET numOut to 0.
UNTIL apoapsis > 75000
{	
	until numOut > 0
	{
		LIST ENGINES IN engines. 
		FOR eng IN engines 
		{
			IF eng:FLAMEOUT 
			{
				SET numOut TO numOut + 1.
			}
		}
		if numOut > 0 { Toggle ag1. Toggle ag2. }.
	}
}

lock throttle to 0.
lock steering to prograde.

set warp to 3.
Wait until altitude > 70000.
set warp to 0.

WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
KUNIVERSE:QUICKSAVETO("_Script node ahead").
PRINT "game saved to '_Script node ahead'".

//Exec maneuver node.
Unlock all.
SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
RUNPATH("0:/circapoapsis").
RUNPATH("0:/EXECNODE").

WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
KUNIVERSE:QUICKSAVETO("_Script finished").
PRINT "game saved to '_Script finished'".
