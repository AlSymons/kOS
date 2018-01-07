
DECLARE PARAMETER warpCancelTime IS 15, autoStage IS true, doWarp IS false.

WAIT UNTIL SHIP:UNPACKED. //need this to ensure boot works?

WAIT 1. //RT takes a little longer

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

PRINT "==| Maneuver Node execution program running |==".
PRINT "Autostage: " + autoStage.
PRINT "Time warping mode: " + doWarp.
if (doWarp)
	PRINT "Warp cancel buffer: " + warpCancelTime + " seconds.".

//todo if file exists etc
IF ADDONS:RT:HASCONNECTION(SHIP) //does work
{
	COPYPATH("0:/execNode.ks","1:/boot/execNode.ks"). //volume out of range error. wat.
	COPYPATH("0:/setBoot.ks","1:/setBoot.ks").
}
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
		STAGE.
	PRESERVE.
}

FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return ship:maxthrust/ship:mass.
}

set mNode to nextnode.

//print out node's basic parameters - ETA and deltaV
print "Node in: " + round(mNode:eta) + ", DeltaV: " + mNode:deltav:mag.

WAIT UNTIL SHIP:MAXTHRUST > 0.
set burn_duration to mNode:deltav:mag/max_acc.
print "Crude Estimated burn duration: " + (burn_duration) + "s".

lock np to mNode:deltav. //points to node, don't care about the roll direction.
lock steering to np.

SET KUNIVERSE:TIMEWARP:MODE TO "RAILS".
WAIT UNTIL VANG(np, SHIP:FACING:FOREVECTOR) < 0.5.
if doWarp
{
	print "warping".

	UNTIL mNode:eta < burn_duration/2 + warpCancelTime*2
		SET kuniverse:timewarp:rate TO (mNode:eta / 10).

	wait until mNode:eta < burn_duration/2 + warpCancelTime.
	SET KUNIVERSE:TIMEWARP:MODE TO "PHYSICS".
	SET WARP TO 3.
}
wait until mNode:eta < burn_duration/2 + warpCancelTime*2.
SET WARP TO 0.
//now we need to wait until the burn vector and ship's facing are aligned
//wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
//doesn't work. nice tutorial.

//the ship is facing the right direction, let's wait for our burn time
wait until mNode:eta <= (burn_duration/2).

unlock np.
set np to mNode:deltav. //lock steering to the node as of now, don't change.

set dv0 to mNode:deltav.

PRINT "Executing planned maneuver.".
until 0
{
	//throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
	WAIT UNTIL SHIP:MAXTHRUST > 0. //avoid /0 error from max_acc
    set throttle to 1.0001-(1/(mNode:deltav:mag*2/max_acc+1))^3.
	//max throttle until last few seconds, drop off sharply. curve toward 0.
	print throttle.

	//cut throttle when nd:deltav and initial deltav face opposite directions
    //this check is done via checking the dot product of those 2 vectors
	if vdot(dv0, mNode:deltav) < 0
    {
        print "End burn, remain dv " + round(mNode:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, mNode:deltav),1).
        lock throttle to 0.
        break.
    }
}

unlock all.
RUNPATH("1:/setBoot.ks").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
remove mNode.
