print "SHIP:GEOPOSITION: ".
print SHIP:GEOPOSITION.
print " ".
print "BODY:GEOPOSITIONOF(SHIP:POSITION):".
print BODY:GEOPOSITIONOF(SHIP:POSITION).
print " ".

function terrainHeightAt //relative to ship
{
	parameter inPos is V(0,0,0).	
	return BODY:GEOPOSITIONOF(SHIP:POSITION + inPos):TERRAINHEIGHT.
}


function slopeAt
{
	parameter pos is SHIP:POSITION, sampleWidth is 1.
	local originHeight is pos:TERRAINHEIGHT.	
	local maxDelta is 0.
	local rot is 0.
		
	until rot > 359
	{
		set maxDelta to abs(terrainHeightAt(pos) - terrainHeightAt(SHIP:FACING:VECTOR * R(0,rot,0):VECTOR)
		
	}
	//LOCAL foreHeight is terrainHeightAt(SHIP:FACING:VECTOR * sampleWidth).
	//LOCAL aftHeight is terrainHeightAt(SHIP:FACING:VECTOR * -sampleWidth).
	//LOCAL starbHeight is terrainHeightAt(SHIP:STAR:STARVECTOR * sampleWidth).
	//LOCAL portHeight is terrainHeightAt(SHIP:STAR:STARVECTOR * -sampleWidth).
	
	
	
}
abort off.
until abort
{
	print "Altitude of terrain here: " + SHIP:GEOPOSITION:TERRAINHEIGHT.
	print "Altitude of terrain 10m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (SHIP:FACING:VECTOR * 10)):TERRAINHEIGHT.
	print " ".
	print "Terrain height position from function: " + terrainHeightAt.
	
	wait 0.1.
	
	clearscreen.	
}