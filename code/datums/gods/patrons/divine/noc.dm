/datum/patron/divine/noc
	name = "Noc"
	domain = "God of the Moon, Nite, Knowledge and Arcyne"
	desc = "The Nite-Scholar, Noc is the brother and rival of Astrata, a keeper of hidden wisdom and the mysteries that stir beneath the moonlight. Where his sister shines her light upon the world, he invites mortalkind to peer into the shadows and question what they find there. Quiet, secretive, and endlessly curious, Noc delights in knowledge long forgotten, truths yet uncovered, and secrets that others fear to seek. His wisdom is scattered across crumbling tomes and decaying scripts, waiting for those clever or foolish enough to decipher them. He holds little regard for those who fear what they do not understand, believing that even the darkest mysteries deserve to be studied. To follow Noc is to accept that knowledge rarely comes without consequence, and that some questions only lead to stranger ones."
	worshippers = "Wizards, Alchemists, and Scholars"
	mob_traits = list(TRAIT_NIGHT_OWL)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/datum/action/cooldown/spell/noc/nitevision					= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/datum/action/cooldown/spell/noc/enlightenment				= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/moonscorch			= CLERIC_T2,
					/datum/action/cooldown/spell/noc/invisibility				= CLERIC_T2,
					/datum/action/cooldown/spell/noc/spellpack					= CLERIC_T3,
					/datum/action/cooldown/spell/noc/moonlight					= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/noc			= CLERIC_T4
	)
	confess_lines = list(
		"NOC IS NIGHT!",
		"NOC SEES ALL!",
		"I SEEK THE MYSTERIES OF THE MOON!",
	)
	traits_tier = list(TRAIT_DARKVISION = CLERIC_T1)
	storyteller = /datum/storyteller/noc

	titles = list(
		"Nite-Scholar",
		"Moon", // should match a bunch of variant titles like Brother Moon
		"Noishi",
		"Luoyeshen" // lingyue
	)

// In moonlight, church, cross, or ritual chalk
/datum/patron/divine/noc/can_pray(mob/living/follower)
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
	// Allows prayer during nightime if outside.
	if(istype(get_area(follower), /area/rogue/outdoors) && (GLOB.tod == "night" || GLOB.tod == "dusk"))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/noc in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Noc to hear my prayer I must either be in his blessed moonlight, within the church, or near a psycross."))
	return FALSE

/datum/patron/divine/noc/on_lesser_heal(
	mob/living/user,
	mob/living/target,
	message_out,
	message_self,
	conditional_buff,
	situational_bonus
)
	*message_out = span_info("A shroud of soft moonlight falls upon [target]!")
	*message_self = span_notice("I'm shrouded in gentle moonlight!")

	if(GLOB.tod == "night")
		*conditional_buff = TRUE
