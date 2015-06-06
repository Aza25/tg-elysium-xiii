/obj/item/device/doorCharge
	name = "syndicate airlock charge"
	desc = null //Different examine for traitors
	item_state = "electronic"
	icon_state = "doorCharge"
	w_class = 2
	throw_range = 4
	throw_speed = 1
	force = 3
	attack_verb = list("blown up", "exploded", "detonated")
	m_amt = 50
	g_amt = 30

/obj/item/device/doorCharge/ex_act(severity, target)
	switch(severity)
		if(1)
			visible_message("<span class='warning'>[src] detonates!</span>")
			explosion(src.loc,-1,2,4,flame_range = 2)
			qdel(src)
		if(2)
			if(prob(50))
				ex_act(1)
		if(3)
			if(prob(25))
				ex_act(1)

/obj/item/device/doorCharge/examine(mob/user)
	..()
	if(user.mind in ticker.mode.traitors) //No nuke ops because the device is excluded from nuclear
		user << "A small explosive device that can be used to sabotage airlocks to cause an explosion upon opening. To apply, remove the airlock's maintenance panel and place it within."
	else
		user << "A small, suspicious object that feels lukewarm when held."