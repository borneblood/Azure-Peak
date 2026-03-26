<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
// T1: Avert End (channel on an adjacent target to slowly spend devotion to grant them NODEATH and ticks of oxyloss healing)
// Tweaked it to be able to target Tolls, in so to use a more powerful (and risky) version of it that can be used in combat.
/obj/effect/proc_holder/spell/invoked/avert
	name = "Borrowed Time"
	desc = "Shield your fellow man from the Undermaiden's gaze, preventing them from slipping into death for as long as your faith and fatigue may muster. A Toll can be offered to this Miracle, empowering it..."
	overlay_state = "borrowtime"
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	associated_skill = /datum/skill/magic/holy
	miracle = TRUE
	devotion_cost = 10
	
	var/list/near_death_lines = list(
		"A pale haze seeps into my vision, dulling the world to muted greys, then it shudders and pulls back as if something unseen refuses to let me pass.",
		"A crushing weight bears down on my chest, as though the wyrld itself would grind me into the soil, yet it pauses, held at bay by an unseen hand.",
		"The distant murmur of a slow, endless river fills my ears, accompanied by the hollow toll of a ferryman's bell that echoes through my bones.",
		"A vast presence looms just beyond sight, formless, patient, and ancient. I feel its attention settle upon me, cold and absolute.",
		"My breath falters into nothing, my lungs refusing to draw, then with a ragged gasp air is forced back into me against my will.",
		"I feel myself slipping downward into a silent dark, only to be seized and dragged back by something cold, firm, and utterly uncaring.",
		"The darkness gathers at the edges of my sight, thick and suffocating, yet it lingers there, denied its claim.",
		"A deathly chill coils through my marrow, settling deep within me as if something has marked me and chosen to wait.",
		"My heart stutters violently, skipping and faltering, then resumes with a slow, deliberate beat that does not feel like my own.",
		"A whisper, thin as a blade and colder than frost, threads through my thoughts. Not yet.",
		"For a fleeting instant I glimpse something beyond the veil, an endless expanse, still and silent, but I can't go in there.",
		"My body feels distant and hollow, as though I have already begun to leave it behind, but someone refuses to let me go. Who?",
		"Something like a hand, cold, immense, and unseen, steadies me at the brink, holding me in place. My soul can't slip away.",
		"The silence of death presses close around me, thick as a shroud, yet stops just short of swallowing me whole. It trembles in anticipation.",
		"I feel a tether wrapped tight around my being, pulling me back each time I begin to slip too far towards the other side.",
		"A slow, inevitable pull drags at my very soul, urging me onward, then halts, denied by something stronger, kinder.",
		"The world fades into dull, lifeless tones. As though all warmth and color have been leeched away... it suddenly stops.",
		"I know, with dreadful certainty, that I should be gone, yet something has refused that end. I feel hope.",
		"A presence lingers at my side, vast and unmoving, watching with quiet, inexorable patience. Who is that?...",
		"My pulse dwindles to a faint, distant rhythm, each beat slower than the last, yet it stubbornly continues.",
		"The ferryman waits in the distance, pole resting in still waters, but I am not permitted to board. Not yet.",
		"Something has claimed me from Necra's grasp, not to save me, but to hold me in defiance of it. She smiles, amused.",
		"I hang suspended between breaths, between moments, between life and the stillness beyond. I need to wake up.",
		"The veil parts just enough for me to feel what lies beyond, an endless quiet, before sealing once more. Not yet.",
		"A cold certainty settles deep within me. This is no mercy, only postponement. I need to wake up.",
		"My veins feel heavy with stillness, as though death already flows within me, held in check by force alone. Not yet.",
		"A faint echo of distant bells lingers in my skull, each toll marking a moment I was meant to lose. It grows fainter.",
		"The air tastes stale and foreign, as though I no longer fully belong among the living. Yet, I do.",
		"My limbs grow numb and distant, yet still respond, as if moved by something other than my own will. I can't die.",
		"A quiet pressure surrounds my mind, patient and immovable, ensuring I do not slip away just yet. I need to wake up."
	)
	var/empowered_charge = FALSE

/obj/effect/proc_holder/spell/invoked/avert/examine(mob/user)
	. = ..()
	if(empowered_charge)
		. += "</br><span class='danger'>A toll has been offered. Necra is closely watching.</span>"
		. += "</br><span class='danger'>Your next Borrowed Time will last for several seconds upon your target, preventing their death for up to 30 seconds. But beware! If they are not sufficiently healthy by the end of it, they might not survive the backlash!</span>"

/obj/effect/proc_holder/spell/invoked/avert/cast(list/targets, mob/living/carbon/human/user)
	. = ..()

	var/atom/target = targets[1]

	// Offer Toll to empower the spell
	if(istype(target, /obj/item/thetoll))
		if(empowered_charge)
			to_chat(user, span_warning("The miracle is already burdened with a Toll."))
			revert_cast()
			return FALSE

		var/obj/item/thetoll/T = target

		user.visible_message(
			span_danger("[user] crushes a Toll into dust, whispering a grave prayer..."),
			span_danger("I offer the Toll to the Undermaiden. Let Her watch closely...")
		)

		qdel(T)
<<<<<<< Updated upstream
		empowered_charge = TRUE

		return TRUE
=======

		empowered_charge = TRUE
		revert_cast()
		return FALSE
>>>>>>> Stashed changes

	// Invalid target
	if(!isliving(target))
		revert_cast()
		return FALSE

	var/mob/living/living_target = target

	// No self-cast unless empowered
	if(living_target == user && !empowered_charge)
		to_chat(user, span_warning("I cannot invoke this miracle upon myself... not without a Toll."))
		revert_cast()
		return FALSE

	// Must be adjacent unless empowered
	if(!user.Adjacent(living_target) && !empowered_charge)
		to_chat(user, span_warning("I must be beside [living_target]!"))
		revert_cast()
		return FALSE

	var/is_empowered = empowered_charge

<<<<<<< Updated upstream
	if(is_empowered)
		return cast_empowered(living_target, user)
	
	empowered_charge = FALSE

	return cast_normal(living_target, user)
=======
	if(is_empowered && !(HAS_TRAIT(living_target, TRAIT_DEATHLESS))) // stinky immortal people dont get to feel immortal for 30s
		empowered_charge = FALSE
		return cast_empowered(living_target, user)
	else
		return cast_normal(living_target, user)

	return FALSE
>>>>>>> Stashed changes

/obj/effect/proc_holder/spell/invoked/avert/proc/cast_normal(mob/living/living_target, mob/user)

	user.visible_message(
		span_notice("Whispering motes gently bead from [user]'s fingers as [user.p_they()] place a hand near [living_target]..."),
		span_notice("I utter the hallowed words, staying Her grasp for a little while longer...")
	)

	to_chat(user, span_small("I must remain still and at [living_target]'s side..."))
	to_chat(living_target, span_warning("An odd sensation blossoms in my chest, cold and unknown..."))

	ADD_TRAIT(living_target, TRAIT_NODEATH, "avert_spell")

	var/our_holy_skill = user.get_skill_level(associated_skill)
	var/tickspeed = 30 + (5 * our_holy_skill)

	while(do_after(user, tickspeed, target = living_target))
		user.stamina_add(2.5)

		living_target.adjustOxyLoss(-10)
		living_target.blood_volume = max((BLOOD_VOLUME_SURVIVE * 1.5), living_target.blood_volume)
		var/mob/living/carbon/human/H = user
		if(H.devotion?.check_devotion(src))
			H.devotion?.update_devotion(-10)
		else
			to_chat(user, span_warning("My devotion runs dry - the Intercession fades!"))
			break

	REMOVE_TRAIT(living_target, TRAIT_NODEATH, "avert_spell")

	user.visible_message(
		span_danger("[user]'s concentration breaks."),
		span_danger("My concentration breaks, and the Intercession falls silent.")
	)

	return TRUE

/obj/effect/proc_holder/spell/invoked/avert/proc/cast_empowered(mob/living/living_target, mob/user)

	user.visible_message(
		span_danger("[user] presses a hand into [living_target], whispering a grave promise..."),
		span_danger("I bind [living_target] to borrowed time. Necra will collect what is owed...")
	)

	to_chat(living_target, span_userdanger("Death recoils from me... but something waits."))

	living_target.apply_status_effect(/datum/status_effect/buff/borrowed_time_empowered)

	return TRUE

<<<<<<< Updated upstream
=======
/atom/movable/screen/alert/status_effect/buff/borrowed_time
	name = "Living Dead"
	desc = "My whole existence is tettering between lyfe and death, I shall not die until the last tick of this clock..."
	icon_state = "buff"
	alert_group = ALERT_BUFF

>>>>>>> Stashed changes
/datum/status_effect/buff/borrowed_time_empowered
	id = "borrowed_time_empowered"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 20 SECONDS
<<<<<<< Updated upstream
	alert_type = /atom/movable/screen/alert/status_effect/buff/divine_strike
=======
	alert_type = /atom/movable/screen/alert/status_effect/buff/borrowed_time
>>>>>>> Stashed changes
	on_remove_on_mob_delete = TRUE

/datum/status_effect/buff/borrowed_time_empowered/tick()
	. = ..()

	var/static/list/borrowed_time_messages = list(
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"IT SEES ME— WHY DOES IT SEE ME—",
		"I WASN'T MEANT TO LIVE THIS LONG—",
		"IT'S BEHIND MY EYES— GET IT OUT— GET IT OUT—",
		"MY HEART STOPPED— WHY DID IT START AGAIN—",
		"I CAN FEEL IT COUNTING— PLEASE STOP COUNTING—",
		"SHE'S WAITING— SHE'S BEEN WAITING—",
		"I HEARD MYSELF DIE— I HEARD IT—",
		"THIS ISN'T LIFE— THIS ISN'T LIFE—",
		"I'M STILL FALLING— WHY AM I STILL FALLING—",
		"SOMETHING ELSE IS BREATHING FOR ME—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"WHY DOES MY BODY FEEL EMPTY—",
		"I CAN'T FEEL MY BLOOD— WHERE IS MY BLOOD—",
		"MY BONES ARE WRONG— THEY'RE ALL WRONG—",
		"I'M ALREADY DEAD— I KNOW I AM—",
		"THIS IS AFTER— THIS HAS TO BE AFTER—",
		"WHY WON'T IT TAKE ME—",
		"IT'S HOLDING ME HERE— WHY—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"SHE'S LOOKING RIGHT AT ME—",
		"I CAN'T BLINK— IF I BLINK SHE'LL TAKE ME—",
		"I CAN HEAR HER BREATHING—",
		"SHE'S SMILING— WHY IS SHE SMILING—",
		"I'M NOT SUPPOSED TO SEE THIS—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"IT HURTS— IT HURTS— IT HURTS—",
		"MAKE IT STOP— PLEASE MAKE IT STOP—",
		"MY BODY IS TEARING— CAN'T YOU SEE IT—",
		"I'M COMING APART— I'M COMING APART—",
		"I CAN'T HOLD TOGETHER—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"I OWE SOMETHING— I DON'T KNOW WHAT—",
		"SOMETHING IS COMING TO COLLECT—",
		"I CAN FEEL IT REACHING—",
		"IT KNOWS MY NAME—",
		"IT CALLED ME— I HEARD IT CALL ME—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"WHY DID YOU SAVE ME— WHY—",
		"I WAS SUPPOSED TO DIE—",
		"YOU SHOULDN'T HAVE DONE THIS—",
		"THIS IS WRONG— THIS IS WRONG—",
		"I CAN'T STAY HERE—",
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
		"IT'S SO CLOSE—",
		"IT'S ALMOST TIME—",
		"I CAN FEEL THE END—",
		"I CAN SEE IT—",
		"IT'S HERE— IT'S HERE—"

	)

	var/mob/living/M = owner
	if(!M)
		return

	var/msg = pick(borrowed_time_messages)

	M.visible_message(
		span_danger("[M]'s body spasms violently, their form twisting as if something unseen tugs at their soul..."),
		span_userdanger(msg)
	)
<<<<<<< Updated upstream
		// 🔊 Spooky audio cue
	var/static/list/spooky_sounds = list(
		'sound/vo/mobs/ghost/aggro (1).ogg',
		'sound/vo/mobs/ghost/aggro (2).ogg',
		'sound/vo/mobs/ghost/aggro (3).ogg',
		'sound/vo/mobs/ghost/aggro (4).ogg',
		'sound/vo/mobs/ghost/aggro (5).ogg',
		'sound/vo/mobs/ghost/aggro (6).ogg'
	)

=======
	M.emote("breathgasp")

		// 🔊 Spooky audio cue
	var/static/list/spooky_sounds = list(
		'sound/vo/mobs/ghost/aggro (1).ogg',
		'sound/vo/mobs/ghost/aggro (2).ogg',
		'sound/vo/mobs/ghost/aggro (3).ogg',
		'sound/vo/mobs/ghost/aggro (4).ogg',
		'sound/vo/mobs/ghost/aggro (5).ogg',
		'sound/vo/mobs/ghost/aggro (6).ogg'
	)

>>>>>>> Stashed changes
	var/spookyscary = pick(spooky_sounds)
	playsound(get_turf(M), spookyscary, 50, TRUE)

/datum/status_effect/buff/borrowed_time_empowered/on_apply()
	. = ..()

	var/mob/living/M = owner
	if(!M)
		return
	
<<<<<<< Updated upstream
	playsound(get_turf(M), 'sound/vo/mobs/ghost/death.ogg', 50, TRUE)
=======
	playsound(get_turf(M), 'sound/misc/deadbell.ogg', 50, TRUE)
>>>>>>> Stashed changes

	ADD_TRAIT(M, TRAIT_NODEATH, "borrowed_time_empowered")
	ADD_TRAIT(M, TRAIT_NOPAIN, "borrowed_time_empowered")
	ADD_TRAIT(M, TRAIT_DEATHLESS, "borrowed_time_empowered")
	ADD_TRAIT(M, TRAIT_BLOODLOSS_IMMUNE, "borrowed_time_empowered")
	ADD_TRAIT(M, TRAIT_PSYCHOSIS, "borrowed_time_empowered")

/datum/status_effect/buff/borrowed_time_empowered/on_remove()
<<<<<<< Updated upstream
	. = ..()

	var/mob/living/M = owner
	if(!M)
		return

=======
/datum/status_effect/buff/borrowed_time_empowered/on_remove()
	. = ..()

	to_chat(owner, span_warning("DEBUG: borrowed_time_empowered on_remove triggered."))

	var/mob/living/M = owner
	if(!M)
		world.log << "DEBUG: No owner found in borrowed_time_empowered on_remove."
		return

	to_chat(M, span_warning("DEBUG: Owner exists: [M]"))

>>>>>>> Stashed changes
	REMOVE_TRAIT(M, TRAIT_NODEATH, "borrowed_time_empowered")
	REMOVE_TRAIT(M, TRAIT_NOPAIN, "borrowed_time_empowered")
	REMOVE_TRAIT(M, TRAIT_DEATHLESS, "borrowed_time_empowered")
	REMOVE_TRAIT(M, TRAIT_BLOODLOSS_IMMUNE, "borrowed_time_empowered")
	REMOVE_TRAIT(M, TRAIT_PSYCHOSIS, "borrowed_time_empowered")

<<<<<<< Updated upstream
	if(HAS_TRAIT_FROM(M, TRAIT_NODEATH, "avert_spell"))
		return

	var/health_percent = M.health / max(M.maxHealth, 1)

	if(health_percent < 0.1)
		M.visible_message(
			span_danger("[M]'s body seizes as something unseen tears them apart!"),
			span_userdanger("IT COMES DUE— IT COMES DUE!! I WAS ALREADY DEAD LONG AGO!!! AHHAHAHAHAHAHHAHAHAHAAAAA!!!")
		)
		M.emote("laugh")
		playsound(get_turf(M), 'sound/vo/mobs/ghost/death.ogg', 50, TRUE)
		M.gib(TRUE, TRUE, FALSE)
	else
		to_chat(M, span_warning("The weight of death recedes... for now."))
		to_chat(M, span_green("Such bliss... In Paradise or Psydonia, I, was the one who dared dance with death."))
=======
	to_chat(M, span_warning("DEBUG: Traits removed."))

	if(HAS_TRAIT_FROM(M, TRAIT_NODEATH, "avert_spell"))
		to_chat(M, span_warning("DEBUG: Avert spell NODEATH detected. Skipping death."))
		to_chat(M, span_green("I am shielded from oblivion by an unseen force."))
		return

	// === DAMAGE CHECK INSTEAD OF HEALTH ===
	var/brute = M.getBruteLoss()
	var/fire = M.getFireLoss()
	var/oxy = M.getOxyLoss()
	var/tox = M.getToxLoss()

	var/total_loss = brute + fire + oxy + tox
	var/death_threshold = 200

	to_chat(M, span_warning("DEBUG: Damage -> Brute:[brute] Fire:[fire] Oxy:[oxy] Tox:[tox] Total:[total_loss]"))

	// === DEATH CONDITION ===
	if(total_loss < death_threshold)
		to_chat(M, span_warning("DEBUG: Entered DEATH branch (damage present)"))

		M.emote("agony")
		M.visible_message(
			span_danger("[M]'s body seizes as something unseen tears them apart!"),
			span_userdanger("IT COMES DUE, I KNEW IT, IT COMES DU--!")
		)

		playsound(get_turf(M), 'sound/vo/mobs/ghost/death.ogg', 50, TRUE)

		to_chat(M, span_warning("DEBUG: Waiting before gib..."))
		sleep(15)

		to_chat(M, span_warning("DEBUG: Gibbing now."))
		M.gib(TRUE, TRUE, FALSE)

	// === SURVIVAL CONDITION ===
	else
		to_chat(M, span_warning("DEBUG: Entered SURVIVE branch (no damage)"))

		to_chat(M, span_warning("The weight of death recedes... for now."))
		to_chat(M, span_green("Such bliss... In Paradise or Psydonia, I, was the one who dared dance with death."))

		var/list/wCount = M.get_wounds()
		to_chat(M, span_warning("DEBUG: Wound count BEFORE = [wCount.len]"))

		if(wCount.len > 0)
			for(var/datum/wound/W in wCount)
				to_chat(M, span_warning("DEBUG: BEFORE wound -> [W.type] | severity=[W.severity]"))

		if(!M.construct)
			to_chat(M, span_warning("DEBUG: Target is not a construct."))

			if(wCount.len > 0)
				to_chat(M, span_warning("DEBUG: Calling heal_wounds()."))

				M.heal_wounds(999, list(/datum/wound/slash, /datum/wound/puncture, /datum/wound/bite, /datum/wound/bruise, /datum/wound/dynamic))

				to_chat(M, span_warning("DEBUG: heal_wounds() finished."))

				var/list/wCount_after = M.get_wounds()
				to_chat(M, span_warning("DEBUG: Wound count AFTER = [wCount_after.len]"))

				if(wCount_after.len > 0)
					for(var/datum/wound/W2 in wCount_after)
						to_chat(M, span_warning("DEBUG: AFTER wound -> [W2.type] | severity=[W2.severity]"))
				else
					to_chat(M, span_warning("DEBUG: All wounds healed."))

				M.update_damage_overlays()
				to_chat(M, span_warning("DEBUG: Damage overlays updated."))

			if(M.blood_volume < BLOOD_VOLUME_BAD)
				to_chat(M, span_warning("DEBUG: Restoring blood volume. Before = [M.blood_volume]"))
				M.blood_volume = BLOOD_VOLUME_BAD
				to_chat(M, span_warning("DEBUG: Blood volume after = [M.blood_volume]"))
>>>>>>> Stashed changes

/obj/effect/proc_holder/spell/targeted/locate_dead
	name = "Locate Corpse"
	desc = "Beseech the Undermaiden to guide you to the fallen and reveal what still clings to their remains."
	overlay_state = "necraeye"
	sound = 'sound/magic/whiteflame.ogg'
	releasedrain = 30
	chargedrain = 0.5
	max_targets = 0
	cast_without_targets = TRUE
	miracle = TRUE
	associated_skill = /datum/skill/magic/holy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	recharge_time = 7 SECONDS
	devotion_cost = 15

/mob/living
	var/mob/living/necra_tracked_corpse = null
	var/last_necra_ping = 0

/obj/effect/proc_holder/spell/targeted/locate_dead/cast(list/targets, mob/living/user = usr)
	. = ..()

	// =========================
	// TOGGLE OFF
	// =========================
	if(user.necra_tracked_corpse)
		to_chat(user, span_notice("The Undermaiden releases your hand."))
		user.necra_tracked_corpse = null
		STOP_PROCESSING(SSprocessing, user)
		revert_cast()
		return

	user.whisper("Undermaiden, guide my hand to those who have lost their way.")

	var/list/player_bodies = list()
	var/list/npc_bodies = list()

	var/mob/living/nearest_player = null
	var/mob/living/nearest_npc = null

	var/nearest_player_dist = INFINITY
	var/nearest_npc_dist = INFINITY

	var/turf/user_turf = get_turf(user)

	// =========================
	// SCAN (dead OR downed)
	// =========================
	for(var/mob/living/C in GLOB.mob_list)
		if(!C || QDELETED(C))
			continue

		if(istype(C, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(H.buried)
				continue

		var/is_dead = (C.stat == DEAD)
		var/is_downed = (!(C.mobility_flags & MOBILITY_STAND) && !C.buckled)

		if(!is_dead && !is_downed)
			continue

		var/turf/T = get_turf(C)
		if(!T || !user_turf)
			continue

		var/dist = get_dist(user_turf, T)
		var/is_player = (C.mind != null)

		if(is_player)
			var/name = C.real_name ? C.real_name : "Unknown"

			var/has_soul = (C.key || C.get_ghost(FALSE, TRUE))
			var/tag = has_soul ? "Earthbound" : "Departed"

			player_bodies["[name] ([tag])"] = C

			if(dist < nearest_player_dist)
				nearest_player_dist = dist
				nearest_player = C
		else
			var/name = C.name ? C.name : "Unknown"

			npc_bodies["[name]"] = C

			if(dist < nearest_npc_dist)
				nearest_npc_dist = dist
				nearest_npc = C

	// =========================
	// NOTHING FOUND
	// =========================
	if(!length(player_bodies) && !length(npc_bodies))
		to_chat(user, span_userdanger("You reach out. Nothing answers. The Undermaiden is silent..."))
		return

	// =========================
	// STEP 1 — TYPE
	// =========================
	var/type_choice = tgui_input_list(user, "What does the Undermaiden seek?", "Corpse Type", list(
		"Strong-lux (Players)",
		"Weak-lux (NPCs)"
	))

	if(!type_choice || QDELETED(user))
		return

	var/list/selected_list
	var/mob/living/nearest_target

	if(type_choice == "Strong-lux (Players)")
		selected_list = player_bodies
		nearest_target = nearest_player
	else
		selected_list = npc_bodies
		nearest_target = nearest_npc

	if(!length(selected_list))
		to_chat(user, span_warning("The Undermaiden finds none of that kind."))
		return

	// =========================
	// STEP 2 — MODE
	// =========================
	var/mode_choice = tgui_input_list(user, "How shall she guide you?", "Tracking Mode", list(
		"Nearest",
		"Choose specific"
	))

	if(!mode_choice || QDELETED(user))
		return

	var/mob/living/target = null

	if(mode_choice == "Nearest")
		target = nearest_target
	else
		var/choice = tgui_input_list(user, "Which body shall I seek?", "Available Bodies", selected_list)

		if(!choice || QDELETED(user))
			return

		target = selected_list[choice]

	// =========================
	// FINAL VALIDATION
	// =========================
	if(!target || QDELETED(target))
		to_chat(user, span_warning("The Undermaiden's grasp lets slip."))
		return

	user.necra_tracked_corpse = target
	user.last_necra_ping = 0

	if(target.key || target.get_ghost(FALSE, TRUE))
		to_chat(user, span_userdanger("A soul still lingers. The Undermaiden guides your hand."))
	else
		to_chat(user, span_warning("Only a hollow remains. The pull is faint."))

	START_PROCESSING(SSprocessing, user)

/mob/living/process()
	..()

	if(!necra_tracked_corpse)
		to_chat(src, span_warning("The Undermaiden's grasp lets slip."))
		STOP_PROCESSING(SSprocessing, src)
		return

	if(world.time < last_necra_ping + 20)
		return

	last_necra_ping = world.time

	if(QDELETED(necra_tracked_corpse))
		to_chat(src, span_warning("The Undermaiden's attention snaps away."))
		necra_tracked_corpse = null
		STOP_PROCESSING(SSprocessing, src)
		return

	var/turf/user_turf = get_turf(src)
	var/turf/target_turf = get_turf(necra_tracked_corpse)

	if(!user_turf || !target_turf)
		return

	var/direction_name = "here"
	var/z_hint = ""

	if(target_turf.z != user_turf.z)
		var/z_diff = abs(target_turf.z - user_turf.z)
		z_hint = target_turf.z > user_turf.z ? "[z_diff] level\s above" : "[z_diff] level\s below"
	else
		var/dir = get_dir(src, necra_tracked_corpse)
		switch(dir)
			if(NORTH) direction_name = "north"
			if(SOUTH) direction_name = "south"
			if(EAST) direction_name = "east"
			if(WEST) direction_name = "west"
			if(NORTHEAST) direction_name = "northeast"
			if(NORTHWEST) direction_name = "northwest"
			if(SOUTHEAST) direction_name = "southeast"
			if(SOUTHWEST) direction_name = "southwest"

	var/state = "still"
	var/sovl = "departed"

	// Detect skeleton or zombie
	var/datum/antagonist/skeleton/skel = necra_tracked_corpse.mind?.has_antag_datum(/datum/antagonist/skeleton)
	var/datum/antagonist/zombie/zomb = necra_tracked_corpse.mind?.has_antag_datum(/datum/antagonist/zombie)

	// Determine physical state
	if(skel)
		state = "fleshless"                  // Skeletons always override
	else if(zomb)
		if(necra_tracked_corpse.stat != DEAD)
			state = "walking"                // Active zombie
		else if(!(necra_tracked_corpse.mobility_flags & MOBILITY_STAND) && !necra_tracked_corpse.buckled)
			state = "collapsed"            // Collapsed zombie
		else
			state = "rotting"                // Dead zombie
	else if(necra_tracked_corpse.stat != DEAD)
		state = "awake"                     // Probably deadite
	else
		state = "peaceful"                       // Normal corpse

	// Determine soul status
	if(necra_tracked_corpse.key || necra_tracked_corpse.get_ghost(FALSE, TRUE))
		sovl = "earthbound"                   // corpse still has lingering soul

	var/msg = "The Undermaiden guides you <b>[direction_name]</b>"
	if(z_hint)
		msg += " <b>([z_hint])</b>"
	msg += ". They might be [state] and [sovl]."

	to_chat(src, span_warning(msg))

/obj/effect/proc_holder/spell/invoked/blink/shadowstep/miracle // throwing another thing on the wall in hope it sticks
	name = "Veil Passage"
	desc = "A brief step through the veil, carrying the faithful a distance along the threshold of death. This is unorthodoxically exhausting to perform, but can travel farther than most teleportation techniques."
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "shadowstep"
	invocations = list(
		"Lady of the Veil, I walk in your shadow...",
		"Necra, grant me passage...",
		"In death's grace, I take this step...",
		"O' Undermaiden, let the veil part by your will...",
		"Errand spirits, guide my path...",
		"O' Necra, let the threshold open...",
		"In silence, I shall pass unhindered..."
	)
	invocation_type = "whisper"
<<<<<<< Updated upstream
	phase = /obj/effect/temp_visual/blink/shadowstep
=======
	phase = /obj/effect/temp_visual/blink/shadowstep/miracle
>>>>>>> Stashed changes
	miracle = TRUE
	devotion_cost = 75
	releasedrain = 100
	max_range = 6
	recharge_time = 20 SECONDS
	xp_gain = FALSE

<<<<<<< Updated upstream
/obj/effect/temp_visual/blink/shadowstep
=======
/obj/effect/temp_visual/blink/shadowstep/miracle
>>>>>>> Stashed changes
	icon_state = "bluestream_fade"
	light_color = COLOR_PALE_PURPLE_GRAY

/obj/effect/proc_holder/spell/invoked/abrogation
	name = "Abrogation"
	desc = "Call upon the Undermaiden's mercy to unravel abandoned flesh, granting it absolution in the hands of Aeon."
	overlay_state = "necra"
	releasedrain = 50
	chargedrain = 0
	chargetime = 1 SECONDS
	range = 5
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	invocations = list("In Necra's name, I return you to Aeon.")
	invocation_type = "none"
	recharge_time = 5 SECONDS
	devotion_cost = 50
	miracle = TRUE
	var/splash_area = 2 // efficient corpse disposal, just as our forefathers demanded!
	var/underway = FALSE // no spam allowed

/obj/effect/proc_holder/spell/invoked/abrogation/cast(list/targets, mob/living/user)
	. = ..()

	if(underway)
		to_chat(user, span_warning("The rite is already underway. Patience."))
		return FALSE

	if(!targets?.len || !isliving(targets[1]))
		to_chat(user, span_warning("The Undermaiden finds nothing to claim."))
		revert_cast()
		return FALSE

	var/mob/living/target = targets[1]
	var/list/processed = list()
	var/list/to_abrogate = list()
	var/success = FALSE
	var/failure_reason = "The Undermaiden finds no abandoned dead to claim."

	underway = TRUE

	for(var/mob/living/L in range(splash_area, target))

		if(L in processed)
			continue

		if(QDELETED(L))
			continue

		var/is_valid = FALSE
		var/is_corpse = (L.stat == DEAD)
		var/is_undead = (L.mob_biotypes & MOB_UNDEAD)

		// Flat undead execution
		if(!is_corpse && is_undead && iscarbon(L))
			var/mob/living/carbon/carbon = L

			if(!(carbon.mobility_flags & MOBILITY_STAND) && !carbon.buckled)
				is_valid = TRUE
			else
				failure_reason = "[L] is still animated by foul forces."

		// Corpse cleanup
		if(is_corpse)
			is_valid = TRUE

		if(!is_valid)
			continue

		// Block players
		if(L.client)
			failure_reason = "The Undermaiden does not claim the strong of will."
			continue

		// Block ghost-occupied corpses
		if(istype(L, /mob/living/carbon))
			var/mob/living/carbon/C = L

			if(C.key || C.get_ghost(FALSE, TRUE))
				failure_reason = "[L]'s soul still lingers."
				continue

		processed += L
		to_abrogate += L
		success = TRUE

	if(!success)
		underway = FALSE
		to_chat(user, span_warning("[failure_reason]"))
		revert_cast()
		return FALSE

	user.visible_message(
		span_warning("[user]'s eyes glow with cold blue light."),
		span_notice("I invoke Abrogation.")
	)

	playsound(get_turf(target), 'sound/magic/churn.ogg', 80, TRUE)

	// Process with delay
	for(var/mob/living/L in to_abrogate)

		if(QDELETED(L))
			continue

		L.visible_message(
			span_danger("<i>[L]'s body unravels rapidly to the passage of time...</i>"),
		)

		var/turf/T = get_turf(L)
		if(T)
			playsound(T, 'sound/misc/deadbell.ogg', 60, TRUE)
			playsound(T, 'sound/misc/clockloop.ogg', 60, TRUE)

		// Carbon corpses drop soulthread
		if(istype(L, /mob/living/carbon))
			var/mob/living/carbon/C = L
			if(T)
				new /obj/item/soulthread(T)

			C.dust(FALSE, FALSE, TRUE)
		else
			L.gib(TRUE, TRUE, TRUE)

		sleep(5) // Small delay to prevent sound burst


	underway = FALSE
	return TRUE

#define DEATH_HARVEST_FILTER "death_harvest_outline"

/obj/effect/proc_holder/spell/self/death_harvest
	name = "Death Harvest"
	desc = "Requires a weapon capable of cutting or chopping. Consecrate your weapon and surrender your mind to the harvest. On hit, you embody the will of the Grim Reaper, dashing between the dead and the damned, carving them apart in a relentless, reaping frenzy. Corpses will also be affected, and instantly converted into Lux String."
	overlay_state = "deathharvest"
	associated_skill = /datum/skill/magic/holy
	recharge_time = 15 SECONDS
	devotion_cost = 250
	invocation_type = "shout"
	invocations = list("Necra! Guide them to their final rest!")
	miracle = TRUE

/obj/effect/proc_holder/spell/self/death_harvest/cast(mob/living/user)
	if(!isliving(user))
		return FALSE

	var/obj/item/I = user.get_active_held_item()
	if(!I)
		to_chat(user, span_warning("I must hold a weapon to enact the rite."))
		revert_cast()
		return FALSE

	var/list/intents = I.gripped_intents
	if(!intents || !intents.len)
		to_chat(user, span_warning("This weapon cannot channel the rite."))
		revert_cast()
		return FALSE

	var/valid = FALSE
	for(var/path in intents)
		if(findtext("[path]", "/cut") || findtext("[path]", "/chop"))
			valid = TRUE
			break

	if(!valid)
		to_chat(user, span_warning("The rite recoils. This weapon cannot be used."))
		revert_cast()
		return FALSE

	if(user.has_status_effect(/datum/status_effect/buff/death_harvest))
		to_chat(user, span_warning("The rite is already upon my weapon."))
		revert_cast()
		return FALSE

	user.apply_status_effect(/datum/status_effect/buff/death_harvest)
	playsound(get_turf(user), 'sound/magic/antimagic.ogg', 60, TRUE)

	user.visible_message(
		span_danger("[user]'s weapon and eyes gain a horrifying, pallid glow!"),
		span_notice("You hear the whispers of the Ferryman... It tells you to act quickly."))

	return TRUE

/atom/movable/screen/alert/status_effect/buff/death_harvest
	name = "Death Harvest"
	desc = "My next strike will unleash a deadly harvest in Her name."
	icon_state = "buff"

/datum/status_effect/buff/death_harvest
	id = "death_harvest"
	alert_type = /atom/movable/screen/alert/status_effect/buff/death_harvest
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/buff/death_harvest/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack))
	owner.add_filter(DEATH_HARVEST_FILTER, 2, list("type" = "outline", "color" = "#7a2ca3", "alpha" = 220, "size" = 3))

/datum/status_effect/buff/death_harvest/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ITEM_ATTACK)
	owner.remove_filter(DEATH_HARVEST_FILTER)
	. = ..()

/datum/status_effect/buff/death_harvest/proc/on_attack(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER

	if(!target || target == owner || !isliving(target))
		return

	var/list/intents = weapon?.gripped_intents
	var/valid = FALSE
	if(intents)
		for(var/path in intents)
			if(findtext("[path]", "/cut") || findtext("[path]", "/chop"))
				valid = TRUE
				break
	if(!valid)
		return

	INVOKE_ASYNC(src, PROC_REF(reap_chain), user, target)

	consume_reap()
	return COMPONENT_ITEM_NO_DEFENSE

/datum/status_effect/buff/death_harvest/proc/reap_chain(mob/living/user, mob/living/initial_target)
	set waitfor = FALSE

	var/turf/origin = get_turf(user)
	var/turf/center = get_turf(initial_target)
	if(!origin || !center)
		return

	user.emote("cackle", forced = TRUE)

	var/list/targets = list()

	for(var/mob/living/M in view(8, center))
		if(M == user)
			continue

		var/datum/antagonist/skeleton/skel = M.mind?.has_antag_datum(/datum/antagonist/skeleton)
		var/datum/antagonist/zombie/zomb = M.mind?.has_antag_datum(/datum/antagonist/zombie)

		if(skel || zomb || M.stat == DEAD || istype(M, /mob/living/carbon/human/species/npc/deadite) || istype(M, /mob/living/carbon/human/species/skeleton/npc))
			targets += M

	for(var/mob/living/T in targets)
		if(QDELETED(T))
			continue

		var/turf/center_turf = get_turf(T)
		if(!center_turf || center_turf.z != origin.z)
			continue

		var/dir_to_target = get_dir(user, T)
		var/dir_left = turn(dir_to_target, 90)
		var/dir_right = turn(dir_to_target, -90)

		var/turf/pos1 = get_step(center_turf, dir_left)
		var/turf/pos2 = get_step(center_turf, dir_right)
		var/turf/pos3 = get_step(center_turf, turn(dir_left, 180))
		var/turf/pos4 = get_step(center_turf, turn(dir_right, 180))

		if(pos1)
			do_teleport(user, pos1, channel = TELEPORT_CHANNEL_MAGIC)

		sleep(2)

		var/list/cross_positions = list(pos2, pos3, pos4, pos1)

		for(var/turf/P in cross_positions)
			if(!P)
				continue

			var/list/path = getline(get_turf(user), P)
			INVOKE_ASYNC(src, PROC_REF(create_afterimage_trail), user, path)

			do_teleport(user, P, channel = TELEPORT_CHANNEL_MAGIC)
			playsound(P, 'sound/magic/blink.ogg', 25, TRUE)

			var/obj/effect/temp_visual/blade_cut/V = new(get_turf(T))
			V.dir = get_dir(user, T)

			sleep(2)

		T.Stun(70)
		T.Knockdown(70)
		T.adjustFireLoss(100)
		T.emote("scream")

		var/dir = get_dir(user, T)
		var/turf/throw_target = get_step(T, dir)
		if(throw_target)
			T.throw_at(throw_target, 3, 1, user)

		handle_reap(user, T)

	var/turf/current = get_turf(user)
	if(current && origin && current != origin)
		var/list/return_path = getline(current, origin)
		INVOKE_ASYNC(src, PROC_REF(create_afterimage_trail), user, return_path)

		do_teleport(user, origin, channel = TELEPORT_CHANNEL_MAGIC)
		playsound(origin, 'sound/magic/blink.ogg', 30, TRUE)

/datum/status_effect/buff/death_harvest/proc/handle_reap(mob/living/user, mob/living/target)
	var/is_corpse = (target.stat == DEAD)
	var/is_npc = !target.key

	if(is_corpse)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/C = target
			var/has_ghost = (C.key || C.get_ghost(FALSE, TRUE))
			if(!has_ghost && is_npc && !QDELETED(C))
				var/turf/T = get_turf(C)
				if(T)
					C.dust(TRUE, FALSE, TRUE)
					new /obj/item/soulthread(T)
					if(C)
						C.gib(TRUE, TRUE, TRUE)

	user.apply_status_effect(/datum/status_effect/buff/healing/soul_drain)

/datum/status_effect/buff/death_harvest/proc/create_afterimage_trail(mob/living/user, list/path_turfs)
	set waitfor = FALSE

	var/list/images = list()
	var/path_len = length(path_turfs)
	if(path_len < 2)
		return

	var/travel_dir = get_dir(path_turfs[1], path_turfs[path_len])

	for(var/i in 1 to path_len)
		var/turf/T = path_turfs[i]
		var/obj/effect/after_image/img = new(T, 0, 0, 0, 0, 0.5 SECONDS, 2 SECONDS, 0)
		images += img
		img.appearance = user.appearance
		img.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		img.dir = travel_dir
		img.alpha = 120

	QDEL_LIST_IN(images, 2 SECONDS)

/datum/status_effect/buff/death_harvest/proc/consume_reap()
	playsound(get_turf(owner), 'sound/magic/antimagic.ogg', 50, TRUE)

	owner.visible_message(
		span_danger("[owner]'s strike rends both flesh and soul!"),
		span_notice("The harvest is bountiful!"))

	owner.remove_status_effect(/datum/status_effect/buff/death_harvest)

#undef DEATH_HARVEST_FILTER

/datum/status_effect/buff/healing/soul_drain
	id = "healing"
	alert_type = /atom/movable/screen/alert/status_effect/buff/healing
	duration = 8 SECONDS
	healing_on_tick = 10
	outline_colour = "#bbbbbb"

/datum/status_effect/buff/healing/soul_drain/on_apply()
	healing_on_tick = 5
	return TRUE

/datum/status_effect/buff/healing/soul_drain/tick()
	var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal_rogue(get_turf(owner))
	H.color = "#a5a5a5"

	var/list/wCount = owner.get_wounds()

	if(!owner.construct)
		if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
			owner.blood_volume = min(owner.blood_volume + (healing_on_tick + 10), BLOOD_VOLUME_NORMAL)

		if(wCount.len > 0)
			owner.heal_wounds(healing_on_tick, list(/datum/wound/slash, /datum/wound/puncture, /datum/wound/bite, /datum/wound/bruise, /datum/wound/dynamic))
			owner.update_damage_overlays()

		owner.adjustBruteLoss(-healing_on_tick, 0)
		owner.adjustFireLoss(-healing_on_tick, 0)
		owner.adjustOxyLoss(-healing_on_tick, 0)
		owner.adjustToxLoss(-healing_on_tick, 0)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -healing_on_tick)
		owner.adjustCloneLoss(-healing_on_tick, 0)

#define GRAVE_EMBRACE_FILTER "grave_embrace_outline"
#define GRAVE_EMBRACE_DARK "grave_dark"
#define GRAVE_EMBRACE_HIT "grave_hit"

/obj/effect/proc_holder/spell/self/grave_embrace
	name = "Grave Embrace"
	desc = "Consecrate a two-handed cutting weapon with a mark of death. For the duration, you cannot die. Your next swing will never miss, and upon striking, you imprint your closeness to death onto your target."	
	overlay_state = "graveembrace"
	associated_skill = /datum/skill/magic/holy
	recharge_time = 20 SECONDS
	devotion_cost = 100
	invocation_type = "shout"
	invocations = list("Necra... embrace us both!", "An invitation to the underworld!", "The bell tolls!", "You cannot escape Her embrace!", "Death comes for all!")
	miracle = TRUE

/obj/effect/proc_holder/spell/self/grave_embrace/cast(mob/living/user)
	if(!isliving(user))
		return FALSE

	var/obj/item/I = user.get_active_held_item()
	if(!I)
		to_chat(user, span_warning("I must hold a weapon to invoke Her embrace."))
		revert_cast()
		return FALSE

	var/list/intents = I.gripped_intents
	if(!intents || !intents.len)
		to_chat(user, span_warning("This weapon cannot bear Her will."))
		revert_cast()
		return FALSE

	var/valid = FALSE
	for(var/path in intents)
		if(findtext("[path]", "/cut") || findtext("[path]", "/chop") || findtext("[path]", "/stab"))
			valid = TRUE
			break

	if(!valid)
		to_chat(user, span_warning("The rite recoils. This weapon is unworthy."))
		revert_cast()
		return FALSE

	if(user.has_status_effect(/datum/status_effect/buff/grave_embrace))
		to_chat(user, span_warning("Necra's embrace is already upon me."))
		revert_cast()
		return FALSE

	user.apply_status_effect(/datum/status_effect/buff/grave_embrace)

	playsound(get_turf(user), 'sound/magic/antimagic.ogg', 60, TRUE)

	user.visible_message(
		span_danger("[user]'s weapon glows dim with a deathly cold."),
		span_notice("Necra's whisper coils around your suffering..."))

	return TRUE

/atom/movable/screen/alert/status_effect/buff/grave_embrace
	name = "Grave Embrace"
	desc = "My suffering will be shared."
	icon_state = "buff"

/datum/status_effect/buff/grave_embrace
	id = "grave_embrace"
	alert_type = /atom/movable/screen/alert/status_effect/buff/grave_embrace
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/buff/grave_embrace/on_apply()
	. = ..()

	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack))

	owner.add_filter(GRAVE_EMBRACE_FILTER, 2, list(
		"type" = "outline",
		"color" = "#5b3c7a",
		"alpha" = 220,
		"size" = 3
	))

/datum/status_effect/buff/grave_embrace/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ITEM_ATTACK)
	owner.remove_filter(GRAVE_EMBRACE_FILTER)
	owner.remove_filter(GRAVE_EMBRACE_DARK)
	owner.remove_filter(GRAVE_EMBRACE_HIT)
	. = ..()

/datum/status_effect/buff/grave_embrace/proc/on_attack(mob/living/user, mob/living/target, obj/item/weapon)
	SIGNAL_HANDLER

	if(!target || target == owner || !isliving(target))
		return

	var/obj/item/I = user.get_active_held_item()
	if(!I)
		return

	var/list/intents = I.gripped_intents
	if(!intents || !intents.len)
		return

	var/valid = FALSE
	for(var/path in intents)
		if(findtext("[path]", "/cut") || findtext("[path]", "/chop") || findtext("[path]", "/stab"))
			valid = TRUE
			break

	if(!valid)
		return

	INVOKE_ASYNC(src, PROC_REF(grave_transfer), user, target)

	consume_grave()

/datum/status_effect/buff/grave_embrace/proc/grave_transfer(mob/living/user, mob/living/target)
	set waitfor = FALSE

	if(QDELETED(user) || QDELETED(target))
		return

	grave_animation(user, target)

	sleep(4)

	var/static/list/spooky_sounds = list(
		'sound/vo/mobs/ghost/aggro (1).ogg',
		'sound/vo/mobs/ghost/aggro (2).ogg',
		'sound/vo/mobs/ghost/aggro (3).ogg',
		'sound/vo/mobs/ghost/aggro (4).ogg',
		'sound/vo/mobs/ghost/aggro (5).ogg',
		'sound/vo/mobs/ghost/aggro (6).ogg'
	)

	var/spookyscary = pick(spooky_sounds)
	playsound(get_turf(target), spookyscary, 50, TRUE)

	// Calculate missing health
	var/missing_health = 0
	missing_health += user.getBruteLoss()
	missing_health += user.getFireLoss()
	missing_health += user.getOxyLoss()
	missing_health += user.getToxLoss()
	missing_health += user.getCloneLoss()

	var/wounds_transferred = FALSE

	// Wound transfer (Humans only)
	var/list/wounds = user.get_wounds()

	if(wounds && wounds.len && ishuman(target))
		for(var/datum/wound/W in wounds)

			var/datum/wound/new_wound = new W.type()

			var/mob/living/carbon/human/H = target
			var/static/list/body_zones = list(
				BODY_ZONE_CHEST,
				BODY_ZONE_HEAD,
				BODY_ZONE_L_ARM,
				BODY_ZONE_R_ARM,
				BODY_ZONE_L_LEG,
				BODY_ZONE_R_LEG
			)

			var/obj/item/bodypart/target_part = H.get_bodypart(pick(body_zones))

			if(target_part && new_wound.can_apply_to_bodypart(target_part))
				new_wound.apply_to_bodypart(target_part)
				wounds_transferred = TRUE

	// Bonus damage logic
	if(missing_health > 0)
		if(HAS_TRAIT(target, TRAIT_SIMPLE_WOUNDS) && !ishuman(target))
			// Simplemobs take 100%
			target.adjustBruteLoss(missing_health)
		else
			// Humans take 50%
			target.adjustBruteLoss(missing_health * 0.5)

	// Brain transfer
	var/brain = user.getOrganLoss(ORGAN_SLOT_BRAIN)
	if(brain > 0)
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, brain)

	// Briefly wears them out if wounds transferred
	if(wounds_transferred)
		target.Slowdown(4)
		target.emote("painscream", forced = TRUE)
		target.visible_message(span_warning("[target] seizes, ghastly wounds being imprinted on them!"))
		target.apply_status_effect(/datum/status_effect/debuff/clickcd, 4 SECONDS)
	
	var/miracleLV = user.get_skill_level(/datum/skill/magic/holy) // the luck(miracle skill?)-based combo of purge corpse and embrace
	if(target.mob_biotypes & MOB_UNDEAD)
		if(prob((8 * miracleLV)))
			target.Knockdown(6 SECONDS, ignore_canstun = TRUE)

	//will wear you out regardless if you transferred or not, so be careful!
	user.visible_message(span_warning("[owner] wavers, exposing themselves."))
	user.apply_status_effect(/datum/status_effect/debuff/clickcd, 4 SECONDS)
	user.OffBalance(4 SECONDS)
	user.emote("breathgasp", forced = TRUE)
	user.Slowdown(4)

/datum/status_effect/buff/grave_embrace/proc/grave_animation(mob/living/user, mob/living/target)
	set waitfor = FALSE

	var/turf/origin = get_turf(user)
	var/turf/impact = get_turf(target)

	if(!origin || !impact)
		return

	user.add_filter(GRAVE_EMBRACE_DARK, 3, list(
		"type" = "outline",
		"color" = "#3b2a4a",
		"alpha" = 255,
		"size" = 4
	))

	animate(user, alpha = 200, time = 2)
	animate(user, alpha = 255, time = 2)

	var/list/path = getline(origin, impact)

	INVOKE_ASYNC(src, PROC_REF(grave_shadow_trail), user, path)

	sleep(2)

	user.Shake(3,3)
	target.Shake(4,4)

	target.add_filter(GRAVE_EMBRACE_HIT, 2, list(
		"type" = "outline",
		"color" = "#6d4b8f",
		"alpha" = 255,
		"size" = 3
	))

	playsound(impact, 'sound/combat/fracture/fracturewet (1).ogg', 60, TRUE)

	for(var/i in 1 to 3)
		target.pixel_x = rand(-3,3)
		target.pixel_y = rand(-3,3)
		sleep(1)

	target.pixel_x = 0
	target.pixel_y = 0

	sleep(4)

	target.remove_filter(GRAVE_EMBRACE_HIT)
	user.remove_filter(GRAVE_EMBRACE_DARK)

/datum/status_effect/buff/grave_embrace/proc/grave_shadow_trail(mob/living/user, list/path_turfs)
	set waitfor = FALSE

	if(!path_turfs || path_turfs.len < 2)
		return

	var/list/images = list()

	for(var/turf/T in path_turfs)
		var/obj/effect/after_image/A = new(T)

		A.appearance = user.appearance
		A.alpha = 100
		A.color = "#4b3a63"
		A.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

		animate(A, alpha = 0, time = 5)

		images += A

	sleep(4)

	QDEL_LIST(images)

/datum/status_effect/buff/grave_embrace/proc/consume_grave()
	playsound(get_turf(owner), 'sound/misc/deadbell.ogg', 50, TRUE)

	owner.remove_status_effect(/datum/status_effect/buff/grave_embrace)

#undef GRAVE_EMBRACE_FILTER
#undef GRAVE_EMBRACE_DARK
#undef GRAVE_EMBRACE_HIT

/obj/effect/proc_holder/spell/invoked/necra_vow
	name = "Vow to Necra"
	desc = "Make a vow to Necra. Your chances of revival or recovery of limb will be greatly reduced. You will harm undeath and heal yourself at a slow rate."
	range = 1
	overlay_state = "necra"
	releasedrain = 30
	chargedloop = /datum/looping_sound/invokeholy
	chargetime = 50
	chargedrain = 0.5
	recharge_time = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocations = list("The Undermaiden Protects.")
	invocation_type = "shout"
	miracle = TRUE
	devotion_cost = 100

/obj/effect/proc_holder/spell/invoked/necra_vow/cast(list/targets, mob/living/user = usr)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/H = targets[1]
		if(HAS_TRAIT(H, TRAIT_ROTMAN) || HAS_TRAIT(H, TRAIT_NOBREATH) || H.mob_biotypes & MOB_UNDEAD)	//No Undead, no Rotcured, no Deathless
			to_chat(user, span_warning("Necra cares not for the vows of the corrupted."))
			revert_cast()
			return FALSE
		if(H.has_status_effect(/datum/status_effect/buff/necras_vow) || H.patron?.type != /datum/patron/divine/necra)
			to_chat(user, span_notice("They have already pledged a vow."))
			revert_cast()
			return FALSE
		var/choice = alert(H, "You are being asked to pledge a vow. Your chances of revival or recovery of limb will be greatly reduced. You will harm undeath and heal yourself at a slow rate. Do you agree?", "VOW", "Yes", "No")
		if(choice != "Yes")
			to_chat(user, span_notice("They declined."))
			return TRUE
		user.visible_message(span_warning("[user] grants [H] the blessing of their promise."))
		to_chat(H, span_warning("I have committed. There is no going back."))
		H.apply_status_effect(/datum/status_effect/buff/necras_vow)
		H.apply_status_effect(/datum/status_effect/buff/healing/necras_vow)

/atom/movable/screen/alert/status_effect/buff/necras_vow
	name = "Vow to Necra"
	desc = "I have pledged a promise to Necra. Undeath shall be harmed or lit aflame if they strike me. Rot will not claim me. Lost limbs can only be restored if they are myne."
	icon_state = "necravow"

#define NECRAVOW_FILTER "necravow_glow"

/datum/status_effect/buff/necras_vow
	var/outline_colour ="#929186" // A dull grey.
	id = "necravow"
	alert_type = /atom/movable/screen/alert/status_effect/buff/necras_vow
	effectedstats = list(STATKEY_CON = 2)
	duration = -1

/datum/status_effect/buff/necras_vow/on_apply()
	. = ..()
	var/filter = owner.get_filter(NECRAVOW_FILTER)
	if (!filter)
		owner.add_filter(NECRAVOW_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))
	ADD_TRAIT(owner, TRAIT_NECRAS_VOW, TRAIT_MIRACLE)
	owner.rot_type = null
	to_chat(owner, span_warning("My limbs feel more alive than ever... I feel whole..."))

/datum/status_effect/buff/necras_vow/on_remove()
	. = ..()
	owner.remove_filter(NECRAVOW_FILTER)
	to_chat(owner, span_warning("My body feels strange... hollow..."))

#undef NECRAVOW_FILTER

/obj/effect/proc_holder/spell/invoked/necras_sight
	name = "Necra's Sight"
	desc = "Mark a psycross or a grave marker, and peer through them."
	releasedrain = 30
	chargetime = 0 SECONDS
	recharge_time = 10 SECONDS
	warnie = "spellwarning"
	invocation_type = "whisper"
	invocations = list("Undermaiden guide my gaze...")
	associated_skill = /datum/skill/magic/holy
	overlay_state = "necraeye"
	miracle = TRUE
	devotion_cost = 30
	range = 1
	var/static/list/whitelisted_objects = list(/obj/structure/gravemarker, /obj/structure/fluff/psycross, /obj/structure/fluff/psycross/copper, /obj/structure/fluff/psycross/crafted, /obj/structure/fluff/psycross/necra/cloth, /obj/structure/fluff/psycross/necra)
	var/list/marked_objects = list()
	var/outline_color = "#4ea1e6"
	var/last_index = 1

/obj/effect/proc_holder/spell/invoked/necras_sight/cast(list/targets, mob/user)
	var/success
	if(isobj(targets[1]))
		var/obj/O = targets[1]
		if((O.type in whitelisted_objects))
			add_to_scry(O, user)
			return TRUE
	if(isturf(targets[1]))
		var/turf/T = targets[1]
		for(var/obj/O in T)
			if((O.type in whitelisted_objects))
				add_to_scry(O, user)
				return TRUE
		if(length(marked_objects))
			success = try_scry(user)
	if(ismob(targets[1]))
		if(length(marked_objects))
			success = try_scry(user)
	if(success)
		return TRUE
	revert_cast()
	return FALSE

#define GRAVE_SPY "grave_spy"

/obj/effect/proc_holder/spell/invoked/necras_sight/proc/try_scry(mob/living/carbon/human/user)
	listclearnulls(marked_objects)
	if(!length(marked_objects))
		return FALSE
// Build a display list: label -> obj
	var/list/choices = list()
	for(var/obj/O as anything in marked_objects)
		choices[marked_objects[O]] = O

	var/choice = input(user, "Which grave shall we peer through?", "") as null|anything in choices
	if(!choice)
		return FALSE

	var/obj/structure/gravemarker/spygrave = choices[choice]
	if(!spygrave)
		return FALSE

	// Add outline filter if missing
	var/filter = spygrave.get_filter(GRAVE_SPY)
	if(!filter)
		spygrave.add_filter(
			GRAVE_SPY,
			2,
			list(
				"type" = "outline",
				"color" = outline_color,
				"alpha" = 200,
				"size" = 1
			)
		)

	// Create scry eye
	var/mob/dead/observer/screye/S = user.scry_ghost()
	if(!S)
		return FALSE

	spygrave.visible_message(span_warning("[spygrave] shimmers with an eerie glow."))
	S.ManualFollow(spygrave)

	user.visible_message(
		span_danger("[user] blinks, [user.p_their()] eyes rolling back into [user.p_their()] head.")
	)

	user.playsound_local(get_turf(user), 'sound/magic/necra_sight.ogg', 80)

	// Cleanup after duration
	addtimer(CALLBACK(S, TYPE_PROC_REF(/mob/dead/observer, reenter_corpse)), 8 SECONDS)

	addtimer(CALLBACK(spygrave, TYPE_PROC_REF(/atom/movable, remove_filter), GRAVE_SPY), 8 SECONDS)

	return TRUE

#undef GRAVE_SPY

/obj/effect/proc_holder/spell/invoked/necras_sight/proc/add_to_scry(obj/O, mob/living/carbon/human/user)
	if(O in marked_objects)
		revert_cast()
		return
	var/holyskill = user.get_skill_level(/datum/skill/magic/holy)
	var/label = input(user, "Name this grave for your sight:", "Mark Holy Object") as text|null
	if(!label || !length(label))
		label = "[O.name]"

// Replace logic when at cap
	if(length(marked_objects) >= holyskill)
		to_chat(user, span_warning("I'm focusing on too many graves already. One slips from my mind..."))

		var/old_obj = marked_objects[last_index]
		marked_objects -= old_obj

		marked_objects[O] = label

		last_index++
		if(last_index > holyskill)
			last_index = 1
		return

	to_chat(user, span_info("I whisper a name and mark the grave for later use..."))
	marked_objects[O] = label

/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance
	name = "Avenging Spirits"
	desc = "Summon rancorous spirits to tear at an opponent!"
	range = 7
	sound = list('sound/magic/magnet.ogg')
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	releasedrain = 40
	chargetime = 30
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokeholy
	gesture_required = TRUE 
	associated_skill = /datum/skill/magic/holy
	recharge_time = 90 SECONDS
	hide_charge_effect = TRUE
	miracle = TRUE
	devotion_cost = 50
	overlay_icon = 'icons/mob/actions/necramiracles.dmi'
	overlay_state = "vengeful_spirit"
	action_icon_state = "vengeful_spirit"
	action_icon = 'icons/mob/actions/necramiracles.dmi'
	invocations = list("Awaken, rancor!!")
	invocation_type = "shout"



/obj/effect/proc_holder/spell/invoked/raise_spirits_vengeance/cast(list/targets, mob/living/user)
	. = ..()

	if(istype(get_area(user), /area/rogue/indoors/ravoxarena))
		to_chat(user, span_userdanger("I reach for outer help, but something rebukes me! This challenge is only for me to overcome!"))
		revert_cast()
		return FALSE

	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(user.dir == SOUTH || user.dir == NORTH)
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_turf(user),user)
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_step(user, EAST),user)
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_step(user, WEST),user)
		else
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_turf(user),user)
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_step(user, NORTH),user)
			new /mob/living/simple_animal/hostile/rogue/spirit_vengeance(get_step(user, SOUTH),user)
		for(var/mob/living/simple_animal/hostile/rogue/spirit_vengeance/swarm in view(2, user))
			swarm.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target) 
		return TRUE
	revert_cast()
	return FALSE
