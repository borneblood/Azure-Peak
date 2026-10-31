// Flags returned by scan_instruments()
#define DIAGNOSE_HAS_LEECH (1<<0)
#define DIAGNOSE_HAS_INCISION (1<<1)
#define DIAGNOSE_HAS_HEMOSTAT (1<<2)

// Diagnose
/datum/action/cooldown/spell/pestra/diagnose
	name = "Diagnose"
	desc = "Call upon Pestra's medical wisdom to read the body's humors and hidden ailments at a distance. Reveals a target's condition with perfect clarity. To perceive one's blood content, all you'll need is but an incision."
	button_icon = 'icons/mob/actions/pestraspells.dmi'
	button_icon_state = "diagnose"
	sound = 'sound/magic/diagnose.ogg'
	spell_type = SPELL_MIRACLE
	invocation_type = INVOCATION_NONE
	antimagic_flags = NONE
	associated_skill = /datum/skill/magic/holy
	charge_required = FALSE
	cast_range = 4 // just in case free wants to demolish me for changing that, but 4 range is essential for this skill's functionality
	cooldown_time = 3 SECONDS
	devotion_cost = 5
	/// Miracle casts act as if capped on medicine; the secular version does not.
	var/is_miracle = TRUE

	/// Infection messages by level (1 = minor, 2 = regular, 3 = major).
	var/static/list/mid_infection_msgs = list(
		"Slight redness and irritation are visible, possibly an early-stage infection of the humors.",
		"Localized redness and warmth are present, consistent with an active infection of the humors.",
		"Pronounced redness and swelling are visible, with signs of discharge suggesting a severe infection of the humors.",
	)
	var/static/list/high_infection_msgs = list(
		"A minor infection taints their humors.",
		"A notable infection taints their humors.",
		"A severe infection taints their humors.",
	)
	/// Black Rot messages by tier (1-4).
	var/static/list/mid_rot_msgs = list(
		"<i>--A faint darkness spreads beneath their skin...</i>",
		"<i>--Their veins run black with corruption. They will surely die if this persists.</i>",
		"<i>--Their flesh decays and their bones apparently ache. It looks like their skin is boiling.</i>",
		"<i>--The body succumbs to total necrosis from the now beyond obvious Black Rot.</i>",
	)
	var/static/list/high_rot_msgs = list(
		"I can see the Black Rot in its first stage, 'Creeping'.",
		"I can see the Black Rot in its second stage, 'Festering'.",
		"I can see the Black Rot in its third stage, 'Boiling'.",
		"I can see the Black Rot in its terminal stage, 'Necrosis'.",
	)

/datum/action/cooldown/spell/pestra/diagnose/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return ishuman(owner) && ishuman(cast_on)

/datum/action/cooldown/spell/pestra/diagnose/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/mob/living/user = owner
	var/mob/living/carbon/human/target = cast_on

	var/skill_level = user.get_skill_level(associated_skill)
	var/is_mid_tier = (skill_level >= SKILL_LEVEL_JOURNEYMAN && skill_level <= SKILL_LEVEL_EXPERT)
	// miracle/secular share this proc; a miracle always acts as if capped on medicine, the "cheating" of being a miracle
	var/is_high_tier = (skill_level >= SKILL_LEVEL_MASTER) || is_miracle

	// skill happens as per normal
	target.check_for_injuries(user)

	report_missing_organs(user, target)
	report_deadite(user, target, is_high_tier)
	report_suffocation(user, target, is_high_tier)
	if(!(is_mid_tier || is_high_tier))
		report_poison_hint(user, target)
	if(is_mid_tier)
		report_mid_tier(user, target)
	if(is_high_tier)
		report_high_tier(user, target)
	report_blood(user, target, is_mid_tier, is_high_tier)
	return TRUE

/********************REPORTS********************/

/// One line listing every organ the target should have but doesn't.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_missing_organs(mob/living/user, mob/living/carbon/human/target)
	var/list/required_organs = target.dna?.species?.organs
	if(!length(required_organs))
		return
	var/list/missing = list()
	for(var/slot in required_organs)
		if(target.getorganslot(slot))
			continue
		var/obj/item/organ/organ_type = required_organs[slot]
		missing += LOWER_TEXT(initial(organ_type.name))
	if(length(missing))
		to_chat(user, span_boldwarning("They are missing: [english_list(missing)]."))

/// Rot is made -very clear- here: someone rotting to death needs immediate care, behold.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_deadite(mob/living/user, mob/living/carbon/human/target, is_high_tier)
	if(target.has_status_effect(/datum/status_effect/zombie_infection))
		to_chat(user, span_necrosis(is_high_tier ? "They are infected and turning into a DEADITE!" : "Their humors rot unnaturally, as their body is quickly decaying."))
		to_chat(user, span_infection("Their rot needs to be burned immediately!"))
		to_chat(user, span_infection("==="))
	if(HAS_TRAIT(target, TRAIT_DEADITE)) //IDK what you expected but hey, Pestra's looking out for you!
		to_chat(user, span_necrosis("They are infected and have already turned into a DEADITE!"))
		to_chat(user, span_infection("Their rot needs to be burned to prevent them from spreading their infection!"))
		to_chat(user, span_infection("==="))

/// Suffocation is free for all (highest cause of deaths in game); high tier gets the exact number, the rest get IC hints.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_suffocation(mob/living/user, mob/living/carbon/human/target, is_high_tier)
	if(is_high_tier)
		to_chat(user, span_blue("<i>Suffocation: [target.oxyloss]%</i>"))
		return
	if(target.stat >= DEAD)
		to_chat(user, span_purple("No breath passes through their lips; Pestra rest their soul."))
		return
	switch(target.oxyloss)
		if(0 to 1)
			to_chat(user, span_notice("Their breath flows true and untroubled."))
		if(1 to 50)
			to_chat(user, span_boldwarning("Their breathing is somewhat impeded; the chest labors lightly."))
		if(50 to 100)
			to_chat(user, span_boldred("They are openly suffocating to death; air is desperately needed!"))
		if(100 to INFINITY)
			to_chat(user, span_purple("No breath passes through their lips; Pestra rest their soul."))

/// Unskilled seculars can only tell once poison has taken a deep root, not early signs.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_poison_hint(mob/living/user, mob/living/carbon/human/target)
	if(target.toxloss >= 50)
		to_chat(user, span_necrosis("Cold sweat, pallid skin, and a failing breath... Signs of poisoning."))

/// Journeyman to Expert: qualitative findings.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_mid_tier(mob/living/user, mob/living/carbon/human/target)
	switch(target.toxloss)
		if(0 to 1)
			to_chat(user, span_notice("Their humors seem well-balanced; no oddities of note."))
		if(1 to 50)
			to_chat(user, span_boldwarning("A faint pallor and sweat are seen, the body is burdened with mild toxicity."))
		if(50 to 100)
			to_chat(user, span_boldred("Multiple subtle physical distress are seen, the body is crumbling under heavy toxicity."))
		if(100 to INFINITY)
			to_chat(user, span_necrosis("Their body is ravaged under the weight of fatal toxicity; Pestra rest their soul."))
	//very important to let them know that spamming water buckets is not a real medical procedure when someone is bleeding to death
	if(target.get_bleed_rate() > 10)
		to_chat(user, span_bloody("They are bleeding worryingly faster than the body can recover!"))
	report_infection(user, target, mid_infection_msgs)
	report_black_rot(user, target, mid_rot_msgs)

/// Master and Legendary (and every miracle): raw data.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_high_tier(mob/living/user, mob/living/carbon/human/target)
	var/bleed_rate = target.get_bleed_rate()
	var/bleed_percent = max(0.1, round((bleed_rate / BLOOD_VOLUME_NORMAL) * 100, 0.1))
	var/blood_percent = round((target.blood_volume / BLOOD_VOLUME_NORMAL) * 100)

	to_chat(user, span_necrosis("<i>Toxicity: [target.toxloss]%</i>"))
	to_chat(user, span_bloody("<i>Blood volume: [target.blood_volume]u ([blood_percent]%)</i>"))
	if(bleed_rate)
		to_chat(user, span_bloody("<i>Bleeding rate: [bleed_rate]u/sec ([bleed_percent]%/sec)</i>"))

	report_infection(user, target, high_infection_msgs)
	if(report_black_rot(user, target, high_rot_msgs))
		to_chat(user, span_infection("<i>Drinking Heartblood should delay the inevitable, but excising it is the cure.<i>"))

/// Prints the infection message for the target's infection level, if any.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_infection(mob/living/user, mob/living/carbon/human/target, list/messages)
	var/level = get_infection_level(target)
	if(!level)
		return
	var/message = messages[level]
	to_chat(user, (level == 3) ? span_boldwarning(message) : span_warning(message))

/// Prints the Black Rot message for the target's tier. Returns TRUE if they have Black Rot.
/datum/action/cooldown/spell/pestra/diagnose/proc/report_black_rot(mob/living/user, mob/living/carbon/human/target, list/messages)
	var/datum/status_effect/black_rot/rot = target.has_status_effect(/datum/status_effect/black_rot)
	if(!rot)
		return FALSE
	var/message = messages[rot.tier]
	to_chat(user, (rot.tier <= 2) ? span_infection(message) : span_necrosis(message))
	return TRUE

/// 0 = none, 1 = minor, 2 = regular, 3 = major. Checked worst-first.
/datum/action/cooldown/spell/pestra/diagnose/proc/get_infection_level(mob/living/carbon/human/target)
	if(target.reagents.has_reagent(/datum/reagent/infection/major))
		return 3
	if(target.reagents.has_reagent(/datum/reagent/infection))
		return 2
	if(target.reagents.has_reagent(/datum/reagent/infection/minor))
		return 1
	return 0

/********************BLOOD ANALYSIS********************/

/// Looks for a leech and a hemostat embedded anywhere, and an incision anywhere. Returns DIAGNOSE_HAS_* flags.
/datum/action/cooldown/spell/pestra/diagnose/proc/scan_instruments(mob/living/carbon/human/target)
	var/found = 0
	for(var/obj/item/bodypart/BP in target.bodyparts)
		for(var/datum/wound/W in BP.wounds)
			if(istype(W, /datum/wound/slash/incision))
				found |= DIAGNOSE_HAS_INCISION
				break
		for(var/obj/item/I in BP.embedded_objects)
			if(istype(I, /obj/item/natural/worms/leech))
				found |= DIAGNOSE_HAS_LEECH
			if(istype(I, /obj/item/rogueweapon/surgery/hemostat))
				found |= DIAGNOSE_HAS_HEMOSTAT
	return found

/// Every reagent worth reporting (anything but water and nutriment).
/datum/action/cooldown/spell/pestra/diagnose/proc/get_foreign_reagents(mob/living/carbon/human/target)
	var/list/foreign = list()
	for(var/datum/reagent/R in target.reagents.reagent_list)
		if(R.volume > 0 && R.type != /datum/reagent/water && R.type != /datum/reagent/consumable/nutriment)
			foreign += R
	return foreign

/datum/action/cooldown/spell/pestra/diagnose/proc/report_blood(mob/living/user, mob/living/carbon/human/target, is_mid_tier, is_high_tier)
	var/found = scan_instruments(target)
	var/has_leech = found & DIAGNOSE_HAS_LEECH
	var/has_incision = found & DIAGNOSE_HAS_INCISION
	var/has_hemostat = found & DIAGNOSE_HAS_HEMOSTAT

	var/list/foreign = get_foreign_reagents(target)
	var/list/names = list()
	var/list/names_with_amounts = list()
	var/datum/reagent/top_reagent
	for(var/datum/reagent/R as anything in foreign)
		names += LOWER_TEXT(R.name)
		names_with_amounts += "[LOWER_TEXT(R.name)] ([round(R.volume, 0.1)]u)"
		if(!top_reagent || R.volume > top_reagent.volume)
			top_reagent = R
	var/more_than_one = length(names) > 1

	// the way for babies to check if something's wrong with them on the run, just throw a leech and diagnose! cant be simpler than that
	if(has_leech)
		if(more_than_one)
			to_chat(user, span_red("The blood-sucking creecher stirs very uncomfortably... more than one foreign substances may be in their blood."))
		else if(length(names))
			to_chat(user, span_red("The blood-sucking creecher stirs uncomfortably... a foreign substance may be in their blood."))
		else
			to_chat(user, span_blue("The blood-sucking creecher seems unbothered and content; hinting a clean blood."))

	// and this is mostly for when you have surgical tools, pestrans with miracles can cheat better, it takes an incision only rather than a forceps inside
	if(length(names))
		if(is_miracle && has_incision)
			to_chat(user, span_necrosis("<b><i>With Pestra's wisdom, I perceive their blood in full detail, revealing [english_list(names_with_amounts)] within.</b></i>"))
		else if(is_high_tier && has_hemostat && !is_miracle)
			to_chat(user, span_boldwarning("<i>Studying the blood drawn upon the instrument, I easily discern [english_list(names)] within.</i>"))
		else if(is_mid_tier && has_hemostat && !is_miracle)
			if(more_than_one)
				to_chat(user, span_boldwarning("<i>Studying the blood drawn upon the instrument, I can only see heavy traces of [LOWER_TEXT(top_reagent.name)], though other substances may be present.</i>"))
			else
				to_chat(user, span_boldwarning("<i>Studying the blood drawn upon the instrument, I can only see heavy traces of [LOWER_TEXT(top_reagent.name)] within.</i>"))
	else
		if(is_miracle && has_incision)
			to_chat(user, span_boldgreen("<i>Even with divine insight, I perceive no foreign substances within their blood.</i>"))
		else if((is_mid_tier || is_high_tier) && has_hemostat && !is_miracle)
			to_chat(user, span_boldgreen("<i>From the blood drawn upon the instrument, I find no clear trace of any substances in their blood.</i>"))

/datum/action/cooldown/spell/pestra/diagnose/secular
	name = "Secular Diagnosis"
	desc = "A practiced reading of the body's humors and hidden ailments. Reveals a target's condition, with greater skill granting deeper detail. By embedding a Forceps on your patient, you may even identify substances within the blood; but even the most unskilled physicker can tell from a Cheele or Leech's reactions."
	cast_range = 4 // 2 range doesn't let you see over a meeting table, 4 range is just enough for that, it also falls in line with normal miracle
	associated_skill = /datum/skill/misc/medicine
	is_miracle = FALSE
	devotion_cost = 0 //Doctors are not clerics
	// cooldown should be 1:1 with the parent skill

#undef DIAGNOSE_HAS_LEECH
#undef DIAGNOSE_HAS_INCISION
#undef DIAGNOSE_HAS_HEMOSTAT

/obj/effect/proc_holder/spell/invoked/attach_bodypart
	name = "Bodypart Miracle"
	desc = "Attach all limbs and organs you are holding, and on the same tile as the target."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "flextape"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/gore/flesh_eat_03.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 60 SECONDS
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/invoked/attach_bodypart/cast(list/targets, mob/living/user)
	if(!targets || !targets.len)
		to_chat(user, span_warning("No target found!"))
		revert_cast()
		return FALSE
	var/mob/living/target = targets[1]
	if(!ishuman(target))
		to_chat(user, span_warning("The spell can only be cast on humans!"))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/human_target = target
	var/same_owner = FALSE
	var/attached_count = 0
	if(human_target.has_status_effect(/datum/status_effect/buff/necras_vow))
		same_owner = TRUE
		to_chat(user, span_warning("This one has pledged a vow to Necra. Only their own limbs will be accepted."))

	// Get missing limbs first
	var/list/missing_limbs = human_target.get_missing_limbs()

	// Search caster's hands and free-standing items on the target's turf
	var/turf/target_turf = get_turf(human_target)
	var/list/search_items = list()
	if(user)
		search_items += user.held_items
	search_items += target_turf.contents

	// Try to attach limbs
	for(var/obj/item/bodypart/limb in search_items)
		if(!(limb.body_zone in missing_limbs))
			continue

		// Skip if limb is already attached to someone
		if(limb.owner && limb.owner != human_target)
			continue

		// Necra vow check
		if(same_owner && limb.original_owner && limb.original_owner != human_target)
			to_chat(user, span_warning("Limb [limb] doesn't belong to target due to Necra vow!"))
			continue

		// Check if target already has this limb
		if(human_target.get_bodypart(limb.body_zone))
			continue

		// Try to attach the limb
		if(limb.attach_limb(human_target))
			human_target.visible_message(
				span_info("\The [limb] attaches itself to [human_target]!"),
				span_notice("\The [limb] attaches itself to me!")
			)
			attached_count++
			to_chat(user, span_green("Successfully attached [limb]"))
			missing_limbs -= limb.body_zone
		else
			to_chat(user, span_warning("Failed to attach [limb]"))

	// Now handle organs
	var/list/missing_organs = list(
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_GUTS,
	)

	// Remove organs that are already present
	for(var/organ_slot in missing_organs)
		if(human_target.getorganslot(organ_slot))
			missing_organs -= organ_slot

	// Try to attach organs from the same sources
	for(var/obj/item/organ/organ in search_items)
		if(!(organ.slot in missing_organs))
			continue

		// Skip if organ is already in someone
		if(organ.owner && organ.owner != human_target)
			continue

		// Necra vow check for organs
		if(same_owner && organ.owner && organ.owner != human_target)
			continue

		// Check if target already has this organ
		if(human_target.getorganslot(organ.slot))
			continue

		// Try to insert the organ
		if(organ.Insert(human_target))
			human_target.visible_message(
				span_info("\The [organ] attaches itself to [human_target]!"),
				span_notice("\The [organ] attaches itself to me!")
			)
			attached_count++
			to_chat(user, span_green("Successfully attached [organ]"))
			missing_organs -= organ.slot
		else
			to_chat(user, span_warning("Failed to attach [organ]"))

	if(attached_count > 0)
		if(!(human_target.mob_biotypes & MOB_UNDEAD))
			for(var/obj/item/bodypart/limb in human_target.bodyparts)
				limb.rotted = FALSE
				limb.skeletonized = FALSE
		human_target.update_body()
	else
		to_chat(user, span_warning("No body parts were attached."))

	return TRUE

/obj/effect/proc_holder/spell/invoked/infestation
	name = "Infestation"
	desc = "Causes a swarm of bugs to surround your target, bites them and causes sickness. Infecting targets gives you charges to use other spells."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "infestation0"
	releasedrain = 50
	chargetime = 1 SECONDS
	recharge_time = 20 SECONDS
	range = 8
	warnie = "spellwarning"
	movement_interrupt = FALSE
	no_early_release = FALSE
	devotion_cost = 50 // attack miracle
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/whiteflame.ogg'
	chargedloop = /datum/looping_sound/fliesloop
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	miracle = TRUE
	invocation_type = "shout"
	invocations = list("Rot, take them.")
	var/datum/component/infestation_charges/charge_component

/obj/effect/proc_holder/spell/invoked/infestation/on_gain(mob/living/user)
	// Note: there is no logic to remove the component yet, this should be fine
	. = ..()
	if(overlay_state && !hide_charge_effect)
		var/obj/effect/R = new /obj/effect/spell_rune
		R.icon = action_icon
		R.icon_state = "infestation10"
		mob_charge_effect = R
	if(user && !charge_component)
		// Sanity check
		var/datum/component/existing_component = user.GetComponent(/datum/component/infestation_charges)
		if(existing_component)
			charge_component = existing_component
			charge_component.parent_spell = src
		else
			charge_component = user.AddComponent(/datum/component/infestation_charges, src)

/obj/effect/proc_holder/spell/invoked/infestation/proc/update_charge_overlay(charge_count)
	overlay_state = "infestation[charge_count]"
	update_icon()
	action.build_all_button_icons(force = TRUE)
	action.desc = "[desc]\n<span class='notice'>Charges = [charge_count]</span>"

/obj/effect/proc_holder/spell/invoked/infestation/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(isliving(target))
		var/mob/living/carbon/M = target
		if(spell_guard_check(M, TRUE))
			M.visible_message(span_warning("[M] wards off the pestilent vermin!"))
			return TRUE
		M.visible_message(span_warning("[M] is surrounded by a cloud of pestilent vermin!"), span_notice("You surround [M] in a cloud of pestilent vermin!"))
		M.apply_status_effect(/datum/status_effect/buff/infestation/) //apply debuff
		SEND_SIGNAL(src, COMSIG_INFESTATION_CHARGE_ADD, 10)
		if(!M.mind)
			M.visible_message(span_necrosis("The infestation contaminates [M] with a rapidly spreading disease."))
		return TRUE
	if(SSchimeric_tech.get_node_status("INFESTATION_ROT_SNACKS") && istype(target, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/snack = target
		if(snack.eat_effect == /datum/status_effect/debuff/rotfood)
			revert_cast()
			return FALSE

		var/total_charge = 5
		var/rotted_count = 1
		var/search_count = SSchimeric_tech.get_infestation_food_rot_count()
		snack.become_rotten()

		var/list/potential_snacks = range(1, snack.loc)
		var/list/valid_snacks = list()
		for(var/atom/A in potential_snacks)
			if(!istype(A, /obj/item/reagent_containers/food/snacks))
				continue
			var/obj/item/reagent_containers/food/snacks/S = A
			if(S == snack)
				continue
			if(S.eat_effect == /datum/status_effect/debuff/rotfood)
				continue
			valid_snacks += S
		for(var/obj/item/reagent_containers/food/snacks/extra_snack in valid_snacks)
			if(rotted_count >= search_count)
				break
			extra_snack.become_rotten()
			total_charge += 5
			rotted_count++
		if(rotted_count <= 1)
			snack.visible_message(span_warning("[snack] is swarmed by vermin and rapidly rots!"))
		else
			snack.visible_message(span_warning("Some food is swarmed by vermin and rapidly rots!"))
		SEND_SIGNAL(src, COMSIG_INFESTATION_CHARGE_ADD, total_charge)
		return TRUE
	revert_cast()
	return FALSE

/datum/status_effect/buff/infestation
	id = "infestation"
	alert_type = /atom/movable/screen/alert/status_effect/buff/infestation
	duration = 10 SECONDS
	effectedstats = list(STATKEY_CON = -2)
	var/static/mutable_appearance/rotten = mutable_appearance('icons/roguetown/mob/rotten.dmi', "rotten")
	var/extended_duration = FALSE
	var/next_spread = 0 // see I learned my lesson! :>
	var/death_burst_done = FALSE

/datum/status_effect/buff/infestation/on_apply()
	. = ..()
	var/mob/living/target = owner
	if(owner.stat == DEAD) // infinite corpse miasma explosions are cool but not the scope here, soz!
		qdel(src)
	to_chat(owner, span_danger("I am suddenly surrounded by a cloud of bugs!"))
	target.Jitter(20)
	target.add_overlay(rotten)
	target.update_vision_cone()
	if(!target.mind)
		target.change_stat(STATKEY_SPD, -5) // rot take them
	next_spread = world.time + 5 SECONDS

/datum/status_effect/buff/infestation/on_remove()
	var/mob/living/target = owner
	if(owner.stat == DEAD)
		return
	target.cut_overlay(rotten)
	target.update_vision_cone()
	if(!target.mind)
		target.change_stat(STATKEY_SPD, 5) // rot take them
	. = ..()

/datum/status_effect/buff/infestation/tick()
	var/mob/living/target = owner
	var/mob/living/carbon/C = target
	if(!extended_duration && !target.mind) // 30 seconds on npc so we don't need to worry too much about upkeep and can focus on healing friends
		duration += 20 SECONDS
		extended_duration = TRUE
	if(!target.mind) // technically speaking we're just turning the brain rot into actual body rot, rotception
		target.adjustToxLoss(3)
		target.adjustBruteLoss(1)
		target.adjustOxyLoss(2)
		if(!target.getToxLoss())
			target.adjustBruteLoss(3)
		if(!target.getOxyLoss())
			target.adjustBruteLoss(2)

		if(world.time >= next_spread && !(HAS_TRAIT(target,TRAIT_NOBREATH)))
			next_spread = world.time + 5 SECONDS

			if(prob(15)) // I don't want this to be guaranteed or else it'll make pve boring
				target.emote(pick("gag","cough","breathgasp"))
				var/turf/open/T = get_turf(target)
				if(istype(T))
					T.pollute_turf(/datum/pollutant/rot, 5)

				for(var/mob/living/carbon/M in range(2, target))
					if(M == target || M.has_status_effect(/datum/status_effect/buff/infestation) || M.mind)
						continue
					if(!HAS_TRAIT(target,TRAIT_NOBREATH) && !target.mind)
						M.visible_message(span_necrosis("[M] is engulfed by a cloud of pestilence!"), span_danger("The infestation spreads to me!"))
						M.apply_status_effect(/datum/status_effect/buff/infestation)

		if(target.stat == DEAD && !death_burst_done)
			death_burst_done = TRUE
			target.visible_message(span_userdanger("[target]'s corpse ruptures into a horrific cloud of rotting miasma!"))
			var/turf/open/DT = get_turf(target)
			if(istype(DT))
				DT.pollute_turf(/datum/pollutant/rot, 15)

			for(var/mob/living/carbon/M in range(5, target))
				if(M == target)
					continue
				if(M.has_status_effect(/datum/status_effect/buff/infestation))
					continue
				if(!HAS_TRAIT(M,TRAIT_NOBREATH) && !M.mind)
					M.visible_message(span_necrosis("[target] is contaminated by [M]!"), span_danger("The plague-ridden miasma descends upon me!"))
					M.apply_status_effect(/datum/status_effect/buff/infestation)
	else // i mean at least we got pestilent blade or something idk
		target.adjustBruteLoss(2)
	var/prompt = pick(1,2,3)
	var/message = pick(
		"Ticks on my skin start to engorge with blood!",
		"Flies are laying eggs in my open wounds!",
		"Something crawled in my ear!",
		"There are too many bugs to count!",
		"They're trying to get under my skin!",
		"Make it stop!",
		"Millipede legs tickle the back of my ear!",
		"Fire ants bite at my feet!",
		"A wasp sting right on the nose!",
		"Cockroaches scurry across my neck!",
		"Maggots slimily wriggle along my body!",
		"Beetles crawl over my mouth!",
		"Fleas bite my ankles!",
		"Gnats buzz around my face!",
		"Lice suck my blood!",
		"Crickets chirp in my ears!",
		"Earwigs crawl into my ears!")
	if(prompt == 1 && iscarbon(C))
		C.add_nausea(pick(10,20))
		to_chat(target, span_warning(message))

/atom/movable/screen/alert/status_effect/buff/infestation
	name = "Infestation"
	desc = "Pestilent vermin bite and chew at my skin."
	icon_state = "debuff"

// Cure rot
/obj/effect/proc_holder/spell/invoked/cure_rot
	name = "Cure Rot"
	desc = "Invoke Pestra's will though a Psycross to cast out rot from people or regrow their flesh."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "rot"
	releasedrain = 90
	chargedrain = 0
	chargetime = 50
	range = 1
	warnie = "sydwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/revive.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 2 MINUTES
	miracle = TRUE
	devotion_cost = 30
	/// Amount of PQ gained for curing zombos
	var/unzombification_pq = PQ_GAIN_UNZOMBIFY
	var/is_lethal = TRUE

/obj/effect/proc_holder/spell/invoked/cure_rot/priest
	desc = "Burn out the rot by Astrata's will."
	is_lethal = FALSE

/obj/effect/proc_holder/spell/invoked/cure_rot/cast(list/targets, mob/living/user)
	var/stinky = FALSE
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]

		var/obj/item/black_rose/rose = user.get_active_held_item()
		// Check if the user is holding a black rose and the target follows Pestra.
		if(istype(rose) && target.patron?.type == /datum/patron/divine/pestra)
			// If the target is a Pestran and we are holding the rose, implant the component.
			var/time_elapsed = STATION_TIME_PASSED() / (1 MINUTES)
			if(time_elapsed < 45)
				var/time_left = 45 - time_elapsed
				to_chat(user, span_smallred("Pestra's rot is still preparing to bloom. Wait another [round(time_left, 0.1)] minutes."))
				revert_cast()
			if(!target.GetComponent(/datum/component/infestation_black_rot))
				target.AddComponent(/datum/component/infestation_black_rot)
				ADD_TRAIT(target, TRAIT_PESTRAS_BLESSING, TRAIT_MIRACLE)
				target.visible_message(span_notice("[user] gently presses the [rose] against [target]'s flesh. The rose dissolves, leaving a black mark."), \
										span_userdanger("The rose fuses with my flesh, granting me the trait of Pestra's protection."))
				qdel(rose)
				return TRUE
			else
				to_chat(user, span_warning("[target] is already infused with Pestra's black blessing."))
				revert_cast()
				return FALSE
		if(!target.mind.has_spell(/datum/action/cooldown/spell/summon_bed/pestra) && target.patron?.type == /datum/patron/divine/pestra && target.get_skill_level(/datum/skill/magic/holy) >= 1 && SSchimeric_tech.get_node_status("BLACK_ROSE"))
			target.visible_message(span_green("[target]'s body seems to jitter for a moment, their eyes flash with black rot momentarily."), span_green("Thanks to your affinity to Pestra, you can now create black rose petal beds."))
			target.mind.AddSpell(new /datum/action/cooldown/spell/summon_bed/pestra)

		if(GLOB.tod == "night")
			to_chat(user, span_warning("Let there be light."))
		for(var/obj/structure/fluff/psycross/S in oview(5, user))
			S.AOE_flash(user, range = 8)

		var/datum/antagonist/zombie/was_zombie = target.mind?.has_antag_datum(/datum/antagonist/zombie)
		if(target.stat == DEAD || was_zombie)	//Checks if the target is a dead rotted corpse
			var/datum/component/rot/rot = target.GetComponent(/datum/component/rot)
			if(rot && rot.amount && rot.amount >= 5 MINUTES)	//Fail-safe to make sure the dead person has at least rotted for ~5 min.
				stinky = TRUE

		if(remove_rot(target = target, user = user, method = "prayer",
			success_message = "The rot leaves [target]'s body!",
			fail_message = "Nothing happens.", lethal = is_lethal))
			target.visible_message(span_notice("The rot leaves [target]'s body!"), span_green("I feel the rot leave my body!"))
			target.remove_status_effect(/datum/status_effect/debuff/rotted_zombie)	//Removes the rotted-zombie debuff if they have it.
			if(stinky)
				target.apply_status_effect(/datum/status_effect/debuff/rotted)	//Perma debuff, needs cure
			return TRUE
		else //Attempt failed, no rot
			target.visible_message(span_warning("The rot fails to leave [target]'s body!"), span_warning("I feel no different..."))
			return FALSE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/cure_rot/cast_check(skipcharge, mob/user = usr)
	if(!..())
		return FALSE
	var/found = null
	for(var/obj/structure/fluff/psycross/S in oview(5, user))
		found = S
	if(!found)
		to_chat(user, span_warning("I need a holy cross."))
		revert_cast()
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/pestra_leech
	name = "Leeching Purge"
	desc = "Manifest leeches inside of target, causing them to puke them out while restoring some blood and curing minor poisoning."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "leech"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/gore/flesh_eat_03.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 60 SECONDS
	miracle = TRUE
	devotion_cost = 30

/obj/effect/proc_holder/spell/invoked/pestra_leech/cast(list/targets, mob/living/user)
	if(iscarbon(targets[1]))
		var/mob/living/carbon/C = targets[1]
		if(C.cmode)
			to_chat(user, span_warning("They're too tense for the delicate arts!"))
			revert_cast()
			return FALSE
		C.vomit()
		C.adjustToxLoss(-30)
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume = min(C.blood_volume+30, BLOOD_VOLUME_NORMAL)
		C.visible_message(span_warning("[C] expels some leeches out of them!"), span_warning("Something roils within me!"))
		new /obj/item/natural/worms/leech(get_turf(C))
		if(prob( (user.get_skill_level(/datum/skill/magic/holy) * 10) ))
			new /obj/item/natural/worms/leech(get_turf(C))
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/pestra_heal
	name = "Rebirth"
	desc = "A greater heal, more effective on targets affected by some form of greater rot. Requires infestation charges to cast."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "heal"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0.6 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/heal.ogg'
	invocations = list("Pestra! Let them be reborn!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 10 SECONDS
	miracle = TRUE
	// Greater heal, but requires a resource to cast.
	devotion_cost = 45
	var/datum/component/infestation_charges/charge_component

/obj/effect/proc_holder/spell/invoked/pestra_heal/cast_check(skipcharge, mob/user = usr)
	if(!..())
		return FALSE
	if(!charge_component)
		charge_component = user.GetComponent(/datum/component/infestation_charges)
	// Check again just in case the component got deleted somehow!
	if(!charge_component || charge_component.get_charges() < 1)
		to_chat(user, span_warning("I need at least one infestation charge to cast this spell!"))
		update_charges(0)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/pestra_heal/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/charge_count
		if(!charge_component)
			to_chat(user, span_warning("Oopsie woopsie, seems the infestation gear somehow got lost... Make a bug report!"))
			revert_cast()
			return FALSE
		charge_count = charge_component.get_charges()
		if(charge_count < 1)
			to_chat(user, span_warning("I need at least one infestation charge to cast this spell!"))
			update_charges(charge_count)
			revert_cast()
			return FALSE
		var/mob/living/target = targets[1]
		if(HAS_TRAIT(target, TRAIT_PSYDONITE))
			target.visible_message(span_info("[target] stirs for a moment, the miracle dissipates."), span_blue("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
			playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return TRUE
		if(HAS_TRAIT(target, TRAIT_UNFORGIVABLE)) //Vhelsynites aren't affected
			target.visible_message(span_info("[target] stirs for a moment, the miracle dissipates."), span_blue("A dull warmth passes through your hollow husk of a body, only to fade as quickly as it arrived."))
			playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return TRUE
		// Keep in mind this is 7.5 per tick with fortify!
		// Double the power of miracle
		var/healing = 5
		target.visible_message(span_info("Skittering ghostly bugs envelop [target]!"), span_notice("Ethereal bugs knit my flesh back together with their mandibles!"))
		target.apply_status_effect(/datum/status_effect/buff/healing, healing)
		// 225 healing but slowly released across 10 minutes, can't be refreshed.
		target.apply_status_effect(/datum/status_effect/buff/pestra_care)
		remove_infestation_charges(user, 10)
		// We just reduced it by 1 so we can assume that we might not have enough charges to cast again.
		update_charges(charge_count - 1)
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/pestra_heal/proc/update_charges(charge_count)
	if(charge_count > 0)
		overlay_state = "heal"
	else
		overlay_state = "heal_disabled"
	update_icon()
	if(action)
		action.build_all_button_icons(force = TRUE)

/obj/effect/proc_holder/spell/invoked/divine_rebirth
	name = "Divine Rebirth"
	desc = "A miraculous heal that can restore even the most grievous wounds, including missing limbs. But it requires being at maximum infestation capacity. No force can resist this miracle."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "heal_ascended"
	releasedrain = 50
	chargedrain = 0
	chargetime = 2 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/ahh2.ogg'
	invocations = list("O SWARM MOTHER, CONSUME AND CLEANSE!!!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	// Doesn't matter in the slightest, as the cooldown of this is handled by the component, not the spell.
	recharge_time = 999 MINUTES
	miracle = TRUE
	devotion_cost = 250
	chargedloop = /datum/looping_sound/invokeholy

// Given this is Pestra's true T4 spell, and it is limited in availability and gated heavily behind tech, this heal does affect Psydonites.
// You can't resist Pestra's most divine gift.
/obj/effect/proc_holder/spell/invoked/divine_rebirth/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		target.visible_message(span_info("An ethereal, mushroom infested arm caresses [target]!"), span_notice("I feel a caring touch!"))
		target.apply_status_effect(/datum/status_effect/buff/divine_rebirth_healing)
		SEND_SIGNAL(user, COMSIG_DIVINE_REBIRTH_CAST, target)
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/pestilent_blade
	name = "Pestilent Blade"
	desc = "Enchant your blade with Pestra's power, consuming one infestation charge to make your next strike against an infested target more potent. Negligible effect if the target isn't infested..."
	overlay_icon = 'icons/mob/actions/pestraspells.dmi'
	action_icon = 'icons/mob/actions/pestraspells.dmi'
	overlay_state = "blade"
	releasedrain = 20
	chargedrain = 0
	chargetime = 1 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	range = 1 // Self-target
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/slimesquish.ogg'
	invocations = list("Pestra, bless this blade!")
	invocation_type = "whisper"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 30 SECONDS
	miracle = TRUE
	devotion_cost = 25
	var/datum/component/infestation_charges/charge_component

/obj/effect/proc_holder/spell/invoked/pestilent_blade/cast_check(skipcharge, mob/user = usr)
	if(!..())
		return FALSE

	if(!charge_component)
		charge_component = user.GetComponent(/datum/component/infestation_charges)

	if(!charge_component || charge_component.get_charges() < 1)
		to_chat(user, span_warning("I need at least one infestation charge to enchant my blade!"))
		return FALSE

	var/obj/item/held_item = user.get_active_held_item()
	if(!held_item || !isitem(held_item))
		to_chat(user, span_warning("I need to be holding a weapon to enchant it!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/pestilent_blade/cast(list/targets, mob/living/user)
	var/obj/item/weapon = user.get_active_held_item()
	if(!weapon || !isitem(weapon))
		to_chat(user, span_warning("I must hold a weapon to enchant it!"))
		revert_cast()
		return FALSE

	if(!charge_component || charge_component.get_charges() < 1)
		to_chat(user, span_warning("The infestation charges have been depleted!"))
		revert_cast()
		return FALSE

	if(weapon.AddComponent(/datum/component/pestilent_blade_enchant))
		remove_infestation_charges(user, 10)
		to_chat(user, span_infection("I feel pestilence flow into my [weapon.name]!"))
		weapon.visible_message(span_infection("[weapon] glows with a sickly green light!"))
		return TRUE

	revert_cast()
	return FALSE
