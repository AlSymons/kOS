PRINT "==| Glider brake throttle control running |==".
BRAKES ON.

SET airBrakesList TO SHIP:PARTSTITLED("A.I.R.B.R.A.K.E.S").
SET brakesModList TO LIST().
SET airBrakesIt TO airBrakesList:ITERATOR.
UNTIL airBrakesIt:NEXT = false
	brakesModList:ADD(airBrakesIt:VALUE:GETMODULE("ModuleAeroSurface")).

lock x TO 100 - SHIP:CONTROL:PILOTMAINTHROTTLE * 100.

FUNCTION setAirBrakeLimiters
{
	PARAMETER limit is 100.

	SET brakesModIt TO brakesModList:ITERATOR.
	UNTIL brakesModIt:NEXT = false
		brakesModIt:VALUE:SETFIELD("Authority Limiter", limit).
}

UNTIL SHIP:STATUS = "Landed"
{
	setAirBrakeLimiters(x).
	wait 0.1.
}
setAirBrakeLimiters(100).