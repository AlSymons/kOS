//doesn't work. this seems impossible.

//This script is specifically for circularising orbit.
//The manuever node is only used for guidance on when to begin the burn.

print "==| Circularising at Apoapsis node |==".

set nd to nextnode.

set np to nd:deltav.
lock steering to np.

set burn_duration to nd:deltav:mag/(ship:maxthrust/ship:mass).

wait until nd:eta <= 10.
set warp to 0.
wait until nd:eta <= burn_duration / 1.5.

LOCK THROTTLE TO 1.
WAIT UNTIL ETA:APOAPSIS > ETA:PERIAPSIS. //passed apo
UNTIL (ETA:APOAPSIS < ETA:PERIAPSIS)
	LOCK THROTTLE TO (1 - (SHIP:PERIAPSIS / SHIP:APOAPSIS))*10.

unlock steering.
unlock throttle.
//remove nd.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.