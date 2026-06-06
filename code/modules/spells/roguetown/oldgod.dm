/datum/action/cooldown/spell/psydon
	background_icon = 'icons/mob/actions/psydonmiracles.dmi'
	button_icon = 'icons/mob/actions/psydonmiracles.dmi'
	spell_color = GLOW_COLOR_ASTRATA
	glow_intensity = null

	ignore_armor_penalty = TRUE

	attunement_school = null

	primary_resource_type = SPELL_COST_DEVOTION

	secondary_resource_type = SPELL_COST_STAMINA

	has_visual_effects = FALSE
	spell_impact_intensity = SPELL_IMPACT_NONE
	associated_stat = null
	associated_skill = /datum/skill/magic/holy
	spell_tier = 0

	point_cost = 0

	spell_flags = SPELL_PSYDON
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	required_items = list(/obj/item/clothing/neck/roguetown/psicross) //He is dead so yeah we need something to INVOKE IT

/////////////////////
// T0 - BOOTCHECK  //
/////////////////////

/datum/action/cooldown/spell/psydon/bootcheck
	name = "BOOTCHECK"
	desc = "'Now, where did I put that..?' </br>Checks your boot - or failing that, your surroundings - for something of use.\
	Scales with FORTUNE of the user."
	button_icon_state = "BOOTCHECK"
	sound = null

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_ADJACENT
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE

	secondary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocation_type = INVOCATION_NONE
	invocations = null

	charge_required = FALSE
	cooldown_time = 10 MINUTES

	var/static/list/lootpool = list(/obj/item/flowercrown/rosa,
	/obj/item/bouquet/rosa,
	/obj/item/jingle_bells,
	/obj/item/bouquet/salvia,
	/obj/item/bouquet/calendula,
	/obj/item/roguecoin/gold,
	/obj/item/roguecoin/silver,
	/obj/item/roguecoin/copper,
	/obj/item/alch/atropa,
	/obj/item/alch/salvia,
	/obj/item/alch/artemisia,
	/obj/item/alch/rosa,
	/obj/item/rogueweapon/huntingknife/idagger/navaja,
	/obj/item/lockpick,
	/obj/item/reagent_containers/glass/bottle/alchemical/strpot,
	/obj/item/reagent_containers/glass/bottle/alchemical/willpot,
	/obj/item/reagent_containers/glass/bottle/alchemical/conpot,
	/obj/item/reagent_containers/glass/bottle/alchemical/lucpot,
	/obj/item/reagent_containers/glass/bottle/rogue/poison,
	/obj/item/reagent_containers/glass/bottle/rogue/healthpot,
	/obj/item/needle,
	/obj/item/natural/rock,
	/obj/item/natural/bundle/cloth,
	/obj/item/natural/bundle/fibers,
	/obj/item/clothing/suit/roguetown/armor/leather/hide/bikini,
	/obj/item/reagent_containers/glass/bottle/waterskin/milk,
	/obj/item/reagent_containers/food/snacks/rogue/bread,
	/obj/item/reagent_containers/food/snacks/grown/apple,
	/obj/item/natural/worms,
	/obj/item/natural/worms/leech,
	/obj/item/reagent_containers/food/snacks/rogue/psycrossbun,
	/obj/item/clothing/neck/roguetown/psicross,
	/obj/item/clothing/neck/roguetown/psicross/wood,
	/obj/item/rope/chain,
	/obj/item/rope,
	/obj/item/clothing/neck/roguetown/collar,
	/obj/item/natural/dirtclod,
	/obj/item/reagent_containers/glass/cup/wooden,
	/obj/item/natural/glass,
	/obj/item/clothing/shoes/roguetown/sandals,
	/obj/item/alch/transisdust)

/datum/action/cooldown/spell/psydon/bootcheck/cast(atom/cast_on)
	. = ..()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/H = owner
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE

	var/obj/item/found_thing
	if(H.get_stress_amount() < 0 && H.STALUC > 10)
		found_thing = new /obj/item/roguecoin/gold(T)
	else if(H.STALUC == 10)
		found_thing = new /obj/item/roguecoin/silver(T)
	else
		found_thing = new /obj/item/roguecoin/copper(T)

	to_chat(H, span_info("A coin in my boot? Psydon smiles upon me!"))
	if(!H.put_in_hands(found_thing, FALSE))
		found_thing.forceMove(T)

	if(prob(H.STALUC + H.get_skill_level(associated_skill)))
		var/path = pick(lootpool)
		var/obj/item/extra = new path(T)
		to_chat(H, span_info("Ah, of course! I almost forgot I had this stashed away for a perfect occasion."))
		if(!H.put_in_hands(extra, FALSE))
			extra.forceMove(T)

	return TRUE

/////////////////
// T1 - ENDURE //
/////////////////

/datum/action/cooldown/spell/psydon/endure
	name = "ENDURE"
	desc = "Invoke an invigorating prayer for those who are faltering in body and spirit. </br>‎  </br>Provides minor wound regeneration, staunches bleeding, and eases the burden of suffocation. Healing scales with the caster's Miracle proficiency and the quality of their worn Psycross. Those who have suffered grievous injury find the prayer's strength magnified, drawing resolve from pain itself."
	fluff_desc = "<font color='#579aff'>THE WORLD DOES NOT OWE US MERCY. IT OFFERS ONLY SUFFERING, LOSS, AND STRIFE. SO WE SHALL MEET IT WITH CLENCHED FISTS AND BARED TEETH. WE SHALL BLEED. WE SHALL STUMBLE. WE SHALL FALL. BUT WE SHALL ALWAYS RISE AGAIN. ENDURE.</font>"
	button_icon_state = "ENDURE"
	sound = 'sound/magic/ENDVRE.ogg'

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_ADJACENT + 1
	self_cast_possible = TRUE

	primary_resource_cost = SPELLCOST_MIRACLE + 10

	secondary_resource_cost = SPELLCOST_MIRACLE_MINOR

	charge_required = FALSE
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/psydon/endure/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/H = owner

	if(!isliving(cast_on))
		return FALSE

	var/mob/living/target = cast_on

	if(!check_psydon_favor(H))
		return FALSE

	if(H.cmode)
		if(H != target)
			H.visible_message(span_blue("[H] fervently recites an orison, invoking the warmth of a dying light."))
			H.say(pick("ENDURE!!", "ENDURE!!", "ENDURE!!", "ENDURE!!", "ENDURE!!", "ENDURE!!", "COME ON!!", "HANG ON!!", "GRIT!!", "STAND TALL!!"))
		else
			H.visible_message(span_blue("[H] grits their teeth and recites an orison, invoking the warmth of a dying light."))
	else
		H.visible_message(span_blue("[H] quietly recites an orison, invoking the warmth of a dying light."))

	if(H.patron?.undead_hater && (target.mob_biotypes & MOB_UNDEAD))
		target.visible_message(span_info("A strange stirring feeling pours from [target]!"), span_info("Sentimental thoughts drive away my pain..."))
		return TRUE

	target.visible_message(span_info("A strange stirring feeling pours from [target]!"), span_info("Sentimental thoughts drive away my pain..."))

	var/psyhealing = 3
	psyhealing += get_healing_power(H)
	psyhealing += get_suffering_bonus(target)

	if(get_suffering_bonus(target))
		to_chat(H, "<font color='#ffffff'><b>PAIN</b> is a <b>MINOR SETBACK</b>! Let it be <b>FUEL</b> for <b>RESOLVE</b>.</font>")
		to_chat(target, "<font color='#c5c5c5'><i>You can't stay down. You won't stay down. CARRY. ON. DON'T. STOP.</i></font>")
		to_chat(target, "<font color='#ffffff'><b><i>ENDURE!</b></i></font>")
		if(H.resting)
			H.remove_status_effect(/datum/status_effect/incapacitating/stun)
			H.remove_status_effect(/datum/status_effect/incapacitating/knockdown)
			H.set_resting(FALSE, FALSE)

	target.apply_status_effect(/datum/status_effect/buff/psyhealing, (psyhealing/3))

	for(var/datum/wound/W as anything in target.get_wounds())
		if(W?.bleed_rate > 0)
			W.set_bleed_rate(0)

	return TRUE

////////////////////
// T1~3 - PERSIST //
////////////////////

/datum/action/cooldown/spell/psydon/persist
	name = "PERSIST"
	desc = "Stand firm against pain and doubt through nothing but sheer Humen grit. </br>‎  </br>While remaining still, steadily restores Brute and Burn damage over time at the cost of your Energy and Nutrition. Healing scales with Miracle skill and the quality of your worn Psycross. The more wounded you are, the more fiercely your faith compels your body to recover."
	fluff_desc = "<font color='#579aff'>MY FAITH IS MY SHIELD, FOR FAITH IS NOT THE ABSENCE OF SUFFERING, BUT THE STRENGTH TO WEATHER IT. SO LONG AS MY DEVOTION TO HIM ENDURES, SO TOO SHALL I PERSIST!!</font>"
	button_icon_state = "PERSIST"
	sound = null

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_ADJACENT
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = 15

	secondary_resource_cost = SPELLCOST_MIRACLE_MINOR

	charge_required = FALSE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/spell/psydon/persist/cast(atom/cast_on)
	. = ..()

	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/H = owner

	if(!check_psydon_favor(H))
		return FALSE

	show_visible_message(H, span_blue("[H] closes their eyes, and takes a deep breath..."), span_blue("I take a moment to collect myself..."))

	for(var/i in 1 to 10)

		if(!do_after(H, 50))
			break

		var/heal_amount = get_persist_healing(H)

		playsound(H, 'sound/magic/psydonrespite.ogg', 100, TRUE)
		new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#e4e4e4")
		new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#e4e4e4")

		H.adjustBruteLoss(-heal_amount)
		H.adjustFireLoss(-heal_amount)
		H.energy_add(-heal_amount/2)
		H.nutrition -= heal_amount

		if(!(i % 2))
			to_chat(H, span_info("<i><font color='#71c6ff'>[get_persist_quote()]</i></font>"))

	show_visible_message(H, span_blue("[H] opens their eyes, smiling eerily for a mote."), span_blue("My thoughts and sense of quiet escape me."))

	return TRUE

///////////////
// T3 - WEEP //
///////////////
// This is now a T3 Miracle, which means, Missionary can also get it. The idea will be fairly controversial, but we'll see if it's good or not sooner or later.

/obj/effect/proc_holder/spell/invoked/psydonlux_tamper
	name = "WEEP"
	action_icon = 'icons/mob/actions/psydonmiracles.dmi'
	overlay_icon = 'icons/mob/actions/psydonmiracles.dmi'
	overlay_state = "WEEP" //Absolver-exclusive. Classified as 'lux-magicka', rather than a traditional miracle. Same line of thought as the Naledians.
	releasedrain = 33
	chargedrain = 0
	chargetime = 0
	range = 3
	warnie = "sydwarning"
	desc = "Lesser lux-magicka. Endure the wounds of another, for their sake. </br>‎  </br>Siphons away lesser injuries, such as gashes and fractures, from the target. In exchange, any siphoned injuries are subsequently imposed onto you. If the target has lost any blood, they will be fully replenished through your own veins."
	movement_interrupt = FALSE
	sound = 'sound/magic/psydonbleeds.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 30 SECONDS
	miracle = TRUE
	devotion_cost = 80

/obj/effect/proc_holder/spell/invoked/psydonlux_tamper/cast(list/targets, mob/living/user)

	if(!ishuman(targets[1]))
		to_chat(user, span_warning("Their Lux cannot be interacted with."))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/H = targets[1]

	if(H == user)
		to_chat(user, span_warning("I cannot interact with my own Lux."))
		revert_cast()
		return FALSE

	if(!H.key && !H.get_ghost(FALSE, TRUE))
		to_chat(user, span_warning("[H] is irreversibly gone... There's nothing we can do to bring them back anymore!"))
		user.emote("cry")
		revert_cast()
		return FALSE

	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_DEADITE))
		to_chat(user, span_warning("[H]'s Lux is extinguished... What can I do?!"))
		user.emote("cry")
		revert_cast()
		return FALSE

	if(!ishuman(user))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/C_target = H
	var/mob/living/carbon/human/C_caster = user
	var/list/tw_List = C_target.get_wounds()
	var/list/BPs_to_check = list()

	H.visible_message(span_blue("[user] connects their Lux with [H]'s own."))
	if(user.cmode)
		user.say(pick("RESPITE FOR THY WOUNDS!", "BLEED STANDING!", "I BLEED SO YOU MAY ENDURE!", "PERSIST AGAINST THE PAIN!","LET YOUR WOUNDS WEEP NO MORE!","THIS IS OUR TRIAL!"))
		if(HAS_TRAIT(user, TRAIT_IRONMAN))
			user.electrocute_act(10, user)
	else
		user.say(pick("Psydon endures, so we must!","May your wounds weep no more!","Psydon provides respite for thy wounds!","I shall endure for you!","Allfather, let me bleed in their stead!"))
		if(HAS_TRAIT(user, TRAIT_IRONMAN))
			user.adjustFireLoss(25)

	// WOUND TRANSFER
	for(var/datum/wound/targetwound in tw_List)
		if(istype(targetwound, /datum/wound/dismemberment))
			continue
		if(istype(targetwound, /datum/wound/facial))
			continue
		if(istype(targetwound, /datum/wound/fracture/head))
			continue
		if(istype(targetwound, /datum/wound/fracture/neck))
			continue
		if(istype(targetwound, /datum/wound/cbt/permanent))
			continue
		if(!targetwound.bodypart_owner)
			continue

		var/obj/item/bodypart/c_BP = C_caster.get_bodypart(targetwound.bodypart_owner.body_zone)
		if(!c_BP)
			continue

		var/wound_type = translate_wound_for_target(targetwound, C_caster)

		if(!wound_type)
			continue

		var/datum/wound/newwound = new wound_type()

		targetwound.copy_to(newwound)

		// preserve non-bleeding treatment states BEFORE application
		if(targetwound.is_clotted() || targetwound.is_sewn())
			newwound.set_bleed_rate(0)

		newwound = c_BP.add_wound(newwound)

		if(!newwound)
			c_BP.receive_damage(targetwound.whp)

			if(!(c_BP in BPs_to_check))
				LAZYADD(BPs_to_check, c_BP)

		if((HAS_TRAIT(C_caster, TRAIT_NOPAIN) || HAS_TRAIT(C_caster, TRAIT_NOPAINSTUN)) && HAS_TRAIT(C_caster, TRAIT_BLOODLOSS_IMMUNE))
			if(!(c_BP in BPs_to_check))
				c_BP.receive_damage(targetwound.whp)
				LAZYADD(BPs_to_check, c_BP)

		var/obj/item/bodypart/t_BP = C_target.get_bodypart(targetwound.bodypart_owner.body_zone)

		if(t_BP)
			t_BP.remove_wound(targetwound.type)

	if(length(BPs_to_check))
		var/stuntime = 0

		for(var/obj/item/bodypart/c_BP in BPs_to_check)

			if(c_BP.get_damage() >= c_BP.max_damage)

				if(istype(c_BP, /obj/item/bodypart/head) || !c_BP.dismember(skip_checks = TRUE))
					stuntime += 5 SECONDS

		if(stuntime)
			C_caster.Knockdown(stuntime)
			C_caster.apply_status_effect(/datum/status_effect/debuff/exposed, stuntime)
			C_caster.emote("pain")

	var/mob/living/carbon/human/C = user

	// DAMAGE TRANSFER
	var/brute_transfer = H.getBruteLoss() * 0.25
	var/burn_transfer = H.getFireLoss() * 0.25
	var/tox_transfer = H.getToxLoss() * 0.25
	var/oxy_transfer = H.getOxyLoss()
	var/clone_transfer = H.getCloneLoss()

	H.adjustBruteLoss(-brute_transfer)
	H.adjustFireLoss(-burn_transfer)
	H.adjustToxLoss(-tox_transfer)
	H.adjustOxyLoss(-oxy_transfer)
	H.adjustCloneLoss(-clone_transfer)

	C.adjustBruteLoss(brute_transfer)
	C.adjustFireLoss(burn_transfer)
	C.adjustToxLoss(tox_transfer)
	C.adjustOxyLoss(oxy_transfer)
	C.adjustCloneLoss(clone_transfer)

	// BLOOD TRANSFER
	var/blood_needed = max(0, BLOOD_VOLUME_NORMAL - H.blood_volume)

	if(blood_needed)
		if(NOBLOOD in C.dna?.species?.species_traits)
			H.blood_volume = min(BLOOD_VOLUME_NORMAL, H.blood_volume + round(BLOOD_VOLUME_NORMAL * 0.5))
			C.adjustFireLoss(round(blood_needed / 4))
		else
			var/transfer_cap = round(C.blood_volume * 0.5)
			var/transferred = min(blood_needed, transfer_cap)

			if(transferred > 0)
				H.blood_volume += transferred
				C.blood_volume -= transferred

	// VISUALS
	user.visible_message(span_danger("[user] purifies [H]'s wounds!"))

	playsound(get_turf(user), 'sound/magic/psydonbleeds.ogg', 50, TRUE)

	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97")

	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97")

	to_chat(user, span_notice("You purify their Lux with the merging of theirs and your own, for a mote."))
	to_chat(H, span_info("You feel a gentle stirring sensation pour over your Lux, stealing your wounds."))

	return TRUE

//////////////////
// T4 - ABSOLVE //
//////////////////
// This is unique to the Absolver. No buts.

/obj/effect/proc_holder/spell/invoked/psydonabsolve	
	name = "ABSOLVE"
	action_icon = 'icons/mob/actions/psydonmiracles.dmi'
	overlay_icon = 'icons/mob/actions/psydonmiracles.dmi'
	overlay_state = "ABSOLVE" //Absolver-exclusive. Classified as 'lux-magicka', rather than a traditional miracle. Same line of thought as the Naledians.
	desc = "Greater lux-magicka. Exchange your vitality for the sake of another. </br>‎  </br>Siphons away all injuries - be it physical damage, blood loss, or dismemberment - from the target, completely healing them. In exchange, all siphoned injuries are subsequently inflicted unto you. Using this on a target who's dead will fully resurrect them, albeit at the cost of your own lyfe."
	releasedrain = 50
	chargedrain = 0
	chargetime = 0
	range = 3
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/psyabsolution.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 30 SECONDS // 60 seconds cooldown
	miracle = TRUE
	devotion_cost = 100

/obj/effect/proc_holder/spell/invoked/psydonabsolve/cast(list/targets, mob/living/user)

	if(!ishuman(targets[1]))
		to_chat(user, span_warning("ABSOLUTION is for those who walk in HIS image!"))
		revert_cast()
		return FALSE

	if(!ishuman(user))
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/H = targets[1]
	var/mob/living/carbon/human/C = user

	// CONSEQUENCE WARNING CHECKS

	var/will_die = FALSE
	var/will_lose_limbs = FALSE

	// Resurrection costs your life.
	if(H.stat >= DEAD)
		will_die = TRUE

	// Limb restoration costs your limbs.
	var/list/warning_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

	for(var/zone in warning_zones)
		if(!H.get_bodypart(zone))
			if(C.get_bodypart(zone))
				will_lose_limbs = TRUE
				break

	if(will_die || will_lose_limbs)

		var/list/messages = list()

		if(will_die)
			messages += span_userdanger("THIS TARGET IS DEAD. ABSOLUTION WILL CLAIM YOUR LIFE.")

		if(will_lose_limbs)
			messages += span_userdanger("THIS TARGET IS MISSING LIMBS. YOU WILL SACRIFICE YOUR OWN LIMBS.")

		messages += ""
		messages += "Continue?"

		if(alert(C, messages.Join("\n"), "ABSOLUTION WARNING", "YES", "NO") != "YES")
			revert_cast()
			return FALSE

	if(H == C)
		to_chat(C, span_warning("You cannot ABSOLVE yourself!"))
		revert_cast()
		return FALSE

	H.visible_message(span_red("[user] <i>dangerously</i> connects their Lux with [H]'s own."))

	// REVIVE PATH
	if(H.stat >= DEAD)
		if(!H.key && !H.get_ghost(FALSE, TRUE))
			to_chat(user, span_warning("[H] is irreversibly gone... there's nothing we can do to bring them back anymore!"))
			user.emote("cry")
			revert_cast()
			return FALSE
		if(!H.check_revive(C))
			revert_cast()
			return FALSE
		if(alert(C,"REACH OUT AND PULL?","THERE'S NO LUX IN THERE","YES","NO") != "YES")
			revert_cast()
			return FALSE
		C.visible_message(span_danger("[C] grabs [H] by the wrists, attempting to ABSOLVE them!"))
		C.emote("whimper")
		if(alert(H,"They want to ABSOLVE you. Will you let them?","ABSOLUTION","I accept!","I refuse..") != "I accept!")
			return FALSE
		H.apply_status_effect(/datum/status_effect/buff/psyvived)
		C.say("MY LYFE FOR YOURS! LYVE, AS DOES HE!", forced=TRUE, language=/datum/language/common)
		C.visible_message(span_danger("[C] suddenly collapses, as the last of their lux is siphoned into [H]'s chest!")) //Originally "[C] suddenly falls down on the ground... DEAD and PSY-DONE!".
		C.death()
		H.revive(full_heal=TRUE, admin_revive=FALSE)
		H.adjustOxyLoss(-H.getOxyLoss())
		H.grab_ghost(force=TRUE)
		H.emote("breathgasp")
		H.Jitter(100)
		H.update_body()
		record_round_statistic(STATS_LUX_REVIVALS)
		ADD_TRAIT(H, TRAIT_IWASREVIVED, "[type]")
		H.apply_status_effect(/datum/status_effect/buff/psyvived)
		C.apply_status_effect(/datum/status_effect/buff/psyvived)
		H.visible_message(span_notice("[H] is ABSOLVED!"))
		H.mind.remove_antag_datum(/datum/antagonist/zombie)
		H.remove_status_effect(/datum/status_effect/debuff/rotted_zombie)
		H.apply_status_effect(/datum/status_effect/debuff/revived)
		return TRUE

	if(user.cmode)
		user.say(pick("BE ABSOLVED!","I'LL BLEED IN YOUR STEAD!","YOUR TIME IS NOT NOW!","I SHALL WEEP IN YOUR STEAD!","ENDURE, AS HE DOES!","PERSIST, AS HE DOES!"))
		if(HAS_TRAIT(user, TRAIT_IRONMAN))
			user.electrocute_act(10, user)
	else
		user.say(pick("Live, as he does!","Be healed in His name!","May your injuries be mine to bear!","I absolve you of your wounds!","Be absolved!"))
		if(HAS_TRAIT(user, TRAIT_IRONMAN))
			user.adjustFireLoss(25)

	// LIMB TRANSFER
	var/list/zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

	for(var/zone in zones)
		var/obj/item/bodypart/tBP = H.get_bodypart(zone)

		if(!tBP)
			H.regenerate_limb(zone)
			var/obj/item/bodypart/cBP = C.get_bodypart(zone)
			if(cBP)
				cBP.dismember()
				if(HAS_TRAIT(H, TRAIT_IRONMAN)) // im just assuming constructs can't use any other limbs than their own, so instead of delimbing, eat an integrity
					var/obj/item/bodypart/daChest = H.get_bodypart(BODY_ZONE_CHEST)
					daChest.add_wound(/datum/wound/integrity/chest)
				else
					qdel(cBP)

	// WOUND TRANSFER
	var/list/wounds = H.get_wounds()

	for(var/datum/wound/W in wounds)
		if(!W.bodypart_owner)
			continue

		var/obj/item/bodypart/cBP = C.get_bodypart(W.bodypart_owner.body_zone)
		if(!cBP)
			continue

		var/new_type = translate_wound_for_target(W, C)

		if(!new_type)
			continue

		var/datum/wound/newW = new new_type()

		W.copy_to(newW)

		if(W.is_clotted() || W.is_sewn())
			newW.set_bleed_rate(0)

		newW = cBP.add_wound(newW)

		if(!newW)
			cBP.receive_damage(W.whp)

		var/obj/item/bodypart/tBP = H.get_bodypart(W.bodypart_owner.body_zone)

		if(tBP)
			tBP.remove_wound(W.type)

	// DAMAGE TRANSFER
	var/brute_transfer = H.getBruteLoss()
	var/burn_transfer = H.getFireLoss()
	var/tox_transfer = H.getToxLoss()
	var/oxy_transfer = H.getOxyLoss()
	var/clone_transfer = H.getCloneLoss()

	H.adjustBruteLoss(-brute_transfer)
	H.adjustFireLoss(-burn_transfer)
	H.adjustToxLoss(-tox_transfer)
	H.adjustOxyLoss(-oxy_transfer)
	H.adjustCloneLoss(-clone_transfer)

	C.adjustBruteLoss(brute_transfer)
	C.adjustFireLoss(burn_transfer)
	C.adjustToxLoss(tox_transfer)
	C.adjustOxyLoss(oxy_transfer)
	C.adjustCloneLoss(clone_transfer)

	// BLOOD TRANSFER
	var/blood_needed = max(0, BLOOD_VOLUME_NORMAL - H.blood_volume)

	if(blood_needed)
		if(NOBLOOD in C.dna?.species?.species_traits)
			H.blood_volume = BLOOD_VOLUME_NORMAL
			C.adjustFireLoss(round(blood_needed / 4))
		else
			var/transferred = min(blood_needed, C.blood_volume)

			if(transferred > 0)
				H.blood_volume += transferred
				C.blood_volume -= transferred

			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				var/remaining = BLOOD_VOLUME_NORMAL - H.blood_volume

				H.blood_volume += remaining
				C.blood_volume -= remaining

			if(C.blood_volume <= 0)
				C.blood_volume = BLOOD_VOLUME_SURVIVE

	// VISUALS
	C.visible_message(span_danger("[C] absolves [H]'s suffering!"))

	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#aa1717")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#aa1717")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#aa1717")

	new /obj/effect/temp_visual/psyheal_rogue(get_turf(C), "#aa1717")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(C), "#aa1717")
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(C), "#aa1717")

	to_chat(C, span_warning("You take [H]'s suffering upon yourself!"))
	to_chat(H, span_notice("[C] absolves you of your injuries!"))

	return TRUE

/proc/translate_wound_for_target(datum/wound/W, mob/living/carbon/human/recipient)
	if(!W || !recipient)
		return null
	var/is_construct = HAS_TRAIT(recipient, TRAIT_IRONMAN)
	switch(W.type)
		if(/datum/wound/artery)
			return is_construct ? /datum/wound/integrity : W.type
		if(/datum/wound/artery/chest)
			return is_construct ? /datum/wound/integrity/chest : W.type
		if(/datum/wound/artery/neck)
			return is_construct ? /datum/wound/integrity/neck : W.type
		if(/datum/wound/integrity)
			return is_construct ? W.type : /datum/wound/artery
		if(/datum/wound/integrity/chest)
			return is_construct ? W.type : /datum/wound/artery/chest
		if(/datum/wound/integrity/neck)
			return is_construct ? W.type : /datum/wound/artery/neck

	return W.type

// UNUSED DIALOGUE: PRAYER, RESPITE, PERSIST
// ("#..our father above, hallowed be thy name..","#..thy kingdom come, thy will be done..","#..I fear no evil, for thou art with me..")
// ("#..with every broken bone, I swore I lyved..","#..thou shalt ward me within the valleys o' evil..","#..the fires of Syon, everburning with thine vigor..")
// ("#..in Psydon's glory, all malaises shall melt away..","#..thine holy spirit lies within all our hearts, weeping forevermore..","#..thou shalt know all, for enduring begets enlightenment..")
