//Precise version of node execution program.
//Finishes node burn slowly; not suitable for orbital insertion from gravity well.
IF target = ""
	throw("tantrum").

DECLARE PARAMETER warpCancelTime IS 15, autoStage IS true, doWarp IS false.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

PRINT "==| Precise node execution program running |==".
PRINT "Autostage: " + autoStage.
PRINT "Time warping mode: " + doWarp.
if (doWarp)
	PRINT "Warp cancel buffer: " + warpCancelTime + " seconds.".

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
WAIT UNTIL VANG(np, SHIP:FACING:FOREVECTOR) < 0.1.
if doWarp
{
	print "warping".

	UNTIL mNode:eta < burn_duration/2 + warpCancelTime*2
		SET kuniverse:timewarp:rate TO (mNode:eta / 10).

	SET KUNIVERSE:TIMEWARP:MODE TO "PHYSICS".
	SET WARP TO 3.

	wait until mNode:eta < burn_duration/2 + warpCancelTime.
}
SET WARP TO 0.

//now we need to wait until the burn vector and ship's facing are aligned
//wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
//doesn't work. nice tutorial.

//the ship is facing the right direction, let's wait for our burn time
wait until mNode:eta <= (burn_duration/2).

unlock np.
set np to mNode:deltav. //lock steering to the node as of now, don't change.

set done to false.
set dv0 to mNode:deltav.

//returns the number of times to call nextpatch on an orbit to get it's final patch.
FUNCTION numPatches
{
	DECLARE PARAMETER orb IS SHIP:ORBIT.
	set x to 0.
	UNTIL orb:HASNEXTPATCH = false
	{
    set x to x + 1.
		set orb to orb:NEXTPATCH.
	}
	return x.
}
//FUNCTION getLastPatch
//{
//	DECLARE PARAMETER orb IS SHIP:ORBIT.
//	
//	UNTIL orb:HASNEXTPATCH = false
//		set orb to orb:NEXTPATCH.
//	return orb.
//}
FUNCTION getTgtBodyPatch
{
	DECLARE PARAMETER orb IS SHIP:ORBIT.
	
	UNTIL orb:HASNEXTPATCH = false
	{
		set orb to orb:NEXTPATCH.
		if orb:BODY = target.
			return orb.
	}
	return 0.
}


//if there's more than one patch, then the periapsis in the final patch is the most sensitive
//variable to initial conditions and the most important factor in our destination.
set tgtMode to 0.
IF mNode:ORBIT:HASNEXTPATCH
	set tgtMode to 1.

if tgtMode = 1 until 0
{
	//TODO: numpatches caused an exception when KSP max patched conics set higher
	//but not until it predicted a bunch of flybys
	if numPatches = numPatches(mNode:ORBIT) //patched conics of ship and maneuver node should share the same SoI's
	{
		if getTgtBodyPatch:PERIAPSIS < getTgtBodyPatch(mNode:ORBIT):PERIAPSIS
		{
			lock throttle to 0.
			SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
			break.
		}
		WAIT UNTIL SHIP:MAXTHRUST > 0.
		set throttle to (1 - ((getTgtBodyPatch(mNode:ORBIT):PERIAPSIS*0.9999999999 / getTgtBodyPatch:PERIAPSIS)^2))/max_acc.
		PRINT throttle.
//		LOCK THROTTLE TO 1 - ((peritarget * 0.9999999999 / SHIP:PERIAPSIS)^2).
	}
	else
	{
		WAIT UNTIL SHIP:MAXTHRUST > 0.
//		set throttle to min(mNode:deltav:mag/max_acc, 1). //no lock to avoid /0 error
		set throttle to mNode:deltav:mag/max_acc. //no lock to avoid /0 error
	}
}
else //until 0
{
//node orbit contained within this SoI, pick Apo or Peri as most important based on which is further away in time.
//todo

}

unlock all.
remove mNode.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.