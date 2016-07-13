
#define BEE_IDLE_ROAMING		70 //The value of idle at which a bee in a beebox will try to wander
#define BEE_IDLE_GOHOME			0  //The value of idle at which a bee will try to go home
#define BEE_PROB_GOHOME			35 //Probability to go home when idle is below BEE_IDLE_GOHOME
#define BEE_PROB_GOROAM			5 //Probability to go roaming when idle is above BEE_IDLE_ROAMING
#define BEE_TRAY_RECENT_VISIT	200	//How long in deciseconds until a tray can be visited by a bee again
#define BEE_DEFAULT_COLOUR		"#e5e500" //the colour we make the stripes of the bee if our reagent has no colour (or we have no reagent)

#define BEE_POLLINATE_YIELD_CHANCE		10
#define BEE_POLLINATE_PEST_CHANCE		33
#define BEE_POLLINATE_POTENTCY_CHANCE	50

/mob/living/simple_animal/hostile/poison/bees
	name = "bee"
	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
	icon_state = ""
	icon_living = ""
	icon = 'icons/mob/bees.dmi'
	speak_emote = list("buzzes")
	emote_hear = list("buzzes")
	turns_per_move = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attacktext = "stings"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 10
	health = 10
	faction = list("hostile")
	move_to_delay = 0
	environment_smash = 0
	mouse_opacity = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	flying = 1
	gold_core_spawnable = 1
	search_objects = 1 //have to find those plant trays!

	//Spaceborn beings don't get hurt by space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = 1

	var/datum/reagent/beegent = null //hehe, beegent
	var/obj/structure/beebox/beehome = null
	var/idle = 0
	var/isqueen = FALSE
	var/icon_base = "bee"
	var/static/list/bee_icons = list()


/mob/living/simple_animal/hostile/poison/bees/Process_Spacemove(movement_dir = 0)
	return 1


/mob/living/simple_animal/hostile/poison/bees/New()
	..()
	generate_bee_visuals()


/mob/living/simple_animal/hostile/poison/bees/Destroy()
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	return ..()


/mob/living/simple_animal/hostile/poison/bees/death(gibbed)
	if(beehome)
		beehome.bees -= src
		beehome = null
	beegent = null
	..()


/mob/living/simple_animal/hostile/poison/bees/examine(mob/user)
	..()

	if(!beehome)
		user << "<span class='warning'>This bee is homeless!</span>"


/mob/living/simple_animal/hostile/poison/bees/proc/generate_bee_visuals()
	cut_overlays()

	var/col = BEE_DEFAULT_COLOUR
	if(beegent && beegent.color)
		col = beegent.color

	var/image/base
	if(!bee_icons["[icon_base]_base"])
		bee_icons["[icon_base]_base"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_base")
	base = bee_icons["[icon_base]_base"]
	add_overlay(base)

	var/image/greyscale
	if(!bee_icons["[icon_base]_grey_[col]"])
		bee_icons["[icon_base]_grey_[col]"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_grey")
	greyscale = bee_icons["[icon_base]_grey_[col]"]
	greyscale.color = col
	add_overlay(greyscale)

	var/image/wings
	if(!bee_icons["[icon_base]_wings"])
		bee_icons["[icon_base]_wings"] = image(icon = 'icons/mob/bees.dmi', icon_state = "[icon_base]_wings")
	wings = bee_icons["[icon_base]_wings"]
	add_overlay(wings)


//We don't attack beekeepers/people dressed as bees//Todo: bee costume
/mob/living/simple_animal/hostile/poison/bees/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return 0
	if(isliving(the_target))
		var/mob/living/H = the_target
		return !H.bee_friendly()


/mob/living/simple_animal/hostile/poison/bees/Found(atom/A)
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = A
		if(Hydro.myseed && !Hydro.dead && !Hydro.recent_bee_visit)
			wanted_objects |= /obj/machinery/hydroponics //so we only hunt them while they're alive/seeded/not visisted
			return 1
	if(isliving(A))
		var/mob/living/H = A
		return !H.bee_friendly()
	return 0


/mob/living/simple_animal/hostile/poison/bees/AttackingTarget()
 	//Pollinate
	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/Hydro = target
		pollinate(Hydro)
	else if(target == beehome)
		var/obj/structure/beebox/BB = target
		loc = BB
		target = null
		wanted_objects -= /obj/structure/beebox //so we don't attack beeboxes when not going home
	else
		if(beegent && isliving(target))
			var/mob/living/L = target
			beegent.reaction_mob(L, INJECT)
			L.reagents.add_reagent(beegent.id, rand(1,5))
		target.attack_animal(src)


/mob/living/simple_animal/hostile/poison/bees/proc/assign_reagent(datum/reagent/R)
	if(istype(R))
		beegent = R
		name = "[initial(name)] ([R.name])"
		generate_bee_visuals()


/mob/living/simple_animal/hostile/poison/bees/proc/pollinate(obj/machinery/hydroponics/Hydro)
	if(!istype(Hydro) || !Hydro.myseed || Hydro.dead || Hydro.recent_bee_visit)
		target = null
		return

	target = null //so we pick a new hydro tray next FindTarget(), instead of loving the same plant for eternity
	wanted_objects -= /obj/machinery/hydroponics //so we only hunt them while they're alive/seeded/not visisted
	Hydro.recent_bee_visit = TRUE
	spawn(BEE_TRAY_RECENT_VISIT)
		if(Hydro)
			Hydro.recent_bee_visit = FALSE

	var/growth = health //Health also means how many bees are in the swarm, roughly.
	//better healthier plants!
	Hydro.health += round(growth*0.5)
	if(prob(BEE_POLLINATE_PEST_CHANCE))
		Hydro.pestlevel = max(0, --Hydro.pestlevel)
	if(prob(BEE_POLLINATE_YIELD_CHANCE)) //Yield mod is HELLA powerful, but quite rare
		Hydro.myseed.innate_yieldmod++
	if(prob(BEE_POLLINATE_POTENTCY_CHANCE))
		Hydro.myseed.potency++

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + growth, 100)


/mob/living/simple_animal/hostile/poison/bees/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(!isqueen)
		if(loc == beehome)
			idle = min(100, ++idle)
			if(idle >= BEE_IDLE_ROAMING && prob(BEE_PROB_GOROAM))
				loc = get_turf(beehome)
		else
			idle = max(0, --idle)
			if(idle <= BEE_IDLE_GOHOME && prob(BEE_PROB_GOHOME))
				if(!FindTarget())
					wanted_objects += /obj/structure/beebox //so we don't attack beeboxes when not going home
					target = beehome
	if(!beehome) //add outselves to a beebox (of the same reagent) if we have no home
		for(var/obj/structure/beebox/BB in view(vision_range, src))
			if(reagent_incompatible(BB.queen_bee) || BB.bees.len >= BB.get_max_bees())
				continue
			BB.bees |= src
			beehome = BB

/mob/living/simple_animal/hostile/poison/bees/toxin/New()
	. = ..()
	var/datum/reagent/R = pick(typesof(/datum/reagent/toxin))
	assign_reagent(chemical_reagents_list[initial(R.id)])

 /mob/living/simple_animal/hostile/poison/bees/queen
 	name = "queen bee"
 	desc = "She's the queen of bees, BZZ BZZ!"
 	icon_base = "queen"
 	isqueen = TRUE


 //the Queen doesn't leave the box on her own, and she CERTAINLY doesn't pollinate by herself
/mob/living/simple_animal/hostile/poison/bees/queen/Found(atom/A)
	return 0


//leave pollination for the peasent bees
/mob/living/simple_animal/hostile/poison/bees/queen/AttackingTarget()
	if(beegent && isliving(target))
		var/mob/living/L = target
		beegent.reaction_mob(L, TOUCH)
		L.reagents.add_reagent(beegent.id, rand(1,5))
	target.attack_animal(src)


//PEASENT BEES
/mob/living/simple_animal/hostile/poison/bees/queen/pollinate()
	return


/mob/living/simple_animal/hostile/poison/bees/proc/reagent_incompatible(mob/living/simple_animal/hostile/poison/bees/B)
	if(!B)
		return 0
	if(B.beegent && beegent && B.beegent.id != beegent.id || B.beegent && !beegent || !B.beegent && beegent)
		return 1
	return 0

/mob/living/simple_animal/hostile/poison/bees/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/weapon/melee/flyswatter))
		user << "<span class='warning'>You easily splat the [src].</span>"
		new /obj/effect/decal/cleanable/deadcockroach(get_turf(src))
		death(1)

/obj/item/queen_bee
	name = "queen bee"
	desc = "She's the queen of bees, BZZ BZZ!"
	icon_state = "queen_item"
	item_state = ""
	icon = 'icons/mob/bees.dmi'
	var/mob/living/simple_animal/hostile/poison/bees/queen/queen


/obj/item/queen_bee/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.reagents.has_reagent("royal_bee_jelly")) //checked twice, because I really don't want royal bee jelly to be duped
			if(S.reagents.has_reagent("royal_bee_jelly",5))
				S.reagents.remove_reagent("royal_bee_jelly", 5)
				var/obj/item/queen_bee/qb = new(get_turf(user))
				qb.queen = new(qb)
				if(queen && queen.beegent)
					qb.queen.assign_reagent(queen.beegent) //Bees use the global singleton instances of reagents, so we don't need to worry about one bee being deleted and her copies losing their reagents.
				user.put_in_active_hand(qb)
				user.visible_message("<span class='notice'>[user] injects [src] with royal bee jelly, causing it to split into two bees, MORE BEES!</span>","<span class ='warning'>You inject [src] with royal bee jelly, causing it to split into two bees, MORE BEES!</span>")
			else
				user << "<span class='warning'>You don't have enough royal bee jelly to split a bee in two!</span>"
		else
			var/datum/reagent/R = chemical_reagents_list[S.reagents.get_master_reagent_id()]
			if(R && S.reagents.has_reagent(R.id, 5))
				S.reagents.remove_reagent(R.id,5)
				queen.assign_reagent(R)
				user.visible_message("<span class='warning'>[user] injects [src]'s genome with [R.name], mutating it's DNA!</span>","<span class='warning'>You inject [src]'s genome with [R.name], mutating it's DNA!</span>")
				name = queen.name
			else
				user << "<span class='warning'>You don't have enough units of that chemical to modify the bee's DNA!</span>"
	if(istype(I,/obj/item/weapon/melee/flyswatter))
		user << "<span class='warning'>You easily splat the [src].</span>"
		new /obj/effect/decal/cleanable/deadcockroach(get_turf(src))
		qdel(src)
	..()


/obj/item/queen_bee/bought/New()
	..()
	queen = new(src)


/obj/item/queen_bee/Destroy()
	qdel(queen)
	return ..()

