/datum/patron/divine/necra
	name = "Necra"
	domain = "Goddess of Death and the Afterlife"
	desc = "Veiled Lady of the underworld, equally feared and respected by mortals. She taught mortals the inevitability of death and cares for them as they reach the afterlife."
	worshippers = "The Dead, Mourners, Gravekeepers"
	mob_traits = list(TRAIT_SOUL_EXAMINE, TRAIT_NOSTINK)	//No stink is generic but they deal with dead bodies so.. makes sense, I suppose?
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/necras_sight			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
<<<<<<< Updated upstream
					/obj/effect/proc_holder/spell/invoked/avert					= CLERIC_T1,
					/obj/effect/proc_holder/spell/targeted/locate_dead 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blink/shadowstep/miracle = CLERIC_T3, // im losing my mind here
					/obj/effect/proc_holder/spell/invoked/fog_ward				= CLERIC_T1, // Not bugged, only appears on fog rounds!
					/obj/effect/proc_holder/spell/self/grave_embrace			= CLERIC_T3, // the reverse absolver skill
					/obj/effect/proc_holder/spell/invoked/abrogation			= CLERIC_T2, // Reworked into a corpse disposal spell.
					/obj/effect/proc_holder/spell/invoked/bless_cross			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance = CLERIC_T2,
					/obj/effect/proc_holder/spell/self/death_harvest			= CLERIC_T4, // Most flashy (and expensive) thing ever that basically just skips the procedure of burying vast amounts of corpses, or fucks up undead NPCs.
=======
					/obj/effect/proc_holder/spell/invoked/avert					= CLERIC_T1, // tweaked, so now it can take tolls to become 'enhanced', the v2 can be used on self, as well as others, 30 secs of immortality, can be refreshed by further v2 casts, if your hp is below 20% by end of it, gibbed
					/obj/effect/proc_holder/spell/targeted/locate_dead 			= CLERIC_T1, // tweaked, now will give better information so the paramedic ss13 gameplay is not a chore
					/obj/effect/proc_holder/spell/invoked/blink/shadowstep/miracle = CLERIC_T3, // i ran out of ideas but this still fits, basically shadowstep but VERY VERY VERY VERY costy and bigger CD, not intended for combat
					/obj/effect/proc_holder/spell/invoked/fog_ward				= CLERIC_T1, // Not bugged, only appears on fog rounds!
					/obj/effect/proc_holder/spell/self/grave_embrace			= CLERIC_T4, // no better way to give out a 'death' vibe, needs 2h weapon that cuts, autohits next target, then deals no-AP bonus dmg based on missing HP, if you're at stage 3 bleedout, also copy your wounds to target, has chance to KD undead mobs based on miracle skill
					/obj/effect/proc_holder/spell/invoked/abrogation			= CLERIC_T2, // reworked, now just fast-forwards the procedure of getting lux-thread, with a feature of dusting undead mobs who are KD'd
					/obj/effect/proc_holder/spell/invoked/bless_cross			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance = CLERIC_T2, // i got eyes on this but idk what to do, atm its a horrible spell with no sovl
>>>>>>> Stashed changes
					/obj/effect/proc_holder/spell/invoked/deaths_door			= CLERIC_T4
	)
	confess_lines = list(
		"ALL SOULS FIND THEIR WAY TO NECRA!",
		"THE UNDERMAIDEN IS OUR FINAL REPOSE!",
		"I FEAR NOT DEATH, MY LADY AWAITS ME!",
	)
	storyteller = /datum/storyteller/necra

// Near a grave, cross, or within the church
/datum/patron/divine/necra/can_pray(mob/living/follower)
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
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Necra to hear my prayer I must either pray within the church, near a psycross, or near a grave where we all go to be given our final embrace.."))
	return FALSE

/datum/patron/divine/necra/on_lesser_heal(
    mob/living/user,
    mob/living/target,
    message_out,
    message_self,
    conditional_buff,
    situational_bonus
)
	*message_out = span_info("A sense of quiet respite radiates from [target]!")
	*message_self = span_notice("I feel the Undermaiden's gaze turn from me for now!")

	if(iscarbon(target))
		var/mob/living/carbon/carbon = target
		if(carbon.health <= (carbon.maxHealth * 0.25))
			*conditional_buff = TRUE
			*situational_bonus = 2.5
		if(user.has_status_effect(/datum/status_effect/buff/necran_mists))
			*conditional_buff = TRUE
			*situational_bonus += 1.25
