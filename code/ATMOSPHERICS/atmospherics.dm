/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0
	var/can_unwrench = 0



obj/machinery/atmospherics/var/initialize_directions = 0
obj/machinery/atmospherics/var/pipe_color

obj/machinery/atmospherics/process()
	if(gc_destroyed) //comments on /vg/ imply that GC'd pipes still process
		return PROCESS_KILL
	build_network()

/*
obj/machinery/atmospherics/Destroy()

	worldm << "Pre Destroy()"
	test_pipenet()
		..()
	world << "Post Destroy()"
	test_pipenet()

obj/machinery/atmospherics/verb/test_pipenet()
	set src in view()
	var/found = 0
	var/srcref = "\ref[src]"
	var/netref = ""
	var/pipelineref = ""
	for(var/datum/pipe_network/Network in pipe_networks)
		netref = "\ref[Network]"
		for(var/obj/machinery/atmospherics/AT in Network.normal_members)
			if(AT == src)
				world << "Found <A HREF='?_src_=vars;Vars=\ref[src]'>[srcref] - [src.type]</A> in normal_members of pipenet#<A HREF='?_src_=vars;Vars=\ref[Network]'>[netref]</A>"
				found++
		for(var/datum/pipeline/PL in Network.line_members)
			pipelineref = "\ref[PL]"
			for(var/obj/machinery/atmospherics/AT in PL.members)
				if(AT == src)
					world << "Found <A HREF='?_src_=vars;Vars=\ref[src]'>[srcref] - [src.type]</A> in members of pipeline#<A HREF='?_src_=vars;Vars=\ref[PL]'>[pipelineref]</A> in pipenet#<A HREF='?_src_=vars;Vars=\ref[Network]'>[netref]</A>"
					found++
			for(var/obj/machinery/atmospherics/ATE in PL.edges)
				if(ATE == src)
					world << "Found <A HREF='?_src_=vars;Vars=\ref[src]'>[srcref] - [src.type]</A> in edges of pipeline#<A HREF='?_src_=vars;Vars=\ref[PL]'>[pipelineref]</A> in pipenet#<A HREF='?_src_=vars;Vars=\ref[Network]'>[netref]</A>"
					found++
	if(!found)
		world << "Unable to find <A HREF='?_src_=vars;Vars=\ref[src]'>[srcref]</A> in any pipenets"
*/

obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node

	return null

obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)

obj/machinery/atmospherics/update_icon()
	return null

obj/machinery/atmospherics/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(can_unwrench && istype(W, /obj/item/weapon/wrench))
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		add_fingerprint(user)
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			var/obj/item/pipe/newpipe = new(loc, make_from=src)
			transfer_fingerprints_to(newpipe)
			if(istype(src, /obj/machinery/atmospherics/pipe))
				for(var/obj/machinery/meter/meter in T)
					if(meter.target == src)
						new /obj/item/pipe_meter(T)
						qdel(meter)
			qdel(src)
	else
		return ..()
