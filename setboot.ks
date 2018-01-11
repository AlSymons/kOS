DECLARE PARAMETER newBoot IS "None".
SET count to 0.

SET IteratorList TO SHIP:PARTS.
SET MyIterator TO IteratorList:ITERATOR.

PRINT " ".
PRINT "==| Setting ship boot file |==".
PRINT " ".

UNTIL MyIterator:NEXT = false
{
	if MyIterator:VALUE:HASMODULE("kosProcessor")
	{
		SET count to count + 1.
		print MyIterator:VALUE + " found.".
		print "BootFileName: " + MyIterator:VALUE:GETMODULE("kosProcessor"):BootFileName.
		
		if count = 1
			SET MyIterator:VALUE:GETMODULE("kosProcessor"):BootFileName to newBoot.
		else
			SET MyIterator:VALUE:GETMODULE("kosProcessor"):BootFileName to "None".

		print "->" + MyIterator:VALUE:GETMODULE("kosProcessor"):BootFileName.
		print " ".
	}
}