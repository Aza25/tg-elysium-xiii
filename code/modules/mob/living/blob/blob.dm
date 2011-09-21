/mob/living/blob
	name = "blob fragment"
	real_name = "blob fragment"
	icon = 'blob.dmi'
	icon_state = "blob_spore_temp"
	pass_flags = PASSBLOB
	see_in_dark = 8
	see_invisible = 2
	var
		ghost_name = "Unknown"
		creating_blob = 0


/mob/living/blob/New()
	real_name += " [pick(rand(1, 99))]"
	name = real_name
	..()


/mob/living/blob/say(var/message)
	return//No talking for you


/mob/living/blob/emote(var/act,var/m_type=1,var/message = null)
	return


/mob/living/blob/Life()
	set invisibility = 0
	set background = 1

	clamp_values()
	UpdateDamage()
	if(health < 0)
		src.gib()


/mob/living/blob
	proc

		clamp_values()
			stunned = 0//No stun here
			paralysis = 0
			weakened = 0
			sleeping = 0
			bruteloss = max(bruteloss, 0)
			toxloss = max(toxloss, 0)
			oxyloss = max(oxyloss, 0)
			fireloss = max(fireloss, 0)
			if(stat)
				stat = 0
			return


		UpdateDamage()
			health = 60 - (oxyloss + toxloss + fireloss + bruteloss + cloneloss)
			return


/mob/living/blob/death(gibbed)
	if(key)
		var/mob/dead/observer/ghost = new(src)
		ghost.name = ghost_name
		ghost.real_name = ghost_name
		ghost.key = key
		if (ghost.client)
			ghost.client.eye = ghost
		return ..(gibbed)


/mob/living/blob/bullet_act(var/obj/item/projectile/Proj)
	for(var/i = 1, i<= Proj.mobdamage.len, i++)
		switch(i)
			if(1)
				bruteloss = Proj.mobdamage[BRUTE]
			if(2)
				fireloss = Proj.mobdamage[BURN]
	return


/mob/living/blob/blob_act()
	src << "The blob attempts to reabsorb you."
	toxloss += 10
	return


/mob/living/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node"
	set desc = "Create a Node."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/blob/B = (locate(/obj/blob) in T)
	if(!B)//We are on a blob
		usr << "There is no blob here!"
		creating_blob = 0
		return
	if(B.blobtype != "Blob")
		usr << "Unable to use this blob, find another one."
		creating_blob = 0
		return
	for(var/obj/blob/blob in orange(5))
		if(blob.blobtype == "Node")
			usr << "There is another node nearby, move away from it!"
			creating_blob = 0
			return
	B.blobdebug = 2
	spawn(0)
		B.Life()
	src.gib()
	return


/mob/living/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Defense"
	set desc = "Create a Spore producing blob."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/blob/B = (locate(/obj/blob) in T)
	if(!B)
		usr << "There is no blob here!"
		creating_blob = 0
		return
	if(B.blobtype != "Blob")
		usr << "Unable to use this blob, find another one."
		creating_blob = 0
		return
	for(var/obj/blob/blob in orange(1))//Not right next to nodes/cores
		if(blob.blobtype == "Node")
			usr << "There is a node nearby, move away from it!"
			creating_blob = 0
			return
		if(blob.blobtype == "Core")
			usr << "There is a core nearby, move away from it!"
			creating_blob = 0
			return
	B.blobdebug = 3
	spawn(0)
		B.Life()
	src.gib()
	return


///mob/proc/Blobize()
/client/proc/Blobize()//Mostly stolen from the respawn command
	set category = "Debug"
	set name = "Ghostblob"
	set desc = "Ghost into blobthing."
	set hidden = 1

	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	var/input = input(src, "Please specify which key will be turned into a bloby.", "Key", "")
	if(!input)
		return

	var/mob/dead/observer/G_found
	if(input == "Random")
		var/list/ghosts = list()
		for(var/mob/dead/observer/G in world)
			if(G.client)
				ghosts += G
		if(ghosts.len)
			G_found = pick(ghosts)

	else
		for(var/mob/dead/observer/G in world)
			if(G.client&&ckey(G.key)==ckey(input))
				G_found = G
				break

	if(!G_found)//If a ghost was not found.
		alert("There is no active key like that in the game or the person is not currently a ghost. Aborting command.")
		return

	if(G_found.client)
		G_found.client.screen.len = null
	var/mob/living/blob/B = new/mob/living/blob(locate(0,0,1))//temp area also just in case should do this better but tired
	for(var/obj/blob/core in world)
		if(core)
			if(core.blobtype == "Core")
				B.loc = core.loc
	B.ghost_name = G_found.real_name
	if (G_found.client)
		G_found.client.mob = B
	B.verbs += /mob/living/blob/verb/create_node
	B.verbs += /mob/living/blob/verb/create_factory
	B << "<B>You are now a blob fragment.</B>"
	B << "You are a weak bit that has temporarily broken off of the blob."
	B << "If you stay on the blob for too long you will likely be reabsorbed."
	B << "If you stray from the blob you will likely be killed by other organisms."
	B << "You have the power to create a new blob node that will help expand the blob."
	B << "To create this node you will have to be on a normal blob tile and far enough away from any other node."
	B << "Check your Blob verbs and hit Create Node to build a node."
	spawn(10)
		del(G_found)
