/*
Tiers and Requirements

Pieces of scripture require certain follower counts, contruction value, and active caches in order to recite.
Drivers: Unlocked by default
Scripts: 5 servants and a cache
Applications: 8 servants, 3 caches, and 100 CV
Revenant: 10 servants, 4 caches, and 200 CV
Judgement: 12 servants, 5 caches, 300 CV, and any existing AIs are converted or destroyed
*/

/datum/clockwork_scripture
	var/descname = "useless" //a simple name for the scripture's effect
	var/name = "scripture"
	var/desc = "Ancient Ratvarian lore. This piece seems particularly mundane."
	var/list/invocations = list() //Spoken over time in the ancient language of Ratvar. See clock_unsorted.dm for more details on the language and how to make it.
	var/channel_time = 10 //In deciseconds, how long a ritual takes to chant
	var/list/required_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0) //Components required
	var/list/consumed_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0) //Components consumed
	var/obj/item/clockwork/slab/slab //The parent clockwork slab
	var/mob/living/invoker //The slab's holder
	var/whispered = FALSE //If the invocation is whispered rather than spoken aloud
	var/usage_tip = "This piece seems to serve no purpose and is a waste of components." //A generalized tip that gives advice on a certain scripture
	var/invokers_required = 1 //How many people are required, assuming that a scripture requires multiple
	var/multiple_invokers_used = FALSE //If scripture requires more than one invoker
	var/multiple_invokers_optional = FALSE //If scripture can have multiple invokers to bolster its effects
	var/tier = SCRIPTURE_PERIPHERAL //The scripture's tier
	var/quickbind = FALSE //if this scripture can be quickbound to a clockwork slab
	var/quickbind_desc = "This shouldn't be quickbindable. File a bug report!"
	var/primary_component
	var/sort_priority = 1 //what position the scripture should have in a list of scripture. Should be based off of component costs/reqs, but you can't initial() lists.

//components the scripture used from a slab
	var/list/used_slab_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)
//components the scripture used from the global cache
	var/list/used_cache_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)

//messages for offstation scripture recital, courtesy ratvar's generals(and neovgre)
	var/static/list/neovgre_penalty = list("Go to the station.", "Useless.", "Don't waste time.", "Pathetic.", "Wasteful.")
	var/static/list/inathneq_penalty = list("Child, this is too far out!", "The barrier isn't thin enough for for me to help!", "Please, go to the station so I can assist you.", \
	"Don't waste my Cogs on this...", "There isn't enough time to linger out here!")
	var/static/list/sevtug_penalty = list("Fool! Get to the station and don't waste capacitors.", "You go this far out and expect help?", "The veil is too strong, idiot.", \
	"How does the Justicar get anything done with servants like you?", "Oh, you love wasting time, don't you?")
	var/static/list/nezbere_penalty = list("You disgrace our master's name with this endeavour.", "This is too far from the station to be a good base.", "This will take too long, friend.", \
	"The barrier isn't weakened enough to make this practical.", "Don't waste alloy.")
	var/static/list/nzcrentr_penalty = list("You'd be easy to hunt in that little hunk of metal.", "Boss says you need to get back to the beacon.", "Boss says I can kill you if you do this again.", \
	"Sending you power is too difficult here.", "Boss says stop wasting time.")

/datum/clockwork_scripture/proc/run_scripture()
	if(can_recite() && has_requirements())
		if(slab.busy)
			invoker << "<span class='warning'>[slab] refuses to work, displaying the message: \"[slab.busy]!\"</span>"
			return FALSE
		slab.busy = "Invocation ([name]) in progress"
		if(!ratvar_awakens && !slab.no_cost)
			for(var/i in consumed_components)
				if(consumed_components[i])
					for(var/j in 1 to consumed_components[i])
						if(slab.stored_components[i])
							slab.stored_components[i]--
							used_slab_components[i]++
						else
							clockwork_component_cache[i]--
							used_cache_components[i]++
		else
			channel_time *= 0.5 //if ratvar has awoken or the slab has no cost, half channel time
		if(!recital() || !check_special_requirements() || !scripture_effects()) //if we fail any of these, refund components used
			for(var/i in used_slab_components)
				if(used_slab_components[i])
					if(slab)
						slab.stored_components[i] += consumed_components[i]
					else //if we can't find a slab add to the global cache
						clockwork_component_cache[i] += consumed_components[i]
			for(var/i in used_cache_components)
				if(used_cache_components[i])
					clockwork_component_cache[i] += consumed_components[i]
		else if(slab && !slab.no_cost) //if the slab exists and isn't debug, log the scripture as being used
			feedback_add_details("clockcult_scripture_recited", name)
	if(slab)
		slab.busy = null
	qdel(src)
	return TRUE

/datum/clockwork_scripture/proc/can_recite() //If the words can be spoken
	if(!slab || !invoker)
		return FALSE
	if(!invoker.can_speak_vocal())
		invoker << "<span class='warning'>You are unable to speak the words of the scripture!</span>"
		return FALSE
	return TRUE

/datum/clockwork_scripture/proc/has_requirements() //if we have the components and invokers to do it
	var/checked_penalty = FALSE
	if(!ratvar_awakens && !slab.no_cost)
		checked_penalty = check_offstation_penalty()
		var/component_printout = "<span class='warning'>You lack the components to recite this piece of scripture!"
		var/failed = FALSE
		for(var/i in required_components)
			var/cache_components = clockwork_caches ? clockwork_component_cache[i] : 0
			var/total_components = slab.stored_components[i] + cache_components
			if(required_components[i] && total_components < required_components[i])
				component_printout += "\nYou have <span class='[get_component_span(i)]_small'><b>[total_components]/[required_components[i]]</b> \
				[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""].</span>"
				failed = TRUE
		if(failed)
			component_printout += "</span>"
			invoker << component_printout
			return FALSE
	if(multiple_invokers_used && !multiple_invokers_optional && !ratvar_awakens && !slab.no_cost)
		var/nearby_servants = 0
		for(var/mob/living/L in range(1, get_turf(invoker)))
			if(is_servant_of_ratvar(L) && L.stat == CONSCIOUS && L.can_speak_vocal())
				nearby_servants++
		if(nearby_servants < invokers_required)
			invoker << "<span class='warning'>There aren't enough non-mute servants nearby ([nearby_servants]/[invokers_required])!</span>"
			return FALSE
	if(!check_special_requirements())
		return FALSE
	if(checked_penalty && !slab.busy)
		var/message
		var/ratvarian_prob = 0
		switch(primary_component)
			if(BELLIGERENT_EYE)
				message = pick(neovgre_penalty)
				ratvarian_prob = 80
			if(VANGUARD_COGWHEEL)
				message = pick(inathneq_penalty)
				ratvarian_prob = 30
			if(GEIS_CAPACITOR)
				message = pick(sevtug_penalty)
				ratvarian_prob = 50
			if(REPLICANT_ALLOY)
				message = pick(nezbere_penalty)
				ratvarian_prob = 10
			if(HIEROPHANT_ANSIBLE)
				message = pick(nzcrentr_penalty)
				ratvarian_prob = 100
		if(message)
			if(prob(ratvarian_prob))
				message = text2ratvar(message)
			invoker << "<span class='[get_component_span(primary_component)]'>\"[message]\"</span>"
	return TRUE

/datum/clockwork_scripture/proc/check_offstation_penalty()
	var/turf/T = get_turf(invoker)
	if(!T || (T.z != ZLEVEL_STATION && T.z != ZLEVEL_CENTCOM && T.z != ZLEVEL_MINING && T.z != ZLEVEL_LAVALAND))
		channel_time *= 2
		for(var/i in consumed_components)
			if(consumed_components[i])
				consumed_components[i] *= 2
				if(required_components[i])
					required_components[i] = max(consumed_components[i], required_components[i])
		return TRUE
	return FALSE

/datum/clockwork_scripture/proc/check_special_requirements() //Special requirements for scriptures, checked multiple times during invocation
	return TRUE

/datum/clockwork_scripture/proc/recital() //The process of speaking the words
	if(!channel_time && invocations.len)
		if(multiple_invokers_used)
			for(var/mob/living/L in range(1, invoker))
				if(is_servant_of_ratvar(L) && L.stat == CONSCIOUS && L.can_speak_vocal())
					for(var/invocation in invocations)
						clockwork_say(L, text2ratvar(invocation), whispered)
		else
			for(var/invocation in invocations)
				clockwork_say(invoker, text2ratvar(invocation), whispered)
	invoker << "<span class='brass'>You [channel_time <= 0 ? "recite" : "begin reciting"] a piece of scripture entitled \"[name]\".</span>"
	if(!channel_time)
		return TRUE
	for(var/invocation in invocations)
		if(!check_special_requirements() || !do_after(invoker, channel_time / invocations.len, target = invoker) || !check_special_requirements())
			slab.busy = null
			return FALSE
		if(multiple_invokers_used)
			for(var/mob/living/L in range(1, get_turf(invoker)))
				if(is_servant_of_ratvar(L) && L.stat == CONSCIOUS && L.can_speak_vocal())
					clockwork_say(L, text2ratvar(invocation), whispered)
		else
			clockwork_say(invoker, text2ratvar(invocation), whispered)
	return TRUE

/datum/clockwork_scripture/proc/scripture_effects() //The actual effects of the recital after its conclusion


//Channeled scripture begins instantly but runs constantly
/datum/clockwork_scripture/channeled
	var/list/chant_invocations = list("AYY LMAO")
	var/chant_amount = 5 //Times the chant is spoken
	var/chant_interval = 10 //Amount of deciseconds between times the chant is actually spoken aloud

/datum/clockwork_scripture/channeled/check_offstation_penalty()
	. = ..()
	if(.)
		chant_interval *= 2

/datum/clockwork_scripture/channeled/scripture_effects()
	for(var/i in 1 to chant_amount)
		if(!can_recite())
			break
		if(!do_after(invoker, chant_interval, target = invoker))
			break
		clockwork_say(invoker, text2ratvar(pick(chant_invocations)), whispered)
		chant_effects(i)
	if(invoker && slab)
		chant_end_effects()
	return TRUE

/datum/clockwork_scripture/channeled/proc/chant_effects(chant_number) //The chant's periodic effects

/datum/clockwork_scripture/channeled/proc/chant_end_effects() //The chant's effect upon ending
	invoker << "<span class='brass'>You cease your chant.</span>"


//Creates an object at the invoker's feet
/datum/clockwork_scripture/create_object
	var/object_path = /obj/item/clockwork //The path of the object created
	var/creator_message = "<span class='brass'>You create a meme.</span>" //Shown to the invoker
	var/observer_message
	var/one_per_tile = FALSE
	var/prevent_path
	var/space_allowed = FALSE

/datum/clockwork_scripture/create_object/New()
	..()
	if(!prevent_path)
		prevent_path = object_path

/datum/clockwork_scripture/create_object/check_special_requirements()
	var/turf/T = get_turf(invoker)
	if(!space_allowed && isspaceturf(T))
		invoker << "<span class='warning'>You need solid ground to place this object!</span>"
		return FALSE
	if(one_per_tile && (locate(prevent_path) in T))
		invoker << "<span class='warning'>You can only place one of this object on each tile!</span>"
		return FALSE
	return TRUE

/datum/clockwork_scripture/create_object/scripture_effects()
	if(creator_message && observer_message)
		invoker.visible_message(observer_message, creator_message)
	else if(creator_message)
		invoker << creator_message
	new object_path (get_turf(invoker))
	return TRUE

//Uses a ranged slab ability, returning only when the ability no longer exists(ie, when interrupted) or finishes.
/datum/clockwork_scripture/ranged_ability
	var/slab_icon = "dread_ipad"
	var/ranged_type = /obj/effect/proc_holder/slab
	var/ranged_message = "This is a huge goddamn bug, how'd you cast this?"
	var/timeout_time = 0
	var/datum/progressbar/progbar

/datum/clockwork_scripture/ranged_ability/Destroy()
	qdel(progbar)
	return ..()

/datum/clockwork_scripture/ranged_ability/scripture_effects()
	slab.icon_state = slab_icon
	slab.slab_ability = new ranged_type(slab)
	slab.slab_ability.slab = slab
	slab.slab_ability.add_ranged_ability(invoker, ranged_message)
	invoker.update_inv_hands()
	var/end_time = world.time + timeout_time
	var/successful = FALSE
	if(timeout_time)
		progbar = new(invoker, timeout_time, slab)
	while(slab && slab.slab_ability && !slab.slab_ability.finished && (slab.slab_ability.in_progress || !timeout_time || world.time <= end_time))
		successful = slab.slab_ability.successful
		if(progbar)
			if(slab.slab_ability.in_progress)
				qdel(progbar)
			else
				progbar.update(end_time - world.time)
		sleep(1)
	if(slab)
		if(slab.slab_ability && !slab.slab_ability.finished)
			slab.slab_ability.remove_ranged_ability()
		slab.icon_state = "dread_ipad"
		if(invoker)
			invoker.update_inv_hands()
	return successful //slab doesn't look like a word now.
