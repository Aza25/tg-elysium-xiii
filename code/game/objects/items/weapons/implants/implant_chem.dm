/obj/item/weapon/implant/chem
	name = "chem implant"
	desc = "Injects things."
	icon_state = "reagents"
	origin_tech = "materials=3;biotech=4"
	flags = OPENCONTAINER

/obj/item/weapon/implant/chem/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
				<b>Life:</b> Deactivates upon death but remains within the body.<BR>
				<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
				will suffer from an increased appetite.</B><BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
				the implant releases the chemicals directly into the blood stream.<BR>
				<b>Special Features:</b>
				<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units.<BR>
				Can only be loaded while still in its original case.<BR>
				<b>Integrity:</b> Implant will last so long as the subject is alive. However, if the subject suffers from malnutrition,<BR>
				the implant may become unstable and either pre-maturely inject the subject or simply break."}
	return dat

/obj/item/weapon/implant/chem/New()
	..()
	create_reagents(50)

/obj/item/weapon/implant/chem/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate(reagents.total_volume)

/obj/item/weapon/implant/chem/activate(cause)
	if(!cause || !imp_in)	return 0
	var/mob/living/carbon/R = imp_in
	var/injectamount = null
	if (cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	R << "<span class='italics'>You hear a faint beep.</span>"
	if(!reagents.total_volume)
		R << "<span class='italics'>You hear a faint click from your chest.</span>"
		qdel(src)


/obj/item/weapon/implantcase/chem
	name = "glass case - 'Remote Chemical'"
	desc = "A case containing a remote chemical implant."

/obj/item/weapon/implantcase/chem/New()
	imp = new /obj/item/weapon/implant/chem(src)
	..()