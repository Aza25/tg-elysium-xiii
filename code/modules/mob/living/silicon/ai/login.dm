/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up �_� ~Carn
	..()
	for(var/obj/effect/rune/rune in world)
		var/image/blood = image(loc = rune)
		blood.override = 1
		client.images += blood
	regenerate_icons()
	flash = new /obj/screen()
	flash.icon_state = "blank"
	flash.name = "flash"
	flash.screen_loc = "1,1 to 15,15"
	flash.layer = 17
	blind = new /obj/screen()
	blind.icon_state = "black"
	blind.name = " "
	blind.screen_loc = "1,1 to 15,15"
	blind.plane = -80
	client.screen.Add( blind, flash )

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	src.view_core()
	return