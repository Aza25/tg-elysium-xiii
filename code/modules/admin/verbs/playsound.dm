/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"

	//if(Debug2)
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S,0,1,0)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1

	if(src.holder.rank == "Host" || src.holder.rank == "Coder" || src.holder.rank == "Shit Guy")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		for(var/mob/M in world)
			if(M.midis)
				M << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			for(var/mob/M in world)
				if(M.midis)
					M << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)
//	else
//		usr << "Cant play Sound."


	//else
	//	alert("Debugging is disabled")
	//	return

/client/proc/cuban_pete()
	set category = "Fun"
	set name = "Cuban Pete Time"

	for(var/mob/M in world)
		if(M.midis)
			M << 'cubanpetetime.ogg'

	for(var/mob/living/carbon/human/CP in world)
		if(CP.real_name=="Cuban Pete" && CP.key!="Rosham")
			CP << "Your body can't contain the rhumba beat"
			CP.gib(1)

	/*if(Debug2)
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S,0,1,0)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1

	if(src.holder.rank == "Host" || src.holder.rank == "Coder" || src.holder.rank == "Shit Guy")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		world << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			world << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)*/