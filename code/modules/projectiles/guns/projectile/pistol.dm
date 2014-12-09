/obj/item/weapon/gun/projectile/automatic/pistol
	name = "syndicate pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = 2
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = 1

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/m1911
	name = "M1911 pistol"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "pistol"
	w_class = 3
	mag_type = /obj/item/ammo_box/magazine/m45

/obj/item/weapon/gun/projectile/automatic/pistol45/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	return


/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust .50 AE handgun.."
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50

/obj/item/weapon/gun/projectile/automatic/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"
