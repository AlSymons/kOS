//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp").
//"975.00 K / 1000.00 K"

//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp"):find("K").
//8

//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp"):remove(6,14).
//"975.00"

SET tgtTemp to 1000.

UNTIL SHIP:CONTROL:PILOTPITCH <> 0
{
	clearscreen.

	SET convertotron TO SHIP:PARTSDUBBEDPATTERN("Convert-O-Tron").
	SET coreTempStr TO convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp").

	SET coreTempStr TO coreTempStr:remove(coreTempStr:find("K"),13).
	SET coreTemp TO coreTempStr:TONUMBER(9001).
	PRINT "Convert-O-Tron Core temperature: "+coreTemp+".".
	
	IF coreTemp > 1000
		SET tgtTemp TO tgtTemp - 0.01.

	if coreTemp > tgtTemp
	{
		IF convertotron[0]:GETMODULE("ModuleResourceConverter"):HASEVENT("stop isru [lf+ox]")
			convertotron[0]:GETMODULE("ModuleResourceConverter"):DOEVENT("stop isru [lf+ox]").
		PRINT "Core temp > "+tgtTemp+". ISRU idle.".
		WAIT 0.01.
	}
	else
	{
		IF convertotron[0]:GETMODULE("ModuleResourceConverter"):HASEVENT("start isru [lf+ox]")
			convertotron[0]:GETMODULE("ModuleResourceConverter"):DOEVENT("start isru [lf+ox]").
		PRINT "Running efficiently. ISRU active.".
		WAIT 0.01.
	}
}