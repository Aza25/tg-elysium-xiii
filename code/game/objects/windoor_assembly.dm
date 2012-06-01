/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */


obj/structure/windoor_assembly
	icon = 'windoor.dmi'

	name = "Windoor Assembly"
	icon_state = "l_windoor_assembly01"
	anchored = 0
	density = 0
	dir = NORTH

	var/ini_dir
	var/list/conf_access = null //configuring access, step 6

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = ""		//Whether or not this creates a secure windoor or not
	var/state = "01"	//How far the door assembly has progressed

obj/structure/windoor_assembly/New(dir=NORTH)
	..()
	src.ini_dir = src.dir
	update_nearby_tiles(need_rebuild=1)

obj/structure/windoor_assembly/Del()
	density = 0
	update_nearby_tiles()
	..()

/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing]_[secure]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/attackby(obj/item/W as obj, mob/user as mob)
	switch(state)
		if("01")
			//Wrenching an unsecure assembly anchors it in place. Step 4 complete
			if(istype(W, /obj/item/weapon/wrench) && !anchored)
				playsound(src.loc, 'Ratchet.ogg', 100, 1)
				user.visible_message("[user] secures the windoor assembly to the floor.", "You start to secure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "\blue You've secured the windoor assembly!"
					src.anchored = 1
					if(src.secure)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Anchored Windoor Assembly"

			//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
			else if(istype(W, /obj/item/weapon/wrench) && anchored)
				playsound(src.loc, 'Ratchet.ogg', 100, 1)
				user.visible_message("[user] unsecures the windoor assembly to the floor.", "You start to unsecure the windoor assembly to the floor.")

				if(do_after(user, 40))
					if(!src) return
					user << "\blue You've unsecured the windoor assembly!"
					src.anchored = 0
					if(src.secure)
						src.name = "Secure Windoor Assembly"
					else
						src.name = "Windoor Assembly"

			//Adding r-glass makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			else if(istype(W, /obj/item/stack/rods) && !secure)
				var/obj/item/stack/rods/R = W
				if(R.amount < 4)
					user << "\red You need more rods to do this."
					return
				user << "\blue You start to reinforce the windoor with rods."

				if(do_after(user,40))
					if(!src) return

					R.use(4)
					user << "\blue You reinforce the windoor."
					src.secure = "secure_"
					if(src.anchored)
						src.name = "Secure Anchored Windoor Assembly"
					else
						src.name = "Secure Windoor Assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(istype(W, /obj/item/weapon/cable_coil) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly.")

				if(do_after(user, 40))
					if(!src) return
					var/obj/item/weapon/cable_coil/CC = W
					CC.use(1)
					user << "\blue You wire the windoor!"
					src.state = "02"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"
			else
				..()

		if("02")

			//Removing wire from the assembly. Step 5 undone.
			if(istype(W, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'Wirecutter.ogg', 100, 1)
				user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

				if(do_after(user, 40))
					if(!src) return

					user << "\blue You cut the windoor wires.!"
					new/obj/item/weapon/cable_coil(get_turf(user), 1)
					src.state = "01"
					if(src.secure)
						src.name = "Secure Wired Windoor Assembly"
					else
						src.name = "Wired Windoor Assembly"

			//Screwdrivering the wires in place (setting door access). Step 6 in progress.
			else if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				user.visible_message("[user] adjusts the access wires of the windoor assembly.", "You start to adjust the access wires of the windoor assembly.")
				configure_access()


			//Crowbar to complete the assembly, Step 7 complete.
			if(istype(W, /obj/item/weapon/crowbar))
				usr << browse(null, "window=windoor_access")
				playsound(src.loc, 'Crowbar.ogg', 100, 1)
				user.visible_message("[user] pries the windoor into the frame.", "You start prying the windoor into the frame.")

				if(do_after(user, 40))

					if(!src) return

					density = 1 //Shouldn't matter but just incase
					user << "\blue You finish the windoor!"

					if(secure)
						var/obj/machinery/door/window/brigdoor/windoor = new /obj/machinery/door/window/brigdoor(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "leftsecure"
							windoor.base_state = "leftsecure"
						else
							windoor.icon_state = "rightsecure"
							windoor.base_state = "rightsecure"
						windoor.dir = src.dir
						windoor.req_access = src.conf_access
					else
						var/obj/machinery/door/window/windoor = new /obj/machinery/door/window(src.loc)
						if(src.facing == "l")
							windoor.icon_state = "left"
							windoor.base_state = "left"
						else
							windoor.icon_state = "right"
							windoor.base_state = "right"
						windoor.dir = src.dir
						windoor.req_access = src.conf_access


					del(src)


			else
				..()

	//Update to reflect changes(if applicable)
	update_icon()

//Adjust the access of the door and pass it to Topic
/obj/structure/windoor_assembly/proc/configure_access()
	if(!src || !usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		return

	var/t1 = "<B>Access control</B><br>\n"

	if(!conf_access)
		t1 += "<font color=red>All</font><br>"
	else
		t1 += "<a href='?src=\ref[src];access=all'>All</a><br>"

	t1 += "<br>"

	var/list/accesses = get_all_accesses()
	for (var/acc in accesses)
		var/aname = get_access_desc(acc)

		if (!conf_access || !conf_access.len || !(acc in conf_access))
			t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
		else
			t1 += "<a style='color: red' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	usr << browse(t1, "window=windoor_access")


//Finalize door accesses. Step 6 complete.
/obj/structure/windoor_assembly/Topic(href, href_list)
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr) || href_list["close"])
		usr << browse(null, "window=windoor_access")
		return

	if(href_list["access"])
		var/acc = href_list["access"]

		if (acc == "all")
			conf_access = null
		else
			var/req = text2num(acc)

			if(conf_access == null)
				conf_access = list()

			if(!(req in conf_access))
				conf_access += req
			else
				conf_access -= req
				if (!conf_access.len)
					conf_access = null

		//Refresh the window.
		configure_access()


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	if(src.state != "01")
		update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.dir = turn(src.dir, 270)

	if(src.state != "01")
		update_nearby_tiles(need_rebuild=1)

	src.ini_dir = src.dir
	return

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(src.facing == "l")
		usr << "The windoor will now slide to the right."
		src.facing = "r"
	else
		src.facing = "l"
		usr << "The windoor will now slide to the left."


	return

/obj/structure/windoor_assembly/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/target = get_step(source,dir)

	if(need_rebuild)
		if(istype(source)) //Rebuild/update nearby group geometry
			if(source.parent)
				air_master.groups_to_rebuild += source.parent
			else
				air_master.tiles_to_update += source
		if(istype(target))
			if(target.parent)
				air_master.groups_to_rebuild += target.parent
			else
				air_master.tiles_to_update += target
	else
		if(istype(source)) air_master.tiles_to_update += source
		if(istype(target)) air_master.tiles_to_update += target

	return 1