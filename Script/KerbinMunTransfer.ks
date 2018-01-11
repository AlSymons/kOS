PRINT "==| Adding Kerbin->Mun transfer maneuver |==".
DECLARE PARAMETER tgtPeri is 7200, autoexec is false.

//IF SHIP:ORBIT:INCLINATION > 5
//	THROW("Tantrum").

IF hasnode
	THROW("Tantrum").

	lock max_acc to ship:maxthrust/ship:mass.
set burn_duration to 860/max_acc.

//Add 860 m/s node burn just ahead of craft with a few seconds to spare
SET MunNode TO NODE (TIME:SECONDS + 10 + burn_duration / 2, 0, 0, 860).
ADD MunNode.

SET target TO Mun.

//drag it forward in time until a mun encounter is found
UNTIL MunNode:ORBIT:HASNEXTPATCH
	SET MunNode:ETA TO MunNode:ETA + 3.

//tune to the power of at end of formula for greater accuracy
lock deltaNodeETA to 0.5.//(1 - (tgtPeri / MunNode:ORBIT:NEXTPATCH:PERIAPSIS))^10.

UNTIL MunNode:ORBIT:NEXTPATCH:PERIAPSIS < tgtPeri*2
	SET MunNode:ETA TO MunNode:ETA + deltaNodeETA.

lock deltaNodeETA to (1 - (tgtPeri / MunNode:ORBIT:NEXTPATCH:PERIAPSIS))^100.

UNTIL MunNode:ORBIT:NEXTPATCH:PERIAPSIS < tgtPeri
	SET MunNode:ETA TO MunNode:ETA + deltaNodeETA.
	
if MunNode:ORBIT:NEXTPATCH:PERIAPSIS < 5000
{
	remove mNode.
	runpath("0:/kerbinmuntransfer.ks").

}
	
if hasnode
	if autoexec
		runpath("0:/execnodeprecise.ks",15,true,false).


//set dirVec to MunNode:deltav.
//lock steering to dirVec.