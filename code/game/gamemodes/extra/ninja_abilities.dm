/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++//                    \\++++++++++++++++++++++++++++++++++
==================================SPACE NINJA ABILITIES====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*X is optional, tells the proc to check for specific stuff. C is also optional.
All the procs here assume that the character is wearing the ninja suit if they are using the procs.
They should, as I have made every effort for that to be the case.
In the case that they are not, I imagine the game will run-time error like crazy.
*/

//Cooldown ticks off each second based on the suit recharge proc, in seconds. Default of 1 seconds. Some abilities have no cool down.
/mob/proc/ninjacost(var/C = 0,var/X = 0)
	var/mob/living/carbon/human/U = src
	var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
	if( (U.stat||U.incorporeal_move)&&X!=3 )//Will not return if user is using an adrenaline booster since you can use them when stat==1.
		U << "\red You must be conscious and solid to do this."//It's not a problem of stat==2 since the ninja will explode anyway if they die.
		return 1
	else if(C&&S.cell.charge<C*10)
		U << "\red Not enough energy."
		return 1
	switch(X)
		if(1)
			if(S.active)
				U << "\red You must deactivate the CLOAK-tech device prior to using this ability."
				return 1
		if(2)
			if(S.sbombs<=0)
				U << "\red There are no more smoke bombs remaining."
				return 1
		if(3)
			if(S.aboost<=0)
				U << "\red You do not have any more adrenaline boosters."
				return 1
	return (S.coold)//Returns the value of the variable which counts down to zero.

//Smoke
//Summons smoke in radius of user.
//Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.
/mob/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja Ability"

	if(!ninjacost(,2))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		S.sbombs--
		src << "\blue There are <B>[S.sbombs]</B> smoke bombs remaining."
		var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
		smoke.set_up(10, 0, loc)
		smoke.start()
		playsound(loc, 'bamf.ogg', 50, 2)
		S.coold = 1
	return

//9-10 Tile Teleport
//Click to to teleport 9-10 tiles in direction facing.
/mob/proc/ninjajaunt()
	set name = "Phase Jaunt (10E)"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit in direction facing."
	set category = "Ninja Ability"

	var/C = 100
	if(!ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/list/turfs = new/list()
		var/turf/picked
		var/turf/mobloc = get_turf(loc)
		var/safety = 0
		var/locx
		var/locy
		switch(dir)//Gets rectengular range for target.
			if(NORTH)
				locx = mobloc.x
				locy = (mobloc.y+9)
				for(var/turf/T in block(locate(locx-3,locy-1,loc.z), locate(locx+3,locy+1,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(SOUTH)
				locx = mobloc.x
				locy = (mobloc.y-9)
				for(var/turf/T in block(locate(locx-3,locy-1,loc.z), locate(locx+3,locy+1,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(EAST)
				locy = mobloc.y
				locx = (mobloc.x+9)
				for(var/turf/T in block(locate(locx-1,locy-3,loc.z), locate(locx+1,locy+3,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			if(WEST)
				locy = mobloc.y
				locx = (mobloc.x-9)
				for(var/turf/T in block(locate(locx-1,locy-3,loc.z), locate(locx+1,locy+3,loc.z) ))
					if(T.density)	continue
					if(T.x>world.maxx || T.x<1)	continue
					if(T.y>world.maxy || T.y<1)	continue
					turfs += T
			else	safety = 1

		if(turfs.len&&!safety)//Cancels the teleportation if no valid turf is found. Usually when teleporting near map edge.
			picked = pick(turfs)
			spawn(0)
				playsound(loc, "sparks", 50, 1)
				anim(mobloc,src,'mob.dmi',,"phaseout")

			if(istype(get_active_hand(),/obj/item/weapon/grab))//Handles grabbed persons.
				var/obj/item/weapon/grab/G = get_active_hand()
				G.affecting.loc = locate(picked.x+rand(-1,1),picked.y+rand(-1,1),picked.z)//variation of position.
			if(istype(get_inactive_hand(),/obj/item/weapon/grab))
				var/obj/item/weapon/grab/G = get_inactive_hand()
				G.affecting.loc = locate(picked.x+rand(-1,1),picked.y+rand(-1,1),picked.z)//variation of position.
			loc = picked

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, "sparks", 50, 1)
				anim(loc,src,'mob.dmi',,"phasein")

			spawn(0)//Any living mobs in teleport area are gibbed. Added some more types.
				for(var/mob/living/M in picked)
					if(M==src)	continue
					spawn(0)
						M.gib()
				for(var/obj/mecha/M in picked)
					spawn(0)
						M.take_damage(100, "brute")
				for(var/obj/alien/facehugger/M in picked)//These really need to be mobs.
					spawn(0)
						M.death()
				for(var/obj/livestock/M in picked)
					spawn(0)
						M.gib()
			S.coold = 1
			S.cell.charge-=(C*10)
		else
			src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
	return

//Right Click Teleport
//Right click to teleport somewhere, almost exactly like admin jump to turf.
/mob/proc/ninjashift(var/turf/T in oview())
	set name = "Phase Shift (20E)"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit to a destination in view."
	set category = null//So it does not show up on the panel but can still be right-clicked.

	var/C = 200
	if(!ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		if(!T.density)
			var/turf/mobloc = get_turf(loc)
			spawn(0)
				playsound(loc, 'sparks4.ogg', 50, 1)
				anim(mobloc,src,'mob.dmi',,"phaseout")

			if(istype(get_active_hand(),/obj/item/weapon/grab))//Handles grabbed persons.
				var/obj/item/weapon/grab/G = get_active_hand()
				G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
			if(istype(get_inactive_hand(),/obj/item/weapon/grab))
				var/obj/item/weapon/grab/G = get_inactive_hand()
				G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
			loc = T

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, 'sparks2.ogg', 50, 1)
				anim(loc,src,'mob.dmi',,"phasein")

			spawn(0)//Any living mobs in teleport area are gibbed.
				for(var/mob/living/M in T)
					if(M==src)	continue
					spawn(0)
						M.gib()
				for(var/obj/mecha/M in T)
					spawn(0)
						M.take_damage(100, "brute")
				for(var/obj/alien/facehugger/M in T)//These really need to be mobs.
					spawn(0)
						M.death()
				for(var/obj/livestock/M in T)
					spawn(0)
						M.gib()
			S.coold = 1
			S.cell.charge-=(C*10)
		else
			src << "\red You cannot teleport into solid walls."
	return

//EMP Pulse
//Disables nearby tech equipment.
/mob/proc/ninjapulse()
	set name = "EM Burst (25E)"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja Ability"

	var/C = 250
	if(!ninjacost(C,1))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		playsound(loc, 'EMPulse.ogg', 60, 2)
		empulse(src, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		S.coold = 2
		S.cell.charge-=(C*10)
	return

//Summon Energy Blade
//Summons a blade of energy in active hand.
/mob/proc/ninjablade()
	set name = "Energy Blade (5E)"
	set desc = "Create a focused beam of energy in your active hand."
	set category = "Ninja Ability"

	var/C = 50
	if(!ninjacost(C))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		if(!S.kamikaze)
			if(!get_active_hand()&&!istype(get_inactive_hand(), /obj/item/weapon/blade))
				var/obj/item/weapon/blade/W = new()
				W.spark_system.start()
				playsound(loc, "sparks", 50, 1)
				put_in_hand(W)
				S.cell.charge-=(C*10)
			else
				src << "\red You can only summon one blade. Try dropping an item first."
		else//Else you can run around with TWO energy blades. I don't know why you'd want to but cool factor remains.
			if(!get_active_hand())
				var/obj/item/weapon/blade/W = new()
				put_in_hand(W)
			if(!get_inactive_hand())
				var/obj/item/weapon/blade/W = new()
				put_in_inactive_hand(W)
			S.spark_system.start()
			playsound(loc, "sparks", 50, 1)
			S.coold = 1
	return

//Shoot Ninja Stars
//Shoots ninja stars at random people.
//This could be a lot better but I'm too tired atm.
/mob/proc/ninjastar()
	set name = "Energy Star (3E)"
	set desc = "Launches an energy star at a random living target."
	set category = "Ninja Ability"

	var/C = 30
	if(!ninjacost(C))
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/targets[]//So yo can shoot while yo throw dawg
		targets = new()
		for(var/mob/living/M in oview(7))
			if(M.stat==2)	continue//Doesn't target corpses.
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.

			var/turf/curloc = loc
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || !curloc)
				return
			if (targloc == curloc)
				return
			var/obj/bullet/neurodart/A = new /obj/bullet/neurodart(loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			S.cell.charge-=(C*10)
			A.process()
		else
			src << "\red There are no targets in view."
	return

//Energy Net
//Allows the ninja to capture people, I guess.
//Must right click on a mob to activate.
/mob/proc/ninjanet(var/mob/living/carbon/M in oview())//Only living carbon mobs.
	set name = "Energy Net"
	set desc = "Captures a fallen opponent in a net of energy. Will teleport them to a holding facility after 30 seconds."
	set category = null

	var/C = 200
	if(!ninjacost(C))
		if(!locate(/obj/effects/energy_net) in M.loc.contents)//Check if they are already being affected by an energy net.
			if(M.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
				for(var/turf/T in getline(loc, M.loc))
					if(T==loc||T==M.loc)	continue
					spawn(0)
						anim(T,M,'projectiles.dmi',"energy",,,get_dir_to(loc,M.loc))
				var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
				M.anchored = 1//Anchors them so they can't move.
				say("Get over here!")
				var/obj/effects/energy_net/E = new /obj/effects/energy_net(M.loc)
				E.layer = M.layer+1//To have it appear one layer above the mob.
				for(var/mob/O in viewers(src, 3))
					O.show_message(text("\red [] caught [] with an energy net!", src, M), 1)
				E.affecting = M
				E.master = src
				spawn(0)//Parallel processing.
					E.process(M)
				S.cell.charge-=(C*10)
			else
				src << "They will bring no honor to your Clan!"
	return

//Adrenaline Boost
//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.
/mob/proc/ninjaboost()
	set name = "Adrenaline Boost"
	set desc = "Inject a secret chemical that will counteract all movement-impairing effects."
	set category = "Ninja Ability"

	if(!ninjacost(,3))//Have to make sure stat is not counted for this ability.
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		//Wouldn't need to track adrenaline boosters if there was a miracle injection to get rid of paralysis and the like instantly.
		//For now, adrenaline boosters ARE the miracle injection. Well, radium, really.
		paralysis = 0
		stunned = 0
		weakened = 0
		spawn(30)
			say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))
		spawn(70)
			S.reagents.reaction(src, 2)
			S.reagents.trans_id_to(src, "radium", S.transfera)
			src << "\red You are beginning to feel the after-effects of the injection."
		S.aboost--
		S.coold = 3
	return


//KAMIKAZE=============================
//Or otherwise known as anime mode. Which also happens to be ridiculously powerful.

//Allows for incorporeal movement.
//Also makes you move like you're on crack.
/mob/proc/ninjawalk()
	set name = "Shadow Walk"
	set desc = "Combines the VOID-shift and CLOAK-tech devices to freely move between solid matter. Toggle on or off."
	set category = "Ninja Ability"

	if(!usr.incorporeal_move)
		incorporeal_move = 2
		density = 0
		src << "\blue You will now phase through solid matter."
	else
		incorporeal_move = 0
		density = 1
		src << "\blue You will no-longer phase through solid matter."
	return

/*
Allows to gib up to five squares in a straight line. Seriously.*/
/mob/proc/ninjaslayer()
	set name = "Phase Slayer"
	set desc = "Utilizes the internal VOID-shift device to mutilate creatures in a straight line."
	set category = "Ninja Ability"

	if(!ninjacost())
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/locx
		var/locy
		var/turf/mobloc = get_turf(loc)
		var/safety = 0

		switch(dir)
			if(NORTH)
				locx = mobloc.x
				locy = (mobloc.y+5)
				if(locy>world.maxy)
					safety = 1
			if(SOUTH)
				locx = mobloc.x
				locy = (mobloc.y-5)
				if(locy<1)
					safety = 1
			if(EAST)
				locy = mobloc.y
				locx = (mobloc.x+5)
				if(locx>world.maxx)
					safety = 1
			if(WEST)
				locy = mobloc.y
				locx = (mobloc.x-5)
				if(locx<1)
					safety = 1
			else	safety = 1
		if(!safety)//Cancels the teleportation if no valid turf is found. Usually when teleporting near map edge.
			say("Ai Satsugai!")
			var/turf/picked = locate(locx,locy,mobloc.z)
			spawn(0)
				playsound(loc, "sparks", 50, 1)
				anim(mobloc,src,'mob.dmi',,"phaseout")

			spawn(0)
				for(var/turf/T in getline(mobloc, picked))
					spawn(0)
						for(var/mob/living/M in T)
							if(M==src)	continue
							spawn(0)
								M.gib()
						for(var/obj/mecha/M in T)
							spawn(0)
								M.take_damage(100, "brute")
						for(var/obj/alien/facehugger/M in T)//These really need to be mobs.
							spawn(0)
								M.death()
						for(var/obj/livestock/M in T)
							spawn(0)
								M.gib()
					if(T==mobloc||T==picked)	continue
					spawn(0)
						anim(T,src,'mob.dmi',,"phasein")

			loc = picked

			spawn(0)
				S.spark_system.start()
				playsound(loc, 'Deconstruct.ogg', 50, 1)
				playsound(loc, "sparks", 50, 1)
				anim(loc,src,'mob.dmi',,"phasein")
			S.coold = 1
		else
			src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
	return

//Appear behind a randomly chosen mob while a few decoy teleports appear.
//This is so anime it hurts. But that's the point.
/mob/proc/ninjamirage()
	set name = "Spider Mirage"
	set desc = "Utilizes the internal VOID-shift device to create decoys and teleport behind a random target."
	set category = "Ninja Ability"

	if(!ninjacost())//Simply checks for stat.
		var/obj/item/clothing/suit/space/space_ninja/S = src:wear_suit
		var/targets[]
		targets = new()
		for(var/mob/living/M in oview(6))
			if(M.stat==2)	continue//Doesn't target corpses.
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)
			var/locx
			var/locy
			var/turf/mobloc = get_turf(target.loc)
			var/safety = 0
			switch(target.dir)
				if(NORTH)
					locx = mobloc.x
					locy = (mobloc.y-1)
					if(locy<1)
						safety = 1
				if(SOUTH)
					locx = mobloc.x
					locy = (mobloc.y+1)
					if(locy>world.maxy)
						safety = 1
				if(EAST)
					locy = mobloc.y
					locx = (mobloc.x-1)
					if(locx<1)
						safety = 1
				if(WEST)
					locy = mobloc.y
					locx = (mobloc.x+1)
					if(locx>world.maxx)
						safety = 1
				else	safety=1

			if(!safety)
				say("Kumo no Shinkiro!")
				var/turf/picked = locate(locx,locy,mobloc.z)
				spawn(0)
					playsound(loc, "sparks", 50, 1)
					anim(mobloc,src,'mob.dmi',,"phaseout")

				spawn(0)
					var/limit = 4
					for(var/turf/T in oview(5))
						if(prob(20))
							spawn(0)
								anim(T,src,'mob.dmi',,"phasein")
							limit--
						if(limit<=0)	break

				loc = picked
				dir = target.dir

				spawn(0)
					S.spark_system.start()
					playsound(loc, 'Deconstruct.ogg', 50, 1)
					playsound(loc, "sparks", 50, 1)
					anim(loc,src,'mob.dmi',,"phasein")
				S.coold = 1
			else
				src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
		else
			src << "\red There are no targets in view."
	return