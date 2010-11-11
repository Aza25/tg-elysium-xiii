/*CONTENTS
Buildable pipes
Buildable meters
*/

/obj/item/weapon/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipe_dir = 0
	icon = 'pipe-item.dmi'
	icon_state = "straight"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4
	level = 2

/obj/item/weapon/pipe/New()
	..()
	update()

//update the name and icon of the pipe item depending on the type

/obj/item/weapon/pipe/proc/update()
	var/list/nlist = list("pipe", "bent pipe", "h/e pipe", "bent h/e pipe", "connector", "manifold", "junction", "uvent", "mvalve", "pump", "scrubber")
	name = nlist[pipe_type+1] + " fitting"
	updateicon()

//update the icon of the item

/obj/item/weapon/pipe/proc/updateicon()

	var/list/islist = list("straight", "bend", "he-straight", "he-bend", "connector", "manifold", "junction", "uvent", "mvalve", "pump", "scrubber")

	icon_state = islist[pipe_type + 1]

	if(invisibility)				// true if placed under floor
		icon -= rgb(0,0,0,128)		// fade the icon
	else
		icon = initial(icon)		// otherwise reset to inital icon

// called to hide or unhide a pipe
// i=true if hiding

/obj/item/weapon/pipe/hide(var/i)

	invisibility = i ? 101 : 0		// make hidden pipe items invisible
	updateicon()


//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/weapon/pipe/verb/rotate()
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	switch(pipe_type)
		if(0)
			if(icon_state == "straight")
				pipe_dir = 12
				icon_state = "straight12"
			else if (icon_state == "straight12")
				pipe_dir = 3
				icon_state = "straight"
		if(1)
			if(icon_state == "bend9")
				icon_state = "bend"
				pipe_dir = 10
			else if(icon_state == "bend")
				icon_state = "bend6"
				pipe_dir = 6
			else if(icon_state == "bend6")
				icon_state = "bend5"
				pipe_dir = 5
			else if(icon_state == "bend5")
				icon_state = "bend9"
				pipe_dir = 9

		if(2)
			if(icon_state == "he-straight")
				icon_state = "he-straight12"
				pipe_dir = 12
			else if(icon_state == "he-straight12")
				icon_state = "he-straight"
				pipe_dir = 3

		if(3)
			if(icon_state == "he-bend")
				icon_state = "he-bend9"
				pipe_dir = 9
			else if(icon_state == "he-bend6")
				icon_state = "he-bend"
				pipe_dir = 10
			else if(icon_state == "he-bend5")
				icon_state = "he-bend6"
				pipe_dir = 6
			else if(icon_state == "he-bend9")
				icon_state = "he-bend5"
				pipe_dir = 5

		if(4,7,5,6,7,8,9,10)
			src.dir = turn(src.dir, -90)
	return

// returns the p_dir from the pipe item type and dir

/obj/item/weapon/pipe/proc/get_pdir()

	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(0)
			if(pipe_dir == 0)
				pipe_dir = 3
			return pipe_dir
		if(1)
			if(pipe_dir == 0)
				pipe_dir = 10
			return pipe_dir
		if(2,3)
			return 0
		if(4,7,10)
			return dir
		if(5)
			return dir|cw|acw
		if(6)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/weapon/pipe/proc/get_hdir()

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(0,1,4,5,7,10)
			return 0
		if(2)
			if(pipe_dir == 0)
				pipe_dir = 3
			return pipe_dir
		if(3)
			if(pipe_dir == 0)
				pipe_dir = 10
			return pipe_dir
		if(6)
			return dir

	return 0

/obj/item/weapon/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	//*
	if (istype(W, /obj/item/weapon/wrench))

		var/pipedir = src.get_pdir()|src.get_hdir()		// all possible pipe dirs including h/e#

		for(var/obj/machinery/atmospherics/M in src.loc)
			if(M.level == src.level)		// only on same level
				if( (M.initialize_directions & pipedir) || (M.initialize_directions & pipedir) )	// matches at least one direction on either type of pipe
					user << "There is already a pipe at that location."
					return
		playsound(src.loc, 'Ratchet.ogg', 50, 1)

		// no conflicts found

		// 0	  1			   2			3				4			  5			 6			7		 8		  9		  10
		//"pipe", "bent pipe", "h/e pipe", "bent h/e pipe", "connector", "manifold", "junction", "vent", "valve", "pump", "filter inlet"



		switch(pipe_type)
			if(0)		// straight pipe
				var/obj/machinery/atmospherics/pipe/simple/P = new /obj/machinery/atmospherics/pipe/simple( src.loc )
				switch (icon_state)
					if("straight")
						P.dir = NORTH
						P.initialize_directions = NORTH|SOUTH
					if("straight12")
						P.dir = EAST
						P.initialize_directions = EAST|WEST
				P.level = level
				P.initialize()
				P.build_network()
				if (P.node1)
					P.node1.initialize()
					P.node1.build_network()
				if (P.node2)
					P.node2:initialize()
					P.node2.build_network()


			if(1)		// bent pipe
				var/obj/machinery/atmospherics/pipe/simple/P = new /obj/machinery/atmospherics/pipe/simple( src.loc )
				switch (icon_state)
					if("bend")
						P.dir = SOUTHWEST
						P.initialize_directions = SOUTH|WEST
					if("bend6")
						P.dir = SOUTHEAST
						P.initialize_directions = SOUTH|EAST
					if("bend5")
						P.dir = NORTHEAST
						P.initialize_directions = NORTH|EAST
					if("bend9")
						P.dir = NORTHWEST
						P.initialize_directions = NORTH|WEST
				P.level = level
				P.initialize()
				P.build_network()
				if (P.node1)
					P.node1.initialize()
					P.node1.build_network()
				if (P.node2)
					P.node2:initialize()
					P.node2.build_network()

/*
			if(2,3)		// straight or bent h/e pipe
				P = new/obj/machinery/pipes/heat_exch( src.loc )
				P.h_dir = get_hdir()
				P.icon_state = get_hdir()
				P.level = 2
				P.update()

				var/list/dirs = P.get_dirs()
*/

			if(4)		// connector
				var/obj/machinery/atmospherics/portables_connector/C = new( src.loc )
				C.dir = dir
				C.New()
				C.level = level
				C.initialize()
				C.build_network()


			if(5)		//manifold
				var/obj/machinery/atmospherics/pipe/manifold/M = new( src.loc )
				M.dir = dir
				M.New()
				M.level = level
				M.initialize()
				M.build_network()
/*
			if(6)		//junctions
				var/obj/machinery/junction/J = new( src.loc )
				J.dir = dir
				J.p_dir = src.get_pdir()
				J.h_dir = src.get_hdir()
				J.level = 2
*/
			if(7)		//unary vent
				var/obj/machinery/atmospherics/unary/vent_pump/V = new( src.loc )
				V.dir = dir
				V.New()
				V.level = level
				V.initialize()
				V.build_network()


			if(8)		//manual valve
				var/obj/machinery/atmospherics/valve/V = new( src.loc)
				V.dir = dir
				V.New()
				V.level = level
				V.initialize()
				V.build_network()

			if(9)		//gas pump
				var/obj/machinery/atmospherics/binary/pump/P = new(src.loc)
				P.dir = dir
				P.New()
				P.level = level
				P.initialize()
				P.build_network()


			if(10)		//scrubber
				var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(src.loc)
				S.dir = dir
				S.New()
				S.level = level
				S.initialize()
				S.build_network()




		user << "You have fastened the pipe"
		del(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/weapon/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4

/obj/item/weapon/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)

	if (istype(W, /obj/item/weapon/wrench))
		if(locate(/obj/machinery/atmospherics/pipe, src.loc))
			new/obj/machinery/meter( src.loc )
			playsound(src.loc, 'Ratchet.ogg', 50, 1)
			user << "You have fastened the meter to the pipe"
			del(src)
		else
			user << "You need to fasten it to a pipe"
	return

