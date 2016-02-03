/*
	The global hud:
	Uses the same visual objects for all players.
*/

var/datum/global_hud/global_hud = new()

/datum/global_hud
	var/obj/screen/druggy
	var/obj/screen/blurry
	var/obj/screen/blind
	var/list/vimpaired
	var/list/darkMask

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /obj/screen()
	druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	druggy.icon_state = "druggy"
	druggy.blend_mode = BLEND_MULTIPLY
	druggy.layer = 17
	druggy.mouse_opacity = 0

	//that white blurry effect you get when you eyes are damaged
	blurry = new /obj/screen()
	blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blurry.icon_state = "blurry"
	blurry.layer = 17
	blurry.mouse_opacity = 0

	blind = new /obj/screen()
	blind.icon = 'icons/mob/screen_full.dmi'
	blind.icon_state = "blackimageoverlay"
	blind.screen_loc = "CENTER-7,CENTER-7"
	blind.mouse_opacity = 0
	blind.layer = 18

	var/obj/screen/O
	var/i
	//that nasty looking dither you  get when you're short-sighted
	vimpaired = newlist(/obj/screen,/obj/screen,/obj/screen,/obj/screen)
	O = vimpaired[1]
	O.screen_loc = "WEST,SOUTH to CENTER-3,NORTH"	//West dither
	O = vimpaired[2]
	O.screen_loc = "WEST,SOUTH to EAST,CENTER-3"	//South dither
	O = vimpaired[3]
	O.screen_loc = "CENTER+3,SOUTH to EAST,NORTH"	//East dither
	O = vimpaired[4]
	O.screen_loc = "WEST,CENTER+3 to EAST,NORTH"	//North dither

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "CENTER-5,CENTER-5 to CENTER-3,CENTER+5" //West dither
	O = darkMask[2]
	O.screen_loc = "CENTER-5,CENTER-5 to CENTER+5,CENTER-3"	//South dither
	O = darkMask[3]
	O.screen_loc = "CENTER+3,CENTER-5 to CENTER+5,CENTER+5"	//East dither
	O = darkMask[4]
	O.screen_loc = "CENTER-5,CENTER+3 to CENTER+5,CENTER+5"	//North dither
	O = darkMask[5]
	O.screen_loc = "WEST,SOUTH to CENTER-5,NORTH"	//West black
	O = darkMask[6]
	O.screen_loc = "WEST,SOUTH to EAST,CENTER-5"	//South black
	O = darkMask[7]
	O.screen_loc = "CENTER+5,SOUTH to EAST,NORTH"	//East black
	O = darkMask[8]
	O.screen_loc = "WEST,CENTER+5 to EAST,NORTH"	//North black


	for(i = 1, i <= 4, i++)
		O = vimpaired[i]
		O.icon_state = "dither50"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

		O = darkMask[i]
		O.icon_state = "dither50"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.blend_mode = BLEND_MULTIPLY
		O.layer = 17
		O.mouse_opacity = 0

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/hud_version = 1			//Current displayed version of the HUD
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/ling/chems/lingchemdisplay
	var/obj/screen/ling/sting/lingstingdisplay

	var/obj/screen/blobpwrdisplay

	var/obj/screen/alien_plasma_display

	var/obj/screen/deity_power_display
	var/obj/screen/deity_follower_display

	var/obj/screen/nightvisionicon
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/zone_select
	var/obj/screen/pull_icon
	var/obj/screen/throw_icon
	var/obj/screen/module_store_icon

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/obj/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)
	var/list/screenoverlays = list() //the screen objects used as whole screen overlays (flash, damageoverlay, etc...)

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	var/obj/screen/healths
	var/obj/screen/healthdoll
	var/obj/screen/internals

/datum/hud/New(mob/owner)
	mymob = owner

/mob/proc/create_mob_hud()
	return


//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(l_hand_hud_object)
				mymob.client.screen += l_hand_hud_object	//we want the hands to be visible
			if(r_hand_hud_object)
				mymob.client.screen += r_hand_hud_object	//we want the hands to be visible
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay

	if(screenoverlays.len)
		mymob.client.screen += screenoverlays
	mymob.client.screen += mymob.client.void
	hud_version = display_hud_version
	persistant_inventory_update()
	mymob.update_action_buttons()
	reorganize_alerts()

/datum/hud/human/show_hud(version = 0)
	..()
	hidden_inventory_update()

/datum/hud/robot/show_hud(version = 0)
	..()
	update_robot_modules_display()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistant_inventory_update()
	return

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		usr << "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>"
	else
		usr << "<span class ='warning'>This mob type does not use a HUD.</span>"

