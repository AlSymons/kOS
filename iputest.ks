//it would appear changing ipu in script doesn't cause any issues.
SET X TO 50.

UNTIL X > 2000
{
	SET CONFIG:IPU TO X.
	PRINT "Hello. IPU is " + X + ".".
	SET X TO X + 1.
}