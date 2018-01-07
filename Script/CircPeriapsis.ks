
SET orbitalSpeed TO (SHIP:BODY:MU / (SHIP:BODY:RADIUS + SHIP:PERIAPSIS))^0.5.
PRINT "==| Circularise Periapsis |==".
PRINT "Orbital speed at periapsis calculated at " + orbitalSpeed.
SET circulariseDV to (orbitalSpeed - VELOCITYAT(SHIP, ETA:PERIAPSIS + TIME:SECONDS):ORBIT:MAG).
PRINT "Circularise DV calculated at " + circulariseDV.

ADD NODE (TIME:SECONDS + ETA:PERIAPSIS, 0, 0, circulariseDV).