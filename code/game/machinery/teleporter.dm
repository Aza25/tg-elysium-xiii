/obj/machinery/computer/teleporter
	name = "Teleporter Control Console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/weapon/circuitboard/teleporter"
	var/obj/item/device/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	..()
	return

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/device/gps))
		var/obj/item/device/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.unEquip(L))
				user << "<span class='notice'>\the [I] is stuck to your hand, you cannot put it in \the [src]</span>"
				return
			L.loc = src
			locked = L
			user << "<span class = 'caution'>You insert the GPS device into the [name]'s slot.</span>"
	else
		..()
	return

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/teleporter/interact(mob/user)
	var/data = "<h3>Teleporter Status</h3>"
	if(!power_station)
		data += "<div class='statusDisplay'>No power station linked.</div>"
	else if(!power_station.teleporter_hub)
		data += "<div class='statusDisplay'>No hub linked.</div>"
	else
		data += "<div class='statusDisplay'>Current regime: [regime_set]<BR>Current target: [(!target) ? "None" : "[get_area(target)] [(regime_set != "Gate") ? "" : "Teleporter"]"]</div><BR>"
		data += "<A href='?src=\ref[src];regimeset=1'>Change regime</A><BR>"
		data += "<A href='?src=\ref[src];settarget=1'>Set target</A><BR>"
		if(locked)
			data += "<A href='?src=\ref[src];locked=1'>Get target from memory</A><BR>"
			data += "<A href='?src=\ref[src];eject=1'>Eject GPS device</A><BR>"
		else
			data += "<span class='linkOff'>Get target from memory</span><BR>"
			data += "<span class='linkOff'>Eject GPS device</span>"

	var/datum/browser/popup = new(user, "teleporter", name, 400, 400)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return
	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		reset_regime()
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		set_target(usr)
	if(href_list["locked"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		target = get_turf(locked.locked_location)
	if(href_list["eject"])
		eject()
	updateDialog()

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	if(regime_set == "Teleporter")
		var/list/L = list()
		var/list/areaindex = list()

		for(var/obj/item/device/radio/beacon/R in world)
			var/turf/T = get_turf(R)
			if (!T)
				continue
			if(T.z == 2 || T.z > 7)
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

		for (var/obj/item/weapon/implant/tracking/I in world)
			if (!I.implanted || !ismob(I.loc))
				continue
			else
				var/mob/M = I.loc
				if (M.stat == 2)
					if (M.timeofdeath + 6000 < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!T)	continue
				if(T.z == 2)	continue
				var/tmpname = M.real_name
				if(areaindex[tmpname])
					tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else
					areaindex[tmpname] = 1
				L[tmpname] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		target = L[desc]

	else
		var/list/L = list()
		var/list/areaindex = list()
		var/list/S = power_station.linked_stations
		if(!S.len)
			user << "<span class='alert'>No connected stations located.</span>"
			return
		for(var/obj/machinery/teleport/station/R in S)
			var/turf/T = get_turf(R)
			if (!T || !R.teleporter_hub || !R.teleporter_console)
				continue
			if(T.z == 2 || T.z > 7)
				continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R
		var/desc = input("Please select a station to lock in.", "Locking Computer") in L
		target = L[desc]
		if(target)
			var/obj/machinery/teleport/station/trg = target
			trg.linked_stations |= power_station
			trg.stat &= ~NOPOWER
			if(trg.teleporter_hub)
				trg.teleporter_hub.stat &= ~NOPOWER
				trg.teleporter_hub.update_icon()
			if(trg.teleporter_console)
				trg.teleporter_console.stat &= ~NOPOWER
				trg.teleporter_console.update_icon()
	return

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = 1
	anchored = 1.0

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station

/obj/machinery/teleport/hub/New()
	..()
	link_power_station()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_hub(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accurate = A

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if(power_station && power_station.engaged && !panel_open)
			teleport(M)
			use_power(5000)
	return

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		return

	default_deconstruction_crowbar(W)

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (!com)
		return
	if (!com.target)
		visible_message("<span class='notice'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(prob(30 - (accurate * 10))) //oh dear a problem
			do_teleport(M, com.target)
			if(ishuman(M))//don't remove people from the round randomly you jerks
				var/mob/living/carbon/human/human = M
				if(human.dna && !human.dna.mutantrace)
					M  << "<span class='danger'>You hear a buzzing in your ears.</span>"
					human.dna.mutantrace = "fly"
					human.update_body()
					human.update_hair()
				human.apply_effect((rand(120 - accurate * 40, 180 - accurate * 60)), IRRADIATE, 0)
		else
			do_teleport(M, com.target)
	return

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(power_station && power_station.engaged)
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/station
	name = "station"
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/teleporter_station(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, dir))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Del()
	if(teleporter_hub)
		teleporter_hub.update_icon()
	..()

/obj/machinery/teleport/station/attackby(var/obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/multitool) && !panel_open)
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
			if(linked_stations.len < efficiency)
				linked_stations.Add(M.buffer)
				M.buffer = null
				user << "<span class = 'caution'>You upload the data from the [W.name]'s buffer.</span>"
			else
				user << "<span class = 'alert'>This station cant hold more information, try to use better parts.</span>"
	if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		return

	default_deconstruction_crowbar(W)

	if(panel_open)
		if(istype(W, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = W
			M.buffer = src
			user << "<span class = 'caution'>You download the data to the [W.name]'s buffer.</span>"
			return
		if(istype(W, /obj/item/weapon/wirecutters))
			link_console_and_hub()
			user << "<span class = 'caution'>You reconnect the station to nearby machinery.</span>"
			return

/obj/machinery/teleport/station/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand(mob/user)
	if(!panel_open)
		toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console )
		return
	if (teleporter_console.target)
		src.engaged = !src.engaged
		use_power(5000)
		visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	src.add_fingerprint(user)
	return

/obj/machinery/teleport/station/power_change()
	..()
	if(stat & NOPOWER)
		update_icon()
		if(teleporter_hub)
			teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & NOPOWER)
		icon_state = "controller-p"
	else
		icon_state = "controller"
