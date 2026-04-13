/obj/item/rogueweapon/mace/parasol
	force = 15
	name = "paper parasol"
	desc = "A handy instrument intended to shield one's delicate head from the rain and sun."
	icon = 'icons/roguetown/items/parasols32.dmi'
	icon_state = "parasol1"
	wbalance = WBALANCE_SWIFT
	wdefense = 1
	possible_item_intents = list(/datum/intent/parasol/point, /datum/intent/mace/strike/wood)
	smeltresult = /obj/item/ash
	anvilrepair = /datum/skill/craft/sewing
	max_integrity = 150
	minstr = 1
	resistance_flags = FLAMMABLE
	slot_flags = null
	wlength = WLENGTH_NORMAL
	w_class = WEIGHT_CLASS_BULKY
	grid_width = 32
	grid_height = 64

	var/is_open = TRUE
	var/variant = 1
	var/active_item = FALSE

/obj/item/rogueweapon/mace/parasol/examine(mob/user)
	. = ..()
	if(is_open)
		. += span_warning("It is open, offering protection from rain and weather.")
	else
		. += span_warning("It is closed, might be a decent whacking stick.")

/obj/item/rogueweapon/mace/parasol/Initialize()
	. = ..()
	variant = rand(1,6)
	update_parasol()

/obj/item/rogueweapon/mace/parasol/proc/update_parasol()
	if(is_open)
		icon_state = "parasol[variant]"
		force = 0

		slot_flags = null

	else
		icon_state = "parasolC[variant]"
		force = 15

		slot_flags = SLOT_BACK | SLOT_BELT

	update_force_dynamic()


/obj/item/rogueweapon/mace/parasol/attack_self(mob/living/user)
	. = ..()

	is_open = !is_open

	if(is_open)
		playsound(src, 'sound/items/scroll_open.ogg', 100, FALSE)
		if(active_item)
			ADD_TRAIT(user, TRAIT_WEATHER_PROTECTED, "[type]")
	else
		playsound(src, 'sound/items/scroll_close.ogg', 100, FALSE)
		REMOVE_TRAIT(user, TRAIT_WEATHER_PROTECTED, "[type]")

	update_parasol()
	user.update_inv_hands()


/obj/item/rogueweapon/mace/parasol/pickup(mob/living/user, slot)
	. = ..()
	active_item = TRUE

	if(is_open)
		ADD_TRAIT(user, TRAIT_WEATHER_PROTECTED, "[type]")


/obj/item/rogueweapon/mace/parasol/dropped(mob/living/user)
	. = ..()

	if(!active_item)
		return

	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_WEATHER_PROTECTED, "[type]")

/obj/item/rogueweapon/mace/parasol/noble/Initialize()
	. = ..()
	variant = rand(1,4)
	update_parasol()

/obj/item/rogueweapon/mace/parasol/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.8,"sx" = -6,"sy" = 8,"nx" = 6,"ny" = 9,"wx" = 0,"wy" = 7,"ex" = -1,"ey" = 9,"northabove" = 1,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -50,"sturn" = 40,"wturn" = 50,"eturn" = -50,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)


/obj/item/rogueweapon/mace/parasol/rose
	name = "rose parasol"
	desc = "A fine instrument intended to shield one's delicate head from the rain and sun. This one is a beautiful luxurious black and red, with fringes."
	icon = 'icons/roguetown/items/parasols64.dmi'
	icon_state = "parasolC5"
	max_integrity = 75
	sellprice = 45
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/rogueweapon/mace/parasol/noble
	name = "fine parasol"
	desc = "A delicate instrument intended to shield one's delicate head from the rain and sun. This one is a beautiful luxurious white and gold, with fringes."
	icon = 'icons/roguetown/items/parasols64.dmi'
	icon_state = "parasol1"
	max_integrity = 75
	sellprice = 45
	inhand_x_dimension = 64
	inhand_y_dimension = 64


/obj/item/rogueweapon/mace/parasol/noble/Initialize()
	. = ..()
	variant = rand(1,2)
	update_parasol()


/obj/item/rogueweapon/mace/parasol/noble/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -6,"sy" = 8,"nx" = 6,"ny" = 9,"wx" = 0,"wy" = 7,"ex" = -1,"ey" = 9,"northabove" = 1,"southabove" = 1,"eastabove" = 1,"westabove" = 1,"nturn" = -50,"sturn" = 40,"wturn" = 50,"eturn" = -50,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/datum/intent/parasol/point
	name = "point at"
	blade_class = BCLASS_EFFECT
	attack_verb = list("points")
	animname = "stab"
	icon_state = "instab"
	reach = 7
	clickcd = CLICK_CD_CHARGED
	recovery = 30
	warnie = "mobwarning"
	hitsound = list('sound/combat/riposte.ogg')
	penfactor = PEN_BSTEEL
	damfactor = 0
	item_d_type = "blunt"
	var/last_use = 0
	var/cooldown_time = 25 SECONDS

/datum/intent/parasol/point/spec_on_apply_effect(mob/living/H, mob/living/user, params)
	if(!H || !user)
		return

	if(world.time < last_use + cooldown_time)
		return

	var/turf/start_turf = get_turf(H)

	user.visible_message(
		span_warning("[user] points their parasol at [H]!"),
		span_notice("I point my parasol at [H]...")
	)

	if(!do_after(user, 1.5 SECONDS, target = H))
		return

	if(get_turf(H) != start_turf)
		return

	last_use = world.time

	if(HAS_TRAIT(user, TRAIT_NOBLE))

		if(HAS_TRAIT(H, TRAIT_CLERGY))
			H.visible_message(
				span_danger("[H]'s authority is openly challenged by [user]!"),
				span_userdanger("How-- How sinful! To do such a thing to the clergy!!")
			)
			return

		if((HAS_TRAIT(H, TRAIT_HORDE)||HAS_TRAIT(H, TRAIT_DEPRAVED)||HAS_TRAIT(H, TRAIT_CABAL)||HAS_TRAIT(H, TRAIT_FREEMAN)))
			H.apply_status_effect(/datum/status_effect/debuff/vulnerable)

			H.visible_message(
				span_danger("[H] is marked by [user]'s noble authority!"),
				span_userdanger("BY THE FOUR, I WILL HAVE THE GROUND RED IN YOUR PUTRID BLOOD!")
			)
			return

		if(!HAS_TRAIT(H, TRAIT_NOBLE))
			H.apply_status_effect(/datum/status_effect/debuff/vulnerable)

			H.visible_message(
				span_danger("[H] is marked by [user]'s noble authority!"),
				span_userdanger("I feel exposed. Damnable noble!")
			)
			return
		else
			H.visible_message(
				span_danger("[H]'s authority is openly challenged by [user]!"),
				span_userdanger("They DARE do this at me? At ME? <i>ME??</i>")
			)
			return
