/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	if(holder.rank == "Game Admin")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else if(holder.rank == "Game Master")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else
		alert("Coders only baby")
		return



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	var/target = null
	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			class = input("Proc owned by...","Owner") in list("Obj","Mob","Area or Turf","Client","CANCEL ABORT STOP")
			switch(class)
				if("CANCEL ABORT STOP")
					return
				if("Obj")
					target = input("Enter target:","Target",usr) as obj in world
				if("Mob")
					target = input("Enter target:","Target",usr) as mob in world
				if("Area or Turf")
					target = input("Enter target:","Target",usr.loc) as area|turf in world
				if("Client")
					var/list/keys = list()
					for(var/mob/M in world)
						keys += M.client
					target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
		if("No")
			target = null

	var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null)

	var/argnum = input("Number of arguments","Number:",0) as num

	lst.len = argnum // Expand to right length

	var/i
	for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

		// Make a list with each index containing one variable, to be given to the proc
		class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return

			if("text")
				lst[i] = input("Enter new text:","Text",null) as text

			if("num")
				lst[i] = input("Enter new number:","Num",0) as num

			if("type")
				lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in world

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in world
				lst[i] = temp.loc


	spawn(0)
		if(target)
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	usr << "\blue Proc returned: [returnval ? returnval : "null"]"

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen]\n"
	t+= "Oxygen : [env.oxygen]\n"
	t+= "Plasma : [env.toxins]\n"
	t+= "CO2: [env.carbon_dioxide]\n"

	usr.show_message(t, 1)

/client/proc/cmd_admin_robotize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/makepAI(var/turf/T in world)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in world)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!istype(choice, /mob/dead/observer))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text
	pai.real_name = pai.name
	pai.key = choice.key
	card.pai = pai
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)

/client/proc/cmd_admin_alienize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_metroidize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Metroid"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has metroidized [M.key].")
		spawn(10)
			M:Metroidize()
	else
		alert("Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in world)
	set category = null
	set name = "Make Abomination"

	usr << "Ruby Mode disabled. Command aborted."
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in world) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!wordtravel)
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground."
				new /obj/item/weapon/tome(M.loc)
			else
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie."
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					M << "\red You remembered one thing from the glimpse... [wordtravel] is travel..."
				if("2")
					M << "\red You remembered one thing from the glimpse... [wordblood] is blood..."
				if("3")
					M << "\red You remembered one thing from the glimpse... [wordjoin] is join..."
				if("4")
					M << "\red You remembered one thing from the glimpse... [wordhell] is Hell..."
				if("5")
					M << "\red You remembered one thing from the glimpse... [worddestr] is destroy..."
				if("6")
					M << "\red You remembered one thing from the glimpse... [wordtech] is technology..."
				if("7")
					M << "\red You remembered one thing from the glimpse... [wordself] is self..."
				if("8")
					M << "\red You remembered one thing from the glimpse... [wordsee] is see..."

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			src << "Made [M] a cultist."
*/

/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				del(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)

/client/proc/cmd_admin_grantfullaccess(var/mob/M in world)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered]'s ID Card ([id.assignment])"
			H.equip_if_possible(id, H.slot_wear_id)
			H.update_clothing()
	else
		alert("Invalid mob")

/client/proc/cmd_switch_radio()
	set category = "Debug"
	set name = "Switch Radio Mode"
	set desc = "Toggle between normal radios and experimental radios. Have a coder present if you do this."

	GLOBAL_RADIO_TYPE = !GLOBAL_RADIO_TYPE // toggle
	log_admin("[key_name(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].", 0)





/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in world)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"standard space gear",
		"tournament standard red",
		"tournament standard green",
		"tournament gangster",
		"tournament chef",
		"tournament janitor",
		"pirate",
		"space pirate",
		"soviet admiral",
		"tunnel clown",
		"masked killer",
		"assassin",
		"death commando",
		"syndicate commando",
		"centcom official",
		"centcom commander",
		"special ops officer",
		"blue wizard",
		"red wizard",
		"marisa wizard",
		)
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/weapon/implant))
			continue
		del(I)
	switch(dresscode)
		if ("strip")
			//do nothing
		if ("standard space gear")
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/under/color/grey(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/space(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/space(M), M.slot_head)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_if_possible(J, M.slot_back)
			J.toggle()
			M.equip_if_possible(new /obj/item/clothing/mask/breath(M), M.slot_wear_mask)
			J.Topic(null, list("stat" = 1))
		if ("tournament standard red","tournament standard green") //we think stunning weapon is too overpowered to use it on tournaments. --rastaf0
			if (dresscode=="tournament standard red")
				M.equip_if_possible(new /obj/item/clothing/under/color/red(M), M.slot_w_uniform)
			else
				M.equip_if_possible(new /obj/item/clothing/under/color/green(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/suit/armor/vest(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/thunderdome(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/smokebomb(M), M.slot_r_store)


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_if_possible(new /obj/item/clothing/under/det(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/suit/det_suit(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/head/det_hat(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/cloaking_device(M), M.slot_r_store)

			M.equip_if_possible(new /obj/item/weapon/gun/projectile(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/ammo_magazine/a357(M), M.slot_l_store)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_if_possible(new /obj/item/clothing/under/rank/chef(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/chef(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/chefhat(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_s_store)

		if ("tournament janitor")
			M.equip_if_possible(new /obj/item/clothing/under/rank/janitor(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				del(I)
			M.equip_if_possible(backpack, M.slot_back)

			M.equip_if_possible(new /obj/item/weapon/mop(M), M.slot_r_hand)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_if_possible(bucket, M.slot_l_hand)

			M.equip_if_possible(new /obj/item/weapon/chem_grenade/cleaner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/chem_grenade/cleaner(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)

		if ("pirate")
			M.equip_if_possible(new /obj/item/clothing/under/pirate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/brown(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/bandana(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword/pirate(M), M.slot_r_hand)

		if ("space pirate")
			M.equip_if_possible(new /obj/item/clothing/under/pirate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/brown(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/suit/space/pirate(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/space/pirate(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(M), M.slot_glasses)

			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword/pirate(M), M.slot_r_hand)

/*
		if ("soviet soldier")
			M.equip_if_possible(new /obj/item/clothing/under/soviet(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/ushanka(M), M.slot_head)
*/

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_if_possible(new /obj/item/clothing/under/rank/clown(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/black(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/chaplain_hood(M), M.slot_head)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/chaplain_hoodie(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/bikehorn(M), M.slot_r_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Tunnel Clown!"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

			var/obj/item/weapon/fireaxe/fire_axe = new(M)
			fire_axe.name = "Fire Axe (Unwielded)"
			M.equip_if_possible(fire_axe, M.slot_r_hand)

		if("masked killer")
			M.equip_if_possible(new /obj/item/clothing/under/overalls(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/white(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/latex(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/clothing/mask/surgical(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/apron(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/scalpel(M), M.slot_r_store)

			var/obj/item/weapon/fireaxe/fire_axe = new(M)
			fire_axe.name = "Fire Axe (Unwielded)"
			M.equip_if_possible(fire_axe, M.slot_r_hand)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			M.equip_if_possible(new /obj/item/clothing/under/suit_jacket(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/black(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/wcoat(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/cloaking_device(M), M.slot_r_store)

			var/obj/item/weapon/secstorage/sbriefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				del(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/mateba
			sec_briefcase.contents += new /obj/item/ammo_magazine/a357
			sec_briefcase.contents += new /obj/item/weapon/plastique
			M.equip_if_possible(sec_briefcase, M.slot_l_hand)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, M.slot_belt)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Reaper"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("death commando")//Was looking to add this for a while.
			M.equip_death_commando()

		if("syndicate commando")
			M.equip_syndicate_commando()

		if("centcom official")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom_officer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/black(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/weapon/gun/energy(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/weapon/pen(M), M.slot_l_store)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "CentCom Review Official"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, M.slot_r_store)

			M.equip_if_possible(new /obj/item/weapon/clipboard(M), M.slot_l_hand)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer")
			W.assignment = "CentCom Review Official"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("centcom commander")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom_commander(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/armor/bulletproof(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/swat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/swat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/mask/cigarette/cigar/cohiba(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/centhat(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/gun/projectile/mateba(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/weapon/lighter/zippo(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/ammo_magazine/a357(M), M.slot_l_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "CentCom Commanding Officer"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("special ops officer")
			M.equip_if_possible(new /obj/item/clothing/under/syndicate/combat(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/armor/swat/officer(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/combat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/combat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/mask/cigarette/cigar/havana(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle/M1911(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/weapon/lighter/zippo(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(M), M.slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Special Operations Officer"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("blue wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)

		if("red wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe/red(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard/red(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)

		if("marisa wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe/marisa(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal/marisa(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard/marisa(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)
		if("soviet admiral")
			M.equip_if_possible(new /obj/item/clothing/head/hgpiratecap(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/shoes/combat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/combat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/hgpirate(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack/bandolier(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/gun/projectile/mateba(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/soviet(M), M.slot_w_uniform)
			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Admiral"
			W.registered = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

	M.update_clothing()
	return

/client/proc/cmd_debug_blood()
	set category = "Debug"
	set name = "Analyze all blood_DNA"

	// to prevent REALLY stupid activations
	switch(alert("Are you sure?", ,"Yes", "No"))
		if("No")
			return
	world << "\red ALERT! \black Standby for high CPU bugtesting to determine missing blood_DNA values!"
	world << "\red THIS WILL PROBABLY LAG LIKE HELL."
	world << "Initiating in 10 BYOND seconds..."
	log_admin("[key_name(src)] has initiated a scan of all blood_DNA lists!")
	message_admins("[key_name_admin(src)] has initiated a scan of all blood_DNA lists!", 0)
	sleep(100)
	world << "\red SCAN INITIATED."
	spawn(0) //I am not stupid enough to leave that in a regular loop.
		for(var/atom/O in world)
			if(!islist(O.blood_DNA))
				var/turf/T = get_turf(O)
				if(istype(O.loc,/turf))
					src << "[O] at [T.x],[T.y],[T.z] has a non-list blood_DNA variable! (Last touched by [O.fingerprintslast])"
				else
					src << "[O] in [O.loc] at [T.x],[T.y],[T.z] has a non-list blood_DNA variable! (Last touched by [O.fingerprintslast])"
		world << "\red SCAN COMPLETE."
		world << "Thank you for your patience."
		return


/client/proc/cmd_debug_prints()
	set category = "Debug"
	set name = "Analyze all fingerprints"

	// to prevent REALLY stupid activations
	switch(alert("Are you sure?", ,"Yes", "No"))
		if("No")
			return
	world << "\red ALERT! \black Standby for high CPU bugtesting to determine incorrect fingerprint values!"
	world << "\red THIS WILL PROBABLY LAG LIKE HELL."
	world << "Initiating in 10 BYOND seconds..."
	log_admin("[key_name(src)] has initiated a scan of all fingerprints!")
	message_admins("[key_name_admin(src)] has initiated a scan of all fingerprints!", 0)
	sleep(100)
	world << "\red SCAN INITIATED."
	spawn(0) //I am not stupid enough to leave that in a regular loop.
		for(var/atom/O in world)
			if(istype(O, /mob)) //Lets not.
				continue
			if(!islist(O.fingerprints))
				var/turf/T = get_turf(O)
				if(istype(O.loc,/turf))
					src << "[O] at [T.x],[T.y],[T.z] has a non-list fingerprints variable! (Last touched by [O.fingerprintslast])"
				else
					src << "[O] in [O.loc] at [T.x],[T.y],[T.z] has a non-list fingerprints variable! (Last touched by [O.fingerprintslast])"
			else if (O.fingerprints.len)
				for(var/i = 1, i <= O.fingerprints.len, i++)
					if(length(O.fingerprints[i]) != 69)
						var/turf/T = get_turf(O)
						if(isnull(T))
							src << "[O] at [O.loc] has a fingerprints variable of incorrect length! (TURF NOT FOUND). (Last touched by [O.fingerprintslast])"
						else
							if(istype(O.loc,/turf))
								src << "[O] at [T.x],[T.y],[T.z] has a fingerprints variable of incorrect length! (Last touched by [O.fingerprintslast])"
							else
								src << "[O] in [O.loc] at [T.x],[T.y],[T.z] has a fingerprints variable of incorrect length! (Last touched by [O.fingerprintslast])"
						break

		world << "\red SCAN COMPLETE."
		world << "Thank you for your patience."
		return
