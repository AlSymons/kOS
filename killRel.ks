FUNCTION max_acc
{
	if SHIP:MAXTHRUST = 0
		return 0.
	return SHIP:MAXTHRUST/SHIP:MASS.
}

lock tgtRetrograde to TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
lock tgtVel to (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.
//lock tgtPrograde to -(target:velocity:orbit - ship:velocity:orbit).
SAS OFF.
lock steering to tgtRetrograde.

wait until VANG(SHIP:FACING:VECTOR, tgtRetrograde) < 1.

//local burn_duration is tgtVel/max_acc.
//wait until TARGET:POSITION:MAG < 5000. //TODO: calculate this as half burn time to closest approach. TODO: figure out how to calculate closest approach.

lock throttle to 1.0001-(1/(tgtVel*2/max_acc+1))^3.
wait until tgtVel < 1.

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock all.
