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
	local originHeight is BODY:GEOPOSITIONOF(pos):TERRAINHEIGHT.	
	local maxDelta is 0.
	local rot is 0.
	local bearingVec is V(0,0,0).
	
	//check the terrain height in different directions
	until rot > 359
	{
		set bearingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED * sampleWidth.
		set maxDelta to max(maxDelta,abs(originHeight - terrainHeightAt(bearingVec * R(0,rot,0)))).
		set rot to rot + 45.
	}
	
	return maxDelta. //todo: convert this to a meaningful slope.
}

abort off.
until abort
{
	clearscreen.	
	print "Altitude of terrain here: " + SHIP:GEOPOSITION:TERRAINHEIGHT.
	print "Altitude of terrain 10m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (SHIP:FACING:VECTOR * 10)):TERRAINHEIGHT.
	print " ".
	print "Terrain height position from function: " + terrainHeightAt.
	print " ".
	print "Slope value here: " + slopeAt.
	print "Slope 10m ahead: " + slopeAt(SHIP:POSITION + VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED * 10).
	print "Slope 50m ahead: " + slopeAt(SHIP:POSITION + VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED * 50).
	print "Slope 100m ahead: " + slopeAt(SHIP:POSITION + VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED * 100).

	wait 1.
}