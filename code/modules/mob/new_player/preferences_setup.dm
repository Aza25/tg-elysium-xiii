
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	underwear = random_underwear(gender)
	undershirt = random_undershirt(gender)
	socks = random_socks(gender)
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = hair_color
	eye_color = random_eye_color()
	if(!pref_species)
		pref_species = new /datum/species/human()
	backbag = 2
	lizard_parts = random_lizard_features()
	age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()		//seriously. This is horrendous.
	del(preview_icon_front)
	del(preview_icon_side)
	var/icon/preview_icon = null

	if(job_engsec_high) //cyborg/AI check, put first to avoid so much unneeded blending
		switch(job_engsec_high)
			if(AI)
				preview_icon = new /icon('icons/mob/AI.dmi', "AI")

			if(CYBORG)
				preview_icon = new /icon('icons/mob/robots.dmi', "robot")

		if(preview_icon) //We're busting out!
			preview_icon_front = new(preview_icon, dir = SOUTH)
			preview_icon_side = new(preview_icon, dir = WEST)

			del(preview_icon)
			return

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	if(pref_species.id == "human" || !config.mutant_races)
		preview_icon = new /icon('icons/mob/human.dmi', "[skin_tone]_[g]_s")
	else
		preview_icon = new /icon('icons/mob/human.dmi', "[pref_species.id]_[g]_s")
		preview_icon.Blend("#[mutant_color]", ICON_MULTIPLY)

	var/datum/sprite_accessory/S
	var/icon/eyes_s = new/icon()
	if(EYECOLOR in pref_species.specflags)
		eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[pref_species.eyes]_s")
		eyes_s.Blend("#[eye_color]", ICON_MULTIPLY)

	S = hair_styles_list[hair_style]
	if(S && (HAIR in pref_species.specflags))
		var/icon/hair_s = new/icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		hair_s.Blend("#[hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	S = facial_hair_styles_list[facial_hair_style]
	if(S && (FACEHAIR in pref_species.specflags))
		var/icon/facial_s = new/icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		facial_s.Blend("#[facial_hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/icon_state_string = "[pref_species.id]_"

	if(pref_species.sexes)
		icon_state_string += "[g]_s"
	else
		icon_state_string += "_s"

	for(var/layer in relevent_layers)
		for(var/bodypart in pref_species.mutant_bodyparts)
			switch(bodypart)
				if("tail")
					S = tails_list[lizard_parts["tail"]]
				if("spines")
					S = spines_list[lizard_parts["spines"]]
				if("snout")
					S = snouts_list[lizard_parts["snout"]]
				if("frills")
					S = frills_list[lizard_parts["frills"]]
				if("horns")
					S = horns_list[lizard_parts["horns"]]
				if("body_markings")
					S = body_markings_list[lizard_parts["body_markings"]]

			if(S.icon_state == "none")
				continue
			var/icon_string
			if(S.gender_specific)
				icon_string = "[pref_species.id]_[g]_[bodypart]_[S.icon_state]_[layer]"
			else
				icon_string = "[pref_species.id]_m_[bodypart]_[S.icon_state]_[layer]"
			var/icon/part = new/icon("icon" = 'icons/mob/mutant_bodyparts.dmi', "icon_state" = icon_string)

			part.Blend("#[mutant_color]", ICON_MULTIPLY)
			preview_icon.Blend(part, ICON_OVERLAY)

	if(underwear)
		S = underwear_list[underwear]
		if(S)
			preview_icon.Blend(new /icon(S.icon, "[S.icon_state]_s"), ICON_OVERLAY)

	if(undershirt)
		S = undershirt_list[undershirt]
		if(S)
			preview_icon.Blend(new /icon(S.icon, "[S.icon_state]_s"), ICON_OVERLAY)

	if(socks)
		S = socks_list[socks]
		if(S)
			preview_icon.Blend(new /icon(S.icon, "[S.icon_state]_s"), ICON_OVERLAY)

	var/icon/clothes_s = null
	if(job_civilian_low & ASSISTANT)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)

	else if(job_civilian_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_civilian_high)
			if(HOP)
				clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hopcap"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(BARTENDER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "bar_suit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(BOTANIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(COOK)
				clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "chef"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "chef"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(JANITOR)
				clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(LIBRARIAN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(QUARTERMASTER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "clipboard"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(CARGOTECH)
				clothes_s = new /icon('icons/mob/uniform.dmi', "cargo_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(MINER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
			if(LAWYER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "bluesuit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "briefcase"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(CHAPLAIN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "chapblack_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "bible"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(CLOWN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "clown_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "clownpack"), ICON_OVERLAY)
			if(MIME)
				clothes_s = new /icon('icons/mob/uniform.dmi', "mime_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suspenders"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "mimepack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)

	else if(job_medsci_high)
		switch(job_medsci_high)
			if(RD)
				clothes_s = new /icon('icons/mob/uniform.dmi', "director_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "clipboard"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(SCIENTIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "toxinswhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(CHEMIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(CMO)
				clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "firstaid"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(DOCTOR)
				clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "firstaid"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(GENETICIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(VIROLOGIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "virologywhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(ROBOTICIST)
				clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_lefthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)

	else if(job_engsec_high)
		switch(job_engsec_high)
			if(CAPTAIN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "capcarapace"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "captainpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-cap"), ICON_OVERLAY)
			if(HOS)
				clothes_s = new /icon('icons/mob/uniform.dmi', "hos_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hosberetblack"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "hostrench"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
			if(WARDEN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "policehelm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "warden_jacket"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
			if(DETECTIVE)
				clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
			if(OFFICER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "security_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
			if(CHIEF)
				clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
			if(ENGINEER)
				clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "workboots"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
				if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
			if(ATMOSTECH)
				clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)

	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	del(preview_icon)
	del(eyes_s)
	del(clothes_s)