/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Only one AI may project from a holopad at any given time.
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

// HOLOPAD MODE
// 0 = RANGE BASED
// 1 = AREA BASED
var/const/HOLOPAD_MODE = 0

/obj/machinery/hologram/holopad
	name = "\improper AI holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	var/list/masters = list()//List of AIs that use the holopad
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.

/obj/machinery/hologram/holopad/attack_hand(var/mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return
	if(alert(user,"Would you like to request an AI's presence?",,"Yes","No") == "Yes")
		if(last_request + 200 < world.time) //don't spam the AI with requests you jerk!
			last_request = world.time
			user << "<span class='notice'>You request an AI's presence.</span>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in living_mob_list)
				if(!AI.client)	continue
				AI << "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=\ref[src]'>\the [area]</a>.</span>"
		else
			user << "<span class='notice'>A request for AI presence was already sent recently.</span>"

/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)
	return

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/silicon/ai/user)
	if(!(stat & NOPOWER) && user.eyeobj.loc == src.loc)//If the projector has power and client eye is on it.
		if (istype(user.current, /obj/machinery/hologram/holopad))
//			var/obj/machinery/hologram/holopad/H = user.current
//			if(H.masters[user])//If there is already a hologram.
			user << "\red ERROR: \black Image feed in progress."
			return
		create_holo(user)//Create one.
		src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
	else
		user << "\red ERROR: \black Unable to project hologram."
	return

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/hear_talk(mob/living/M, text)
	if(M && masters.len)//Master is mostly a safety in case lag hits or something.
		for (var/mob/living/silicon/ai/master in masters)
			if(!master.say_understands(M))//The AI will be able to understand most mobs talking through the holopad.
				text = stars(text)
			var/name_used = M.GetVoice()
			//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
			var/rendered = "<i><span class='game say'>Holopad received, <span class='name'>[name_used]</span> <span class='message'>[M.say_quote(text)]</span></span></i>"
			master.show_message(rendered, 2)
	return

/obj/machinery/hologram/holopad/proc/create_holo(mob/living/silicon/ai/A, turf/T = loc)
	var/obj/effect/overlay/h = new(T)//Spawn a blank effect at the location.
	h.icon = A.holo_icon
	h.mouse_opacity = 0//So you can't click on it.
	h.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	h.anchored = 1//So space wind cannot drag it.
	h.name = "[A.name] (Hologram)"//If someone decides to right click.
	h.SetLuminosity(2)	//hologram lighting
	masters[A] = h
	SetLuminosity(2)			//pad lighting
	icon_state = "holopad1"
	A.current = src
	use_power = 2//Active power usage.
	return 1

/obj/machinery/hologram/holopad/proc/clear_holo(mob/living/silicon/ai/user)
//	hologram.SetLuminosity(0)//Clear lighting.	//handled by the lighting controller when its ower is deleted
	if(user.current == src)
		user.current = null
	qdel(masters[user])//Get rid of user's hologram
	masters -= user //Discard AI from the list of those who use holopad
	if (!masters.len)//If no users left
		SetLuminosity(0)			//pad lighting (hologram lighting will be handled automatically since its owner was deleted)
		icon_state = "holopad0"
		use_power = 1//Passive power usage.
	return 1

/obj/machinery/hologram/holopad/process()
	if(masters.len)//If there is a hologram.
		for (var/mob/living/silicon/ai/master in masters)
			if(master && !master.stat && master.client && master.eyeobj)//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
				if(!(stat & NOPOWER))//If the  machine has power.
					if((HOLOPAD_MODE == 0 && (get_dist(master.eyeobj, src) <= holo_range)))
						return 1

					else if (HOLOPAD_MODE == 1)

						var/area/holo_area = get_area(src)
						var/area/eye_area = get_area(master.eyeobj)

						if(eye_area in holo_area.master.related)
							return 1

			clear_holo(master)//If not, we want to get rid of the hologram.
	return 1

/obj/machinery/hologram/holopad/proc/move_hologram(mob/living/silicon/ai/user)
	if(masters[user])
		step_to(masters[user], user.eyeobj) // So it turns.
		var/obj/machinery/hologram/holopad/H = masters[user]
		H.loc = get_turf(user.eyeobj)
		masters[user] = H
	return 1

/*
 * Hologram
 */

/obj/machinery/hologram
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
//	var/obj/effect/overlay/hologram//The projection itself. If there is one, the instrument is on, off otherwise.

/obj/machinery/hologram/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= ~NOPOWER

//Destruction procs.
/obj/machinery/hologram/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/machinery/hologram/blob_act()
	qdel(src)
	return

/obj/machinery/hologram/holopad/Destroy()
	for (var/mob/living/silicon/ai/master in masters)
		clear_holo(master)
	..()

/*
Holographic project of everything else.

/mob/verb/hologram_test()
	set name = "Hologram Debug New"
	set category = "CURRENT DEBUG"

	var/obj/effect/overlay/hologram = new(loc)//Spawn a blank effect at the location.
	var/icon/flat_icon = icon(getFlatIcon(src,0))//Need to make sure it's a new icon so the old one is not reused.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/input = input("Select what icon state to use in effect.",,"")
	if(input)
		var/icon/alpha_mask = new('icons/effects/effects.dmi', "[input]")
		flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
		hologram.icon = flat_icon

		world << "Your icon should appear now."
	return
*/

/*
 * Other Stuff: Is this even used?
 */
/obj/machinery/hologram/projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hologram0"