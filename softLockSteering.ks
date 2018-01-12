DECLARE PARAMETER tgtheading is 90, tgtpitch is 10.

SAS off.

until SHIP:CONTROL:PILOTTOP <> 0
{
	//check for pilot input
	if SHIP:CONTROL:PILOTPITCH = 0 and SHIP:CONTROL:PILOTYAW = 0 and SHIP:CONTROL:PILOTROLL = 0
		lock STEERING TO HEADING(tgtheading,tgtpitch).
	else
	{
		unlock steering.
		wait 0.5.
	}

	WAIT 0.01.
}
unlock STEERING.