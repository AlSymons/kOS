DECLARE PARAMETER tgtSeperation IS 5000.

PRINT "==| Kill Relative Velocity program running |==".
PRINT "Waiting until target separation < " + tgtSeperation + " meters".


LOCK STEERING TO targetVesse

//

FUNCTION dok_kill_relative_velocity
{
	PARAMETER targetPort.
	
	LOCK relativeVelocity TO SHIP:VELOCITY:ORBIT - targetPort:VELOCITY:ORBIT.
	UNTIL relativeVelocity:MAG < 0.1
	{
		dok_translate(-relativeVelocity).
	}
	dok_translate(V(0,0,0)).
}