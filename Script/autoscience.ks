DECLARE PARAMETER rerunOnly is true, safeECPercent is 100, continuous is 5. //continuous: run once every x seconds.

LOCAL partsList is SHIP:PARTS.
LOCAL partsIt is partsList:ITERATOR.
LOCAL sciModList is LIST().

LOCAL maxEC is 0.
LOCAL res is SHIP:RESOURCES.
LOCAL resIt is SHIP:RESOURCES:ITERATOR.
UNTIL resIT:NEXT = false
	if resIT:VALUE:NAME = "ElectricCharge"
		SET maxEC TO maxEC + resIT:VALUE:CAPACITY.

LOCAL safeEC is maxEC * safeECPercent / 100.

UNTIL partsIt:NEXT = false
	if partsIt:VALUE:HASMODULE("ModuleScienceExperiment")
	{
		if partsIt:VALUE:GETMODULE("ModuleScienceExperiment"):RERUNNABLE
			sciModList:add(partsIt:VALUE:GETMODULE("ModuleScienceExperiment")).
		else if rerunOnly = false
			sciModList:add(partsIt:VALUE:GETMODULE("ModuleScienceExperiment")).
	}
			
PRINT " ".
PRINT "==| Automatic science transmission running |==".
if rerunOnly
	PRINT "Transmitting rerunnable experiments only.".
PRINT "Minimum safe EC: "+safeECPercent+"% ("+safeEC+").".
PRINT " ".


UNTIL false
{
	LOCAL totalSci is 0.
	LOCAL grandTotalSci is 0.
	LOCAL noDataPasses is 0.

	UNTIL noDataPasses > 1
	{
		SET totalSci to 0.
		LOCAL sciModListIt is sciModList:ITERATOR.
		UNTIL sciModListIt:NEXT = false
		{
			LOCAL exp is sciModListIt:VALUE.
			LOCAL done is false.
			UNTIL done
			{
				if exp:hasdata //sci module has data.
				{
					LOCAL dataList is exp:data.
					LOCAL dataListIt is dataList:ITERATOR.
					UNTIL dataListIt:NEXT = false
					{
						if dataListIt:VALUE:transmitvalue > 0 //it's worth something. send it.
						{
							LOCAL sciValue is dataListIt:VALUE:transmitvalue.
							SET totalSci TO totalSci + sciValue.
							PRINT dataListIt:VALUE:title.
							PRINT round(dataListIt:VALUE:transmitvalue,1) + " science.".
							if SHIP:ELECTRICCHARGE < safeEC
								PRINT "Waiting for "+safeEC+" electric charge.".
							WAIT UNTIL SHIP:ELECTRICCHARGE >= safeEC.
							if ADDONS:AVAILABLE("RT")
								if ADDONS:RT:HASKSCCONNECTION(SHIP) = false
								{
									PRINT "CONNECTION ERROR. AWAITING RECONNECTION WITH KSC...".
									WAIT UNTIL ADDONS:RT:HASKSCCONNECTION(SHIP).
								}
							PRINT "Transmitting...".
							sciModListIt:VALUE:TRANSMIT().
							WAIT UNTIL dataListIt:VALUE:transmitvalue < sciValue.
							PRINT "Done.".
							
						}
						else //got data but it's worth nothing.
						{
							if exp:RERUNNABLE
							{	
								exp:RESET().
								WAIT UNTIL exp:hasdata = false.
								//PRINT "RESETTING " + dataListIt:VALUE:title.
							}
							SET done to true.
						}
					}
				}
				else
				{
					if exp:inoperable
						SET done to true.
					else
					{
						if exp:hasAction("Log Seismic Data")
						{
							if ship:status = "LANDED"
							{
								exp:DEPLOY().
								WAIT UNTIL exp:HASDATA.
							}
							else SET done to true.
						}
						if exp:hasAction("Log Gravity Data")
						{
							if ship:status <> "FLYING"
							{
								exp:DEPLOY().
								WAIT UNTIL exp:HASDATA.
							}
							else SET done to true.
						}
						if not exp:hasAction("Log Seismic Data") and not exp:hasAction("Log Gravity Data")
						{
							exp:DEPLOY().
							WAIT UNTIL exp:HASDATA.
						}
					}
				}
			}
		}
		SET grandTotalSci TO grandTotalSci + totalSci.
		if totalSci = 0
			SET noDataPasses TO noDataPasses + 1.
	//	else PRINT "Total science transmitted this pass: "+round(totalSci,1)+".".
	}
	
	if continuous = false
	{
		PRINT round(grandTotalSci,1) + " science transmitted.".
		break.
	}
	else wait continuous.
}
