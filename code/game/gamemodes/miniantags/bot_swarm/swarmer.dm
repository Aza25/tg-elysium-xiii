////Deactivated swarmer shell////
/obj/item/unactivated_swarmer
	name = "unactivated swarmer"
	desc = "A currently unactivated swarmer. Swarmers can self activate at any time, it would be wise to immediately dispose of this."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_unactivated"

/obj/item/unactivated_swarmer/New()
	notify_ghosts("An unactivated swarmer has been created in [get_area(src)]!", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>", source = src, attack_not_jump = 1)
	..()

/obj/item/unactivated_swarmer/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/item/unactivated_swarmer/attack_ghost(mob/user)
	var/be_swarmer = alert("Become a swarmer? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_swarmer == "No")
		return
	if(qdeleted(src))
		user << "Swarmer has been occupied by someone else."
		return
	var/mob/living/simple_animal/hostile/swarmer/S = new /mob/living/simple_animal/hostile/swarmer(get_turf(loc))
	S.key = user.key
	qdel(src)

////The Mob itself////

/mob/living/simple_animal/hostile/swarmer
	name = "Swarmer"
	unique_name = 1
	icon = 'icons/mob/swarmer.dmi'
	desc = "A robot of unknown design, they seek only to consume materials and replicate themselves indefinitely."
	speak_emote = list("tones")
	bubble_icon = "swarmer"
	health = 40
	maxHealth = 40
	status_flags = CANPUSH
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	icon_gib = null
	wander = 0
	harm_intent_damage = 5
	minbodytemp = 0
	maxbodytemp = 500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	languages = SWARMER
	environment_smash = 0
	attacktext = "shocks"
	attack_sound = 'sound/effects/EMPulse.ogg'
	friendly = "pinches"
	speed = 0
	faction = list("swarmer")
	AIStatus = AI_OFF
	pass_flags = PASSTABLE
	ventcrawler = 2
	ranged = 1
	projectiletype = /obj/item/projectile/beam/disabler
	ranged_cooldown_cap = 2
	projectilesound = 'sound/weapons/taser2.ogg'
	var/resources = 0 //Resource points, generated by consuming metal/glass

/mob/living/simple_animal/hostile/swarmer/Login()
	..()
	src << "<b>You are a swarmer, a weapon of a long dead civilization. Until further orders from your original masters are received, you must continue to consume and replicate.</b>"
	src << "<b>Ctrl + Click provides most of your swarmer specific interactions, such as cannibalizing metal or glass, destroying the environment, or teleporting mobs away from you."
	src << "<b>Objectives:</b>"
	src << "1. Consume resources and replicate until there are no more resources left."
	src << "2. Ensure that the station is fit for invasion at a later date, do not perform actions that would render it dangerous or inhospitable."
	src << "3. Biological resources will be harvested at a later date, do not harm them."

/mob/living/simple_animal/hostile/swarmer/New()
	..()
	verbs -= /mob/living/verb/pulled

/mob/living/simple_animal/hostile/swarmer/Stat()
	..()
	if(statpanel("Status"))
		stat("Resources:",resources)

/mob/living/simple_animal/hostile/swarmer/death(gibbed)
	..(gibbed)
	new /obj/effect/decal/cleanable/robot_debris(src.loc)
	new /obj/item/weapon/ore/bluespace_crystal/artificial(src.loc)
	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/swarmer/emp_act()
	if(health > 1)
		health = 1
		return
	else
		death()

/mob/living/simple_animal/hostile/swarmer/CanPass(atom/movable/O)
	if(istype(O, /obj/item/projectile/beam/disabler))//Allows for swarmers to fight as a group without wasting their shots hitting each other
		return 1
	if(isswarmer(O))
		return 1
	..()

////CTRL CLICK FOR SWARMERS AND SWARMER_ACT()'S////
/mob/living/simple_animal/hostile/swarmer/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return
	A.swarmer_act(src)
	return

/atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/item/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.Integrate(src)

/obj/item/weapon/gun/swarmer_act()//Stops you from eating the entire armory
	return

/turf/floor/swarmer_act()//ex_act() on turf calls it on its contents, this is to prevent attacking mobs by DisIntegrate()'ing the floor
	return

/obj/machinery/atmospherics/swarmer_act()
	return

/obj/structure/disposalpipe/swarmer_act()
	return

/obj/machinery/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DismantleMachine(src)

/obj/machinery/light/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/door/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/camera/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)
	toggle_cam(S, 0)

/obj/machinery/particle_accelerator/control_box/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/field/generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/gravity_generator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/vending/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//It's more visually interesting than dismantling the machine
	S.DisIntegrate(src)

/obj/machinery/turretid/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisIntegrate(src)

/obj/machinery/chem_dispenser/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>The volatile chemicals in this machine would destroy us. Aborting.</span>"

/obj/machinery/nuclearbomb/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This device's destruction would result in the extermination of everything in the area. Aborting.</span>"

/obj/machinery/dominator/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This device is attempting to corrupt our entire network; attempting to interact with it is too risky. Aborting.</span>"

/obj/effect/decal/cleanable/crayon/gang/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Searching... sensor malfunction! Target lost. Aborting.</span>"

/obj/effect/rune/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Searching... sensor malfunction! Target lost. Aborting.</span>"

/obj/structure/reagent_dispensers/fueltank/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Destroying this object would cause a chain reaction. Aborting.</span>"

/obj/structure/cable/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>"

/obj/machinery/portable_atmospherics/canister/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>An inhospitable area may be created as a result of destroying this object. Aborting.</span>"

/obj/machinery/telecomms/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This communications relay should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>"

/obj/machinery/message_server/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This communications relay should be preserved, it will be a useful resource to our masters in the future. Aborting.</span>"

/obj/machinery/blackbox_recorder/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This machine has recorded large amounts of data on this structure and its inhabitants, it will be a useful resource to our masters in the future. Aborting. </span>"

/obj/machinery/power/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Disrupting the power grid would bring no benefit to us. Aborting.</span>"

/obj/machinery/gateway/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This bluespace source will be important to us later. Aborting.</span>"

/turf/wall/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	for(var/turf/T in range(1, src))
		if(istype(T, /turf/space) || istype(T.loc, /area/space))
			S << "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>"
			return
	..()

/obj/structure/window/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	for(var/turf/T in range(1, src))
		if(istype(T, /turf/space) || istype(T.loc, /area/space))
			S << "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>"
			return
	..()

/obj/item/stack/cable_coil/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)//Wiring would be too effective as a resource
	S << "<span class='warning'>This object does not contain enough materials to work with.</span>"

/obj/machinery/porta_turret/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>Attempting to dismantle this machine would result in an immediate counterattack. Aborting.</span>"

/mob/living/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S.DisperseTarget(src)

/mob/living/simple_animal/slime/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This biological resource is somehow resisting our bluespace transceiver. Aborting.</span>"

/obj/machinery/droneDispenser/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	S << "<span class='warning'>This object is receiving unactivated swarmer shells to help us. Aborting.</span>"


////END CTRL CLICK FOR SWARMERS////

/mob/living/simple_animal/hostile/swarmer/proc/Fabricate(var/atom/fabrication_object,var/fabrication_cost = 0)
	if(!isturf(loc))
		src << "<span class='warning'>This is not a suitable location for fabrication. We need more space.</span>"
	if(resources >= fabrication_cost)
		resources -= fabrication_cost
	else
		src << "<span class='warning'>You do not have the necessary resources to fabricate this object.</span>"
		return 0
	new fabrication_object(loc)
	return 1

/mob/living/simple_animal/hostile/swarmer/proc/Integrate(var/obj/item/target)
	if(resources >= 100)
		src << "<span class='warning'>We cannot hold more materials!</span>"
		return
	if((target.materials[MAT_METAL]) || (target.materials[MAT_GLASS]))
		resources++
		do_attack_animation(target)
		changeNext_move(CLICK_CD_MELEE)
		var/obj/effect/overlay/temp/swarmer/integrate/I = PoolOrNew(/obj/effect/overlay/temp/swarmer/integrate, get_turf(target))
		I.pixel_x = target.pixel_x
		I.pixel_y = target.pixel_y
		I.pixel_z = target.pixel_z
		if(istype(target, /obj/item/stack))
			var/obj/item/stack/S = target
			S.use(1)
			if(S.amount)
				return
		qdel(target)
	else
		src << "<span class='warning'>\the [target] is incompatible with our internal matter recycler.</span>"
		return

/mob/living/simple_animal/hostile/swarmer/proc/DisIntegrate(var/atom/movable/target)
	PoolOrNew(/obj/effect/overlay/temp/swarmer/disintegration, get_turf(target))
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)
	target.ex_act(3)
	return

/mob/living/simple_animal/hostile/swarmer/proc/DisperseTarget(var/mob/living/target)
	if(target != src)
		src << "<span class='info'>Attempting to remove this being from our presence.</span>"
		if(src.z != ZLEVEL_STATION)
			src << "<span class='warning'>Our bluespace transceiver cannot locate a viable bluespace link, our teleportation abilities are useless in this area.</span>"
			return
		if(do_mob(src, target, 30))
			var/cycle
			for(cycle=0,cycle<100,cycle++)
				var/random_location = locate(rand(37,202),rand(75,192),ZLEVEL_STATION)//Drunk dial a turf in the general ballpark of the station
				if(istype(random_location, /turf/floor))
					var/turf/floor/F = random_location
					if(F.air)
						var/datum/gas_mixture/A = F.air
						var/list/A_gases = A.gases
						var/trace_gases
						for(var/id in A_gases)
							if(id in hardcoded_gases)
								continue
							trace_gases = TRUE
							break
						if((A_gases["o2"] && A_gases["o2"][MOLES] >= 16) && !A_gases["plasma"] && (!A_gases["co2"] || A_gases["co2"][MOLES] < 10) && !trace_gases)//Can most things breathe in this location?
							if((A.temperature > 270) && (A.temperature < 360))//Not too hot, not too cold
								var/pressure = A.return_pressure()
								if((pressure > 20) && (pressure < 550))//Account for crushing pressure or vaccuums
									if(ishuman(target))//If we're getting rid of a human, slap some zipties on them to keep them away from us a little longer
										var/obj/item/weapon/restraints/handcuffs/cable/zipties/Z = new /obj/item/weapon/restraints/handcuffs/cable/zipties(src)
										var/mob/living/carbon/human/H = target
										Z.apply_cuffs(H, src)
									do_teleport(target, F, 0)
									playsound(src,'sound/effects/sparks4.ogg',50,1)
									break
			return

/mob/living/simple_animal/hostile/swarmer/proc/DismantleMachine(var/obj/machinery/target)
	do_attack_animation(target)
	src << "<span class='info'>We begin to dismantle this machine. We will need to be uninterrupted.</span>"
	var/obj/effect/overlay/temp/swarmer/dismantle/D = PoolOrNew(/obj/effect/overlay/temp/swarmer/dismantle, get_turf(target))
	D.pixel_x = target.pixel_x
	D.pixel_y = target.pixel_y
	D.pixel_z = target.pixel_z
	if(do_mob(src, target, 100))
		src << "<span class='info'>Dismantling complete.</span>"
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(target.loc)
		M.amount = 5
		for(var/obj/item/I in target.component_parts)
			I.loc = M.loc
		var/obj/effect/overlay/temp/swarmer/disintegration/N = PoolOrNew(/obj/effect/overlay/temp/swarmer/disintegration, get_turf(target))
		N.pixel_x = target.pixel_x
		N.pixel_y = target.pixel_y
		N.pixel_z = target.pixel_z
		target.dropContents()
		if(istype(target, /obj/machinery/computer))
			var/obj/machinery/computer/C = target
			if(C.circuit)
				C.circuit.loc = M.loc
		qdel(target)


/obj/effect/swarmer //Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	gender = NEUTER
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "ui_light"
	mouse_opacity = 0
	layer = MOB_LAYER
	unacidable = 1

/obj/effect/overlay/temp/swarmer //temporary swarmer visual feedback objects
	icon = 'icons/mob/swarmer.dmi'
	layer = MOB_LAYER

/obj/effect/overlay/temp/swarmer/disintegration
	icon_state = "disintegrate"
	duration = 10

/obj/effect/overlay/temp/swarmer/disintegration/New()
	playsound(src.loc, "sparks", 100, 1)
	..()

/obj/effect/overlay/temp/swarmer/dismantle
	icon_state = "dismantle"
	duration = 25

/obj/effect/overlay/temp/swarmer/integrate
	icon_state = "integrate"
	duration = 5

/obj/effect/swarmer/destructible //Default destroyable object for swarmer constructions
	luminosity = 1
	mouse_opacity = 1
	var/health = 30

/obj/effect/swarmer/destructible/proc/TakeDamage(damage)
	health -= damage
	if(health <= 0)
		qdel(src)

/obj/effect/swarmer/destructible/bullet_act(obj/item/projectile/Proj)
	if(Proj.damage)
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			TakeDamage(Proj.damage)
	..()

/obj/effect/swarmer/destructible/attackby(obj/item/weapon/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon))
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		TakeDamage(I.force)
	return

/obj/effect/swarmer/destructible/ex_act()
	qdel(src)
	return

/obj/effect/swarmer/destructible/blob_act()
	qdel(src)
	return

/obj/effect/swarmer/destructible/emp_act()
	qdel(src)
	return

/obj/effect/swarmer/destructible/attack_animal(mob/living/user)
	if(isanimal(user))
		var/mob/living/simple_animal/S = user
		S.do_attack_animation(src)
		user.changeNext_move(CLICK_CD_MELEE)
		if(S.melee_damage_type == BRUTE || S.melee_damage_type == BURN)
			TakeDamage(rand(S.melee_damage_lower, S.melee_damage_upper))
	return

/mob/living/simple_animal/hostile/swarmer/proc/CreateTrap()
	set name = "Create trap"
	set category = "Swarmer"
	set desc = "Creates a simple trap that will non-lethally electrocute anything that steps on it. Costs 5 resources"
	if(/obj/effect/swarmer/destructible/trap in loc)
		src << "<span class='warning'>There is already a trap here. Aborting.</span>"
		return
	Fabricate(/obj/effect/swarmer/destructible/trap, 5)
	return

/obj/effect/swarmer/destructible/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	luminosity = 1
	health = 10

/obj/effect/swarmer/destructible/trap/Crossed(var/atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/simple_animal/hostile/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, 1, -1)
			L.electrocute_act(0, src, 1, 1)
			if(isrobot(L))
				L.Weaken(5)
			qdel(src)
	..()

/mob/living/simple_animal/hostile/swarmer/proc/CreateBarricade()
	set name = "Create barricade"
	set category = "Swarmer"
	set desc = "Creates a barricade that will stop anything but swarmers and disabler beams from passing through."
	if(/obj/effect/swarmer/destructible/blockade in loc)
		src << "<span class='warning'>There is already a blockade here. Aborting.</span>"
		return
	if(resources < 5)
		src << "<span class='warning'>We do not have the resources for this!</span>"
		return
	if(do_mob(src, src, 10))
		Fabricate(/obj/effect/swarmer/destructible/blockade, 5)
	return

/obj/effect/swarmer/destructible/blockade
	name = "swarmer blockade"
	desc = "A quickly assembled energy blockade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	icon_state = "barricade"
	luminosity = 1
	health = 50
	density = 1
	anchored = 1

/obj/effect/swarmer/destructible/blockade/CanPass(atom/movable/O)
	if(isswarmer(O))
		return 1
	if(istype(O, /obj/item/projectile/beam/disabler))
		return 1

/mob/living/simple_animal/hostile/swarmer/proc/CreateSwarmer()
	set name = "Replicate"
	set category = "Swarmer"
	set desc = "Creates a shell for a new swarmer. Swarmers will self activate."
	src << "<span class='info'>We are attempting to replicate ourselves. We will need to stand still until the process is complete.</span>"
	if(resources < 50)
		src << "<span class='warning'>We do not have the resources for this!</span>"
		return
	if(!isturf(loc))
		src << "<span class='warning'>This is not a suitable location for replicating ourselves. We need more room.</span>"
		return
	if(do_mob(src, src, 100))
		if(Fabricate(/obj/item/unactivated_swarmer, 50))
			playsound(loc,'sound/items/poster_being_created.ogg',50, 1, -1)

/mob/living/simple_animal/hostile/swarmer/proc/RepairSelf()
	set name = "Self Repair"
	set category = "Swarmer"
	set desc = "Attempts to repair damage to our body. You will have to remain motionless until repairs are complete."
	if(!isturf(loc))
		return
	src << "<span class='info'>Attempting to repair damage to our body, stand by...</span>"
	if(do_mob(src, src, 100))
		adjustHealth(-100)
		src << "<span class='info'>We successfully repaired ourselves.</span>"

/mob/living/simple_animal/hostile/swarmer/proc/ToggleLight()
	if(!luminosity)
		SetLuminosity(3)
	else
		SetLuminosity(0)

/mob/living/simple_animal/hostile/swarmer/proc/ContactSwarmers()
	var/message = input(src, "Announce to other swarmers", "Swarmer contact")
	var/rendered = "<B>Swarm communication - </b> [src] states: [message]"
	if(message)
		for(var/mob/M in mob_list)
			if(isswarmer(M))
				M << rendered
			if(M in dead_mob_list)
				M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [rendered]"

