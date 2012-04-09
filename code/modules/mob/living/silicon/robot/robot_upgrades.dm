// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade/
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'module.dmi'
	icon_state = "id_mod"
	var/construction_time = 120
	var/construction_cost = list("metal"=10000)
	var/locked = 0

/obj/item/borg/upgrade/proc/action()
	return


/obj/item/borg/upgrade/reset/
	name = "Borg module reset board"
	desc = "Used to reset a borg's module. Destroys any other upgrades applied to the borg."

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	R.uneq_all()
	R.hands.icon_state = "nomod"
	R.icon_state = "robot"
	del(R.module)
	R.module = null
	R.modtype = "robot"
	R.real_name = "Cyborg [R.ident]"
	R.name = R.real_name
	R.nopush = 0
	R.updateicon()
	return



/obj/item/borg/upgrade/flashproof/
	name = "Borg Flash-Supression"
	desc = "A highly advanced, complicated system for supressing incoming flashes directed at the borg's optical processing system."
	construction_cost = list("metal"=10000,"gold"=2000,"silver"=3000,"glass"=2000, "diamond"=5000)


/obj/item/borg/upgrade/flashproof/New()   // Why the fuck does the fabricator make a new instance of all the items?
	//desc = "Sunglasses with duct tape." // Why?  D:

/obj/item/borg/upgrade/flashproof/action(var/mob/living/silicon/robot/R)
	if(R.module)
		R.module += src
