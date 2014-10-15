/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0

/obj/item/weapon/gun/projectile/shotgun/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()

/obj/item/weapon/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return


/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pumped = 0
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/examine(mob/user)
	..()
	if (chambered)
		user << "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	desc = "A traditional shotgun with tactical furniture and an eight-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shotcom
	w_class = 5

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=3;materials=1"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/dualshot

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if (istype(A,/obj/item/ammo_box) || istype(A,/obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		user << "<span class='notice'>You begin to shorten the barrel of \the [src].</span>"
		if(get_ammo())
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			return
		if(do_after(user, 30))	//SHIT IS STEALTHY EYYYYY
			icon_state = "sawnshotgun"
			w_class = 3.0
			item_state = "gun"
			slot_flags &= ~SLOT_BACK	//you can't sling it on your back
			slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			user << "<span class='warning'>You shorten the barrel of \the [src]!</span>"
			name = "sawn-off shotgun"
			desc = "Omar's coming!"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		user << "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>"
	else
		user << "<span class='notice'>[src] is empty.</span>"


// IMPROVISED SHOTGUN //

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/improvised

/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(10))
			flags =  CONDUCT
			slot_flags = SLOT_BACK
			icon_state = "ishotgunsling"
			user << "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>"
			update_icon()
		else
			user << "<span class='warning'>You need at least ten lengths of cable if you want to make a sling.</span>"
			return

/obj/item/ishotgunreciever
	name = "firearm reciever"
	desc = "An improvised trigger assembly for a firearm."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunreciever"
	m_amt = 200000 //You need to upgrade the autolathe to make either of these

/obj/item/ishotgunbarrel
	name = "shotgun barrel"
	desc = "A long metal slug barrel, with threading and pin holes that are only compatible with specific weapon recievers."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunbarrel"
	m_amt = 200000

/obj/item/ishotgunstock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstock"

/obj/item/ishotgunreciever/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/ishotgunbarrel))
		user << "You attach the shotgun barrel to the reciever. The pins seem loose."
		var/obj/item/ishotgunconstruction/I = new /obj/item/ishotgunconstruction
		user.unEquip(src)
		user.put_in_hands(I)
		del(W)
		del(src)
		return

/obj/item/ishotgunconstruction
	name = "slightly conspicuous metal construction"
	desc = "A long shotgun barrel attached to a trigger assembly."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/ishotgunconstruction/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/weapon/screwdriver))
		var/obj/item/ishotgunconstruction2/C = new /obj/item/ishotgunconstruction2
		user.unEquip(src)
		user.put_in_hands(C)
		user << "<span class='notice'>You screw the pins into place, attaching the .</span>"
		qdel(src)

/obj/item/ishotgunconstruction2
	name = "very conspicuous metal construction"
	desc = "A long shotgun barrel attached to a trigger assembly."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep1"

/obj/item/ishotgunconstruction2/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/ishotgunstock))
		user << "You attach the stock to the reciever-barrel assembly."
		var/obj/item/ishotgunconstruction3/I = new /obj/item/ishotgunconstruction3
		user.unEquip(src)
		user.put_in_hands(I)
		del(W)
		del(src)
		return

/obj/item/ishotgunconstruction3
	name = "extremely conspicuous metal construction"
	desc = "A reicever-barrel shotgun assembly with a loose wooden stock. There's no way you can fire it without the stock coming loose."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "ishotgunstep2"

/obj/item/ishotgunconstruction3/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/packageWrap))
		var/obj/item/stack/packageWrap/C = I
		if (C.use(5))
			var/obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised/W = new /obj/item/weapon/gun/projectile/revolver/doublebarrel/improvised
			user.unEquip(src)
			user.put_in_hands(W)
			user << "<span class='notice'>You tie the wrapping paper around the stock and the barrel to secure it.</span>"
			qdel(src)
		else
			user << "<span class='warning'>You need at least five feet of wrapping paper to secure the grip.</span>"
			return

