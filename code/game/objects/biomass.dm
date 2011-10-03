/obj/effects/biomass
	icon = 'biomass.dmi'
	icon_state = "stage1"
	opacity = 0
	density = 0
	anchored = 1
	layer = 20 //DEBUG
	var/health = 10
	var/stage = 1
	var/obj/effects/rift/originalRift = null //the originating rift of that biomass
	var/maxDistance = 15 //the maximum length of a thread
	var/newSpreadDistance = 10 //the length of a thread at which new ones are created
	var/curDistance = 1 //the current length of a thread
	var/continueChance = 3 //weighed chance of continuing in the same direction. turning left or right has 1 weight both
	var/spreadDelay = 1 //will change to something bigger later, but right now I want it to spread as fast as possible for testing

/obj/effects/rift
	icon = 'biomass.dmi'
	icon_state = "rift"
	var/list/obj/effects/biomass/linkedBiomass = list() //all the biomass patches that have spread from it
	var/newicon = 1 //DEBUG

/obj/effects/rift/New()
	set background = 1

	..()

	for(var/turf/T in orange(1,src))
		if(!IsValidBiomassLoc(T))
			continue
		var/obj/effects/biomass/starting = new /obj/effects/biomass(T)
		starting.dir = get_dir(src,starting)
		starting.originalRift = src
		linkedBiomass += starting
		spawn(1) //DEBUG
			starting.icon_state = "[newicon]"

/obj/effects/rift/Del()
	for(var/obj/effects/biomass/biomass in linkedBiomass)
		del(biomass)
	..()

/obj/effects/biomass/New()
	set background = 1

	..()
	if(!IsValidBiomassLoc(loc,src))
		del(src)
		return
	spawn(1) //so that the dir and stuff can be set by the source first
		if(curDistance >= maxDistance)
			return
		switch(dir)
			if(NORTHWEST)
				dir = NORTH
			if(NORTHEAST)
				dir = EAST
			if(SOUTHWEST)
				dir = WEST
			if(SOUTHEAST)
				dir = SOUTH
		sleep(spreadDelay)
		Spread()

/obj/effects/biomass/proc/Spread(var/direction = dir)
	set background = 1
	var/possibleDirsInt = 0

	for(var/newDirection in cardinal)
		if(newDirection == turn(direction,180)) //can't go backwards
			continue
		var/turf/T = get_step(loc,newDirection)
		if(!IsValidBiomassLoc(T,src))
			continue
		possibleDirsInt |= newDirection

	var/list/possibleDirs = list()

	if(possibleDirsInt & direction)
		for(var/i=0 , i<continueChance , i++)
			possibleDirs += direction
	if(possibleDirsInt & turn(direction,90))
		possibleDirs += turn(direction,90)
	if(possibleDirsInt & turn(direction,-90))
		possibleDirs += turn(direction,-90)

	if(!possibleDirs.len)
		return

	direction = pick(possibleDirs)

	var/obj/effects/biomass/newBiomass = new /obj/effects/biomass(get_step(src,direction))
	newBiomass.curDistance = curDistance + 1
	newBiomass.maxDistance = maxDistance
	newBiomass.dir = direction
	newBiomass.originalRift = originalRift
	newBiomass.icon_state = "[originalRift.newicon]" //DEBUG
	originalRift.linkedBiomass += newBiomass

	if(!(curDistance%newSpreadDistance))
		var/obj/effects/rift/newrift = new /obj/effects/rift(loc)
		if(originalRift.newicon <= 3)
			newrift.newicon = originalRift.newicon + 1
//		NewSpread()

/obj/effects/biomass/proc/NewSpread(maxDistance = 15)
	set background = 1
	for(var/turf/T in orange(1,src))
		if(!IsValidBiomassLoc(T,src))
			continue
		var/obj/effects/biomass/starting = new /obj/effects/biomass(T)
		starting.dir = get_dir(src,starting)
		starting.maxDistance = maxDistance

/proc/IsValidBiomassLoc(turf/location,obj/effects/biomass/source = null)
	set background = 1
	for(var/obj/effects/biomass/biomass in location)
		if(biomass != source)
			return 0
	if(istype(location,/turf/space))
		return 0
	if(location.density)
		return 0
	return 1