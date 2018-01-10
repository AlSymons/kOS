//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp").
//"975.00 K / 1000.00 K"

//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp"):find("K").
//8

//print convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp"):remove(6,14).
//"975.00"

DECLARE PARAMETER lf is true, ox is true, mono is true, desiredOre is 10.

LOCAL maxLF is 0.
LOCAL res is SHIP:RESOURCES.
LOCAL resIt is SHIP:RESOURCES:ITERATOR.
UNTIL resIT:NEXT = false
	if resIT:VALUE:NAME = "LiquidFuel"
		SET maxLF TO maxLF + resIT:VALUE:CAPACITY.

LOCAL maxOX is 0.
LOCAL res is SHIP:RESOURCES.
LOCAL resIt is SHIP:RESOURCES:ITERATOR.
UNTIL resIT:NEXT = false
	if resIT:VALUE:NAME = "Oxidizer"
		SET maxOX TO maxOX + resIT:VALUE:CAPACITY.

LOCAL maxMono is 0.
LOCAL res is SHIP:RESOURCES.
LOCAL resIt is SHIP:RESOURCES:ITERATOR.
UNTIL resIT:NEXT = false
	if resIT:VALUE:NAME = "Monopropellant"
		SET maxMono TO maxMono + resIT:VALUE:CAPACITY.

SET maxEffTemp to 1010. //TODO: determine this programatically
SET tgtTemp to maxEffTemp.
SET convertotron TO SHIP:PARTSTITLEDPATTERN("Convert-O-Tron").

FUNCTION coreTemp
{
	SET coreTempStr TO convertotron[0]:GETMODULE("ModuleOverHeatDisplay"):GETFIELD("core temp").
	SET coreTempStr TO coreTempStr:remove(coreTempStr:find("K"),13).
	return coreTempStr:TONUMBER(9001).
}

FUNCTION isruOn
{
	LOCAL moduleIt is convertotron[0]:modules:ITERATOR.
	UNTIL moduleIt:NEXT = false
	{
		if moduleIt:VALUE = "ModuleResourceConverter"
		{
			LOCAL resMod is convertotron[0]:GETMODULEBYINDEX(moduleIt:INDEX).
			
			if lf and SHIP:LIQUIDFUEL < maxLF
				if resMod:HASEVENT("start isru [lqdfuel]")
					resMod:DOEVENT("start isru [lqdfuel]").
			
			if ox and SHIP:OXIDIZER < maxOX
				if resMod:HASEVENT("start isru [ox]")
					resMod:DOEVENT("start isru [ox]").
			
			if mono and SHIP:MONOPROPELLANT < maxMono
				if resMod:HASEVENT("start isru [monoprop]")
					resMod:DOEVENT("start isru [monoprop]").
		}
	}
}
FUNCTION isruOff
{
	LOCAL moduleIt is convertotron[0]:modules:ITERATOR.
	UNTIL moduleIt:NEXT = false
	{
		if moduleIt:VALUE = "ModuleResourceConverter"
		{
			LOCAL resMod is convertotron[0]:GETMODULEBYINDEX(moduleIt:INDEX).
			
			if resMod:HASEVENT("stop isru [lqdfuel]")
				resMod:DOEVENT("stop isru [lqdfuel]").
			if resMod:HASEVENT("stop isru [ox]")
				resMod:DOEVENT("stop isru [ox]").
			if resMod:HASEVENT("stop isru [monoprop]")
				resMod:DOEVENT("stop isru [monoprop]").
		}
	}
}

//main loop
UNTIL SHIP:CONTROL:PILOTPITCH <> 0
{
	clearscreen.
	
	if SHIP:ORE > desiredOre
		drills off.
	else
		drills on.

	PRINT "Convert-O-Tron Core temperature: "+coreTemp+".".
	
	IF coreTemp > maxEffTemp
		SET tgtTemp TO tgtTemp - 0.01.

	if coreTemp > tgtTemp
	{
		isruOff.
		PRINT "Core temp > "+tgtTemp+". ISRU idle.".
		WAIT 0.01.
	}
	else
	{
		isruOn.
		PRINT "Running efficiently. ISRU active.".
		WAIT 0.01.
	}
}