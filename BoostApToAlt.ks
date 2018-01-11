DECLARE PARAMETER inputparam IS 2868000.

PRINT "Precise Apoapsis Boost program running.".
PRINT "Target Apoapsis: " + (inputparam * 1). //crash here if input argument isn't a number

PRINT "Steering Locked. Waiting for near apo/periapsis.".
LOCK STEERING TO PROGRADE.

WAIT UNTIL ABS(SHIP:VERTICALSPEED) < 100. //Absolute value means this will work approaching apoapsis or periapsis.
LOCK THROTTLE TO 1.
PRINT "Absolute vertical speed <100m/s. Throttling up.".

WAIT UNTIL SHIP:APOAPSIS > (inputparam * 0.98).
LOCK THROTTLE TO 0.01.
PRINT "Apoapsis at 98% of target. Throttle lowered to 1%.".

WAIT UNTIL SHIP:APOAPSIS >= inputparam.
LOCK THROTTLE TO 0.
PRINT "Target apoapsis achieved.".

RUNPATH("CirculariseNodeAtApoapsis.ks").

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0. //Pilot throttle - throttle after program ends - only pilot control that is settable.