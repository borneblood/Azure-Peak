/datum/patron/divine/xylix
	name = "Xylix"
	domain = "God of Trickery, Freedom and Inspiration"
	desc = "The Laughing God, Xylix is a merry and mischievous soul, fond of a good jest, a daring gamble, and the many surprises life has to offer. He delights in the triumphs and follies of mortalkind alike, and seems to hold a particular fondness for freedom, much like the Free God himself. He despises a life dictated by certainty, preferring that every soul be free to take its chances, make its mistakes, and walk its own path. Many a bard owes their finest lyric to his inspiration, and he speaks to his faithful through his gift to mankind: the Tarot deck. Whether his guidance brings fortune or misfortune is anyone's guess, but perhaps that is precisely how he likes it."
	worshippers = "Gamblers, Bards, Artists, and the Silver-Tongued"
	mob_traits = list(TRAIT_XYLIX)
	miracles = list(/datum/action/cooldown/spell/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/xylixslip				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/ventriloquism			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/mimicry				= CLERIC_T0,
					/datum/action/cooldown/spell/miracle/heal					= CLERIC_T1,
					/datum/action/cooldown/spell/miracle/bloodmiracle			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/tipscales				= CLERIC_T1,
					/datum/action/cooldown/spell/projectile/vicious_mockery		= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/vendetta				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/mastersillusion		= CLERIC_T2,
					/obj/effect/proc_holder/spell/targeted/touch/parlor_trick	= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/abscond				= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/resurrect/xylix		= CLERIC_T4,
	)
	traits_tier = list(TRAIT_XYLIX_DEVOTEE = CLERIC_T0) //Requires a minimal holy skill or the 'Devotee' virtue to unlock. Rerolls luck events
	confess_lines = list(
		"ASTRATA IS MY LIGHT!",
		"NOC IS NIGHT!",
		"DENDOR PROVIDES!",
		"ABYSSOR COMMANDS THE WAVES!",
		"RAVOX IS JUSTICE!",
		"ALL SOULS FIND THEIR WAY TO NECRA!",
		"HAHAHAHA! AHAHAHA! HAHAHAHA!",
		"PESTRA SOOTHES ALL ILLS!",
		"MALUM IS MY MUSE!",
		"EORA BRINGS US TOGETHER!",
		"LONG LIVE ZIZO!",
		"GRAGGAR IS THE BEAST I WORSHIP!",
		"MATTHIOS IS MY LORD!",
		"BAOTHA IS MY JOY!",
		"REBUKE THE HERETICAL- PSYDON ENDURES!",
	)
	storyteller = /datum/storyteller/xylix

	titles = list(
		"Tragedian",
		"Xyji",
		"Luck"
	)

// Near a gambling machine, cross, or within the church
/datum/patron/divine/xylix/can_pray(mob/living/follower)
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
	// Allows prayer near gambling machines.
	for(var/obj/structure/roguemachine/lottery_roguetown/L in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Xylix to hear my prayer I must either pray within the church, near a psycross, or near a machine of fortune blessed by the grand jester.."))
	return FALSE

/datum/patron/divine/xylix/on_lesser_heal(
	mob/living/user,
	mob/living/target,
	message_out,
	message_self,
	conditional_buff,
	situational_bonus
)
	*message_out = span_info("A fugue seems to manifest briefly across [target]!")
	*message_self = span_notice("My wounds vanish as if they had never been there! ")

	if(prob(50))
		*conditional_buff = TRUE
		*situational_bonus = rand(1, 2.5)
