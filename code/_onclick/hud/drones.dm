/datum/hud/drone/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand) //Hand being true means the LEFT hand is active
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand) //Hand being true means the LEFT hand is active
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = slot_drone_storage
	inv_box.layer = 19
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head/mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_drone_head
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	static_inventory += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	static_inventory += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	static_inventory += using

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)


/datum/hud/drone/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/simple_animal/drone/D = mymob

	if(hud_shown)
		if(D.internal_storage)
			D.internal_storage.screen_loc = ui_drone_storage
			D.client.screen += D.internal_storage
		if(D.head)
			D.head.screen_loc = ui_drone_head
			D.client.screen += D.head
	else
		if(D.internal_storage)
			D.internal_storage.screen_loc = null
		if(D.head)
			D.head.screen_loc = null

	if(hud_version != HUD_STYLE_NOHUD)
		if(D.r_hand)
			D.r_hand.screen_loc = ui_rhand
			D.client.screen += D.r_hand
		if(D.l_hand)
			D.l_hand.screen_loc = ui_lhand
			D.client.screen += D.l_hand
	else
		if(D.r_hand)
			D.r_hand.screen_loc = null
		if(D.l_hand)
			D.l_hand.screen_loc = null

/mob/living/simple_animal/drone/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/drone(src, ui_style2icon(client.prefs.UI_style))
