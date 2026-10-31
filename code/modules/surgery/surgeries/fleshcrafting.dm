/datum/surgery/organ_reconstruction
	name = "Reconstruct organs"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp,
		/datum/surgery_step/retract,
		/datum/surgery_step/shape_viscera,
		/datum/surgery_step/cauterize,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	target_mobtypes = list(/mob/living/carbon/human)


/datum/surgery_step/shape_viscera
	name = "Shape viscera into organs"
	implements = list(
		/obj/item/alch/viscera = 100,
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	target_mobtypes = list(/mob/living/carbon/human)
	time = 8 SECONDS
	surgery_flags = SURGERY_CLAMPED
	skill_min = SKILL_LEVEL_JOURNEYMAN
	skill_median = SKILL_LEVEL_EXPERT
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	repeating = TRUE
	/// Fallback if the species doesn't define its own organ list.
	var/list/default_organs = list(
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/cat,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/wild_tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
	)
	/// Which body zone each organ slot can be built in.
	var/list/organ_zones = list(
		ORGAN_SLOT_HEART = BODY_ZONE_CHEST,
		ORGAN_SLOT_LUNGS = BODY_ZONE_CHEST,
		ORGAN_SLOT_LIVER = BODY_ZONE_CHEST,
		ORGAN_SLOT_STOMACH = BODY_ZONE_CHEST,
		ORGAN_SLOT_APPENDIX = BODY_ZONE_CHEST,
		ORGAN_SLOT_GUTS = BODY_ZONE_CHEST,
		ORGAN_SLOT_EYES = BODY_ZONE_HEAD,
		ORGAN_SLOT_EARS = BODY_ZONE_HEAD,
		ORGAN_SLOT_TONGUE = BODY_ZONE_HEAD,
	)

/// Returns an assoc list of slot = organ type for every organ the target should have but doesn't.
/// If target_zone is given, only organs that belong in that zone are returned.
/datum/surgery_step/shape_viscera/proc/get_missing_organs(mob/living/carbon/human/target, target_zone)
	var/list/required = default_organs
	// Prefer the species' own list so e.g. non-cat races don't get cat ears.
	if(target.dna?.species?.organs)
		required = target.dna.species.organs
	var/zone = target_zone ? check_zone(target_zone) : null
	var/list/missing = list()
	for(var/slot in required)
		if(zone && organ_zones[slot] != zone)
			continue
		if(!target.getorganslot(slot))
			missing[slot] = required[slot]
	return missing

/// Turns a missing organ list into readable text, e.g. "heart, lungs and liver".
/datum/surgery_step/shape_viscera/proc/missing_organs_text(list/missing)
	var/list/names = list()
	for(var/slot in missing)
		var/obj/item/organ/organ_type = missing[slot]
		names += initial(organ_type.name)
	return english_list(names)

/datum/surgery_step/shape_viscera/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	var/list/missing_here = get_missing_organs(target, target_zone)
	if(!length(missing_here))
		var/list/missing_anywhere = get_missing_organs(target)
		if(length(missing_anywhere))
			to_chat(user, span_warning("Nothing is missing from [target]'s [parse_zone(target_zone)], but they still lack: [missing_organs_text(missing_anywhere)]. Those belong elsewhere."))
		else
			to_chat(user, span_notice("[target] isn't missing any organs. Time to cauterize."))
		return FALSE

	// Announce what's missing here, and what we're about to work on.
	to_chat(user, span_warning("[target]'s biology is lacking: [missing_organs_text(missing_here)]."))
	var/obj/item/organ/next_organ = missing_here[missing_here[1]]
	display_results(user, target, span_notice("I begin to shape the viscera into [initial(next_organ.name)] inside [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to shape viscera into something organ-like inside [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to shape viscera into something organ-like inside [target]'s [parse_zone(target_zone)]."))
	return TRUE

/datum/surgery_step/shape_viscera/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/intent/intent)
	// Step datums are shared, so recompute instead of storing state from preop.
	var/list/missing_here = get_missing_organs(target, target_zone)
	if(!length(missing_here))
		return TRUE

	var/organ_type = missing_here[missing_here[1]]
	var/obj/item/organ/new_organ = new organ_type()
	new_organ.Insert(target)

	display_results(user, target, span_notice("I shape the viscera into [new_organ] and set it in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] shapes viscera into [new_organ] and sets it in [target]'s [parse_zone(target_zone)]!"),
		span_notice("[user] shapes viscera into [new_organ] and sets it in [target]'s [parse_zone(target_zone)]!"))

	// Consume exactly one viscera per organ.
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/viscera_stack = tool
		viscera_stack.use(1)
	else
		qdel(tool)

	var/list/still_missing = get_missing_organs(target)
	if(length(still_missing))
		to_chat(user, span_warning("Still missing or destroyed: [missing_organs_text(still_missing)]."))
	else
		to_chat(user, span_notice("[target] has all of their organs now. Time to cauterize!"))
	return TRUE
