
/////////////////
//DRONE VISUALS//
/////////////////
//Drone overlays
//Drone visuals


/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	var/image/I = drone_overlays[cache_index]
	if(I)
		overlays += I


/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	if(drone_overlays[cache_index])
		overlays -= drone_overlays[cache_index]
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/proc/update_inv_hands()
	remove_overlay(DRONE_HANDS_LAYER)
	var/list/hands_overlays = list()

	var/y_shift = getItemPixelShiftY()

	if(r_hand)

		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		var/image/r_hand_image = r_hand.build_worn_icon(state = r_state, default_layer = DRONE_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		if(y_shift)
			r_hand_image.pixel_y += y_shift

		hands_overlays += r_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand

	if(l_hand)

		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		var/image/l_hand_image = l_hand.build_worn_icon(state = l_state, default_layer = DRONE_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		if(y_shift)
			l_hand_image.pixel_y += y_shift

		hands_overlays += l_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand


	if(hands_overlays.len)
		drone_overlays[DRONE_HANDS_LAYER] = hands_overlays
	apply_overlay(DRONE_HANDS_LAYER)


/mob/living/simple_animal/drone/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_drone_storage
		client.screen += internal_storage


/mob/living/simple_animal/drone/update_inv_head()
	remove_overlay(DRONE_HEAD_LAYER)

	if(head)
		if(client && hud_used && hud_used.hud_shown)
			head.screen_loc = ui_drone_head
			client.screen += head
		var/used_head_icon = 'icons/mob/head.dmi'
		if(istype(head, /obj/item/clothing/mask))
			used_head_icon = 'icons/mob/mask.dmi'
		var/image/head_overlay = head.build_worn_icon(state = head.icon_state, default_layer = DRONE_HEAD_LAYER, default_icon_file = used_head_icon)
		head_overlay.pixel_y += -15

		drone_overlays[DRONE_HEAD_LAYER]	= head_overlay

	apply_overlay(DRONE_HEAD_LAYER)


//These procs serve as redirection so that the drone updates as expected when other things call these procs
/mob/living/simple_animal/drone/update_inv_l_hand()
	update_inv_hands()


/mob/living/simple_animal/drone/update_inv_r_hand()
	update_inv_hands()


/mob/living/simple_animal/drone/update_inv_wear_mask()
	update_inv_head()

/mob/living/simple_animal/drone/regenerate_icons()
	// Drones only have 4 slots, which in this specific instance
	// is a small blessing.
	update_inv_hands()
	update_inv_head()
	update_inv_internal_storage()


/mob/living/simple_animal/drone/proc/pickVisualAppearence()
	picked = FALSE
	var/appearence = input("Choose your appearence!", "Appearence", "Maintenance Drone") in list("Maintenance Drone", "Repair Drone", "Scout Drone")
	switch(appearence)
		if("Maintenance Drone")
			visualAppearence = MAINTDRONE
			var/colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
			icon_state = "[visualAppearence]_[colour]"
			icon_living = "[visualAppearence]_[colour]"
			icon_dead = "[visualAppearence]_dead"

		if("Repair Drone")
			visualAppearence = REPAIRDRONE
			icon_state = visualAppearence
			icon_living = visualAppearence
			icon_dead = "[visualAppearence]_dead"

		if("Scout Drone")
			visualAppearence = SCOUTDRONE
			icon_state = visualAppearence
			icon_living = visualAppearence
			icon_dead = "[visualAppearence]_dead"

		else
			return

	picked = TRUE



/mob/living/simple_animal/drone/proc/getItemPixelShiftY()
	switch(visualAppearence)
		if(MAINTDRONE)
			. = 0
		if(REPAIRDRONE)
			. = -6
		if(SCOUTDRONE)
			. = -6

/mob/living/simple_animal/drone/proc/updateSeeStaticMobs()
	if(!client)
		return

	for(var/i in staticOverlays)
		client.images.Remove(i)
		staticOverlays.Remove(i)
	staticOverlays.len = 0

	if(seeStatic)
		for(var/mob/living/L in mob_list)
			if(isdrone(L))
				continue
			var/image/chosen
			if(staticChoice in L.staticOverlays)
				chosen = L.staticOverlays[staticChoice]
			else
				chosen = L.staticOverlays["static"]
			staticOverlays |= chosen
			client.images |= chosen


/mob/living/simple_animal/drone/generateStaticOverlay()
	return
