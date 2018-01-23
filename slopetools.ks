local debug is false.
set config:ipu to 2000.

lock shipBearingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED.

function terrainHeightAt
{
	parameter inPos is SHIP:POSITION.	

	if debug
	{
		SET debugVec TO VECDRAW(
			  inPos, //start
			  SHIP:UP:VECTOR, //vector
			  RGB(0,0.5,0), //colour
			  "SAMPLING TERRAIN HEIGHT HERE", //words
			  3.0, //scale
			  TRUE, //show
			  0.1 //width 
			).
		wait 0.01.
		CLEARVECDRAWS().
	}
	return BODY:GEOPOSITIONOF(inPos):TERRAINHEIGHT.
}

function slopeAt
{
	parameter pos is SHIP:POSITION, sampleWidth is 5, numSamples is 8.
	local originHeight is terrainHeightAt(pos).
	local maxDelta is 0.
	local rot is 0.
	local bearingDir is LOOKDIRUP(shipBearingVec,SHIP:UP:VECTOR).
	
	//check the terrain height in different directions
	until rot > 359
	{
		if debug
		{
			SET debugVec2 TO VECDRAW(
			  pos, //start
			  (bearingDir * R(0,rot,0)):VECTOR, //vector
			  RGB(0.5,0,0), //colour
			  "bearingDir", //words
			  sampleWidth, //scale
			  TRUE, //show
			  0.1 //width 
			).
		}

		set maxDelta to max(maxDelta,abs(originHeight - terrainHeightAt(pos + (bearingDir * R(0,rot,0)):VECTOR * sampleWidth))).
		set rot to rot + (360 / numSamples).
	}
	
	return arcsin(min(1,(maxDelta / sampleWidth))).
}

//abort off.
until 1//abort
{
	clearscreen.	
	print "Altitude of terrain here: " + terrainHeightAt.
	print "Altitude of terrain 10m ahead:" + terrainHeightAt(SHIP:POSITION + (shipBearingVec * 10)).
	print "Altitude of terrain 50m ahead:" + terrainHeightAt(SHIP:POSITION + (shipBearingVec * 50)).
	print "Altitude of terrain 100m ahead:" + terrainHeightAt(SHIP:POSITION + (shipBearingVec * 100)).
	print " ".
	print "Slope value here: " + slopeAt.
	print "Slope 10m ahead: " + slopeAt(SHIP:POSITION + (shipBearingVec * 10)).
	print "Slope 50m ahead: " + slopeAt(SHIP:POSITION + (shipBearingVec * 50)).
	print "Slope 100m ahead: " + slopeAt(SHIP:POSITION + (shipBearingVec * 100)).

	wait 0.01.
}