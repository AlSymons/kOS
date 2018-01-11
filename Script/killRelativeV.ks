lock tgtRetrograde to target:velocity:orbit - ship:velocity:orbit.
//lock tgtPrograde to -(target:velocity:orbit - ship:velocity:orbit).
lock tgtVel to (target:velocity:orbit - ship:velocity:orbit):mag.

lock steering to tgtRetrograde.

wait until target:position:mag < 5000. //TODO: calculate this as half burn time.
lock throttle to 1 - (1/tgtVel).
wait until tgtVel < 1.

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock all.