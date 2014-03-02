/datum/wires/autolathe

	holder_type = /obj/machinery/autolathe
	wire_count = 10

var/const/AUTOLATHE_HACK_WIRE = 1
var/const/AUTOLATHE_SHOCK_WIRE = 2
var/const/AUTOLATHE_DISABLE_WIRE = 4

/datum/wires/autolathe/GetInteractWindow()
	var/obj/machinery/autolathe/A = holder
	. += ..()
	. += text("<BR>The red light is [A.disabled ? "off" : "on"].<BR>The green light is [A.shocked ? "off" : "on"].<BR>The blue light is [A.hacked ? "off" : "on"].<BR>")

/datum/wires/autolathe/CanUse()
	var/obj/machinery/autolathe/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/autolathe/UpdateCut(index)
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			A.hacked = !A.hacked
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !A.shocked
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !A.disabled

/datum/wires/autolathe/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/autolathe/A = holder
	switch(index)
		if(AUTOLATHE_HACK_WIRE)
			A.hacked = !A.hacked
			spawn(100)
				if(A && !IsIndexCut(index))
					A.hacked = 0
					Interact(usr)
		if(AUTOLATHE_SHOCK_WIRE)
			A.shocked = !A.shocked
			spawn(100)
				if(A && !IsIndexCut(index))
					A.shocked = 0
					Interact(usr)
		if(AUTOLATHE_DISABLE_WIRE)
			A.disabled = !A.disabled
			spawn(100)
				if(A && !IsIndexCut(index))
					A.disabled = 0
					Interact(usr)