/datum/advclass/immolator
	name = "Immolator"
	tutorial = "Diehard zealots of the Psydonite Inquisition, Immolators are living pyres clad in scripture and steel. Sorcerers who have learned how to blend their Lux to flames, recreating the purity of Silver. Where others see sin, they see fuel. Flame is their sermon, ash their absolution. Mercy is scarce, but purification is not. They forsake the use of armor to better channel their Lux into the flames, increasing their control sharply."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/immolator
	subclass_languages = list(/datum/language/otavan)
	category_tags = list(CTAG_ORTHODOXIST)
	traits_applied = list(
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
	)
	subclass_stats = list(
		STATKEY_WIL = 3,
		STATKEY_CON = 2,
		STATKEY_INT = 2,
		STATKEY_SPD = 2
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
	to_chat(H, span_warning("Your abilities have very low cooldowns, but build Lux-Magicka fatigue. As it rises, it causes pain and damages you over time. Let it cool, or risk harming yourself and your Psydonite allies. At high levels, your power intensifies — but if you push too far, it may end in a fatal discharge of fire and soul."))
	if(H.mind)
		ADD_TRAIT(H, TRAIT_FIRE_RESIST, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_ARCYNE, TRAIT_GENERIC)
		H.mind.AddSpell(new /datum/action/cooldown/spell/fire_blast/immolator)
		H.mind.AddSpell(new /datum/action/cooldown/spell/fire_curtain/immolator)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/purity_afloat)

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

#define LUX_FILTER "lux_glow"
#define LUX_DECAY_DELAY (8 SECONDS)
#define LUX_DECAY_INTERVAL (6 SECONDS)

/atom/movable/screen/alert/status_effect/buff/lux_fatigue
	name = "Lux Fatigue (0)"
	desc = "Using Lux-Magicka builds fatigue over time. High fatigue increases power, but damages you and may cause a violent discharge."
	icon_state = "buff"

/datum/status_effect/buff/lux_fatigue
	id = "lux_fatigue"
	alert_type = /atom/movable/screen/alert/status_effect/buff/lux_fatigue
	duration = -1
	tick_interval = 20
	status_type = STATUS_EFFECT_UNIQUE

	var/stacks = 0
	var/max_stacks = 10

	var/overcharge_threshold = 7
	var/explosion_threshold = 10

	var/damage_per_tick = 3
	var/last_gain_time = 0
	var/last_decay_time = 0

	var/glow_colour = "#d9b84a"
	var/overcharge_colour = "#ff9a3c"

	var/is_overcharged = FALSE

/datum/status_effect/buff/lux_fatigue/on_apply()
	. = ..()
	update_alert()

/datum/status_effect/buff/lux_fatigue/on_remove()
	owner.remove_filter(LUX_FILTER)
	. = ..()

/datum/status_effect/buff/lux_fatigue/proc/add_fatigue(amount)
	var/old = stacks
	stacks = min(stacks + amount, max_stacks)
	last_gain_time = world.time

	if(stacks == old)
		return

	owner.balloon_alert(owner, "F: [stacks]/[max_stacks]")
	update_visuals()
	update_alert()

	if(old < overcharge_threshold && stacks >= overcharge_threshold)
		to_chat(owner, span_warning("My power surges uncontrollably!"))

	if(stacks >= explosion_threshold)
		trigger_explosion()

/datum/status_effect/buff/lux_fatigue/proc/reduce_fatigue(amount)
	stacks = max(stacks - amount, 0)
	owner.balloon_alert(owner, "F: [stacks]/[max_stacks]")
	update_visuals()
	update_alert()

/datum/status_effect/buff/lux_fatigue/proc/update_visuals()
	owner.remove_filter(LUX_FILTER)

	if(stacks >= overcharge_threshold)
		owner.add_filter(LUX_FILTER, 2, list(
			"type" = "outline",
			"color" = overcharge_colour,
			"alpha" = 200,
			"size" = 2
		))
		if(!is_overcharged)
			enter_overcharge()
	else if(stacks >= 4)
		owner.add_filter(LUX_FILTER, 2, list(
			"type" = "outline",
			"color" = glow_colour,
			"alpha" = 120,
			"size" = 1
		))
		if(is_overcharged)
			exit_overcharge()
	else
		if(is_overcharged)
			exit_overcharge()

/datum/status_effect/buff/lux_fatigue/proc/update_alert()
	if(linked_alert)
		linked_alert.name = "Lux Fatigue ([stacks]/[max_stacks])"

/datum/status_effect/buff/lux_fatigue/tick()
	if(stacks > 0 && world.time - last_gain_time >= LUX_DECAY_DELAY)
		if(world.time - last_decay_time >= LUX_DECAY_INTERVAL)
			last_decay_time = world.time
			stacks = max(stacks - 1, 0)
			owner.balloon_alert(owner, "F: [stacks]/[max_stacks]")
			update_visuals()
			update_alert()

	if(stacks >= overcharge_threshold)
		owner.apply_damage(damage_per_tick, BRUTE, BODY_ZONE_CHEST)
		owner.emote(pick("twitch", "strain"), forced = TRUE)

/datum/status_effect/buff/lux_fatigue/proc/enter_overcharge()
	is_overcharged = TRUE
	to_chat(owner, span_boldwarning("My bones creak, my skin singes, the pain! I need to STOP! NOW!"))

/datum/status_effect/buff/lux_fatigue/proc/exit_overcharge()
	is_overcharged = FALSE

/datum/status_effect/buff/lux_fatigue/proc/trigger_explosion()
	to_chat(owner, span_boldwarning("My LUX and BODY cannot ENDURE this HEAT!!"))
	owner.emote("agony")
	explosion(owner, 3, 0, 3, 0, FALSE, FALSE, 3)
	// Full reset
	stacks = 0
	update_visuals()
	update_alert()

/proc/get_lux_fatigue(mob/living/target)
	if(!istype(target))
		return 0
	var/datum/status_effect/buff/lux_fatigue/F = target.has_status_effect(/datum/status_effect/buff/lux_fatigue)
	if(!F)
		return 0
	return F.stacks

#undef LUX_FILTER
#undef LUX_DECAY_DELAY
#undef LUX_DECAY_INTERVAL

/datum/action/cooldown/spell/fire_blast/immolator
	name = "Pyre Blast"
	desc = "Unleash a volatile blast of Lux-fire. Scales with your fatigue, risking loss of control at high levels."
	button_icon_state = "fire_blast"
	cooldown_time = 10 SECONDS
	var/max_bonus_damage = 20
	var/max_bonus_range = 3
	var/max_bonus_width = 2

/datum/action/cooldown/spell/fire_blast/immolator/cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/datum/status_effect/buff/lux_fatigue/F = H.has_status_effect(/datum/status_effect/buff/lux_fatigue)
	var/fatigue = F ? F.stacks : 0

	var/original_cd = cooldown_time
	cooldown_time = max(3 SECONDS, original_cd - (fatigue * 1 SECONDS))

	. = ..()

	cooldown_time = original_cd

	var/bonus_damage = min(fatigue * 2, max_bonus_damage)
	var/bonus_range = min(round(fatigue / 3), max_bonus_range)
	var/bonus_width = (fatigue >= 6) ? min(1 + round((fatigue - 6) / 2), max_bonus_width) : 0

	var/final_damage = blast_damage + bonus_damage
	var/final_range = line_length + bonus_range

	var/list/directions = list()

	if(fatigue >= 8)
		directions = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	else
		var/turf/start = get_turf(H)
		var/turf/target_turf = get_turf(cast_on)
		var/dir = get_dir(start, target_turf)
		if(!dir)
			dir = H.dir
		directions = list(dir)

	for(var/d in directions)
		src.cast_line(H, d, final_range, final_damage, bonus_width, fatigue)

	if(fatigue >= 5)
		if(H.patron?.type == /datum/patron/old_god)
			H.apply_damage(10 + fatigue, BURN, BODY_ZONE_CHEST)
			to_chat(H, span_warning("The Lux turns against me!"))

	return TRUE

/datum/action/cooldown/spell/fire_blast/immolator/proc/cast_line(mob/living/carbon/human/H, dir, range, damage, width, fatigue)
	var/turf/start = get_turf(H)
	var/list/line_turfs = list()

	var/turf/current = start
	for(var/i in 1 to range)
		current = get_step(current, dir)
		if(!current || current.density)
			break
		line_turfs += current

	if(!length(line_turfs))
		return

	playsound(start, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, TRUE, 4)

	var/list/already_hit = list()
	var/blocked = FALSE

	for(var/turf/T in line_turfs)
		if(blocked)
			break

		var/list/affected = list(T)

		if(width > 0)
			var/turf/L = T
			var/turf/R = T
			for(var/i in 1 to width)
				L = get_step(L, turn(dir, 90))
				R = get_step(R, turn(dir, -90))
				if(L) affected += L
				if(R) affected += R

		for(var/turf/AT in affected)
			new /obj/effect/temp_visual/fire(AT)
			new /obj/effect/hotspot(AT, null, null, hotspot_life)

			for(var/mob/living/victim in AT)
				if(victim == H || (victim in already_hit))
					continue

				if(H.patron?.type == /datum/patron/old_god)
					if(fatigue < 5 && victim.patron?.type == /datum/patron/old_god)
						continue

				if(victim.anti_magic_check())
					continue

				if(spell_guard_check(victim, FALSE, H))
					blocked = TRUE
					continue

				var/damage_dealt = arcyne_strike(H, victim, null, damage, BODY_ZONE_CHEST, \
					BCLASS_BURN, spell_name = "Pyre Blast", \
					allow_shield_check = TRUE, damage_type = BURN, \
					skip_animation = TRUE)

				if(!damage_dealt)
					blocked = TRUE
					continue

				victim.adjust_fire_stacks(fire_stacks_applied)
				victim.ignite_mob()

				new /obj/effect/temp_visual/spell_impact(get_turf(victim), spell_color, spell_impact_intensity)

				already_hit += victim

				var/push_dir = get_dir(H, victim)
				if(!push_dir)
					push_dir = dir

				var/push_dist_scaled = push_dist + round(fatigue / 3)
				victim.safe_throw_at(get_ranged_target_turf(victim, push_dir, push_dist_scaled), push_dist_scaled, 2, H, force = MOVE_FORCE_STRONG)

/datum/action/cooldown/spell/fire_curtain/immolator
	name = "Immolate"
	desc = "Conjure a volatile Lux curtain that scales with fatigue."
	button_icon_state = "fire_curtain"
	cooldown_time = 25 SECONDS

	var/base_width = 2
	var/base_depth = 2
	var/max_bonus_size = 3

/datum/action/cooldown/spell/fire_curtain/immolator/cast(atom/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/datum/status_effect/buff/lux_fatigue/F = H.has_status_effect(/datum/status_effect/buff/lux_fatigue)
	var/fatigue = F ? F.stacks : 0

	var/original_cd = cooldown_time
	cooldown_time = max(5 SECONDS, original_cd - (fatigue * 1 SECONDS))

	. = ..()

	cooldown_time = original_cd

	var/size_bonus = min(round(fatigue / 2), max_bonus_size)

	curtain_width = base_width + size_bonus
	curtain_depth = base_depth + round(size_bonus / 2)

	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	var/list/affected_turfs = get_curtain_turfs(center, H.dir)

	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/trap_wall/fire(T)

	H.visible_message(span_danger("[H] conjures a wall of Lux-fire!"))
	playsound(get_turf(H), 'sound/magic/charging_fire.ogg', 60, TRUE)

	addtimer(CALLBACK(src, PROC_REF(spawn_curtain_immolator), affected_turfs, fatigue), telegraph_time)
	return TRUE

/datum/action/cooldown/spell/fire_curtain/immolator/proc/spawn_curtain_immolator(list/turfs, fatigue)
	if(QDELETED(src) || QDELETED(owner))
		return

	var/mob/living/carbon/human/H = owner

	for(var/turf/T in turfs)
		new /obj/effect/temp_visual/fire(T)

		for(var/mob/living/victim in T)
			if(victim == H)
				continue

			if(H.patron?.type == /datum/patron/old_god)
				if(fatigue < 5 && victim.patron?.type == /datum/patron/old_god)
					continue

			victim.adjust_fire_stacks(1)
			victim.ignite_mob()

		new /obj/effect/hotspot(T, null, null, hotspot_life)

	playsound(turfs[1], pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 120, TRUE, 6)

