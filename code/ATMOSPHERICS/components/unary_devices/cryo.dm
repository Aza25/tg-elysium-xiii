/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1

	var/on = FALSE
	state_open = FALSE
	var/autoeject = FALSE
	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 750
	var/paralyze_factor = 1000
	var/heat_capacity = 100000
	var/conduction_coefficient = 0.01

	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/reagent_transfer = 0

/obj/machinery/atmospherics/components/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	paralyze_factor = initial(paralyze_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	var/turf/T = loc
	T.contents += contents
	beaker = null
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	if(panel_open)
		icon_state = "cell-o"
	else if(state_open)
		icon_state = "cell-open"
	else if(on && is_operational())
		if(occupant)
			icon_state = "cell-occupied"
		else
			icon_state = "cell-on"
	else
		icon_state = "cell-off"

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()
	if(!on)
		return
	var/datum/gas_mixture/air1 = AIR1
	if(occupant)
		if(occupant.health >= 100) // Don't bother with fully healed people.
			on = FALSE
			update_icon()
			playsound(src.loc, 'sound/machines/ding.ogg', volume, 1) // Bug the doctors.
			if(autoeject) // Eject if configured.
				open_machine()
			return
		else if(occupant.stat == DEAD) // We don't bother with dead people.
			return

		if(occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
			occupant.sleeping = (occupant.bodytemperature / sleep_factor) * 100
			occupant.paralysis = (occupant.bodytemperature / paralyze_factor) * 100

		if(beaker)
			if(reagent_transfer == 0) // Magically transfer reagents. Because cryo magic.
				beaker.reagents.trans_to(occupant, 1, 10 * efficiency) // Transfer reagents, multiplied because cryo magic.
				beaker.reagents.reaction(occupant, VAPOR)
				air1.gases["o2"][MOLES] -= 2 / efficiency // Lets use gas for this.
			if(++reagent_transfer == 10 * efficiency) // Throttle reagent transfer (higher efficiency will transfer the same amount but consume less from the beaker).
				reagent_transfer = 0
	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	..()
	if(!on)
		return
	var/datum/gas_mixture/air1 = AIR1
	if(!NODE1 || !AIR1 || air1.gases["o2"][MOLES] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return
	if(occupant)
		var/cold_protection = 0
		var/mob/living/carbon/human/H = occupant
		if(istype(H))
			cold_protection = H.get_cold_protection(air1.temperature)

		var/temperature_delta = air1.temperature - occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.
		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()
			var/heat = ((1 - cold_protection) / 10 + conduction_coefficient) \
						* temperature_delta * \
						(air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))
			air1.temperature = max(air1.temperature - heat / air_heat_capacity, TCMB)
			occupant.bodytemperature = max(occupant.bodytemperature + heat / heat_capacity, TCMB)

		air1.gases["o2"][MOLES] -= 0.5 / efficiency // Magically consume gas? Why not, we run on cryo magic.

/obj/machinery/atmospherics/components/unary/cryo_cell/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user) // Prevent ventcrawl in this machine.
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine()
	if(!state_open && !panel_open)
		on = FALSE
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		return occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/user)
	usr << "<span class='notice'>You struggle inside the cryotube, kicking the release with your foot.</span>"
	audible_message("<span class='notice'>You hear a thump from [src].</span>")
	addtimer(src, "resist_open", 300, FALSE, user)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/resist_open(mob/user)
	if(occupant && (user in src)) // Check they're still here.
		open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	..()
	if(occupant)
		if(on)
			user << "Someone's inside [src]!"
		else
			user << "You can barely make out a form floating in [src]."
	else
		user << "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !Adjacent(target))
		return
	close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(isrobot(user))
			return
		if(beaker)
			user << "<span class='warning'>A beaker is already loaded into [src]!</span>"
			return
		if(!user.drop_item())
			return
		beaker = I
		I.loc = src
		user.visible_message("[user] places [I] in [src].", \
							"<span class='notice'>You place [I] in [src].</span>")
	if(!(on || occupant || state_open))
		if(default_deconstruction_screwdriver(user, "cell-o", "cell-off", I))
			return
		if(exchange_parts(user, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
																	datum/tgui/master_ui = null, datum/ui_state/state = notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cryo", name, 400, 550, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/get_ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0
	data["isOpen"] = state_open
	data["autoEject"] = autoeject

	var/list/occupantData = list()
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData


	var/datum/gas_mixture/air1 = AIR1
	data["cellTemperature"] = round(air1.temperature)

	data["isBeakerLoaded"] = beaker ? 1 : 0
	var beakerContents = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			if(on)
				on = FALSE
			else if(!state_open)
				on = TRUE
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
		if("autoeject")
			autoeject = !autoeject
		if("ejectbeaker")
			if(beaker)
				beaker.loc = loc
				beaker = null
	update_icon()
	return 1
