DECLARE PARAMETER outputFile is "0:/partsLog.txt".
DELETEPATH(outputFile).

LOCAL partsIt is SHIP:PARTS:ITERATOR.

UNTIL partsIt:NEXT = false
{
	LOG " " to outputFile.
	LOG partsIt:VALUE to outputFile.
	
	LOCAL modIt is partsIt:VALUE:MODULES:ITERATOR.
	UNTIL modIt:NEXT = false
	{
		LOG "    " + modIt:VALUE to outputFile.
		
		LOCAL fieldIt is partsIt:VALUE:GETMODULEBYINDEX(modIt:INDEX):ALLFIELDS:ITERATOR.
		UNTIL fieldIt:NEXT = false
			LOG "        " + fieldIt:VALUE to outputFile.

		LOCAL eventIt is partsIt:VALUE:GETMODULEBYINDEX(modIt:INDEX):ALLEVENTS:ITERATOR.
		UNTIL eventIt:NEXT = false
			LOG "        " + eventIt:VALUE to outputFile.

		LOCAL actionIt is partsIt:VALUE:GETMODULEBYINDEX(modIt:INDEX):ALLACTIONS:ITERATOR.
		UNTIL actionIt:NEXT = false
			LOG "        " + actionIt:VALUE to outputFile.
	}
}