FUNCTION RDV_STEER //lock steering, wait until pointing close to vector.
{
	PARAMETER vector.
	LOCK STEERING TO vector.
	WAIT UNTIL VANG(Ship:FACING:FOREVECTOR, vector) < 2.
}

FUNCTION RDV_APPROACH
{
	PARAMETER craft, speed.
	
	LOCK rVel TO CRAFT:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
	RDV_STEER(craft:POSITION). LOCK STEERING TO craft:POSITION.
	
	LOCK maxAccel TO SHIP:MAXTHRUST / SHIP:MASS.
	LOCK THROTTLE TO MIN(1, ABS(speed - rVel:MAG) / maxAccel).
	
	WAIT UNTIL rVel:MAG > speed - 0.1.
	LOCK THROTTLE TO 0.
	LOCK STEERING TO rVel.
}

FUNCTION RDV_CANCEL
{
	PARAMETER craft.
	
	LOCK rVel TO CRAFT:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
	RDV_STEER(rVel). LOCK STEERING TO rVel.
	
	LOCK maxAccel TO SHIP:MAXTHRUST / SHIP:MASS.
	LOCK THROTTLE TO MIN(1, rVel:MAG / maxAccel).

	WAIT UNTIL rVel:MAG < 0.1.
	LOCK THROTTLE TO 0.
}

FUNCTION RDV_AWAIT_NEAREST
{
	PARAMETER craft, minDistance.
	
	UNTIL 0
	{
		SET lastDistance TO craft:DISTANCE.
		WAIT 0.1.
		IF craft:distance > lastDistance OR craft:distance < minDistance { BREAK. }
	}
}