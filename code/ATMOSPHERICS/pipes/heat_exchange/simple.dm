/obj/machinery/atmospherics/pipe/heat_exchanging/simple
	icon_state = "intact"

	name = "pipe"
	desc = "A one meter section of heat-exchanging pipe"

	volume = 70

	dir = SOUTH
	initialize_directions_he = SOUTH|NORTH

	device_type = BINARY

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/SetInitDirections()
	if(dir in diagonals)
		initialize_directions_he = dir
	switch(dir)
		if(SOUTH)
			initialize_directions_he = SOUTH|NORTH
		if(NORTH)
			initialize_directions_he = SOUTH|NORTH
		if(EAST)
			initialize_directions_he = EAST|WEST
		if(WEST)
			initialize_directions_he = WEST|EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/proc/normalize_dir()
	if(dir==SOUTH)
		dir = NORTH
	else if(dir==WEST)
		dir = EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/simple/atmosinit()
	normalize_dir()
	..()