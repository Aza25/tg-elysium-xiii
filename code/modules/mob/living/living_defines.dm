/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	languages = HUMAN

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0		//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0		//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/brainloss = 0	//'Retardation' damage caused by someone hitting you in the head with a bible or being infected with brainrot.
	var/staminaloss = 0		//Stamina damage, or exhaustion. You recover it slowly naturally, and are stunned if it gets too high. Holodeck and hallucinations deal this.


	var/hallucination = 0 //Directly affects how long a mob will hallucinate for
	var/list/atom/hallucinations = list() //A list of hallucinated people that try to attack the mob. See /obj/effect/fake_attacker in hallucinations.dm


	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/now_pushing = null

	var/cameraFollow = null

	var/tod = null // Time of death

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/ventcrawler = 0 //0 No vent crawling, 1 vent crawling in the nude, 2 vent crawling always
	var/floating = 0
	var/mob_size = MOB_SIZE_HUMAN
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..
	var/list/image/staticOverlays = list()
	var/lying_pixel_offset = 0 //offset for pixel_y when the mob is lying down.
	var/has_limbs = 0 //does the mob have distinct limbs?(arms,legs, chest,head)
	var/list/datum/action/actions = list()