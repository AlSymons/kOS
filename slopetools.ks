print "SHIP:GEOPOSITION: ".
print SHIP:GEOPOSITION.
print " ".
print "BODY:GEOPOSITIONOF(SHIP:POSITION):".
print BODY:GEOPOSITIONOF(SHIP:POSITION).
print " ".

lock shipBearingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED.

function terrainHeightAt //relative to ship
{
	parameter inPos is V(0,0,0).	

	SET debugVec TO VECDRAW(
		  inPos, //start
		  SHIP:UP:VECTOR, //vector
		  RGB(0,0.5,0), //colour
		  "SAMPLING TERRAIN HEIGHT HERE", //words
		  3.0, //scale
		  TRUE, //show
		  0.1 //width 
		).
	
	wait 0.1.
	CLEARVECDRAWS().

	return BODY:GEOPOSITIONOF(SHIP:POSITION + inPos):TERRAINHEIGHT.
}

function slopeAt
{
	parameter pos is SHIP:POSITION, sampleWidth is 10.
	local originHeight is terrainHeightAt(pos).//BODY:GEOPOSITIONOF(pos):TERRAINHEIGHT.	
	local maxDelta is 0.
	local rot is 0.
	local bearingVec is V(0,0,0).
	
	//check the terrain height in different directions
	until rot > 359
	{
		set bearingVec to shipBearingVec * sampleWidth.
		set maxDelta to max(maxDelta,abs(originHeight - terrainHeightAt(pos + (bearingVec * R(rot,0,0))))).
		set rot to rot + 45.
	}
	
	return maxDelta.
}

abort off.
until abort
{
	clearscreen.	
	print "Altitude of terrain here: " + SHIP:GEOPOSITION:TERRAINHEIGHT.
	print "Altitude of terrain 10m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (shipBearingVec * 10)):TERRAINHEIGHT.
	print "Altitude of terrain 50m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (shipBearingVec * 50)):TERRAINHEIGHT.
	print "Altitude of terrain 100m ahead:" + BODY:GEOPOSITIONOF(SHIP:POSITION + (shipBearingVec * 100)):TERRAINHEIGHT.
	print " ".
	print "Terrain height position from function: " + terrainHeightAt.
	print " ".
	print "Slope value here: " + slopeAt.
	print "Slope 10m ahead: " + slopeAt(SHIP:POSITION + shipBearingVec * 10).
	print "Slope 50m ahead: " + slopeAt(SHIP:POSITION + shipBearingVec * 50).
	print "Slope 100m ahead: " + slopeAt(SHIP:POSITION + shipBearingVec * 100).

	wait 1.
}