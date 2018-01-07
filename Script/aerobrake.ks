DECLARE PARAMETER thrust is 0.

if body:atm:exists
{
	lock steering to retrograde.
	
	PRINT "==| Aerobrake program running |==".
	PRINT "Thrust at periapsis: "+thrust.

	until body:atm:altitudepressure(altitude) > 0
		set warp to min(warp,round(altitude/body:atm:height)).
	
	panels off.
	SET WARP TO 0.
	
	if (thrust)
	{
		wait until eta:periapsis < 1.
		lock throttle to thrust.
		wait until apoapsis > 0.
		lock throttle to 0.
		set ship:control:pilotmainthrottle to 0.
	}
	
	wait until body:atm:altitudepressure(altitude) = 0.
	unlock all.
}