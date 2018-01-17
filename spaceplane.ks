//Basic spaceplane ascent to orbit program
//to be run after takeoff to avoid ship status 'landed' while flying bug.

FUNCTION waitUntilTopSpeed
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

BRAKES off.
SAS off.
Gear off.

lock steering to heading(90,15).
lock targetspeed to max(200,altitude / 20).
lock throttle to targetspeed / SHIP:AIRSPEED.

wait until altitude > 2500.
set warp to 1.

wait until altitude > 8000.
set warp to 2.

wait until altitude > 12000.
lock steering to heading(90,5).

Toggle ag2. // Afterburner
lock throttle to 1.
Waituntiltopspeed.

set warp to 0.

lock steering to heading (90, 18).
//angle test results:
//35: 23m/s. 30: 74m/s 25: 116m/s 20: 142m/s 15: 144m/s, but at 72849m apoapsis.
//17: 145m/s, 73924m apo. 19: 146m/s, 74579 apo. 18:152m/s!!! 74344m apoapsis.

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
	wait 0.1.
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
//RUNPATH("0:/PAUSEGAME.KS"). doesn't work. the pause part anyway.
panels on.