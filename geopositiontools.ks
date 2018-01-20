PRINT "SHIP:GEOPOSITION: ".
PRINT SHIP:GEOPOSITION.
PRINT " ".
PRINT "BODY:GEOPOSITIONOF(SHIP:POSITION):".
PRINT BODY:GEOPOSITIONOF(SHIP:POSITION).
PRINT " ".

function terrainHeightPosition //relative to ship
{
	PARAMETER inPos is V(0,0,0).	
	return BODY:GEOPOSITIONOF(SHIP:POSITION + inPos):TERRAINHEIGHT.
}


function slopeAt
{
	PARAMETER geoPos is SHIP:GEOPOSITION, sampleWidth is 1.
	LOCAL originHeight is geoPos:TERRAINHEIGHT.	
	LOCAL foreHeight is terrainHeightPosition(SHIP:FACING:VECTOR * sampleWidth).
	LOCAL aftHeight is terrainHeightPosition(SHIP:FACING:VECTOR * -sampleWidth).
	LOCAL starbHeight is terrainHeightPosition(SHIP:STAR:STARVECTOR * sampleWidth).
	LOCAL portHeight is terrainHeightPosition(SHIP:STAR:STARVECTOR * -sampleWidth).
	
	
	
}
abort off.
until abort
{
	PRINT "Altitude of terrain here: " + SHIP:GEOPOSITION:TERRAINHEIGHT.
	PRINT "Altitude of terrain 10m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (SHIP:FACING:VECTOR * 10)):TERRAINHEIGHT.
	PRINT " ".
	PRINT "Terrain height position from function: " + terrainHeightPosition.
	
	wait 0.1.
	
	clearscreen.	
}