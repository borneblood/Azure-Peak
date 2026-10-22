/datum/patron/divine/abyssor
	name = "Abyssor"
	domain = "God of the Sea, Dreams, and The Unknown"
	desc = "Lord of the seas and keeper of the deep, Abyssor is a mighty god who spends much of His time in slumber beneath the waves. His moods are reflected in the waters above Him; His temper stirs the storms, and His restless dreams send great waves crashing against the shore. Yet He is no mindless destroyer. To sailors, fishermen, and those who live by the sea, He is a generous patron, providing bounty to those who respect His domain. He asks little of His followers beyond their reverence and patience, for even the mightiest of gods has little taste for being disturbed from a good nap. Still, those who mistake His quiet for weakness may soon learn what sleeps beneath the waters."
	worshippers = "Sailors, Seapeople, and Sages"
	mob_traits = list(TRAIT_ABYSSOR_SWIM, TRAIT_SEA_DRINKER, TRAIT_DEEP_DREAMER)
	traits_tier = list(TRAIT_WATERSLEEP = CLERIC_T0)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/aquatic_compulsion	= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/abyssor_wind				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssor_bends			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssor_undertow		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/abyssheal				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/call_mossback			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/call_dreamfiend		= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/abyssal_infusion		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/abyssor		= CLERIC_T4,
	)
	var/paint_miracles = list(
		/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
		/obj/effect/proc_holder/spell/invoked/aquatic_compulsion	= CLERIC_T0,
		/obj/effect/proc_holder/spell/self/abyssor_wind				= CLERIC_T0,
		/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
		/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
		/datum/action/cooldown/spell/ink_presence					= CLERIC_T1,
		/datum/action/cooldown/spell/paint_blessing					= CLERIC_T1,
		/datum/action/cooldown/spell/umbral_viscosity				= CLERIC_T2,
		/datum/action/cooldown/spell/transmute_ink					= CLERIC_T3,
		/obj/effect/proc_holder/spell/invoked/call_dreamfiend		= CLERIC_T3,
		/datum/action/cooldown/spell/recharge_pylon					= CLERIC_T4,
		/obj/effect/proc_holder/spell/invoked/resurrect/dream		= CLERIC_T4,
	)
	confess_lines = list(
		"ABYSSOR COMMANDS THE WAVES!",
		"THE OCEAN'S FURY IS ABYSSOR'S WILL!",
		"I AM DRAWN BY THE PULL OF THE TIDE!",
	)
	titles = list(
		"Dreamer",
		"Abysawa",
		"Forgotten One",
		"Siren",
		"Abysawa",
		"Aiboshen", // lingyue
		"Deepfather", // used by painter content
		"Kraken" // fjall
	)

	storyteller = /datum/storyteller/abyssor

// Near water, cross, or within the church.
/datum/patron/divine/abyssor/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer near any body of water turf.
	for(var/turf/open/water in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Abyssor to hear my prayer I must either pray within the church, near a psycross, or at any body of water so that the tides of prayer may flow.."))
	return FALSE

/datum/patron/divine/abyssor/on_lesser_heal(
	mob/living/user,
	mob/living/target,
	message_out,
	message_self,
	conditional_buff,
	situational_bonus
)
	*message_out = span_info("A mist of salt-scented vapour settles on [target]!")
	*message_self = span_notice("I'm invigorated by healing vapours!")

	if(istype(get_turf(target), /turf/open/water))
		*conditional_buff = TRUE
		*situational_bonus = 1.5
