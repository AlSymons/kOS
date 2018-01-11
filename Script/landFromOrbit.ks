WHEN SHIP:MAXTHRUST = 0 THEN
{
	STAGE. PRESERVE.
}

SAS OFF.
LOCK STEERING TO RETROGRADE.
WAIT UNTIL VANG(SHIP:RETROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR) < 1.
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:GROUNDSPEED < 50. //TODO: set this to body surface rotational speed if heading eastish
LOCK THROTTLE TO 0.
RUNPATH("0:/land.ks").