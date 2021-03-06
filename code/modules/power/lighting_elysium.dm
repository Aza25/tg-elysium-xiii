/obj/machinery/light
	var/fixturestate = null

/obj/item/light
	var/bulb_colour = "#FFFFFF"
	var/fixturestate = null

/obj/item/light/tube
	fixturestate = "tube"

/obj/item/light/bulb
	fixturestate = "bulb"


/obj/item/light/tube/red
	name = "red light tube"
	desc = "A replacement red light tube."
	icon_state = "ltube-red"
	base_state = "ltube-red"
	item_state = "c_tube"
	brightness = 8
	bulb_colour = "#FF0000"
	fixturestate = "tube-red"



/obj/item/light/tube/green
	name = "green light tube"
	desc = "A replacement green light tube."
	icon_state = "ltube-green"
	base_state = "ltube-green"
	item_state = "c_tube"
	brightness = 8
	light_power = 2
	bulb_colour = "#00FF00"
	fixturestate = "tube-green"


/obj/item/light/tube/blue
	name = "blue light tube"
	desc = "A replacement blue light tube."
	icon_state = "ltube-blue"
	base_state = "ltube-blue"
	item_state = "c_tube"
	brightness = 8
	bulb_colour = "#0000FF"
	fixturestate = "tube-blue"


/obj/item/light/tube/lounge
	name = "lounge light tube"
	desc = "A replacement purple light tube."
	icon_state = "ltube-lounge"
	base_state = "ltube-lounge"
	item_state = "c_tube"
	brightness = 8
	bulb_colour = "#B00CFE"
	fixturestate = "tube-lounge"