/datum/advclass/immolator
	name = "Immolator"
	tutorial = "The flames reveal all. Where others see impurity, heresy, and weakness, you see fuel. Immolators are wandering zealots of Saint Astrata, carrying sacred fire across Grenzelhoft and beyond. Though they reject the Ten and their temples, they do not reject civilization; they seek to cleanse it. Through flame, suffering, and unwavering conviction, they believe mankind may yet be made pure."
	allowed_sexes = list(MALE, FEMALE)
	
	outfit = /datum/outfit/job/roguetown/immolator
	subclass_languages = list(/datum/language/otavan, /datum/language/grenzelhoftian)
	category_tags = list(CTAG_ORTHODOXIST)
	traits_applied = list(
		TRAIT_ARCYNE,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_NOPAINSTUN,
	)
	subclass_stats = list(
		STATKEY_PER = 4,
		STATKEY_WIL = 3,
		STATKEY_CON = 3,
		STATKEY_SPD = -1,
		STATKEY_LCK = 1,
	)
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
	)
	subclass_stashed_items = list(
	)
	extra_context = "This subclass may choose between multiple Disciplines. The Immolator-Purifier wields the Flammenzheuer, a revered relic combining a pressurized projector of sacred flame with a pilebunker-drill for breaching fortifications and crushing the impure. The Immolator-Illuminator forsakes some of the Purifier's martial prowess to master Astratan firecraft, wielding Arcyne flame with greater skill at the cost of diminished Miracle aptitude."

/datum/outfit/job/roguetown/immolator
	job_bitflag = BITFLAG_HOLY_WARRIOR

/obj/item/storage/belt/rogue/leather/rope/dark
	color = "#505050"

/datum/outfit/job/roguetown/immolator/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	if(H.mind)
		var/weapons = list("Purifier - Flammenzheuer & Axe", "Illuminator - Staff & Axe + Dodge Expert")
		var/weapon_choice = input(H,"Choose your PATH.", "TAKE UP SAINT ASTRATA'S FLAME.") as anything in weapons
		switch(weapon_choice)
			if("Purifier - Flammenzheuer & Axe")
				H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/magic/holy, SKILL_LEVEL_NOVICE, TRUE)
				ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_GENERIC)
				H.change_stat(STATKEY_INT, 2)
				var/datum/devotion/C = new /datum/devotion(H, H.patron)
				C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)
				handl = /obj/item/clothing/gloves/roguetown/bandages/pugilist

			if("Illuminator - Staff & Axe, Dodge Expert")
				H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/magic/holy, SKILL_LEVEL_NOVICE, TRUE)
				ADD_TRAIT(H, TRAIT_ARCYNE, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
				H.change_stat(STATKEY_WIL, -2)
				H.change_stat(STATKEY_CON, -2)
				H.change_stat(STATKEY_SPD, 4)
				H.change_stat(STATKEY_INT, 2)
				var/datum/devotion/C = new /datum/devotion(H, H.patron)
				C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)
				handl = /obj/item/clothing/gloves/roguetown/bandages/pugilist

	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/head/roguetown/helmet/blacksteel/psythorns
	backl = /obj/item/storage/backpack/rogue/satchel/otavan
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers/psythorns
	neck = /obj/item/clothing/neck/roguetown/psicross/silver
	id = /obj/item/clothing/ring/signet/psy
	gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
	mask = /obj/item/clothing/mask/rogue/facemask/steel/confessor/immolator

	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots

	backpack_contents = list(/obj/item/roguekey/inquisitionmanor = 1,
	/obj/item/paper/inqslip/arrival/ortho = 1)
	belt = /obj/item/storage/belt/rogue/leather/rope/dark
	beltl = /obj/item/storage/belt/rogue/pouch/coins/mid
	cloak = /obj/item/clothing/cloak/tabard/psydontabard/alt
