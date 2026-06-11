/datum/patron/mossmother
	name = "The Mossmother"
	domain = "Hags, primordial evyl, poisoned boons and eternal life."
	desc = "The mother of all hags. Murmured by hags to have been defeated in times long past, but her spirit carries on in the soil. Old grievances will be settled."
	worshippers = "Hags"
	associated_faith = /datum/faith/mossmother
	preference_accessible = FALSE
	undead_hater = FALSE
	confess_lines = list(
		"I SERVE THE MOSSMOTHER!",
		"THE MOSSMOTHER SEES YOU!",
		"THE MOSSMOTHER'S ROOTS RUN BENEATH YOUR FEET!",
		"THE LAND BELONGS TO THE MOSSMOTHER!",
		"THE MOSSMOTHER DEMANDS REVENGE!",
		"THE SOIL REMEMBERS FOR THE MOSSMOTHER!",
		"OLD GRUDGES WILL BE PAID IN THE MOSSMOTHER'S NAME!",
	)

/datum/patron/mossmother/can_pray(mob/living/follower)
	. = ..()
	to_chat(follower, span_danger("I do not need to pray to the Mossmother, she is with me always."))
	return FALSE	//heathen

/datum/patron/mossmother/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("Without any particular cause or reason, [target] is healed!")
	*message_self = span_notice("My wounds close without cause.")
