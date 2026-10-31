/datum/surgery/healing
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp,
		/datum/surgery_step/retract,
		/datum/surgery_step/heal,
		/datum/surgery_step/cauterize,
	)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery_step/heal
	name = "Healing surgery"
	implements = list(
		TOOL_SUTURE = 80,
		TOOL_HEMOSTAT = 60,
		TOOL_IMPROVISED_HEMOSTAT = 50,
		TOOL_SCREWDRIVER = 50,
	)
	target_mobtypes = list(/mob/living/carbon/human)
	time = 4 SECONDS
	/// Unmodified do-after length; `time` is recalculated from this every application.
	var/base_time = 4 SECONDS
	requires_tech = TRUE
	replaced_by = /datum/surgery_step
	repeating = TRUE
	repeatingonfail = TRUE
	surgery_flags = SURGERY_BLOODY | SURGERY_CLAMPED
	skill_min = SKILL_LEVEL_NONE
	skill_median = SKILL_LEVEL_NONE
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	/// How much brute damage we heal per completion
	var/brutehealing = 0
	/// How much burn damage we heal per completion
	var/burnhealing = 0
	/// How much we heal each wound (whp) on the limb per completion
	var/woundhealing = 0

/// Wounds on this limb that this step can treat (everything with whp except the surgical incision).
/datum/surgery_step/heal/proc/get_treatable_wounds(obj/item/bodypart/limb)
	var/list/treatable = list()
	for(var/datum/wound/W as anything in limb.wounds)
		if(W.whp <= 0)
			continue
		if(istype(W, /datum/wound/slash/incision))
			continue
		treatable += W
	return treatable

/// Returns the bodypart that most needs this step's healing, or null if nothing qualifies.
/// Form steps rank limbs by brute/burn damage, wound steps rank them by wounds (incision excluded).
/datum/surgery_step/heal/proc/get_worst_limb(mob/living/carbon/human/target)
	var/obj/item/bodypart/worst
	var/worst_priority = 0
	for(var/obj/item/bodypart/BP as anything in target.bodyparts)
		if(!BP || QDELETED(BP))
			continue
		var/priority = 0
		if(brutehealing)
			priority += BP.brute_dam
		if(burnhealing)
			priority += BP.burn_dam
		if(woundhealing)
			for(var/datum/wound/W as anything in get_treatable_wounds(BP))
				priority += (W.severity >= WOUND_SEVERITY_MODERATE) ? 20 : 10
		if(priority > worst_priority)
			worst_priority = priority
			worst = BP
	return worst

/// Wound steps only: once every other injury is cured, returns the limb holding the surgical incision.
/datum/surgery_step/heal/proc/get_incision_limb(mob/living/carbon/human/target)
	if(!woundhealing)
		return null
	if(get_worst_limb(target))
		return null
	if(target.getBruteLoss() > 0 || target.getFireLoss() > 0)
		return null
	for(var/obj/item/bodypart/BP as anything in target.bodyparts)
		if(length(get_treatable_wounds(BP)))
			return null
	for(var/obj/item/bodypart/BP as anything in target.bodyparts)
		if(locate(/datum/wound/slash/incision) in BP.wounds)
			return BP
	return null

/// What we're treating on this limb, as text: "bruises and burns" or the wound names.
/datum/surgery_step/heal/proc/get_treated_text(obj/item/bodypart/limb)
	var/list/names = list()
	if(woundhealing)
		for(var/datum/wound/W as anything in get_treatable_wounds(limb))
			names += W.name
		return english_list(names)
	if(brutehealing && limb.brute_dam > 0)
		names += "bruises"
	if(burnhealing && limb.burn_dam > 0)
		names += "burns"
	return english_list(names)

/// Limb condition from its own _msg vars, limited to the damage types it had before treatment.
/// show_brute / show_burn should be captured BEFORE healing so we never report a type that was never there.
/datum/surgery_step/heal/proc/get_limb_condition(obj/item/bodypart/limb, show_brute, show_burn)
	var/list/parts = list()
	if(show_brute)
		if(limb.brute_dam > 0)
			var/brute_pct = limb.brute_dam / limb.max_damage
			parts += (brute_pct < 0.4) ? limb.light_brute_msg : ((brute_pct < 0.75) ? limb.medium_brute_msg : limb.heavy_brute_msg)
		else
			parts += limb.no_brute_msg
	if(show_burn)
		if(limb.burn_dam > 0)
			var/burn_pct = limb.burn_dam / limb.max_damage
			parts += (burn_pct < 0.4) ? limb.light_burn_msg : ((burn_pct < 0.75) ? limb.medium_burn_msg : limb.heavy_burn_msg)
		else
			parts += limb.no_burn_msg
	return english_list(parts)

/// Pulls every embedded object out of every limb (and any simple embeds) and announces it.
/datum/surgery_step/heal/proc/pull_embeds(mob/user, mob/living/carbon/human/target)
	if(!length(target.get_embedded_objects()))
		return
	var/list/removed = list()
	for(var/obj/item/bodypart/BP as anything in target.bodyparts)
		if(!length(BP.embedded_objects))
			continue
		for(var/obj/item/embedded as anything in BP.embedded_objects.Copy())
			removed += "[embedded] from [target.p_their()] [BP.name]"
			BP.remove_embedded_object(embedded)
	if(length(target.simple_embedded_objects))
		for(var/obj/item/embedded as anything in target.simple_embedded_objects.Copy())
			removed += "[embedded]"
			target.simple_remove_embedded_object(embedded)
	if(!length(removed))
		return
	display_results(user, target, span_warning("I draw out [english_list(removed)]."),
		span_warning("[user] draws out [english_list(removed)]."),
		span_warning("[user] draws out [english_list(removed)]."))

/datum/surgery_step/heal/validate_tech(mob/user, mob/living/target, target_zone, datum/intent/intent)
	if(!brutehealing && !burnhealing && !woundhealing)
		return FALSE
	return ..()

/datum/surgery_step/heal/validate_target(mob/user, mob/living/target, target_zone, datum/intent/intent)
	. = ..()
	if(!.)
		return
	if(!ishuman(target))
		return FALSE
	if(!get_worst_limb(target) && !get_incision_limb(target))
		return FALSE

/datum/surgery_step/heal/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	// Medicine speed bonus: Expert 15% faster, Master 30% faster, Legendary 60% faster.
	var/speed_mult = 1
	switch(user.get_skill_level(skill_used))
		if(SKILL_LEVEL_EXPERT)
			speed_mult = 0.85
		if(SKILL_LEVEL_MASTER)
			speed_mult = 0.7
		if(SKILL_LEVEL_LEGENDARY)
			speed_mult = 0.4
	time = base_time * speed_mult

	var/obj/item/bodypart/affecting = get_worst_limb(target)
	if(!affecting)
		var/obj/item/bodypart/incision_limb = get_incision_limb(target)
		if(!incision_limb)
			return FALSE
		display_results(user, target, span_warning("I begin to sew shut the incision on [target]'s [incision_limb.name]."),
			span_warning("[user] begins to sew shut the incision on [target]'s [incision_limb.name]."),
			span_warning("[user] begins to sew shut the incision on [target]'s [incision_limb.name]."))
		return TRUE

	var/treated = get_treated_text(affecting)
	display_results(user, target, span_warning("I begin to treat [target]'s [treated] on [target.p_their()] [affecting.name]."),
		span_warning("[user] begins to treat [target]'s [treated] on [target.p_their()] [affecting.name]."),
		span_warning("[user] begins to treat [target]'s [treated] on [target.p_their()] [affecting.name]."))
	return TRUE

/datum/surgery_step/heal/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	var/mob/living/carbon/human/H = target
	// Limb is recomputed here because step datums are shared.
	var/obj/item/bodypart/affecting = get_worst_limb(H)

	// Everything else is cured: sew the surgical incision, then pull any embeds.
	if(!affecting)
		var/obj/item/bodypart/incision_limb = get_incision_limb(H)
		if(!incision_limb)
			return TRUE
		var/datum/wound/incision = locate(/datum/wound/slash/incision) in incision_limb.wounds
		if(incision)
			incision.sew_wound()
		pull_embeds(user, target)
		display_results(user, target, span_blue("I sew shut the incision on [target]'s [incision_limb.name]."),
			span_blue("[user] sews shut the incision on [target]'s [incision_limb.name]."),
			span_blue("[user] sews shut the incision on [target]'s [incision_limb.name]."))
		H.update_damage_overlays()
		target.update_damage_hud()
		return TRUE

	var/medicine_level = user.get_skill_level(skill_used)
	var/healing_multiplier = 1
	switch(medicine_level)
		if(SKILL_LEVEL_JOURNEYMAN)
			healing_multiplier = 1.2
		if(SKILL_LEVEL_EXPERT)
			healing_multiplier = 1.4
		if(SKILL_LEVEL_MASTER)
			healing_multiplier = 1.7
		if(SKILL_LEVEL_LEGENDARY)
			healing_multiplier = 2

	// Bonus = (5 * medicine level)% of current damage (brute/fire for form, whp for wounds).
	var/bonus_pct = 0.05 * medicine_level

	var/accessible_mult = 1
	var/clothing_note = ""
	if(!get_location_accessible(target, target_zone))
		accessible_mult = 0.55
		clothing_note = " as best as can be managed through the clothing"

	if(woundhealing)
		// Remember which wounds we're treating so we can report which ones closed.
		var/list/treated_wounds = get_treatable_wounds(affecting)
		var/list/wound_names = list()
		for(var/datum/wound/W as anything in treated_wounds)
			wound_names += W.name
			W.heal_wound(((woundhealing * healing_multiplier) + (W.whp * bonus_pct)) * accessible_mult)

		var/list/open_names = list()
		for(var/datum/wound/W as anything in treated_wounds)
			if(QDELETED(W) || !(W in affecting.wounds) || W.whp <= 0)
				continue
			open_names += W.name

		var/wound_status
		if(length(open_names))
			wound_status = "it seems [english_list(open_names)] still [length(open_names) > 1 ? "need" : "needs"] mending"
		else
			wound_status = "it seems every wound there has closed"
		var/treated_text = english_list(wound_names)
		display_results(user, target, span_green("I patch some of [target]'s [treated_text] on [target.p_their()] [affecting.name][clothing_note], [wound_status]."),
			span_green("[user] patches some of [target]'s [treated_text] on [target.p_their()] [affecting.name][clothing_note], [wound_status]."),
			span_green("[user] patches some of [target]'s [treated_text] on [target.p_their()] [affecting.name][clothing_note], [wound_status]."))

		// Wound curing is complete once no treatable wound remains anywhere: pull out all embeds.
		if(!get_worst_limb(H))
			pull_embeds(user, target)
	else
		// Capture which damage types the limb had BEFORE healing; only those get reported.
		var/had_brute = affecting.brute_dam > 0
		var/had_burn = affecting.burn_dam > 0
		var/treated = get_treated_text(affecting)

		var/urhealedamt_brute = brutehealing * healing_multiplier
		var/urhealedamt_burn = burnhealing * healing_multiplier
		if(brutehealing)
			urhealedamt_brute += target.getBruteLoss() * bonus_pct
		if(burnhealing)
			urhealedamt_burn += target.getFireLoss() * bonus_pct
		affecting.heal_damage(urhealedamt_brute * accessible_mult, urhealedamt_burn * accessible_mult)

		// Condition is read after healing, so it describes how the limb looks now.
		var/condition = get_limb_condition(affecting, had_brute, had_burn)
		display_results(user, target, span_green("I patch some of [target]'s [treated] on [target.p_their()] [affecting.name][clothing_note], it seems [condition]."),
			span_green("[user] patches some of [target]'s [treated] on [target.p_their()] [affecting.name][clothing_note], it seems [condition]."),
			span_green("[user] patches some of [target]'s [treated] on [target.p_their()] [affecting.name][clothing_note], it seems [condition]."))

	H.update_damage_overlays()
	target.update_damage_hud()
	return TRUE

/datum/surgery_step/heal/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent, success_prob)
	var/mob/living/carbon/human/H = target
	// Same limb the step was working on (recomputed, since step datums are shared).
	var/obj/item/bodypart/affecting = get_worst_limb(H)

	// Botched the incision: just hurt the limb a little.
	if(!affecting)
		var/obj/item/bodypart/incision_limb = get_incision_limb(H)
		if(!incision_limb)
			return TRUE
		incision_limb.receive_damage(woundhealing * 0.8, 0)
		display_results(user, target, span_red("I screwed up! My stitch tears [target]'s incision on [target.p_their()] [incision_limb.name]."),
			span_red("[user] screws up, tearing [target]'s incision on [target.p_their()] [incision_limb.name]!"),
			span_red("[user] screws up, tearing [target]'s incision on [target.p_their()] [incision_limb.name]!"), TRUE)
		H.update_damage_overlays()
		target.update_damage_hud()
		return TRUE

	if(woundhealing)
		// Worsen the worst treatable wound on this limb.
		var/datum/wound/worst_wound
		for(var/datum/wound/W as anything in get_treatable_wounds(affecting))
			if(!worst_wound || W.whp > worst_wound.whp)
				worst_wound = W
		var/wound_name = "wounds"
		if(worst_wound)
			worst_wound.whp += woundhealing * 0.8
			wound_name = worst_wound.name
		display_results(user, target, span_red("I screwed up! I've worsened [target]'s [wound_name] on [target.p_their()] [affecting.name]."),
			span_red("[user] screws up, worsening [target]'s [wound_name] on [target.p_their()] [affecting.name]!"),
			span_red("[user] screws up, worsening [target]'s [wound_name] on [target.p_their()] [affecting.name]!"), TRUE)
	else
		// Only damage the types the limb already had, so a failure never invents a new kind of injury.
		var/had_brute = affecting.brute_dam > 0
		var/had_burn = affecting.burn_dam > 0
		var/treated = get_treated_text(affecting)
		affecting.receive_damage(had_brute ? brutehealing * 0.8 : 0, had_burn ? burnhealing * 0.8 : 0)
		var/condition = get_limb_condition(affecting, had_brute, had_burn)
		display_results(user, target, span_red("I screwed up! I've worsened [target]'s [treated] on [target.p_their()] [affecting.name], it seems [condition]."),
			span_red("[user] screws up, worsening [target]'s [treated] on [target.p_their()] [affecting.name]!"),
			span_red("[user] screws up, worsening [target]'s [treated] on [target.p_their()] [affecting.name]!"), TRUE)

	H.update_damage_overlays()
	target.update_damage_hud()
	return TRUE

/********************STEPS********************/
/datum/surgery_step/heal/form
	name = "Cure damage surgery"
	brutehealing = 5
	burnhealing = 5
	requires_tech = FALSE
	replaced_by = null

/datum/surgery_step/heal/wounds
	name = "Cure wounds surgery"
	woundhealing = 5
	requires_tech = FALSE
	replaced_by = null
