/client/verb/powernets_debug()
	if(!holder)	return
	for(var/i=1,i<=powernets.len,i++)
//		src << "<a href='?\ref[holder];adminplayervars=\ref[powernets[i]]'>[copytext("\ref[powernets[i]]",8,12)]</A>"
		src << "<A HREF='?_src_=vars;Vars=\ref[powernets[i]]'>[copytext("\ref[powernets[i]]",8,12)]</A>"


/client/verb/powernet_overlays()
	for(var/obj/structure/cable/C in cable_list)
		C.maptext = "<font color='white'>[copytext("\ref[C.powernet]",8,12)]</font>"
	for(var/obj/machinery/power/M in machines)
		M.maptext = "<font color='white'>[copytext("\ref[M.powernet]",8,12)]</font>"

