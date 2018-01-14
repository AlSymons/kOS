
FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return SHIP:MAXTHRUST/SHIP:MASS.
}

lock tgtRetrograde to TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
lock tgtVel to (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.

SAS OFF.
lock steering to tgtRetrograde.
lock orbPeriodDiff to abs(TARGET:ORBIT:PERIOD - SHIP:ORBIT:PERIOD).

wait until VANG(SHIP:FACING:VECTOR, tgtRetrograde) < 1.
lock throttle to 1.0001-(1/(tgtVel*2/max_acc+1))^3.

LOCAL lastPeriodDiff is orbPeriodDiff.

until false
{
	if orbPeriodDiff < 1
		break.
	
	//this triggers false positives. probably come up with something else
//	if lastPeriodDiff < orbPeriodDiff //overshot
	//	break.
	
	set lastPeriodDiff to orbPeriodDiff.
	wait 0.01.
}

PRINT "Orbital Period: "+round(SHIP:ORBIT:PERIOD,5)+" seconds.".
PRINT "Target OPeriod: "+round(TARGET:ORBIT:PERIOD,5)+" seconds.".

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock all.
