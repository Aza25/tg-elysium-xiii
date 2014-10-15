/obj/machinery/atmospherics/trinary
	icon = 'icons/obj/atmospherics/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = 1

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network1
	var/datum/pipe_network/network2
	var/datum/pipe_network/network3

	var/flipped = 0

/obj/machinery/atmospherics/trinary/New()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|WEST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|EAST
	air1 = new
	air2 = new
	air3 = new

	air1.volume = 200
	air2.volume = 200
	air3.volume = 200

/*
Iconnery
*/
/obj/machinery/atmospherics/trinary/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/trinary/icon_addintact(var/obj/machinery/atmospherics/node, var/connected)
	var/image/img = getpipeimage('icons/obj/atmospherics/trinary_devices.dmi', "intact", get_dir(src,node), node.pipe_color)
	overlays += img

	return connected | img.dir

/obj/machinery/atmospherics/trinary/icon_addbroken(var/connected)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			overlays += getpipeimage('icons/obj/atmospherics/trinary_devices.dmi', "intact", direction)

/obj/machinery/atmospherics/trinary/update_icon()
	update_icon_nopipes()

	var/connected = 0
	overlays.Cut()

	//Add non-broken pieces
	if(node1)
		connected = icon_addintact(node1, connected)

	if(node2)
		connected = icon_addintact(node2, connected)

	if(node3)
		connected = icon_addintact(node3, connected)

	//Add broken pieces
	icon_addbroken(connected)

/*
Housekeeping and pipe network stuff below
*/
/obj/machinery/atmospherics/trinary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network

	else if(reference == node2)
		network2 = new_network

	else if (reference == node3)
		network3 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/trinary/Destroy()
	if(node1)
		node1.disconnect(src)
		del(network1)
	if(node2)
		node2.disconnect(src)
		del(network2)
	if(node3)
		node3.disconnect(src)
		del(network3)

	node1 = null
	node2 = null
	node3 = null

	..()

/obj/machinery/atmospherics/trinary/initialize()
	src.disconnect(src)

	//Mixer:
	//1 and 2 is input
	//Node 3 is output
	//If we flip the mixer, 1 and 3 shall exchange positions

	//Filter:
	//Node 1 is input
	//Node 2 is filtered output
	//Node 3 is rest output
	//If we flip the filter, 1 and 3 shall exchange positions

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	if(flipped)
		node1_connect = turn(node1_connect, 180)
		node3_connect = turn(node3_connect, 180)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	update_icon()

/obj/machinery/atmospherics/trinary/build_network()
	if(!network1 && node1)
		network1 = new /datum/pipe_network()
		network1.normal_members += src
		network1.build_network(node1, src)

	if(!network2 && node2)
		network2 = new /datum/pipe_network()
		network2.normal_members += src
		network2.build_network(node2, src)

	if(!network3 && node3)
		network3 = new /datum/pipe_network()
		network3.normal_members += src
		network3.build_network(node3, src)


/obj/machinery/atmospherics/trinary/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network1

	if(reference==node2)
		return network2

	if(reference==node3)
		return network3

	return null

/obj/machinery/atmospherics/trinary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network1 == old_network)
		network1 = new_network
	if(network2 == old_network)
		network2 = new_network
	if(network3 == old_network)
		network3 = new_network

	return 1

/obj/machinery/atmospherics/trinary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network1 == reference)
		results += air1
	if(network2 == reference)
		results += air2
	if(network3 == reference)
		results += air3

	return results

/obj/machinery/atmospherics/trinary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		del(network1)
		node1 = null

	else if(reference==node2)
		del(network2)
		node2 = null

	else if(reference==node3)
		del(network3)
		node3 = null

	update_icon()

	return null

/obj/machinery/atmospherics/trinary/nullifyPipenetwork()
	network1 = null
	network2 = null
	network3 = null