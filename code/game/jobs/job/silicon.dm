/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 1
	minimal_player_age = 30

	equip_items(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1

	config_check()
		if(config && config.allow_ai)
			return 1
		return 0



/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21

	equip_items(var/mob/living/carbon/human/H)
		if(!H)	return 0
		return 1