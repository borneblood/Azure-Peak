/obj/effect/proc_holder/spell/invoked/vigorousexchange
	name = "Vigorous Exchange"
	desc = "Restores the target's Energy, twice as effective on someone else."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "vigorousexchange"
	releasedrain = 0
	chargedrain = 0
	chargetime = 0
	warnie = "sydwarning"
	movement_interrupt = FALSE
	no_early_release = TRUE
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list("Through flame and ash, let vigor rise, by Malum’s hand, let strength reprise!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 3 MINUTES
	chargetime = 2 SECONDS
	miracle = TRUE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	devotion_cost = 30

/obj/effect/proc_holder/spell/invoked/heatmetal
	name = "Heat Metal"
	desc= "Damages Armor, forces target to drop a metallic weapon, heats up an ingot in tongs or smelts a single item."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "heatmetal"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	no_early_release = TRUE
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list("With heat I wield, with flame I claim, Let metal serve in Malum's name!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 2 MINUTES
	chargetime = 2 SECONDS
	miracle = TRUE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	devotion_cost = 40

/obj/effect/proc_holder/spell/invoked/hammerfall
	name = "Hammerfall"
	desc = "Damages structures in an area while possibly knocking down mobs in the area."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "hammerfall"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	no_early_release = TRUE
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list("By molten might and hammer's weight, in Malum’s flame, the earth shall quake!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 MINUTES
	chargetime = 3 SECONDS // Used to be 2 seconds but we don't want a race condition and chain casting
	miracle = TRUE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	devotion_cost = 80

/obj/effect/proc_holder/spell/invoked/hammerfall/cast(list/targets, mob/user = usr)
	var/turf/fallzone = null
	var/skill = user.get_skill_level(/datum/skill/magic/holy)
	var/damage = 150 + (skill * 100) //So weak damage for this cooldown. Upped
	var/const/radius = 1 //Radius of the spell
	var/const/shakeradius = 7 //Radius of the quake
	var/diceroll = 0
	var/const/dc = 42 //Code will roll 2d20 and add target's perception and Speed then compare to this to see if they fall down or not. 42 Means they need to roll 2x 20 with Speed and Perception at I
	var/const/delay = 2 SECONDS // Delay between the ground marking appearing and the effect playing.
	fallzone = get_turf(targets[1])
	if(!fallzone)
		return
	else
		show_visible_message(usr, "[usr] raises their arm, conjuring a hammer wreathed in molten fire. As they hurl it toward the ground, the earth trembles under its impact, shaking its very foundations!", "You raise your arm, conjuring a hammer wreathed in molten fire. As you hurl it toward the ground, the earth trembles under its impact, shaking its very foundations!")
	for (var/turf/open/visual in view(radius, fallzone))
		var/obj/effect/temp_visual/lavastaff/Lava = new /obj/effect/temp_visual/lavastaff(visual)
		animate(Lava, alpha = 255, time = 5)
	sleep(delay)
	for (var/mob/living/carbon/screenshaken in view(shakeradius, fallzone))
		shake_camera(screenshaken, 5, 5)
	for (var/mob/living/carbon/shaken in view(radius, fallzone))
		if(spell_guard_check(shaken, TRUE))
			shaken.visible_message(span_warning("[shaken] braces against the quake!"))
			continue
		diceroll = roll(2,20) + shaken.STAPER + shaken.STASPD
		if (diceroll > dc)
			shaken.apply_effect(1 SECONDS, EFFECT_IMMOBILIZE, 0)
			show_visible_message(shaken, null, "The ground quakes but I manage to keep my footing.")
		else
			shaken.apply_effect(1 SECONDS, EFFECT_KNOCKDOWN, 0)		
			show_visible_message(shaken, null, "The ground quakes, making me fall over.")
	for (var/obj/structure/damaged in view(radius, fallzone))
		if(!istype(damaged, /obj/structure/flora/newbranch))
			damaged.take_damage(damage,BRUTE,"blunt",1)
	for (var/turf/closed/wall/damagedwalls in view(radius, fallzone))
		damagedwalls.take_damage(damage,BRUTE,"blunt",1)
	for (var/turf/closed/mineral/aoemining in view(radius, fallzone))
		aoemining.lastminer = usr
		aoemining.take_damage(damage,BRUTE,"blunt",1)
	return TRUE

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

/obj/effect/proc_holder/spell/invoked/craftercovenant
	name = "The Crafter’s Covenant"
	desc = "Melt a pile of valuables and convert them into a single item. Sacrifice is accepted even if it's not valuable enough to make anything."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "craftercovenant"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 1
	warnie = "sydwarning"
	movement_interrupt = TRUE
	no_early_release = TRUE
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/items/bsmithfail.ogg'
	invocations = list("Coins to ash, flame to form, in Malum’s name, let creation be born!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 25 MINUTES
	chargetime = 10 SECONDS
	miracle = TRUE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	devotion_cost = 100

/obj/effect/proc_holder/spell/invoked/heatmetal/cast(list/targets, mob/user = usr)
	. = ..()
	var/list/nosmeltore = list(/obj/item/rogueore/coal)
	var/datum/effect_system/spark_spread/sparks = new()
	var/target
	for(var/i in targets)
		target = i
	if (!target)
		return
	if(target in nosmeltore)
		return
	if (istype(target, /obj/item))
		handle_item_smelting(target, user, sparks, nosmeltore)
	else if (iscarbon(target))
		if(spell_guard_check(target, TRUE))
			var/mob/living/carbon/C = target
			C.visible_message(span_warning("[target] resists the searing heat!"))
			return
		handle_living_entity(target, user, nosmeltore)

/proc/show_visible_message(mob/user, text, selftext)
	var/text_to_send = addtext("<font color='yellow'>", text, "</font>")
	var/selftext_to_send = addtext("<font color='yellow'>", selftext, "</font>")
	user.visible_message(text_to_send, selftext_to_send)

/proc/handle_item_smelting(obj/item/target, mob/user, datum/effect_system/spark_spread/sparks, list/nosmeltore)
	if (!target.smeltresult) return
	var/obj/item/itemtospawn = target.smeltresult
	show_visible_message(user, "After [user]'s incantation, [target] glows brightly and melts into an ingot.", null)
	new itemtospawn(target.loc)
	sparks.set_up(1, 1, target.loc)
	sparks.start()
	qdel(target)

/proc/handle_living_entity(mob/target, mob/user, list/nosmeltore)
	var/obj/item/targeteditem = get_targeted_item(user, target)
	if (!targeteditem || targeteditem.smeltresult == /obj/item/ash || target.anti_magic_check(TRUE,TRUE))
		show_visible_message(user, "After their incantation, [user] points at [target] but it seems to have no effect.", "After your incantation, you point at [target] but it seems to have no effect.")
		return
	if (istype(targeteditem, /obj/item/rogueweapon/tongs))
		handle_tongs(targeteditem, user)
	else if (should_heat_in_hand(user, target, targeteditem, nosmeltore))
		handle_heating_in_hand(target, targeteditem, user)
	else
		handle_heating_equipped(target, targeteditem, user)

/proc/get_targeted_item(mob/user, mob/target)
    var/target_item
    switch(user.zone_selected)
        if (BODY_ZONE_PRECISE_R_HAND)
            target_item = target.held_items[2]
        if (BODY_ZONE_PRECISE_L_HAND)
            target_item = target.held_items[1]
        if (BODY_ZONE_HEAD)
            target_item = target.get_item_by_slot(SLOT_HEAD)
        if (BODY_ZONE_PRECISE_EARS)
            target_item = target.get_item_by_slot(SLOT_HEAD)
        if (BODY_ZONE_CHEST)
            if(target.get_item_by_slot(SLOT_ARMOR))
                target_item = target.get_item_by_slot(SLOT_ARMOR)
            else if (target.get_item_by_slot(SLOT_SHIRT))
                target_item = target.get_item_by_slot(SLOT_SHIRT)    
        if (BODY_ZONE_PRECISE_NECK)
            target_item = target.get_item_by_slot(SLOT_NECK)
        if (BODY_ZONE_PRECISE_R_EYE)
            target_item = target.get_item_by_slot(ITEM_SLOT_MASK)
        if ( BODY_ZONE_PRECISE_L_EYE)
            target_item = target.get_item_by_slot(ITEM_SLOT_MASK)
        if (BODY_ZONE_PRECISE_NOSE)
            target_item = target.get_item_by_slot(ITEM_SLOT_MASK)
        if (BODY_ZONE_PRECISE_MOUTH)
            target_item = target.get_item_by_slot(ITEM_SLOT_MOUTH)
        if (BODY_ZONE_L_ARM)
            target_item = target.get_item_by_slot(ITEM_SLOT_WRISTS)
        if (BODY_ZONE_R_ARM)
            target_item = target.get_item_by_slot(ITEM_SLOT_WRISTS)
        if (BODY_ZONE_L_LEG)
            target_item = target.get_item_by_slot(ITEM_SLOT_PANTS)
        if (BODY_ZONE_R_LEG)
            target_item = target.get_item_by_slot(ITEM_SLOT_PANTS)
        if (BODY_ZONE_PRECISE_GROIN)
            target_item = target.get_item_by_slot(ITEM_SLOT_PANTS)
        if (BODY_ZONE_PRECISE_R_FOOT)
            target_item = target.get_item_by_slot(ITEM_SLOT_SHOES)
        if (BODY_ZONE_PRECISE_L_FOOT)
            target_item = target.get_item_by_slot(ITEM_SLOT_SHOES)
    return target_item

/proc/handle_tongs(obj/item/rogueweapon/tongs/T, mob/user) //Stole the code from smithing.
	if (!T.hingot) return
	var/tyme = world.time
	T.hott = tyme
	addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/item/rogueweapon/tongs, make_unhot), tyme), 100)
	T.update_icon()
	show_visible_message(user, "After [user]'s incantation, the ingot inside [T] starts glowing.", "After your incantation, the ingot inside [T] starts glowing.")

/proc/handle_heating_in_hand(mob/living/carbon/target, obj/item/targeteditem, mob/user)
	var/datum/effect_system/spark_spread/sparks = new()
	apply_damage_to_hands(target, user)
	target.dropItemToGround(targeteditem)
	show_visible_message(target, "[target]'s [targeteditem.name] glows brightly, searing their flesh.", "Your [targeteditem.name] glows brightly, It burns!")
	target.emote("painscream")
	playsound(target.loc, 'sound/misc/frying.ogg', 100, FALSE, -1)
	sparks.set_up(1, 1, target.loc)
	sparks.start()

/proc/should_heat_in_hand(mob/user, mob/target, obj/item/targeteditem, list/nosmeltore)
	return ((user.zone_selected == BODY_ZONE_PRECISE_L_HAND && target.held_items[1]) || (user.zone_selected == BODY_ZONE_PRECISE_R_HAND && target.held_items[2])) && !(targeteditem in nosmeltore) && targeteditem.smeltresult

/proc/apply_damage_to_hands(mob/living/carbon/target, mob/user)
	var/obj/item/bodypart/affecting
	var/const/adth_damage_to_apply = 10 //How much damage should burning your hand before dropping the item do.
	if (user.zone_selected == BODY_ZONE_PRECISE_R_HAND)
		affecting = target.get_bodypart(BODY_ZONE_R_ARM)
	else if (user.zone_selected == BODY_ZONE_PRECISE_L_HAND)
		affecting = target.get_bodypart(BODY_ZONE_L_ARM)
	affecting.receive_damage(0, adth_damage_to_apply)

/proc/handle_heating_equipped(mob/living/carbon/target, obj/item/clothing/targeteditem, mob/user)
	var/obj/item/armor = target.get_item_by_slot(SLOT_ARMOR)
	var/obj/item/shirt = target.get_item_by_slot(SLOT_SHIRT)
	var/armor_can_heat = armor && armor.smeltresult && armor.smeltresult != /obj/item/ash
	var/shirt_can_heat = shirt && shirt.smeltresult && shirt.smeltresult != /obj/item/ash // Full damage if no shirt 
	var/damage_to_apply = 20 // How much damage should your armor burning you should do.
	if (user.zone_selected == BODY_ZONE_CHEST)
		if (armor_can_heat && (!shirt_can_heat && shirt))
			damage_to_apply = damage_to_apply / 2 // Halve the damage if only armor can heat but shirt can't.
		if (targeteditem == shirt & armor_can_heat) //this looks redundant but it serves to make sure the damage is doubled if both shirt and armor are metallic.
			apply_damage_if_covered(target, list(BODY_ZONE_CHEST), armor, CHEST, damage_to_apply)
		else if (targeteditem == armor & shirt_can_heat)
			apply_damage_if_covered(target, list(BODY_ZONE_CHEST), shirt, CHEST, damage_to_apply)
	apply_damage_if_covered(target, list(BODY_ZONE_CHEST), targeteditem, CHEST, damage_to_apply)
	apply_damage_if_covered(target, list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM), targeteditem, ARMS|HANDS, damage_to_apply)
	apply_damage_if_covered(target, list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG), targeteditem, GROIN|LEGS|FEET, damage_to_apply)
	apply_damage_if_covered(target, list(BODY_ZONE_HEAD), targeteditem, HEAD|HAIR|NECK|NOSE|MOUTH|EARS|EYES, damage_to_apply)
	show_visible_message(target, "[target]'s [targeteditem.name] glows brightly, searing their flesh.", "My [targeteditem.name] glows brightly, It burns!")
	playsound(target.loc, 'sound/misc/frying.ogg', 100, FALSE, -1)

/proc/apply_damage_if_covered(mob/living/carbon/target, list/body_zones, obj/item/clothing/targeteditem, mask, damage)
	var/datum/effect_system/spark_spread/sparks = new()
	var/obj/item/bodypart/affecting = null
	for (var/zone in body_zones)
	{
		if (targeteditem.body_parts_covered & mask)
			affecting = target.get_bodypart(zone)
		if (affecting)
			affecting.receive_damage(0, damage)
			sparks.set_up(1, 1, target.loc)
			sparks.start()
	}

/obj/effect/proc_holder/spell/invoked/vigorousexchange/cast(list/targets, mob/living/carbon/user = usr)
	. = ..()
	var/const/starminatoregen = 500 // How much stamina should the spell give back to the caster.
	var/mob/target = targets[1]
	if (!iscarbon(target)) 
		return
	if (target == user)
		target.energy_add(starminatoregen)
		show_visible_message(usr, "As [user] intones the incantation, vibrant flames swirl around them.", "As you intone the incantation, vibrant flames swirl around you. You feel refreshed.")
	else if (user.energy > (starminatoregen * 2))
		user.energy_add(-(starminatoregen * 2))
		target.energy_add(starminatoregen * 2)
		show_visible_message(target, "As [user] intones the incantation, vibrant flames swirl around them, a dance of energy flowing towards [target].", "As [user] intones the incantation, vibrant flames swirl around them, a dance of energy flowing towards you. You feel refreshed.")

/obj/effect/proc_holder/spell/invoked/craftercovenant/cast(list/targets, mob/user = usr)
	. = ..()
	var/tithe = 0
	var/list/doable[][] = list()
	var/const/divine_tax = 2 // Multiplier used to adjust the price that should be paid.
	var/buyprice = 0
	var/turf/altar
	var/datum/effect_system/spark_spread/sparks = new()
	altar = get_turf(targets[1])
	if(!altar)
		return
	for (var/obj/item/sacrifice in altar.contents)
	{
		if (istype(sacrifice, /obj/item/roguecoin/))
			var/obj/item/roguecoin/coincrifice = sacrifice
			tithe += (coincrifice.quantity * coincrifice.sellprice)
		else if (istype(sacrifice, /obj/item/roguestatue/) || istype(sacrifice, /obj/item/clothing/ring/) || istype(sacrifice, /obj/item/roguegem/))
			tithe += sacrifice.sellprice
		qdel(sacrifice)
	}
	buyprice = tithe / divine_tax
	for (var/list/entry in anvil_recipe_prices)
	{
		var/obj/item/tentative_item = entry[1] // The recipe
		var/total_sellprice = entry[2] // The precompiled material price
		if (total_sellprice <= buyprice)
			var/obj/itemtorecord = tentative_item
			doable += list(list(itemtorecord.name, itemtorecord))
	}
	if (!doable.len)
		show_visible_message(usr, "A wave of heat washes over the pile as [user] speaks Malum's name. The pile of valuables crumble into dust.", "A wave of heat washes over the pile as you speak Malum's name. The pile of valuables crumble into dust. Malum accepted your sacrifice. Yet it seems it wasn't enough.")
		return
	var/list/doablename = list()
	var/list/item_map = list()
	for (var/list/doableextract in doable)
	{
		doablename += list(doableextract[1])
		item_map[doableextract[1]] = doableextract[2]
	}
	var/itemchoice = input(user, "Choose your boon", "Available boons") in (doablename)
	if (itemchoice)
		var/obj/item/itemtospawn = item_map[itemchoice]
		if (itemtospawn)
			new itemtospawn.type(altar)
			sparks.set_up(1, 1, altar)
			sparks.start()
			show_visible_message(usr, "A wave of heat washes over the pile as [user] speaks Malum's name. The pile of valuables crumble into dust, only for the dust to reform into an item as if reborn from the flames. Malum has accepted the offering.", "A wave of heat washes over the pile as you speak Malum's name. The pile of valuables crumble into dust, only for the dust to reform into an item as if reborn from the flames. Malum has accepted the offering.")

var/global/list/anvil_recipe_prices[][]
/proc/add_recipe_to_global(var/datum/anvil_recipe/recipe)
	var/total_sellprice = 0
	var/obj/item/ingot/bar = recipe.req_bar
	var/obj/item/itemtosend = null
	if (bar)
		total_sellprice += bar.sellprice
		itemtosend = recipe.created_item
	if (recipe.additional_items)
		for (var/obj/additional_item in recipe.additional_items)
			total_sellprice += additional_item.sellprice
	if (istype(recipe.created_item, /list))
		var/list/itemlist = recipe.created_item
		total_sellprice = total_sellprice/itemlist.len
		itemtosend = itemlist[1]
	if (!istype(recipe.created_item, /list))
		itemtosend = recipe.created_item
	if (total_sellprice > 0)
		global.anvil_recipe_prices += list(list(itemtosend, total_sellprice))

/proc/initialize_anvil_recipe_prices()
	for (var/datum/anvil_recipe/armor/recipe)
	{
		add_recipe_to_global(recipe)
	}
	for (var/datum/anvil_recipe/tools/recipe)
	{
		add_recipe_to_global(recipe)
	}
	for (var/datum/anvil_recipe/weapons/recipe)
	{
		add_recipe_to_global(recipe)
	}
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/flute, 10))
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/drum, 10))
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/harp, 20))
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/lute, 20))
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/guitar, 30))
	global.anvil_recipe_prices += list(list(new /obj/item/rogue/instrument/accord, 30))
	global.anvil_recipe_prices += list(list(new /obj/item/riddleofsteel, 400))
	global.anvil_recipe_prices += list(list(new /obj/item/dmusicbox, 500))
	// Add any other recipe types if needed

/world/New()
	..()
	initialize_anvil_recipe_prices() // Precompute recipe prices on startup

//T0

/obj/effect/proc_holder/spell/invoked/rework //this whole thing, barely works and fixing it causes only further issues
	name = "Rework"
	desc = "Burn a piece of equipment to create a blessing for the appropriate type of equipment. Cast once more on another item to bless it."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "rework"
	releasedrain = 15
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/heal.ogg'
	invocations = list("Rework.")
	invocation_type = "whisper"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 SECONDS
	miracle = TRUE
	devotion_cost = 100
	var/order_type = null
	var/current_bonus = null
	var/current_duration = null
	var/list/itemblacklist = list(/obj/item/rogueweapon/hoe,
		/obj/item/rogueweapon/thresher,
		/obj/item/rogueweapon/sickle,
		/obj/item/rogueweapon/pitchfork,
		/obj/item/rogueweapon/tongs,
		/obj/item/rogueweapon/hammer/iron,
		/obj/item/rogueweapon/shovel,
		/obj/item/fishingrod,
	)

/obj/effect/proc_holder/spell/invoked/rework/cast(list/targets, mob/user = usr)
	. = ..()
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/H = targets[1]
		if(H == user)
			to_chat(user, "I purge all blessing options!")
			order_type = null
			current_bonus = null
			current_duration = null
	if(isobj(targets[1]))
		var/obj/item/O = targets[1]
		var/bonus = 0
		var/quality = 0
		var/skill = usr.get_skill_level(/datum/skill/magic/holy)
		var/skill_debuff = 6 - skill
		if(!order_type)
			switch(O.smeltresult)
				if(/obj/item/ingot/iron)
					bonus = 0
				if(/obj/item/ingot/bronze)
					bonus = 1.5
				if(/obj/item/ingot/steel)
					bonus = 2
				if(/obj/item/ingot/blacksteel)
					bonus = 3
			if(istype(O, /obj/item/rogueweapon))
				var/obj/item/rogueweapon/W = O
				for(W in itemblacklist)
					revert_cast()
					return FALSE
				order_type = "weapon"
				overlay_state = order_type
				quality = ((W.max_integrity / W.obj_integrity) * W.force) / 2 //full health (150) item with 25 foce = 150/150(1) * 25(25) / 2(12.5)
				current_bonus = floor((quality + bonus - skill_debuff) / 2)
				current_duration = ((quality / 2) + bonus) MINUTES
				var/view_time = floor((current_duration/10)/60)
				to_chat(user, "<font color='purple'>Current Blessing: [order_type], additional [current_bonus] force for [view_time] minutes.</font>")
				devotion_cost = 10
				qdel(W)
				revert_cast()
				return TRUE
			if(istype(O, /obj/item/clothing))
				if(O.smeltresult == /obj/item/ash)
					revert_cast()
					return FALSE
				var/obj/item/clothing/A = O
				quality = (A.max_integrity / A.obj_integrity) * 100
				order_type = "armor"
				overlay_state = order_type
				current_bonus = (bonus*100) - (skill_debuff * 10)
				current_duration = ((quality / 10) + bonus) MINUTES
				var/view_time = floor((current_duration/10)/60)
				if(current_bonus < 0)
					current_bonus *= -1
				to_chat(user, "<font color='purple'>Current Blessing: [order_type], additional max integrity [current_bonus] for [view_time] minutes.</font>")
				devotion_cost = 10
				qdel(A)
				revert_cast()
				return TRUE
			if(O.smeltresult != /obj/item/ash && O.smeltresult != /obj/item/rogueore/coal)
				quality = (O.max_integrity / O.obj_integrity) * 200
				order_type = "forge"
				overlay_state = order_type
				current_bonus = (quality + (bonus * 100)) - (skill_debuff * 20)
				current_duration = null
				to_chat(user, "<font color='purple'>Current Blessing: [order_type], fixes [current_bonus] item integrity.</font>")
				devotion_cost = 10
				qdel(O)
				revert_cast()
				return TRUE
			revert_cast()
			return FALSE

		else if(order_type == "weapon")
			if(istype(O, /obj/item/rogueweapon))
				var/obj/item/rogueweapon/W = O
				if(W.malumblessed_w == TRUE)
					to_chat(user, "The [W.name] already blessed!")
					revert_cast()
					return FALSE
				W.force = W.force + current_bonus
				W.malumblessed_w = TRUE
				var/view_time = floor((current_duration/10)/60)
				to_chat(user, "<font color='purple'>The [W.name] gain additional [current_bonus] force!</font>")
				to_chat(user, "<font color='purple'>This bonus active [view_time] Minutes!</font>")
				addtimer(CALLBACK(W, TYPE_PROC_REF(/obj/item/rogueweapon, unbuff), TRUE), current_duration)

		else if(order_type == "armor")
			if(istype(O, /obj/item/clothing))
				var/obj/item/clothing/A = O
				if(A.malumblessed_c == TRUE)
					to_chat(user, "The [A.name] already blessed!")
					revert_cast()
					return FALSE
				A.max_integrity = A.max_integrity + current_bonus
				A.malumblessed_c = TRUE
				var/view_time = floor((current_duration/10)/60)
				to_chat(user, "<font color='purple'>The [A.name] gain additional [current_bonus] integrity!</font>")
				to_chat(user, "<font color='purple'>This bonus active [view_time] Minutes!</font>")
				addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/item/clothing, unbuff), TRUE), current_duration)

		else if(order_type == "forge")
			if((O.obj_integrity + current_bonus) > O.max_integrity)
				var/need_points = (O.max_integrity - O.obj_integrity)
				O.obj_integrity += need_points
				to_chat(user, "<font color='purple'>A [need_points] integrity for [O.name] has been fixed!</font>")
			else
				O.obj_integrity += current_bonus
				to_chat(user, "<font color='purple'>A [current_bonus] integrity for [O.name] has been fixed!</font>")

		overlay_state = "rework"
		devotion_cost = 100
		order_type = null
		current_bonus = null
		current_duration = null
		return TRUE

	revert_cast()
	return FALSE

/obj/item/rogueweapon/proc/unbuff()
	force = initial(force)
	malumblessed_w = FALSE
	visible_message("<font color='purple'>A holy blessing no longer affects [name]!</font>")

/obj/item/clothing/proc/unbuff()
	max_integrity = initial(max_integrity)
	obj_integrity = max_integrity/2
	malumblessed_c = FALSE
	visible_message("<font color='purple'>A holy blessing no longer affects [name]!</font>")

/obj/effect/proc_holder/spell/self/repair
	name = "Order: Repair"
	desc = "Repairs metal items on your person." //it literally repairs everything
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "repair"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 0
	warnie = "sydwarning"
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/timestop.ogg'
	invocations = list("Repair!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 30
	var/rrange = 0
	ignore_los = 1 // this uses some other weird shit for range

/obj/effect/proc_holder/spell/self/repair/cast(mob/living/carbon/human/user)
	var/skill = user.get_skill_level(/datum/skill/magic/holy)
	var/repair_points = 200 * skill
	var/one_fix_points = 50 + (skill * 10)
	var/cost = 40 - (skill * 5)
	for(var/obj/item/I in range(rrange, user)) //items on usertill and user
		var/dist = get_dist(I, user)
		if(repair_points <= 0 || (repair_points - one_fix_points) <= 0)
			repair_points = 0
			return FALSE
		if(dist > 1)
			continue
		if(!I.smeltresult) //only metal items.
			continue
		if(I.smeltresult == /obj/item/ash && I.smeltresult == /obj/item/rogueore/coal) //not cloth and wood.
			continue
		if(I.max_integrity <= I.obj_integrity)
			continue
		if(!do_after(user, 50))
			repair_points = 0
			return FALSE
		I.obj_integrity = min(I.obj_integrity + one_fix_points, I.max_integrity)
		I.visible_message(span_info("[I] glows in a faint mending light."))
		user.devotion?.update_devotion(-cost)
		if(cost != 0)
			to_chat(user, "<font color='purple'>I lose [cost] devotion!</font>")
		if(I.max_integrity <= I.obj_integrity)
			I.obj_fix()
			I.repair_coverage()
			I.visible_message(span_info("[I] mend together, completely."))
			continue
		if((user.devotion?.devotion - cost) < 0)
			to_chat(user, span_warning("I do not have enough devotion!"))
			return FALSE
		cast(user)
	revert_cast()
	return TRUE

/obj/effect/proc_holder/spell/invoked/restoration
	name = "Order: Restoration"
	desc = "Restore integrity of any structure."
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "restoration"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 7
	warnie = "sydwarning"
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/timestop.ogg'
	invocations = list("Repair!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 50

/obj/effect/proc_holder/spell/invoked/restoration/cast(list/targets, mob/living/user)
	var/skill = user.get_skill_level(/datum/skill/magic/holy)
	var/repair_points = 50 * skill
	var/starget = targets[1]
	if(isobj(starget))
		if(istype(starget, /obj/item))
			revert_cast()
			return FALSE
		var/obj/structure/S = starget
		if(S.obj_integrity >= S.max_integrity)
			revert_cast()
			return FALSE
		if(istype(S, /obj/structure/mineral_door/))
			var/obj/structure/mineral_door/door = S
			to_chat(user, span_warning("[door.obj_integrity]"))
			user.visible_message(span_notice("[user] starts concentrating on [door.name]."),
			span_notice("I start concentrating on [door.name]."))
			playsound(user, 'sound/misc/wood_saw.ogg', 100, TRUE)
			if(!do_after(user, (150 / skill), target = door))
				return
			playsound(user, 'sound/misc/wood_saw.ogg', 100, TRUE)
			door.icon_state = "[door.base_state]"
			door.density = TRUE
			door.opacity = TRUE
			door.brokenstate = FALSE
			door.obj_broken = FALSE
			door.repair_state = 0								
			if((S.obj_integrity + repair_points) > S.max_integrity)
				var/need_points = (S.max_integrity - S.obj_integrity)
				S.obj_integrity += need_points
			else
				S.obj_integrity += repair_points
			user.visible_message(span_notice("[user] point on [door.name] and repair this."), \
			span_notice("I point on [door.name]. Malum blessing!"))	
			return TRUE

		if(istype(S, /obj/structure/roguewindow/))
			var/obj/structure/roguewindow/window = S
			if(window.obj_integrity < window.max_integrity)
				to_chat(user, span_warning("[window.obj_integrity]"))	
				user.visible_message(span_notice("[user] starts concentrating on [window.name]."),
				span_notice("I start concentrating on [window.name]."))
				playsound(user, 'sound/misc/wood_saw.ogg', 100, TRUE)
				if(!do_after(user, (150 / skill), target = window))
					return
				playsound(user, 'sound/misc/wood_saw.ogg', 100, TRUE)
				window.icon_state = "[window.base_state]"
				window.density = TRUE
				window.brokenstate = FALSE
				window.obj_broken = FALSE
				if((S.obj_integrity + repair_points) > S.max_integrity)
					var/need_points = (S.max_integrity - S.obj_integrity)
					S.obj_integrity += need_points
				else
					S.obj_integrity += repair_points					
				user.visible_message(span_notice("[user] point on [window.name] and repair this."), \
				span_notice("I point on [window.name]. Malum blessing!"))	
				return TRUE
		else
			if(!do_after(user, (150 / skill), target = S))
				return
			if((S.obj_integrity + repair_points) > S.max_integrity)
				var/need_points = (S.max_integrity - S.obj_integrity)
				S.obj_integrity += need_points
			else
				S.obj_integrity += repair_points
			return TRUE
	if(get_turf(starget))
		var/turf/closed/wall/mineral/W = targets[1]
		if(W.turf_integrity >= W.max_integrity)
			revert_cast()
			return FALSE
		if(!do_after(user, (150 / skill), target = W))
			return
		if((W.turf_integrity + repair_points) > W.max_integrity)
			var/need_points = (W.max_integrity - W.turf_integrity)
			W.turf_integrity += need_points
		else
			W.turf_integrity += repair_points
		return TRUE
	revert_cast()
	return FALSE

/datum/action/cooldown/spell/touch/rework
	name = "Rework"
	desc = "Summon divine forgefire into your hand. You can break down objects into usable material and reshape them through Malum's craft."
	button_icon = 'icons/mob/actions/malummiracles.dmi'
	button_icon_state = "rework"
	sound = 'sound/magic/whiteflame.ogg'
	glow_intensity = GLOW_INTENSITY_LOW
	click_to_activate = FALSE
	self_cast_possible = TRUE
	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP
	charge_required = FALSE
	cooldown_time = 5 SECONDS
	associated_skill = /datum/skill/magic/holy
	infinite_use = TRUE
	hand_path = /obj/item/melee/touch_attack/forgehand
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/divine_alloy = 0
	var/list/materials_known = list()

	var/list/blacklist = list(
		/obj/item/melee/touch_attack/forgehand,
	)

/datum/action/cooldown/spell/touch/rework/examine(mob/user)
	. = ..()
	var/list/inspec = list()

	if(divine_alloy <= 0)
		inspec += span_smallnotice("It holds no divine alloy.<br>")
	else
		inspec += span_smallnotice("Divine Alloy: [divine_alloy]<br>")

	if(materials_known.len)
		inspec += span_smallnotice("Known materials:<br>")
		for(var/T in materials_known)
			var/obj/item/temp = new T
			var/name = initial(temp.name)
			qdel(temp)
			inspec += span_smallnotice("- [name]<br>")

	to_chat(user, "[inspec.Join()]")

/obj/item/melee/touch_attack/forgehand
	name = "\improper forgehand"
	desc = "The teachings of Malum burn within your grasp."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "grabbing_greyscale"
	color = "#da9a63"
	aura_color = "#ff7b00"
	possible_item_intents = list(
		/datum/intent/forgehand_fill,
		/datum/intent/forgehand_bless,
		/datum/intent/forgehand_smelt,
		/datum/intent/forgehand_fire
	)
	associated_skill = /datum/skill/magic/holy
	experimental_inhand = FALSE

	var/datum/action/cooldown/spell/touch/rework/source_spell

/obj/item/melee/touch_attack/forgehand/Initialize(mapload)
	. = ..()
	if(istype(loc, /mob/living))
		var/mob/living/M = loc
		for(var/datum/action/cooldown/spell/touch/rework/S in M.actions)
			source_spell = S
			break

/datum/intent/forgehand_fill
	name = "salvage"
	icon_state = "infill"
	no_attack = FALSE

/datum/intent/forgehand_bless
	name = "bless"
	icon_state = "inbless"

/datum/intent/forgehand_smelt
	name = "smelt"
	icon_state = "inchisel"

/datum/intent/forgehand_fire
	name = "fire"
	icon_state = "inshoot"
	tranged = 1
	noaa = TRUE

/obj/item/melee/touch_attack/forgehand/attack_self()
	qdel(src)

/obj/item/melee/touch_attack/forgehand/afterattack(atom/target, mob/living/carbon/human/user, proximity_flag, click_parameters)
	if(!source_spell)
		return

	var/datum/intent/I = user.used_intent

	if(istype(I, /datum/intent/forgehand_fill))
		if(proximity_flag)
			gather_material(target, user)

	else if(istype(I, /datum/intent/forgehand_bless))
		if(proximity_flag)
			bless_weapon(target, user)

	else if(istype(I, /datum/intent/forgehand_smelt))
		if(proximity_flag)
			smelt_materials(target, user)

	else if(istype(I, /datum/intent/forgehand_fire))
		fire_material(target, user)
	
/obj/item/melee/touch_attack/forgehand/proc/gather_material(atom/target, mob/living/carbon/human/user)
	if(!source_spell)
		return

	if(isitem(target))
		return absorb_item(target, user)

	if(isturf(target))
		var/any = FALSE
		for(var/obj/item/I in target.contents)
			if(absorb_item(I, user))
				any = TRUE
		if(any)
			return 1

	to_chat(user, span_warning("Nothing here can be reworked."))
	return

/obj/item/melee/touch_attack/forgehand/proc/get_alloy_value(obj/item/I, list/visited = null)
	if(!visited)
		visited = list()
	if(!I)
		return 0
	if(I.type in visited)
		return 0
	visited += I.type
	if(istype(I, /obj/item/ash)) return 0
	if(istype(I, /obj/item/natural/clay)) return 0
	if(istype(I, /obj/item/natural/stone)) return 1
	if(istype(I, /obj/item/natural/glass)) return 2
	if(istype(I, /obj/item/rogueore/coal)) return 4 
	if(istype(I, /obj/item/ingot/copper)) return 6 
	if(istype(I, /obj/item/ingot/tin)) return 6 
	if(istype(I, /obj/item/scrap)) return 8 
	if(istype(I, /obj/item/ingot/iron)) return 8 
	if(istype(I, /obj/item/ingot/aaslag)) return 10 
	if(istype(I, /obj/item/ingot/bronze)) return 12
	if(istype(I, /obj/item/ingot/steel)) return 28 
	if(istype(I, /obj/item/ingot/gold)) return 32
	if(istype(I, /obj/item/ingot/blacksteel)) return 128

	if(I.smeltresult)
		var/obj/item/temp = new I.smeltresult
		var/v = get_alloy_value(temp, visited)
		qdel(temp)
		return v

	return 0

/obj/item/melee/touch_attack/forgehand/proc/get_material_type(obj/item/I)
	if(istype(I, /obj/item/scrap))
		return /obj/item/rogueore/iron

	if(I.smeltresult)
		return I.smeltresult

	return null

/obj/item/melee/touch_attack/forgehand/proc/get_material_cost(typepath)
	switch(typepath)
		if(/obj/item/ash) return 0
		if(/obj/item/natural/clay) return 0
		if(/obj/item/natural/stone) return 0
		if(/obj/item/natural/glass) return 2
		if(/obj/item/rogueore/coal) return 4 
		if(/obj/item/ingot/copper) return 6 
		if(/obj/item/ingot/tin) return 6 
		if(/obj/item/scrap) return 8 
		if(/obj/item/ingot/iron) return 8 
		if(/obj/item/ingot/bronze) return 12
		if(/obj/item/ingot/steel) return 28 
		if(/obj/item/ingot/aaslag) return 28 
		if(/obj/item/ingot/gold) return 32
		if(/obj/item/ingot/blacksteel) return 128
	return 0

/obj/item/melee/touch_attack/forgehand/proc/absorb_item(obj/item/I, mob/user)
	if(!source_spell || !I)
		return

	for(var/T in source_spell.blacklist)
		if(istype(I, T))
			return

	if(istype(I, /obj/item/rogueweapon))
		var/int_percent = round(((I.obj_integrity / I.max_integrity) * 100), 1)
		if(!I.obj_broken && int_percent > 10)
			to_chat(user, span_warning("[I] must be broken or nearly destroyed before it can be reworked."))
			return

	var/value = get_alloy_value(I)
	if(value <= 0)
		to_chat(user, span_warning("[I] cannot be reworked by the forgehand."))
		return

	var/typepath = get_material_type(I)
	if(typepath && !(typepath in source_spell.materials_known))
		source_spell.materials_known += typepath

	source_spell.divine_alloy += value

	to_chat(user, span_notice("[I] is reduced to a smoldering, molten essence...<br>Divine Alloy (+[value], [source_spell.divine_alloy])"))

	qdel(I)
	return 1

/obj/item/melee/touch_attack/forgehand/proc/fire_material(atom/target, mob/living/carbon/human/user)
	if(!source_spell)
		return

	var/cost = 1

	if(source_spell.divine_alloy < cost)
		to_chat(user, span_warning("You lack the divine alloy to fire."))
		return

	source_spell.divine_alloy -= cost

	var/obj/item/ammo_casing/caseless/rogue/sling_bullet/iron/C = new()
	var/obj/projectile/P = C.BB

	if(!P)
		qdel(C)
		return

	var/turf/start = get_turf(user)
	var/turf/end = get_turf(target)

	P.forceMove(start)
	P.firer = user
	P.original = target
	P.starting = start

	P.fire(get_dir(start, end))

	to_chat(user, span_notice("You loose a forged bullet."))

	qdel(C)
	return 1

/obj/item/melee/touch_attack/forgehand/proc/bless_weapon(atom/target, mob/living/carbon/human/user)
	if(!source_spell)
		return

	if(!isitem(target))
		to_chat(user, span_warning("That cannot be blessed."))
		return

	var/obj/item/I = target

	if(!istype(I, /obj/item/rogueweapon))
		to_chat(user, span_warning("[I] cannot receive Malum's blessing."))
		return

	var/list/options = list(
		"Reinforce (Durability) - 30" = "durability",
		"Temper (Repair) - 20" = "repair",
		"Overforge (Bonus Force) - 40" = "greater"
	)

	var/choice = input(user, "Shape the divine alloy into a blessing:", "Forgehand Blessing") as null|anything in options
	if(!choice)
		return

	var/selection = options[choice]

	switch(selection)

		if("repair")
			var/cost = 20
			if(source_spell.divine_alloy < cost)
				to_chat(user, span_warning("You lack sufficient Divine Alloy."))
				return

			source_spell.divine_alloy -= cost

			I.obj_integrity = min(I.max_integrity, I.obj_integrity + 100)

			to_chat(user, span_notice("[I] is mended by flowing divine alloy."))
			return 1


		if("durability")
			var/cost = 30
			if(source_spell.divine_alloy < cost)
				to_chat(user, span_warning("You lack sufficient Divine Alloy."))
				return
			source_spell.divine_alloy -= cost
			I.AddComponent(/datum/component/fit_clothing, 15 MINUTES, TRUE, /datum/skill/magic/holy, DURABILITY_ENCHANT)
			to_chat(user, span_notice("[I] is reinforced with divine strength."))
			return 1

		if("greater")
			var/cost = 40
			if(source_spell.divine_alloy < cost)
				to_chat(user, span_warning("You lack sufficient Divine Alloy."))
				return

			if(!I.force)
				to_chat(user, span_warning("[I] cannot channel offensive blessing."))
				return

			source_spell.divine_alloy -= cost

			I.AddComponent(/datum/component/forge_damage_enchant, 5 MINUTES, 10 )

			to_chat(user, span_notice("[I] is engulfed in raging divine fire."))
			return 1

/obj/item/melee/touch_attack/forgehand/proc/smelt_materials(atom/target, mob/living/carbon/human/user)
	if(!source_spell)
		return

	if(!source_spell.materials_known.len)
		to_chat(user, span_warning("You lack the knowledge to shape any materials."))
		return

	var/list/display = list()
	var/list/lookup = list()

	for(var/T in source_spell.materials_known)
		var/cost = get_material_cost(T)
		if(cost <= 0)
			continue

		var/obj/item/temp = new T
		var/name = initial(temp.name)
		qdel(temp)

		var/entry = "[name] ([cost])"
		display += entry
		lookup[entry] = T

	if(!display.len)
		to_chat(user, span_warning("None of your known materials can be shaped."))
		return

	var/choice = input(user, "Shape divine alloy into material:", "Forgehand") as null|anything in display
	if(!choice)
		return

	var/typepath = lookup[choice]
	var/cost = get_material_cost(typepath)

	if(source_spell.divine_alloy < cost)
		to_chat(user, span_warning("You lack sufficient divine alloy."))
		return

	var/amount = floor(source_spell.divine_alloy / cost)
	if(amount <= 0)
		return

	source_spell.divine_alloy -= (amount * cost)

	var/turf/T = get_turf(user)

	for(var/i in 1 to amount)
		new typepath(T)

	to_chat(user, span_notice("You shape divine alloy into [amount] [choice]."))

#define DAMAGE_ENCHANT_BONUS 10
#define DAMAGE_ENCHANT_DURATION (5 MINUTES)

/datum/component/forge_damage_enchant
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/endtime
	var/bonus = DAMAGE_ENCHANT_BONUS

/datum/component/forge_damage_enchant/Initialize(duration_override, bonus_override)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/I = parent

	if(bonus_override)
		bonus = bonus_override

	var/duration = duration_override ? duration_override : DAMAGE_ENCHANT_DURATION
	endtime = world.time + duration

	apply_bonus(I)

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	addtimer(CALLBACK(src, PROC_REF(expire)), duration)

/datum/component/forge_damage_enchant/proc/apply_bonus(obj/item/I)
	if(I.force)
		I.force += bonus

	var/filter = I.get_filter("forge_damage")
	if(!filter)
		I.add_filter("forge_damage", 2, list(
			"type" = "outline",
			"color" = "#ff3c00",
			"alpha" = 120,
			"size" = 2
		))

/datum/component/forge_damage_enchant/proc/remove_bonus()
	var/obj/item/I = parent
	if(I?.force)
		I.force -= bonus

	I?.remove_filter("forge_damage")

/datum/component/forge_damage_enchant/proc/expire()
	qdel(src)

/datum/component/forge_damage_enchant/Destroy()
	remove_bonus()
	. = ..()

/datum/component/forge_damage_enchant/proc/on_examine(datum/source, mob/user, list/examine_list)
	var/remaining = round((endtime - world.time) / 600)
	examine_list += "It burns with divine fury (+[bonus] damage)."
	examine_list += "The blessing will last [remaining] more minutes."

#undef DAMAGE_ENCHANT_BONUS
#undef DAMAGE_ENCHANT_DURATION
