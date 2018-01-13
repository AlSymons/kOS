FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return SHIP:MAXTHRUST/SHIP:MASS.
}


lock tgtRetrograde to TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
lock tgtVel to (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.

lock steering to tgtRetrograde.
lock orbPeriodDiff to abs(target:orbit:period - ship:orbit:period).

wait until VANG(SHIP:FACING:VECTOR, tgtRetrograde) < 1.
lock throttle to 1.0001-(1/(tgtVel*2/max_acc+1))^3.

LOCAL lastPeriodDiff is orbPeriodDiff.

until false
{
	if orbPeriodDiff < 1
		break.
	
	if lastPeriodDiff < orbPeriodDiff //overshot
		break.
	
	set lastPeriodDiff to orbPeriodDiff.
	wait 0.01.
}

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock all.
