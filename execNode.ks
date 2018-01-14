DECLARE PARAMETER warpCancelTime IS 15, autoStage IS true, doWarp IS false.

WAIT UNTIL SHIP:UNPACKED. //need this to ensure boot works?
WAIT 1. //RT takes a little longer

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

PRINT "==| Maneuver Node execution program running |==".
PRINT "Autostage: " + autoStage.
PRINT "Time warping mode: " + doWarp.
if (doWarp)
	PRINT "Warp cancel buffer: " + warpCancelTime + " seconds.".

IF ADDONS:RT:HASCONNECTION(SHIP)
{
	COPYPATH("0:/execNode.ks","1:/boot/execNode.ks").
	COPYPATH("0:/setBoot.ks","1:/setBoot.ks").
} //else nothing because it's running on reboot.
RUNPATH("1:/setBoot.ks","/boot/execNode.ks").

SAS OFF.
WHEN SHIP:MAXTHRUST = 0 THEN
{
	if not autoStage
	{
		print "Stage out of fuel. Stage manually or break program.".
		WAIT UNTIL SHIP:MAXTHRUST > 0.
	}
	else
	{
		STAGE.
		PRESERVE.
	}
}

FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return ship:maxthrust/ship:mass.
}

set mNode to nextnode.


WAIT UNTIL SHIP:MAXTHRUST > 0.


FUNCTION readOut
{
	clearscreen.
	print "Node in: " + round(mNode:eta,2) + ". DeltaV: " + round(mNode:deltav:mag,2) + "m/s.".
	set burn_duration to mNode:deltav:mag/max_acc.
	print "Crude Estimated burn duration: " + round(burn_duration,2) + "s".
	if doWarp and warp > 0 print "Warping.".
	wait 0.01.
}

readOut.
PRINT "Orienting to node...".
lock np to mNode:deltav.
lock steering to np.

SET KUNIVERSE:TIMEWARP:MODE TO "RAILS".
WAIT UNTIL VANG(np, SHIP:FACING:FOREVECTOR) < 0.5.
if doWarp
{
	UNTIL mNode:eta < burn_duration/2 + warpCancelTime*2
	{
		readOut.
		SET kuniverse:timewarp:rate TO (mNode:eta / 10).
	}

	until mNode:eta < burn_duration/2 + warpCancelTime
		readOut.
	
	SET KUNIVERSE:TIMEWARP:MODE TO "PHYSICS".
	SET WARP TO 3.
}
until mNode:eta < burn_duration/2 + warpCancelTime*2
	readOut.

SET WARP TO 0.

until mNode:eta <= (burn_duration/2)
	readOut.

unlock np.
set np to mNode:deltav. //lock steering to the node as of now, don't change.

PRINT "Executing planned maneuver. Backspace to abort.".
until abort
{
	WAIT UNTIL SHIP:MAXTHRUST > 0. //avoid /0 error from max_acc
		set throttle to 1.0001-(1/(mNode:deltav:mag*2/max_acc+1))^3. //max throttle until last few seconds, drop off sharply. curve toward 0.
    
	if vdot(np, mNode:deltav) <= 0 //if negative, vecs facing opposite directions - overshot.
    {
        print "Maneuver complete. Error margin: " + round(mNode:deltav:mag,5) + "m/s.".
        lock throttle to 0.
        break.
    }
}

RUNPATH("1:/setBoot.ks").

unlock all.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

remove mNode.
