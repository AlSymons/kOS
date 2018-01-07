DECLARE PARAMETER aVector is SHIP:FACING:VECTOR.

CLEARVECDRAWS().

local scale is 1.0.
if round(aVector:mag) = 1
	set scale to 3.

SET thevec TO VECDRAW(
	V(0,0,0),
	aVector,
	RGB(1,1,1),
	"a vector",
	scale,
	TRUE,
	0.1
	).
