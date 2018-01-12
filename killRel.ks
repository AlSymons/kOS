
lock tgtRetrograde to TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
//lock tgtPrograde to -(target:velocity:orbit - ship:velocity:orbit).
lock steering to tgtRetrograde.

wait until VANG(SHIP:FACING:VECTOR, tgtRetrograde) < 1.

lock tgtVel to (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.

FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return SHIP:MAXTHRUST/SHIP:MASS.
}
local burn_duration is tgtVel/max_acc.

wait until TARGET:POSITION:MAG < 5000. //TODO: calculate this as half burn time to closest approach. TODO: figure out how to calculate closest approach.

lock throttle to 1 - (1/tgtVel).
wait until tgtVel < 1.

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock all.
