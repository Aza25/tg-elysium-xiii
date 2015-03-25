/obj/effect/proc_holder/spell/targeted/lightning
	name = "Lightning Bolt"
	desc = "Throws a lightning bolt at the nearby enemy. Classic."
	charge_type = "recharge"
	charge_max	= 300
	clothes_req = 1
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "view"
	random_target = 1
	var/energy = 0
	var/ready = 0

/obj/effect/proc_holder/spell/targeted/lightning/Click()
	if(!ready)
		if(cast_check())
			StartChargeup()
	else
		if(cast_check(skipcharge=1))
			choose_targets()
	return 1

/obj/effect/proc_holder/spell/targeted/lightning/proc/StartChargeup(mob/user = usr)
	ready = 1
	user << "<span class='notice'>You start gathering the power.</span>"
	//TODO: Add visual indictaor of charging
	spawn(0)
		while(ready)
			sleep(1)
			energy++
			if(energy >= 100 && ready)
				Discharge()

/obj/effect/proc_holder/spell/targeted/lightning/revert_cast(mob/user = usr)
	user << "<span class='notice'>No target found in range.</span>"
	ready = 0
	energy = 0
	..()

/obj/effect/proc_holder/spell/targeted/lightning/proc/Discharge(mob/user = usr)
	var/mob/living/M = user
	//M.electrocute_act(25,"Lightning Bolt")
	M << "<span class='danger'>You lose control over the spell.</span>"
	energy = 0
	ready = 0
	start_recharge()


/obj/effect/proc_holder/spell/targeted/lightning/cast(list/targets, mob/user = usr)

	var/mob/living/carbon/target = targets[1]

	if(get_dist(user,target)>range)
		user << "<span class='notice'>They are too far away!</span>"
		ready = 0
		energy = 0
		return

	user.Beam(target,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)

	switch(energy)
		if(0 to 25)
			target.electrocute_act(10,"Lightning Bolt")
		if(25 to 75)
			target.electrocute_act(25,"Lightning Bolt")
		if(75 to 100)
			//CHAIN LIGHTNING
			Bolt(user,target,energy,user)
	ready = 0
	energy = 0

/obj/effect/proc_holder/spell/targeted/lightning/proc/Bolt(mob/origin,mob/target,bolt_energy,mob/user = usr)
	origin.Beam(target,icon_state="lightning",icon='icons/effects/effects.dmi',time=5)
	var/mob/living/carbon/current = target
	if(bolt_energy < 75)
		current.electrocute_act(25,"Lightning Bolt")
	else
		current.electrocute_act(25,"Lightning Bolt")
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(range,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,bolt_energy-6,user) // 5 max bounces