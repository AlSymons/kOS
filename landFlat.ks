lock shipBearingVec to VECTOREXCLUDE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR):NORMALIZED.

runpath("0:/slopetools.ks").
runpath("0:/pidHover.ks").

local landingSightPos is V(0,0,0).

function areaSlopeSearch
{
	parameter tgtSlope is 0.02, pos is SHIP:POSITION, samplewidth is 1, maxSamples is 1000.
	
	local minSlope is 90.
	local rot is 0.
	local bearingDir is LOOKDIRUP(shipBearingVec,SHIP:UP:VECTOR).
	
	local numSamples is 0.
	local samplesPerRot is 8.
	local sampleRadius is sampleWidth * 4.

	until minSlope < tgtSlope OR numSamples > maxSamples
	{
		until rot > 359
		{//check the slope at different points
			set minSlope to min(minSlope, slopeAt(pos + (bearingDir * R(0,rot,0)):VECTOR * sampleRadius)).
			set rot to rot + (360 / samplesPerRot).
			set numSamples to numSamples + 1.
		}

		clearscreen.
		print minSlope.
		if minSlope < tgtSlope
		{
			set landingSightPos to pos + (bearingDir * R(0,rot,0)):VECTOR * sampleRadius.
			if 1
			{
				SET landingSiteMarker TO VECDRAW(
				  landingSightPos, //start
				  SHIP:UP:VECTOR, //vector
				  RGB(0,0,1), //colour
				  "Landing Site", //words
				  3.0, //scale
				  TRUE, //show
				  0.1 //width 
				).
			}
		}


		set sampleRadius to sampleRadius + sampleWidth * 4.
		//set samplesPerRot to (sampleRadius / sampleWidth * ?.
		set rot to 0.
	}
	return minSlope.
}

if areaSlopeSearch(0.02) < 0.02
{
	lock throttle to hoverPID(100).
	abort off.
	wait until abort.


}
else
	print "can't find a flat enough landing site.".