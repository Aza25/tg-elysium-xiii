/obj/secure_closet/security1/New()
	..()
	sleep(2)
	//new /obj/item/weapon/storage/flashbang_kit(src)
	// Seriously gimping the number of flashes security get, will probably change later -- TLE
	new /obj/item/weapon/flashbang(src)
//	new /obj/item/weapon/shield/riot(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/gun/energy/taser_gun(src)
	new /obj/item/device/flash(src)
	new /obj/item/clothing/under/color/red(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/baton(src)
	return

/obj/secure_closet/security1/proc/prison_break()
	src.locked = 0
	src.icon_state = src.icon_closed

/obj/secure_closet/security2/New()
	..()
	sleep(2)
	new /obj/item/clothing/under/det( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/head/det_hat( src )
	new /obj/item/clothing/suit/det_suit( src )
	new /obj/item/weapon/storage/fcard_kit( src )
	new /obj/item/weapon/storage/fcard_kit( src )
	new /obj/item/weapon/storage/fcard_kit( src )
	new /obj/item/clothing/gloves/black( src )
	new /obj/item/weapon/storage/lglo_kit( src )
	new /obj/item/weapon/fcardholder( src )
	new /obj/item/weapon/fcardholder( src )
	new /obj/item/weapon/fcardholder( src )
	new /obj/item/weapon/fcardholder( src )
	new /obj/item/device/detective_scanner( src )
	new /obj/item/device/detective_scanner( src )
	new /obj/item/device/detective_scanner( src )
	return

/obj/secure_closet/highsec/New()
	..()
	sleep(2)
	new /obj/item/device/radio/headset/headset_com(src)
	new /obj/item/weapon/gun/energy/general( src )
	new /obj/item/device/flash( src )
	new /obj/item/weapon/storage/id_kit( src )
	new /obj/item/clothing/under/rank/head_of_personnel( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/glasses/sunglasses( src )
	new /obj/item/clothing/suit/armor/vest( src )
	new /obj/item/clothing/head/helmet( src )
	return

/obj/secure_closet/hos/New()
	..()
	sleep(2)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/weapon/shield/riot(src)
	new /obj/item/weapon/gun/energy/general( src )
	new /obj/item/device/flash( src )
	new /obj/item/weapon/storage/id_kit( src )
	new /obj/item/clothing/under/rank/head_of_security( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/glasses/sunglasses( src )
	new /obj/item/clothing/suit/armor/hos( src )
	new /obj/item/clothing/head/helmet( src )
	new /obj/item/weapon/storage/id_kit( src )
	new /obj/item/weapon/storage/flashbang_kit(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/baton(src)
	return