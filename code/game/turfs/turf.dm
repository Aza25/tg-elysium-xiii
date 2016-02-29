/turf
	icon = 'icons/turf/floors.dmi'
	level = 1

	var/slowdown = 0 //negative for faster, positive for slower
	var/intact = 1
	var/baseturf = /turf/space

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0


	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	var/blocks_air = 0

	var/PathNode/PNode = null //associated PathNode in the A* algorithm

	flags = 0

	var/list/proximity_checkers = list()

	var/wet = 0
	var/image/wet_overlay = null
	var/image/obscured	//camerachunks

	var/thermite = 0

/turf/New()
	..()
	for(var/atom/movable/AM in src)
		Entered(AM)

/turf/Destroy()
	// Adds the adjacent turfs to the current atmos processing
	for(var/turf/simulated/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	..()
	return QDEL_HINT_HARDDEL_NOW

/turf/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/attackby(obj/item/C, mob/user, params)
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if((LC.d1==0)||(LC.d2==0))
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return 1

	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, 1)
				return 0

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!

/turf/Entered(atom/movable/M)
	for(var/A in proximity_checkers)
		var/atom/B = A
		B.HasProximity(M)
	//slipping
	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		switch(wet)
			if(TURF_WET_WATER)
				if(!M.slip(3, 1, null, NO_SLIP_WHEN_WALKING))
					M.inertia_dir = 0
			if(TURF_WET_LUBE)
				M.slip(0, 7, null, (SLIDE|GALOSHES_DONT_HELP))
			if(TURF_WET_ICE)
				M.slip(0, 4, null, (SLIDE|NO_SLIP_WHEN_WALKING))

/turf/proc/is_plasteel_floor()
	return 0

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(path)
	if(!path)
		return
	if(path == type)
		return src

	SSair.remove_from_active(src)

	var/s_appearance = appearance
	var/nocopy = density || smooth //dont copy walls or smooth turfs

	var/turf/W = new path(src)
	if(istype(W, /turf/simulated))
		W:Assimilate_Air()
		W.RemoveLattice()
	W.levelupdate()
	W.CalculateAdjacentTurfs()

	if(W.smooth & SMOOTH_DIAGONAL)
		if(!W.apply_fixed_underlay())
			W.underlays += !nocopy ? s_appearance : DEFAULT_UNDERLAY_IMAGE

	if(!can_have_cabling())
		for(var/obj/structure/cable/C in contents)
			C.Deconstruct()

	smooth_icon_neighbors(src)
	return W

//////Assimilate Air//////
/turf/proc/Assimilate_Air()
	if(air)
		var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs
		var/list/total_gases = total.gases
		var/turf_count = 0

		for(var/direction in cardinal)//Only use cardinals to cut down on lag
			var/turf/T = get_step(src,direction)

			if(istype(T,/turf/space))//Counted as no air
				turf_count++//Considered a valid turf for air calcs
				continue

			if(istype(T,/turf/simulated/floor))
				var/turf/simulated/S = T
				if(S.air)//Add the air's contents to the holders
					var/list/S_gases = S.air.gases
					for(var/id in S_gases)
						total.assert_gas(id)
						total_gases[id][MOLES] += S_gases[id][MOLES]
					total.temperature += S.air.temperature
				turf_count++

		air.copy_from(total)
		if(turf_count) //if there weren't any open turfs, no need to update.
			var/list/air_gases = air.gases
			for(var/id in air_gases)
				air_gases[id][MOLES] /= turf_count //Averages contents of the turfs, ignoring walls and the like

			air.temperature /= turf_count

		SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(src.baseturf)
	new /obj/structure/lattice(locate(src.x, src.y, src.z) )

/turf/proc/ReplaceWithCatwalk()
	src.ChangeTurf(src.baseturf)
	new /obj/structure/lattice/catwalk(locate(src.x, src.y, src.z) )

/turf/proc/phase_damage_creatures(damage,mob/U = null)//>Ninja Code. Hurts and knocks out creatures on this turf //NINJACODE
	for(var/mob/living/M in src)
		if(M==U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		M.adjustBruteLoss(damage)
		M.Paralyse(damage/5)
	for(var/obj/mecha/M in src)
		M.take_damage(damage*2, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	if(src_object.contents.len)
		usr << "<span class='notice'>You start dumping out the contents...</span>"
		if(!do_after(usr,20,target=src_object))
			return 0
	for(var/obj/item/I in src_object)
		if(user.s_active != src_object)
			if(I.on_found(user))
				return
		src_object.remove_from_storage(I, src) //No check needed, put everything inside
	return 1

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T) return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////

/turf/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)

/turf/handle_slip(mob/living/carbon/C, s_amount, w_amount, obj/O, lube)
	if(has_gravity(src))
		var/obj/buckled_obj
		var/oldlying = C.lying
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(C.lying || !(C.status_flags & CANWEAKEN)) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(C.m_intent=="walk" && (lube&NO_SLIP_WHEN_WALKING))
				return 0

		C << "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>"

		C.attack_log += "\[[time_stamp()]\] <font color='orange'>Slipped[O ? " on the [O.name]" : ""][(lube&SLIDE)? " (LUBE)" : ""]!</font>"
		playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

		C.accident(C.l_hand)
		C.accident(C.r_hand)

		var/olddir = C.dir
		C.Stun(s_amount)
		C.Weaken(w_amount)
		C.stop_pulling()
		if(buckled_obj)
			buckled_obj.unbuckle_mob()
			step(buckled_obj, olddir)
		else if(lube&SLIDE)
			for(var/i=1, i<5, i++)
				spawn (i)
					step(C, olddir)
					C.spin(1,1)
		if(C.lying != oldlying && lube) //did we actually fall?
			var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
			C.apply_damage(5, BRUTE, dam_zone)
		return 1

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == 101)
				O.singularity_act()
	ChangeTurf(src.baseturf)
	return(2)

/turf/proc/can_have_cabling()
	return 1

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	if(ticker)
		cameranet.updateVisibility(src)

/turf/proc/apply_fixed_underlay()
	if(!fixed_underlay)
		return
	var/obj/O = new
	O.layer = layer
	if(fixed_underlay["icon"])
		O.icon = fixed_underlay["icon"]
		O.icon_state = fixed_underlay["icon_state"]
	else if(fixed_underlay["space"])
		O.icon = 'icons/turf/space.dmi'
		O.icon_state = SPACE_ICON_STATE
	else
		O.icon = DEFAULT_UNDERLAY_ICON
		O.icon_state = DEFAULT_UNDERLAY_ICON_STATE
	underlays += O
	return 1

/turf/proc/burn_tile()

/turf/proc/MakeSlippery(wet_setting = TURF_WET_WATER) // 1 = Water, 2 = Lube, 3 = Ice
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting != TURF_DRY)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		var/turf/simulated/floor/F = src
		if(istype(F))
			wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		else
			wet_overlay = image('icons/effects/water.dmi', src, "wet_static")
		overlays += wet_overlay

	spawn(rand(790, 820)) // Purely so for visual effect
		if(!istype(src, /turf/simulated)) //Because turfs don't get deleted, they change, adapt, transform, evolve and deform. they are one and they are all.
			return
		MakeDry(wet_setting)

/turf/proc/MakeDry(wet_setting = TURF_WET_WATER)
	if(wet > wet_setting)
		return
	wet = TURF_DRY
	if(wet_overlay)
		overlays -= wet_overlay

/turf/proc/is_shielded()

/turf/contents_explosion(severity, target)
	var/affecting_level
	if(severity == 1)
		affecting_level = 1
	else if(is_shielded())
		affecting_level = 3
	else if(intact)
		affecting_level = 2
	else
		affecting_level = 1

	for(var/V in contents)
		var/atom/A = V
		if(A.level >= affecting_level)
			A.ex_act(severity, target)


/turf/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	density = 1
	blocks_air = 1
	opacity = 1
	explosion_block = 50
	layer = TURF_LAYER + 0.05

/turf/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen.dmi'
	icon_state = "title"
	layer = FLY_LAYER
	var/titlescreen = TITLESCREEN

/turf/indestructible/splashscreen/New()
	..()
	if(titlescreen)
		icon_state = titlescreen

/turf/indestructible/riveted
	icon_state = "riveted"

/turf/indestructible/riveted/New()
	..()
	if(smooth)
		smooth_icon(src)
		icon_state = ""

/turf/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	smooth = SMOOTH_TRUE

/turf/indestructible/abductor
	icon_state = "alien1"

/turf/indestructible/opshuttle
	icon_state = "wall3"

/turf/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/indestructible/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "fake_door"

/turf/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"

/turf/indestructible/rock/snow
	name = "mountainside"
	desc = "An extremely densely-packed rock, sheeted over with centuries worth of ice and snow."
	icon = 'icons/turf/walls.dmi'
	icon_state = "snowrock"

/turf/indestructible/rock/snow/ice
	name = "iced rock"
	desc = "Extremely densely-packed sheets of ice and rock, forged over the years of the harsh cold."
	icon = 'icons/turf/walls.dmi'
	icon_state = "icerock"
