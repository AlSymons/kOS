
lock tgtAngle to VANG(ship:facing:vector,TARGET:POSITION).
lock tgtAngleR to VANG(ship:facing:starvector,TARGET:POSITION).
lock tgtAngleL to VANG(-ship:facing:starvector,TARGET:POSITION). //might not need this - <90 to tgtAngleR is right, >90 is left?
lock tgtAngleU to VANG(ship:facing:topvector,TARGET:POSITION).
lock tgtAngleD to VANG(-ship:facing:topvector,TARGET:POSITION).


UNTIL SHIP:CONTROL:PILOTTOP <> 0
{
	if tgtAngleR < tgtAngleL //Target is to the right
	{
	//	set SHIP:CONTROL:YAW to something.
		//PRINT "Target is to the right of ship:facing".
	}
	else //Target is to the left
	{
		//SET SHIP:CONTROL:YAW to -something.
	//	PRINT "Target is to the left of ship:facing".
	}
	if tgtAngleR < 90 //Target is to the right. might have to mod 360? probably not
	{
		//set SHIP:CONTROL:YAW to something.
		PRINT "Target is "+abs(tgtAngleR-90)+" degrees right.".
	}
	else //Target is to the left
	{
		//SET SHIP:CONTROL:YAW to -something.
		PRINT "Target is "+(tgtAngleR-90)+" degrees left.".
	}		
	if tgtAngleU < 90 //Target is up
	{
		//set SHIP:CONTROL:PITCH to something.
		PRINT "Target is "+abs(tgtAngleU-90)+" degrees above".
	}
	else //target is down
		//SET SHIP:CONTROL:PITCH to -something.
		PRINT "Target is "+(tgtAngleU-90)+" degrees below".
		
	wait 0.1.
	clearscreen.
}
	
//roll tho...
//vang won't help there...
