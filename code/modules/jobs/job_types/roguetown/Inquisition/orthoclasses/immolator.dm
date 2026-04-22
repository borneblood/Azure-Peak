/datum/advclass/immolator
	name = "Immolator"
	tutorial = "Zealots of the Psydonite Inquisition, Immolators are living pyres clad in scripture and steel. Where others see sin, they see fuel. Flame is their sermon, ash their absolution. Mercy is scarce, but purification is not."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/immolator
	subclass_languages = list(/datum/language/otavan)
	category_tags = list(CTAG_ORTHODOXIST)
	traits_applied = list(
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_NOPAINSTUN
	)
	subclass_stats = list(
		STATKEY_WIL = 2,
		STATKEY_CON = 1,
		STATKEY_INT = 2,
		STATKEY_SPD = 3
	)
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"Tome of Psydon" = /obj/item/book/rogue/bibble/psy
	)

/datum/outfit/job/roguetown/immolator
	job_bitflag = BITFLAG_HOLY_WARRIOR

/obj/item/storage/belt/rogue/leather/rope/dark
	color = "#505050"

/datum/outfit/job/roguetown/immolator/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	if(H.mind)
		ADD_TRAIT(H, TRAIT_FIRE_RESIST, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_ARCYNE, TRAIT_GENERIC)
		H.mind.AddSpell(new /datum/action/cooldown/spell/fire_blast/immolator)
		H.mind.AddSpell(new /datum/action/cooldown/spell/fire_blast/immolator)

	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
	backl = /obj/item/storage/backpack/rogue/satchel/otavan
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers/psythorns
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	id = /obj/item/clothing/ring/signet/silver

	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	armor = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/disciple

	backpack_contents = list(/obj/item/roguekey/inquisitionmanor = 1,
	/obj/item/paper/inqslip/arrival/ortho = 1)
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	beltl = /obj/item/storage/belt/rogue/pouch/coins/mid
	cloak = /obj/item/clothing/cloak/tabard/psydontabard/alt

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)

/datum/action/cooldown/spell/fire_blast/immolator
	name = "Purity Pyre"
	desc = "Unleash a wave of sanctified white flame in a wide path, scorching all before you. The faithful call it mercy. The condemned call it the end."
	line_length = 5 // forward distance
	var/line_width = 3
	var/blessed_stacks_applied = 2

/datum/action/cooldown/spell/fire_blast/immolator/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/start = get_turf(H)
	var/turf/target_turf = get_turf(cast_on)

	var/dir_forward = get_dir(start, target_turf)
	if(!dir_forward)
		dir_forward = H.dir

	var/dir_left = turn(dir_forward, 90)
	var/dir_right = turn(dir_forward, -90)

	var/list/affected_turfs = list()

	for(var/i in 1 to line_length)
		var/turf/center = get_step(start, dir_forward, i)
		if(!center || center.density)
			break

		var/list/row = list(center)

		if(line_width >= 3)
			var/turf/L = get_step(center, dir_left)
			var/turf/R = get_step(center, dir_right)
			if(L && !L.density) row += L
			if(R && !R.density) row += R

		for(var/turf/T in row)
			if(!T) continue
			affected_turfs += T

	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/fire/white(T)
		new /obj/effect/hotspot(T, null, null, hotspot_life)

	playsound(start, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, TRUE, 4)

	var/list/already_hit = list()
	var/blocked = FALSE

	for(var/turf/T in affected_turfs)
		if(blocked)
			break

		var/list/victims_here = list()
		for(var/mob/living/L in T)
			victims_here += L

		for(var/mob/living/victim as anything in victims_here)
			if(victim == H || (victim in already_hit))
				continue

			if(victim.anti_magic_check())
				victim.visible_message(span_warning("The sacred flames recoil from [victim]!"))
				continue

			if(spell_guard_check(victim, FALSE, H))
				blocked = TRUE
				continue

			var/damage_dealt = arcyne_strike(H, victim, null, blast_damage, BODY_ZONE_CHEST, \
				BCLASS_BURN, spell_name = "Cleansing Pyre", \
				allow_shield_check = TRUE, damage_type = BURN, \
				skip_animation = TRUE)

			if(!damage_dealt)
				blocked = TRUE
				continue

			// 🔥 Apply BLESSED white flame stacks
			var/datum/status_effect/fire_handler/fire_stacks/sunder/blessed/F = victim.get_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)
			if(!F)
				F = victim.apply_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)

			if(F)
				F.add_stacks(blessed_stacks_applied)

			victim.ignite_mob()

			new /obj/effect/temp_visual/spell_impact(get_turf(victim), spell_color, spell_impact_intensity)

			already_hit += victim

			var/push_dir = get_dir(H, victim)
			if(!push_dir)
				push_dir = dir_forward

			victim.safe_throw_at(get_ranged_target_turf(victim, push_dir, push_dist), push_dist, 2, H, force = MOVE_FORCE_STRONG)

		for(var/obj/item/I in T)
			if(I.anchored)
				continue
			var/toss_dir = get_dir(H, I)
			if(!toss_dir)
				toss_dir = dir_forward
			I.throw_at(get_ranged_target_turf(I, toss_dir, push_dist), push_dist, 2)

	if(length(already_hit))
		H.visible_message(span_danger("[H] unleashes a wave of searing white flame, casting [english_list(already_hit)] into the pyre!"))
	else
		H.visible_message(span_danger("[H] unleashes a wave of searing white flame!"))

	return TRUE

/datum/action/cooldown/spell/fire_curtain/immolator
	name = "Purity Inferno"
	desc = "Mark a wide area for divine incineration. After a brief omen, sanctified white flame engulfs all within. None are spared—not even you."

	var/area_size = 4 // 4x4 zone

/datum/action/cooldown/spell/fire_curtain/immolator/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	var/list/affected_turfs = get_area_turfs(center)

	// Telegraph (white flame warning)
	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/trap_wall/fire/white(T)

	H.visible_message(span_danger("[H] marks the ground for immolation!"))
	playsound(get_turf(H), 'sound/magic/charging_fire.ogg', 60, TRUE)

	addtimer(CALLBACK(src, PROC_REF(spawn_curtain), affected_turfs), telegraph_time)
	return TRUE

/datum/action/cooldown/spell/fire_curtain/immolator/proc/get_area_turfs(turf/center)
	var/list/turfs = list()

	var/half = floor(area_size / 2)

	for(var/x = -half to half - 1)
		for(var/y = -half to half - 1)
			var/turf/T = locate(center.x + x, center.y + y, center.z)
			if(T)
				turfs += T

	return turfs

/datum/action/cooldown/spell/fire_curtain/immolator/proc/spawn_curtain(list/turfs)
	if(QDELETED(src) || QDELETED(owner))
		return

	for(var/turf/T in turfs)
		new /obj/effect/hotspot(T, null, null, hotspot_life)
		new /obj/effect/temp_visual/fire/white(T)

		// Apply blessed burning to anything inside at spawn
		for(var/mob/living/L in T)
			if(L.anti_magic_check())
				continue

			var/datum/status_effect/fire_handler/fire_stacks/sunder/blessed/F = L.get_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)
			if(!F)
				F = L.apply_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)

			if(F)
				F.add_stacks(2)

			L.ignite_mob()

	playsound(turfs[1], pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 120, TRUE, 6)

/obj/effect/temp_visual/trap_wall/fire/white
	color = "#FFFFFF"
	light_color = "#FFFFFF"
	duration = 3 SECONDS

/datum/action/cooldown/spell/final_absolution
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	name = "Final Absolution"
	desc = "Pass judgment upon one bound to the psicross. Flame strips away sin—or the sinner."

	button_icon_state = "fireball"
	sound = 'sound/magic/charging_fire.ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_HIGH

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_TARGET

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_EXTREME

	invocations = list("Absolutio per Ignem!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY

	cooldown_time = 60 SECONDS

	associated_skill = /datum/skill/magic/holy

/datum/action/cooldown/spell/final_absolution/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/H = owner
	var/mob/living/carbon/human/target = cast_on

	if(!istype(H) || !istype(target))
		return FALSE

	// Must be bound to psicross
	if(!target.is_bound_to_psicross())
		to_chat(H, span_warning("The rite demands a bound sinner."))
		return FALSE

	H.visible_message(span_danger("[H] raises a hand in judgment over [target]!"))

	// Stage 1: Ignite
	addtimer(CALLBACK(src, PROC_REF(stage_ignite), target), 1 SECONDS)
	return TRUE

/datum/action/cooldown/spell/final_absolution/proc/stage_ignite(mob/living/target)
	if(QDELETED(target)) return

	target.visible_message(span_warning("[target]'s body begins to smolder with pale flame!"))

	target.adjust_fire_stacks(2)
	target.ignite_mob()

	addtimer(CALLBACK(src, PROC_REF(stage_inferno), target), 2 SECONDS)

/datum/action/cooldown/spell/final_absolution/proc/stage_inferno(mob/living/target)
	if(QDELETED(target)) return

	target.visible_message(span_danger("The flames intensify, engulfing [target] in a searing blaze!"))

	// Heavy blessed burn
	var/datum/status_effect/fire_handler/fire_stacks/sunder/blessed/F = target.get_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)
	if(!F)
		F = target.apply_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed)

	if(F)
		F.add_stacks(5)

	target.ignite_mob()

	addtimer(CALLBACK(src, PROC_REF(stage_explosion), target), 2 SECONDS)

/datum/action/cooldown/spell/final_absolution/proc/stage_explosion(mob/living/target)
	if(QDELETED(target)) return

	target.visible_message(span_userdanger("[target] erupts in a burst of sanctified flame!"))

	new /obj/effect/temp_visual/spell_impact(get_turf(target), GLOW_COLOR_FIRE, SPELL_IMPACT_HIGH)
	playsound(get_turf(target), 'sound/misc/explode/incendiary (1).ogg', 120, TRUE)

	// Optional: small AoE damage
	for(var/mob/living/L in range(1, target))
		if(L == target) continue
		arcyne_strike(owner, L, null, 15, BODY_ZONE_CHEST, BCLASS_BURN, damage_type = BURN)

	addtimer(CALLBACK(src, PROC_REF(stage_judgement), target), 2 SECONDS)

/datum/action/cooldown/spell/final_absolution/proc/stage_judgement(mob/living/target)
	if(QDELETED(target)) return

	// Check if "eligible" for cleansing
	var/eligible = FALSE

	if(target.is_werewolf() || target.is_vampire() || target.is_heretic())
		eligible = TRUE

	if(eligible)
		var/choice = alert(target, "The flames do not consume you. They demand surrender. Accept cleansing?", "Final Absolution", "Be Cleansed", "Refuse")

		if(choice == "Be Cleansed")
			target.visible_message(span_notice("[target] is consumed in white flame... and emerges purified?!"))
			target.cleanse_corruption() // you implement this
			return
		else
			target.visible_message(span_danger("[target] rejects absolution! The flames turn wrathful!"))

	// Default outcome: dust
	target.visible_message(span_userdanger("[target] is reduced to ash in HIS fire!"))
	target.dust()
