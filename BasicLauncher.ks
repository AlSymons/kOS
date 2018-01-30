@LAZYGLOBAL OFF.

WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
KUNIVERSE:QUICKSAVETO("_Script start").
PRINT "game saved to '_Script start'".

DECLARE PARAMETER argapoapsis is 80000, argheading is 90, fairingAlt is 40000, extendPanels is true, ditchBooster is false.
PRINT "==| Basic orbital launcher running. |==".
PRINT "Target Apoapsis:" + argapoapsis.
PRINT "Target Heading:" + argheading.
PRINT "Decoupling fairings at "+fairingAlt+"m.".
PRINT "Automatically extend solar panels: " + extendPanels.

LOCAL tgtApoapsis is (argapoapsis * 1). // crash if input parameter not numeric
LOCAL  tgtheading is (argheading * 1). // crash if input parameter not numeric

//list fairings
local PartsList is SHIP:PARTS.
local PartsIterator is PartsList:ITERATOR.
local fairingList is LIST().
UNTIL PartsIterator:NEXT = false
if PartsIterator:VALUE:HASMODULE("ProceduralFairingDecoupler")
	fairingList:ADD(PartsIterator:VALUE).

IF SHIP:SOLIDFUEL > 0
	WHEN SHIP:SOLIDFUEL < 1 THEN
		STAGE.

IF ditchBooster //drop the booster in the atmosphere
	WHEN SHIP:PERIAPSIS > 67000 THEN
		STAGE.
		
local engines is LIST().
local FUNCTION autoStage //asparagus friendly
{
	local numOut is 0.
	LIST ENGINES IN engines. 
	FOR eng IN engines 
	{
		IF eng:FLAMEOUT 
			SET numOut TO numOut + 1.
	}
	if numOut > 0 { stage. }.
	wait 0.1. //for game performance
}
	
WHEN ALTITUDE > fairingAlt THEN
{
	//Jettison Fairings
	local fairingIterator is fairingList:ITERATOR.
	UNTIL fairingIterator:NEXT = false
		fairingIterator:VALUE:GETMODULE("ProceduralFairingDecoupler"):DOEVENT("Jettison").
}

FUNCTION angleToApoapsis
{
	PARAMETER tgtApo is 80000.
	
	return
	    MAX(-90,MIN(90, //always point forward
		(((tgtApo - SHIP:APOAPSIS) / (tgtApo/90)))) //90 at ground level, 0 at apoapsis.
		* (SHIP:VERTICALSPEED / SQRT(SHIP:VERTICALSPEED * SHIP:VERTICALSPEED))). //invert if going down.
}

lock targetspeed to max(200,altitude / 40). //don't overdo atmo drag
lock throttle to targetspeed / SHIP:AIRSPEED.
local countdown is 3.

UNTIL countdown = 0
{
    PRINT countdown + "..." .
    SET countdown TO countdown - 1.
    WAIT 1.
}

PRINT "Launch!".

STAGE.
WAIT 1.

PRINT "Performing gradual turn based on Apoapsis.".
PRINT "Pitch at sea level: 90. Pitch at "+tgtApoapsis+": 0.".

LOCK STEERING TO heading(tgtheading, angleToApoapsis(tgtApoapsis)).

UNTIL SHIP:APOAPSIS >= tgtApoapsis
	autoStage.

PRINT "Target apoapsis achieved. Awaiting atmospheric escape.".

//UNTIL SHIP:PERIAPSIS > 0 OR SHIP:ALTITUDE > 70000 OR ETA:APOAPSIS > 90 //wtf even is this?
//	autoStage.

LOCK THROTTLE TO 0.

SET KUNIVERSE:TIMEWARP:MODE TO "PHYSICS".
//SET WARP TO 3.

WAIT UNTIL ALTITUDE > 70000.

SET WARP TO 0.

if (extendPanels)
	PANELS ON.
TOGGLE AG10. //turn on antennas etc

RUNPATH("0:/CircApoapsis").
RUNPATH("0:/execnode",5,true,true).

IF SHIP:PERIAPSIS < 70000
{
	PRINT "Periapsis < 70000. Correcting.".
	//this can happen if stage transition substantially lowers max acceleration during mNode
	//because the time to node burn calculation is increased. TODO: execnode handles that.
	LOCK STEERING TO PROGRADE.
	LOCK THROTTLE TO 1.05 - SHIP:PERIAPSIS / 70000.
	WAIT UNTIL SHIP:PERIAPSIS > 70000.
	LOCK THROTTLE TO 0.
}

UNLOCK ALL.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. //Pilot throttle - throttle after program ends - only pilot control that is settable.
PRINT "Orbit achieved. Awaiting quicksave...".

WAIT UNTIL KUNIVERSE:CANQUICKSAVE.
KUNIVERSE:QUICKSAVETO("_Script finished").
PRINT "game saved to '_Script finished'".

RUNPATH("0:/setboot").

//todo: try KAC pause (works but only after switching scene) combined with 
//LAUNCHCRAFT() (launch a new craft) to pause game.