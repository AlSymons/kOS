PRINT "==| Glider brake throttle control running |==".
BRAKES ON.

UNTIL SHIP:STATUS = "Landed"
{
	LOCK X TO 100 - SHIP:CONTROL:PILOTMAINTHROTTLE * 100.
	
	SET AirBrakesList TO SHIP:PARTSTITLED("A.I.R.B.R.A.K.E.S").
	SET MyIterator TO AirBrakesList:ITERATOR.
	UNTIL MyIterator:NEXT = false
		MyIterator:VALUE:GETMODULE("ModuleAeroSurface"):SETFIELD("Authority Limiter", x).
}