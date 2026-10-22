/datum/patron/divine/necra
	name = "Necra"
	domain = "Goddess of Death and the Afterlife"
	desc = "The Veiled Lady of the Underworld, the Undermaiden is both feared and respected by mortalkind, for she alone awaits every soul at the end of its journey. She taught mortals that death is inevitable, neither a punishment nor a cruelty, but the final truth shared by all living things. Stern, quiet, and patient beyond mortal understanding, Necra does not judge the dead by the tears they leave behind, nor does she turn away those whose lives were marked by sin or sorrow. She has little need for grand displays of reverence, for every soul must one day come before her. Though she cannot spare mortals their final hour, she offers them something no living hand can promise: a guide through the dark, and a place for them when their time has come. To Necra, death is not an enemy to be conquered, but a passage to be met with dignity. And when the last breath fades, she will be there to receive the departed beneath her veil."
	worshippers = "Mourners, Gravekeepers, and the Dead"
	mob_traits = list(TRAIT_SOUL_EXAMINE, TRAIT_NOSTINK)	//No stink is generic but they deal with dead bodies so.. makes sense, I suppose?
	miracles = list(/datum/action/cooldown/spell/touch/orison						= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/necras_sight				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal						= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/avert						= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/locate_dead					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/fog_ward					= CLERIC_T1, // Not bugged, only appears on fog rounds!
					/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance	= CLERIC_T2,
					/datum/action/cooldown/spell/miracle/necra_consecrate			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/bless_cross				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/deaths_door				= CLERIC_T4
	)
	confess_lines = list(
		"ALL SOULS FIND THEIR WAY TO NECRA!",
		"THE UNDERMAIDEN IS OUR FINAL REPOSE!",
		"I FEAR NOT DEATH, MY LADY AWAITS ME!",
	)
	storyteller = /datum/storyteller/necra

	titles = list(
		"Veiled Lady",
		"Corpse Mother",
		"Undermaiden",
		"Neriko"
	)

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
