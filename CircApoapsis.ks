
SET orbitalSpeed TO (SHIP:BODY:MU / (SHIP:BODY:RADIUS + SHIP:APOAPSIS))^0.5.
PRINT "==| Circularise Apoapsis |==".
PRINT "Orbital speed at apoapsis calculated at " + orbitalSpeed.
SET circulariseDV to (orbitalSpeed - VELOCITYAT(SHIP, ETA:APOAPSIS + TIME:SECONDS):ORBIT:MAG).
PRINT "Circularise DV calculated at " + circulariseDV.

ADD NODE (TIME:SECONDS + ETA:APOAPSIS, 0, 0, circulariseDV).