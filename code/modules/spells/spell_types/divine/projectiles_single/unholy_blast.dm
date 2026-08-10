/datum/action/cooldown/spell/projectile/unholy_blast
	background_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon = 'icons/mob/actions/genericmiracles.dmi'
	button_icon_state = "ublast"
	name = "Profane Blast"
	desc = "Release a blast of sheer divine energy at your enemies. Deals more damage to conformists, undead, and simple-minded creatures. Every so often, the blast may call down a devastating smite upon its victim, leaving them vulnerable.<br><br>Toggle firing mode (Shift+G): Focus or Arc."
	fluff_desc = "Among the first miracles bestowed upon the faithful is the ability to channel their patron's essence into a focused blast of divine power. Though simple in execution, it is a versatile expression of a deity's will, carrying forth a fragment of the patron's nature and allegiances."
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW
	projectile_type = /obj/projectile/energy/unholyblast
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_DEVOTION
	primary_resource_cost = 25
	invocation_type = INVOCATION_SHOUT
	charge_required = TRUE
	charge_time = CHARGETIME_MINOR
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_swingdelay_type = SWINGDELAY_PENALTY
	charge_sound = 'sound/magic/chargingold.ogg'

	cooldown_time = 10 SECONDS
	associated_skill = /datum/skill/magic/holy
	spell_impact_intensity = SPELL_IMPACT_LOW
	spell_requirements = SPELL_REQUIRES_HUMAN
	var/next_bonus_time = 0
	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Focus", "tag" = "FOCUS", "proj" = /obj/projectile/energy/unholyblast, "invocation" = "Larkas Strahl!"),
		list("name" = "Arc", "tag" = "ARC", "proj" = /obj/projectile/energy/unholyblast/arc, "invocation" = "Larkas Strahl!"),
	)

/obj/projectile/energy/unholyblast
	name = "divine blast"
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = LIGHT_COLOR_WHITE
	damage = 32
	max_range = MAGE_LONG_PROJ_RANGE
	damage_type = BURN
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	speed = 0.3
	flag = "fire"
	light_outer_range = 4
	color = "#ff0000"

/obj/projectile/energy/unholyblast/arc
	name = "arced divine blast"
	damage = 22
	arcshot = TRUE

/obj/projectile/energy/unholyblast/on_hit(target, blocked = FALSE)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check() || HAS_TRAIT(M, TRAIT_SILVER_BLESSED))
			visible_message(span_warning("[src] dissipates harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(M))
			var/mob/living/L = M
			if(out_of_effective_range())
				qdel(src)
				return
			if(blocked < 100)
				if(HAS_TRAIT(L, TRAIT_SILVER_WEAK) && !L.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
					L.visible_message("<font color='white'>Divine power staggers [L]!</font>")
					L.Immobilize(1 SECONDS)
					L.Slowdown(2 SECONDS)
					L.apply_status_effect(/datum/status_effect/debuff/clickcd, 2 SECONDS)
				apply_divine_damage(L)
				var/datum/action/cooldown/spell/projectile/unholy_blast/S = source_spell
				if(S && S.can_apply_god_bonus())
					apply_god_bonus(L)
					S.consume_god_bonus()
	qdel(src)

/datum/action/cooldown/spell/projectile/unholy_blast/proc/can_apply_god_bonus()
	return world.time >= next_bonus_time

/datum/action/cooldown/spell/projectile/unholy_blast/proc/consume_god_bonus()
	var/unreliable = rand(25,45)
	next_bonus_time = world.time + unreliable SECONDS

/obj/projectile/energy/unholyblast/proc/apply_divine_damage(mob/living/L)
	var/damage_to_do = damage
	if((L.patron?.type in ALL_DIVINE_PATRONS) || (L.patron?.type in OLD_GOD_PATRON) || (L.mob_biotypes & MOB_UNDEAD))
		damage_to_do += 30
	if(HAS_TRAIT(L, TRAIT_SILVER_WEAK))
		damage_to_do += 15
	if(!L.mind)
		damage_to_do += 60
	var/mob/living/carbon/human/caster = firer
	if(L.guard_deflect_spell("Divine Blast", TRUE, caster))
		return
	if(istype(caster) && ishuman(L))
		arcyne_strike(caster, L, null, damage_to_do, def_zone, BCLASS_BURN, PEN_MEDIUM, spell_name = "Divine Blast", damage_type = BURN, npc_simple_damage_mult = 1, skip_animation = TRUE)
	else
		L.apply_damage(damage_to_do, BURN)
	L.adjust_fire_stacks(1, /datum/status_effect/fire_handler/fire_stacks/divine) // at this point its mostly for vfx lmao
	L.ignite_mob()
	if(!L.mind && !L.stat) // execute dying NPCs with this, might help doing annoying blockades on a time limit D:
		apply_god_bonus(L)
		L.gib()

/obj/projectile/energy/unholyblast/proc/apply_god_bonus(mob/living/L) // mostly to skip on all these meaningless scans for now, since we going with an universal smite now instead of snowflake effects for each god
	L.visible_message("<font color='#a50000'>--Divine Smite!!</font>")
	var/fire_stacks = 5 // jakk here, stack amt
	var/CC_timer = 4 // jokk here, this is in seconds
	if(!L.mind) // godless scuuummmm
		fire_stacks = 10
		CC_timer = 8
		L.emote("superagony")
	var/turf/target_turf = get_turf(L)
	new /obj/effect/temp_visual/thunderstrike_actual(target_turf)
	playsound(target_turf, 'sound/magic/lightning.ogg', 80)
	L.adjust_fire_stacks(fire_stacks, /datum/status_effect/fire_handler/fire_stacks/divine)
	L.ignite_mob()
	L.apply_status_effect(/datum/status_effect/debuff/exposed, CC_timer SECONDS)
	L.apply_status_effect(/datum/status_effect/debuff/clickcd, CC_timer SECONDS)
	L.Slowdown(CC_timer)

/datum/action/cooldown/spell/projectile/unholy_blast/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/unholy_blast/proc/apply_mode(index)
	var/list/mode = modes[index]
	projectile_type = mode["proj"]
	invocations = list(mode["invocation"])
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/unholy_blast/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] mode."))

/datum/action/cooldown/spell/projectile/unholy_blast/proc/update_mode_maptext(tag)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(tag)
		holder.color = "#00ccff"

/datum/action/cooldown/spell/projectile/unholy_blast/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Firing mode (Shift+G): Focus (standard blast) / Arc (lobs over obstacles with reduced damage).")
	return stats
