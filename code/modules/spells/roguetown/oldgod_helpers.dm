/datum/action/cooldown/spell/psydon/proc/get_psicross_tier(mob/living/carbon/human/H)
	if(!H)
		return 0

	for(var/obj/item/clothing/neck/current_item in H.get_equipped_items(TRUE))
		switch(current_item.type)
			if(/obj/item/clothing/neck/roguetown/psicross/wood)
				return 1
			if(/obj/item/clothing/neck/roguetown/psicross/aalloy)
				return 2
			if(/obj/item/clothing/neck/roguetown/psicross)
				return 3
			if(/obj/item/clothing/neck/roguetown/psicross/silver)
				return 4
			if(/obj/item/clothing/neck/roguetown/psicross/g)
				return 5
			if(/obj/item/clothing/neck/roguetown/psicross/weeping)
				return 6

	return 0

/datum/action/cooldown/spell/psydon/proc/get_holy_power(mob/living/carbon/human/H)
	if(!H)
		return 0

	return H.get_skill_level(/datum/skill/magic/holy)

/datum/action/cooldown/spell/psydon/proc/has_corrupted_psicross(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	for(var/obj/item/clothing/neck/current_item in H.get_equipped_items(TRUE))
		if(istype(current_item, /obj/item/clothing/neck/roguetown/psicross/inhumen/aalloy))
			return TRUE

	return FALSE

/datum/action/cooldown/spell/psydon/proc/check_psydon_favor(mob/living/carbon/human/H)
	if(!has_corrupted_psicross(H))
		return TRUE

	H.visible_message(
		span_warning("[H] shuddered. Something's very wrong."),
		span_userdanger("Cold shoots through my spine. Something laughs at me for trying.")
	)

	H.playsound_local(H, 'sound/misc/zizo.ogg', 25, FALSE)
	H.adjustBruteLoss(25)

	return FALSE

/datum/action/cooldown/spell/psydon/proc/get_healing_power(mob/living/carbon/human/H)
	var/healing = 0

	healing += get_holy_power(H) * 2
	healing += get_psicross_tier(H)

	return healing

/datum/action/cooldown/spell/psydon/proc/get_suffering_bonus(mob/living/carbon/human/H)
	if(!H)
		return 0

	var/total_damage = H.getBruteLoss() + H.getFireLoss()

	if(total_damage < 100)
		return 0

	// Starts at 4 bonus at exactly 100 damage.
	var/bonus = 4 + round((total_damage - 100) / 75)

	var/wound_multiplier = 1 + (length(H.get_wounds()) * 0.10)

	return round(bonus * wound_multiplier)

/datum/action/cooldown/spell/psydon/proc/get_persist_quote()
	return pick(
		"My faith steels me against my suffering.",
		"The body falters. The Lux endures.",
		"I have weathered worse than this.",
		"My wounds are temporary. My devotion is not.",
		"Pain is fleeting. Resolve is eternal.",
		"Psydon endures. So too shall I.",
		"The world tests me. I remain unbroken.",
		"I draw breath. Therefore I continue.",
		"My Lux still burns.",
		"Even now, I persist.",
		"The horrors persist, but so will I.",
		"With every broken bone. I swore I lived.",
		"I must hold on, until Your return.",
		"Because when your time has come and gone, I'll be the one to carry on.",
		"I won't give up to the enemy.",
		"My God. I shall not give them the luxury of my demise.",
		"My faith is my shield. My fury is my sword. Your silence is my trial.",
		"My fury knows no bounds. Burn, my Lux. Burn and fill me with lyfe.",
		"It's time to face my fears. Head on. Throw me to the volfs.",
		"Allfather. Protect me from the Inhumen, the Monster, the Heretic.",
		"Purity afloat... Until we reach paradise.",
		"I ain't got no time to bleed.",
		"I can't expect HIM to do all the work.",
	)

/datum/action/cooldown/spell/psydon/proc/get_persist_healing(mob/living/carbon/human/H)
	if(!H)
		return 0

	// Base healing:
	// Holy 1 + Wood Cross 1 = 8
	// Holy 6 + Weeping Cross 6 = 48
	var/healing = (get_holy_power(H) * 4)
	healing += (get_psicross_tier(H) * 4)

	// 1% increased healing per 10 total damage.
	//
	// 100 damage = 10% bonus
	// 300 damage = 30% bonus
	// 500 damage = 50% bonus
	var/total_damage = H.getBruteLoss() + H.getFireLoss()

	var/multiplier = 1 + (total_damage / 1000)

	return round(healing * multiplier)	
