//Jettison Fairings
SET IteratorList TO SHIP:PARTS. SET fairingIterator TO IteratorList:ITERATOR.
UNTIL fairingIterator:NEXT = false
	if fairingIterator:VALUE:HASMODULE("ProceduralFairingDecoupler")
		fairingIterator:VALUE:GETMODULE("ProceduralFairingDecoupler"):DOEVENT("Jettison").