//Balanced LFO fuel transfer program. amount parameter is liquidfuel to transfer.
//must tag fuelOut and fuelIn parts before running.

@lazyglobal off.

DECLARE PARAMETER amount is 10, oxi is true.

LOCAL sourceParts is SHIP:PARTSDUBBED("fuelOut").
LOCAL destinationParts is SHIP:PARTSDUBBED("fuelIn").
LOCAL lf is TRANSFER("liquidfuel", sourceParts, destinationParts, amount).
LOCAL ox is TRANSFER("oxidizer", sourceParts, destinationParts, amount*11/9).
if (oxi)
{
	SET ox:ACTIVE to TRUE.
}
SET lf:ACTIVE to TRUE.

WAIT UNTIL lf:STATUS = "Finished".

IF (oxi)
	WAIT UNTIL ox:STATUS = "Finished".