/datum/surgery/core_removal
	name = "core removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/incise, /datum/surgery_step/extract_core)
	species = list(/mob/living/simple_animal/slime)
	target_must_be_dead = 1


//extract brain
/datum/surgery_step/extract_core
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 100)
	time = 16

/datum/surgery_step/extract_core/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to extract a core from [target].", "<span class='notice'>You begin to extract a core from [target]...</span>")

/datum/surgery_step/extract_core/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/slime/slime = target
	if(slime.cores > 0)
		slime.cores--
		user.visible_message("[user] successfully extracts a core from [target]!", "<span class='notice'>You successfully extract a core from [target]. [slime.cores] core\s remaining.</span>")

		new slime.coretype(slime.loc)

		if(slime.cores <= 0)
			slime.icon_state = "[slime.colour] baby slime dead-nocore"
			return 1
		else
			return 0
	else
		user << "<span class='warning'>There aren't any cores left in [target]!</span>"
		return 1