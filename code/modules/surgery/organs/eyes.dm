/obj/item/organ/eyes
	name = "eyes"
	icon_state = "eyeball"
	desc = "Ocular globes of flesh and humors. Their future was looking bleak, but they never saw this coming."
	zone = BODY_ZONE_PRECISE_R_EYE
	slot = ORGAN_SLOT_EYES
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	maxHealth = 0.5 * STANDARD_ORGAN_THRESHOLD		//half the normal health max since we go blind at 30, a permanent blindness at 50 therefore makes sense unless medicine is administered
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD	//threshold at 30
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD	//threshold at 20

	low_threshold_passed = span_info("Distant objects become somewhat less tangible.")
	high_threshold_passed = span_info("Everything starts to look a lot less clear.")
	now_failing = span_warning("Darkness envelopes you, as my eyes go blind!")
	now_fixed = span_info("Color and shapes are once again perceivable.")
	high_threshold_cleared = span_info("My vision functions passably once more.")
	low_threshold_cleared = span_info("My vision is cleared of any ailment.")

	organ_dna_type = /datum/organ_dna/eyes
	accessory_type = /datum/sprite_accessory/eyes/humanoid
	accessory_colors = "#FFFFFF#FFFFFF"
	visible_organ = TRUE

	var/sight_flags = 0
	var/see_in_dark = 8
	var/tint = 0
	var/eye_icon_state = "eyes"
	var/flash_protect = FLASH_PROTECTION_NONE
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/no_glasses
	var/damaged	= FALSE	//damaged indicates that our eyes are undergoing some level of negative effect

	var/eye_color = "#FFFFFF"
	var/heterochromia = FALSE
	var/second_color = "#FFFFFF"


/obj/item/organ/eyes/update_overlays()
	. = ..()
	if(eye_color && (icon_state == "eyeball"))
		var/mutable_appearance/iris_overlay = mutable_appearance(src.icon, "eyeball-iris")
		iris_overlay.color = "#" + eye_color
		. += iris_overlay

/obj/item/organ/eyes/update_accessory_colors()
	var/list/colors_list = list()
	colors_list += eye_color
	if(heterochromia)
		colors_list += second_color
	else
		colors_list += eye_color
	accessory_colors = color_list_to_string(colors_list)

/obj/item/organ/eyes/imprint_organ_dna(datum/organ_dna/organ_dna)
	. = ..()
	var/datum/organ_dna/eyes/eyes_dna = organ_dna
	eyes_dna.eye_color = eye_color
	eyes_dna.heterochromia = heterochromia
	eyes_dna.second_color = second_color

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/HMN = owner
		if(eye_color)
			HMN.eye_color = eye_color
			HMN.regenerate_icons()
		else
			eye_color = HMN.eye_color
		if(HAS_TRAIT(HMN, TRAIT_NIGHT_VISION) && !lighting_alpha)
			lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	for(var/datum/wound/facial/eyes/eye_wound as anything in M.get_wounds())
		qdel(eye_wound)
	M.update_tint()
	owner.update_sight()
	if(M.has_dna() && ishuman(M))
		M.dna.species.handle_body(M) //updates eye icon

/obj/item/organ/eyes/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(ishuman(M) && eye_color)
		var/mob/living/carbon/human/HMN = M
		HMN.regenerate_icons()
	M.cure_blind(EYE_DAMAGE)
	M.cure_nearsighted(EYE_DAMAGE)
	M.set_blindness(0)
	M.set_blurriness(0)
	M.update_sight()

/obj/item/organ/eyes/on_life()
	..()
	var/mob/living/carbon/C = owner
	//since we can repair fully damaged eyes, check if healing has occurred
	if((organ_flags & ORGAN_FAILING) && (damage < maxHealth))
		organ_flags &= ~ORGAN_FAILING
		C.cure_blind(EYE_DAMAGE)
	//various degrees of "oh fuck my eyes", from "point a laser at my eye" to "staring at the Sun" intensities
	if(damage > 20)
		damaged = TRUE
		if((organ_flags & ORGAN_FAILING))
			C.become_blind(EYE_DAMAGE)
		else if(damage > 30)
			C.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 2)
		else
			C.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 1)
	//called once since we don't want to keep clearing the screen of eye damage for people who are below 20 damage
	else if(damaged)
		damaged = FALSE
		C.clear_fullscreen("eye_damage")
	return

/obj/item/organ/eyes/construct
	name = "construct eyes"
	desc = "Some beast's eyes, preserved through artifice and with magical rock embedded in their back. Seems to fit a construct's head."
	icon_state = "eyeball-con"

/obj/item/organ/eyes/construct/on_life()
	. = ..()
	if(!istype(owner?.dna?.species, /datum/species/construct/metal))
		spawn(100)
			owner.emote("superagony")
			owner.visible_message(span_artery("[owner]'s creature eyes are violently rejected from their sockets, tearing free with a wet, bloody pop and falling into a sickly red goop!"))
			owner.reagents.add_reagent(/datum/reagent/infection/major, 25)
			qdel(src)

/obj/item/organ/eyes/elf
	name = "elf eyes"
	desc = "Keen, elegant eyes with an almost unnatural clarity, seeming to catch every detail that passes before them."

/obj/item/organ/eyes/halfelf
	name = "half-elf eyes"
	desc = "Graceful eyes carrying a faint trace of elven refinement, though still unmistakably grounded in mortal flesh."

/obj/item/organ/eyes/goblin
	name = "goblin eyes"
	desc = "Small, sharp eyes with an unsettlingly alert gaze. Built for dim burrows, cramped tunnels, and spotting trouble before it spots you."

/obj/item/organ/eyes/moth
	name = "fluvian eyes"
	desc = "Large, sensitive eyes adapted to the dark. Their strange construction gives them an almost glassy, otherworldly appearance."
	flash_protect = FLASH_PROTECTION_SENSITIVE
	accessory_type = /datum/sprite_accessory/eyes/moth
	eye_color = "000000"
	second_color = "000000"

/obj/item/organ/eyes/snail
	name = "snail eyes"
	desc = "Small, delicate eyes perched on flexible stalks. Somehow, they remain perfectly functional despite looking like they should snap off at the slightest touch."
	eye_icon_state = "snail_eyes"
	icon_state = "snail_eyeballs"

/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "Eyes that are made to see in perfect darkness, their pupils adjust nicely to the amount of vision you wish to peruse."
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/eyes/night_vision/argonian
	name = "zardman eyes"
	desc = "Luscious and fervent, with that unmistakable zardman intensity. Why are you staring at a zard's eyes like that, weirdo?"

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "Eyes that seem to belong to something far beyond this realm. Staring into them makes you wonder if humanity might one day reach Nocmos, or if it should."
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/zombie
	name = "deadite eyes"
	desc = "Rotted to the core with a pungent stench, you'd wonder how Deadites are even capable of seeing through those lenses, and quickly deduct... Yeah, foul magicks."

/obj/item/organ/eyes/night_vision/zombie/on_life()
	. = ..()
	if(!(owner.mob_biotypes & MOB_UNDEAD))
		if(prob(10))
			owner.emote("pain")
			to_chat(owner, span_danger(pick("MY EYES HURT! GET THEM OUT OF ME!", "MY EYES! SOMETHING IS CRAWLING BEHIND THEM! TAKE THEM OUT!", "I CAN FEEL SOMETHING WRIGGLING INSIDE MY SKULL! RIP THEM OUT!", "GET THESE THINGS OUT OF MY SOCKETS! I DON'T WANT THEM!", "MY EYES ARE MOVING ON THEIR OWN! TEAR THEM OUT!")))
			owner.reagents.add_reagent(/datum/reagent/infection/major, 5)

/obj/item/organ/eyes/night_vision/monster
	name = "creature eyes"
	desc = "Eyes that should likely not be inside a non-monster's eye sockets. But what is really stopping you?"
	icon_state = "burning_eyes"

/obj/item/organ/eyes/night_vision/monster/on_life()
	. = ..()
	if(owner?.mind)
		spawn(100)
			owner.emote("superagony")
			owner.visible_message(span_artery("[owner]'s creature eyes are violently rejected from their sockets, tearing free with a wet, bloody pop and falling into a sickly red goop!"))
			owner.reagents.add_reagent(/datum/reagent/infection/major, 25)
			qdel(src)

/obj/item/organ/eyes/night_vision/nightmare
	name = "unnatural eyes"
	desc = "Eyes that should never have been possible. Heresy to most, opportunity to those willing to look past the blasphemy."
	icon_state = "burning_eyes"
	color = "#006eff"

/obj/item/organ/eyes/night_vision/wild_goblin
	name = "wild goblin eyes"
	desc = "Eyes that have been thoroughly corrupted by the madness within those War Rifts of Sinistar. Neither darkness nor nite has purchase into them."
	icon_state = "burning_eyes"

/obj/item/organ/eyes/night_vision/wild_goblin/on_life()
	. = ..()
	if(!istype(owner, /mob/living/carbon/human/species/goblin) && !istype(owner?.dna?.species, /datum/species/goblin))
		if(prob(10))
			owner.emote("pain")
			to_chat(owner, span_danger(pick("MY EYES HURT! GET THEM OUT OF ME!", "MY EYES! SOMETHING IS CRAWLING BEHIND THEM! TAKE THEM OUT!", "I CAN FEEL SOMETHING WRIGGLING INSIDE MY SKULL! RIP THEM OUT!", "GET THESE THINGS OUT OF MY SOCKETS! I DON'T WANT THEM!", "MY EYES ARE MOVING ON THEIR OWN! TEAR THEM OUT!")))
			owner.reagents.add_reagent(/datum/reagent/infection/major, 5)

/obj/item/organ/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "They still say he is a fun-guy to this very day!"

/obj/item/organ/eyes/night_vision/nitecreacher
	name = "nitecreacher eyes"
	desc = "Eyes that should likely not be inside a non-werevolf's eye sockets. But what is really stopping you?"

/obj/item/organ/eyes/night_vision/nitecreacher/on_life()
	. = ..()
	if(!istype(owner?.mind?.special_role, /datum/antagonist/vampire) && !istype(owner?.mind?.special_role, /datum/antagonist/werewolf) && !istype(owner?.mind?.special_role, /datum/antagonist/gnoll))
		spawn(100)
			owner.emote("superagony")
			owner.visible_message(span_artery("[owner]'s creature eyes are violently rejected from their sockets, tearing free with a wet, bloody pop and falling into a sickly red goop!"))
			owner.reagents.add_reagent(/datum/reagent/infection/major, 25)
			qdel(src)

/obj/item/organ/eyes/night_vision/nitecreacher/ui_action_click()
	sight_flags = initial(sight_flags)
	var/atom/movable/screen/plane_master/weather_plane = usr.hud_used?.plane_masters?["[WEATHER_EFFECT_PLANE]"]
	switch(lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			weather_plane?.alpha = 225
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			weather_plane?.alpha = 200
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			weather_plane?.alpha = 170
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			weather_plane?.alpha = 255
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Artificial eyes of polished metal and glass, built to replace the fragile organs of flesh with something a little more reliable."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(10 * severity))
		return
	to_chat(owner, span_warning("Static obfuscates my vision!"))
	owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "Artificial eyes that peer beyond ordinary sight, revealing the world through walls and solid matter as though they were barely there."
	eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "Artificial eyes that perceive heat instead of light, allowing warm bodies to stand out clearly even through darkness."
	eye_color = "FC0"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	see_in_dark = 8

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "Artificial eyes fitted with compact lamps, letting their owner illuminate the darkness simply by looking through it."
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "Artificial eyes fitted with protective shielding, built to keep hostile electromagnetic interference from scrambling their vision."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext(definitionvar,2,3)][copytext(definitionvar,4,5)][copytext(definitionvar,6,7)]")

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Artificial eyes built to channel light into a focused beam. Their inner workings hum with enough energy to make staring into them a poor idea."
	eye_color = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/current_color_string = "#ffffff"
	var/active = FALSE
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 1
	var/light_object_power = 2
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/obj/effect/abstract/eye_lighting/on_mob
	var/image/mob_overlay
	var/datum/component/mobhook

/obj/item/organ/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	mob_overlay = image('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/eyes/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/Remove(mob/living/carbon/M, special = FALSE)
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate()
	active = FALSE
	clear_visuals(TRUE)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/organ/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/organ/eyes/robotic/glow/proc/prompt_for_controls(mob/user)
	var/C = input(owner, "Select Color", "Select color", "#ffffff") as color|null
	if(!C || QDELETED(src) || QDELETED(user) || QDELETED(owner) || owner != user)
		return
	var/range = input(user, "Enter range (0 - [max_light_beam_distance])", "Range Select", 0) as null|num

	set_distance(CLAMP(range, 0, max_light_beam_distance))
	assume_rgb(C)

/obj/item/organ/eyes/robotic/glow/proc/assume_rgb(newcolor)
	current_color_string = newcolor
	eye_color = RGB2EYECOLORSTRING(current_color_string)
	sync_light_effects()
	cycle_mob_overlay()
	if(!QDELETED(owner) && ishuman(owner))		//Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

/obj/item/organ/eyes/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/organ/eyes/robotic/glow/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	RegisterSignal(M, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_visuals))

/obj/item/organ/eyes/robotic/glow/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	UnregisterSignal(M, COMSIG_ATOM_DIR_CHANGE)

/obj/item/organ/eyes/robotic/glow/Destroy()
	QDEL_NULL(mobhook) // mobhook is not our component
	return ..()

/obj/item/organ/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, span_warning("My [src] clicks and makes a whining noise, before shooting out a beam of light!"))
	active = TRUE
	cycle_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, span_warning("My [src] shuts off!"))
	active = FALSE
	remove_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if (newdir && scandir != newdir) // COMSIG_ATOM_DIR_CHANGE happens before the dir change, but with a reference to the new direction.
		scandir = newdir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	on_mob.forceMove(scanning)
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(scanning.opacity || (scanning.opaque_atom_count > 0))
			stop = TRUE
		var/obj/effect/abstract/eye_lighting/L = LAZYACCESS(eye_lighting, i)
		if(stop)
			L.forceMove(src)
		else
			L.forceMove(scanning)

/obj/item/organ/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
		QDEL_NULL(on_mob)
	else
		for(var/i in eye_lighting)
			var/obj/effect/abstract/eye_lighting/L = i
			L.forceMove(src)
		if(!QDELETED(on_mob))
			on_mob.forceMove(src)

/obj/item/organ/eyes/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		regenerate_light_effects()
	if((eye_lighting.len < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	update_visuals()

/obj/item/organ/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new (src, light_object_range, light_object_power, current_color_string, LIGHT_ATTACHED)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting, new /obj/effect/abstract/eye_lighting(src, light_object_range, light_object_power, current_color_string))
	sync_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/sync_light_effects()
	for(var/I in eye_lighting)
		var/obj/effect/abstract/eye_lighting/L = I
		L.set_light(light_object_range, light_inner_range, light_object_power, l_color =	current_color_string)
	if(on_mob)
		on_mob.set_light(1, 1, 1, l_color = current_color_string)

/obj/effect/abstract/eye_lighting
	var/obj/item/organ/eyes/robotic/glow/parent

/obj/effect/abstract/eye_lighting/Initialize(mapload)
	. = ..()
	parent = loc
	if(!istype(parent))
		return INITIALIZE_HINT_QDEL

/proc/set_eye_color(mob/living/carbon/mob, color_one, color_two)
	var/obj/item/organ/eyes/eyes = mob.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	if(color_one)
		eyes.eye_color = color_one
	if(color_two)
		eyes.second_color = color_two
	eyes.update_accessory_colors()
	if(eyes.owner)
		eyes.owner.update_body_parts(TRUE)

#undef RGB2EYECOLORSTRING

