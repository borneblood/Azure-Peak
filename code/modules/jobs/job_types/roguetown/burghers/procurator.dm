/datum/job/roguetown/procurator
	title = "Procurator"
	flag = PROCURATOR
	department_flag = ATC
	selection_color = JCOLOR_ATC
	faction = "Station"

	total_positions = 2
	spawn_positions = 2

	forbidden_races = list(RACES_DESPISED)
	allowed_sexes = list(MALE, FEMALE)

	is_quest_giver = TRUE

	tutorial = "You began as a capable homesteader, familiar with livestock, timber, tools, and the harsh arithmetic of honest work. The Azurian Trading Company saw promise in your grit and practical cunning, recruiting and training you into a professional Procurator. Now the road is your trade: dangerous deliveries, recovered salvage, struck bargains, and the steady movement of goods into Company coffers."

	outfit = /datum/outfit/job/roguetown/procurator
	display_order = JDO_PROCURATOR

	give_bank_account = TRUE
	min_pq = 25
	max_pq = null
	round_contrib_points = 2

	job_traits = list(
		TRAIT_SEEPRICES,
		TRAIT_CICERONE,
		TRAIT_CARGOTECHIE,
		TRAIT_LONGSTRIDER,
		TRAIT_JACKOFALLTRADES
	)

	virtue_restrictions = list(
		/datum/virtue/combat/combat_virtue,
		/datum/virtue/utility/noble,
		/datum/virtue/thief/drug_runner
	)

	advclass_cat_rolls = list(CTAG_MERCH = 2)

	job_subclasses = list(
		/datum/advclass/procurator
	)


/datum/advclass/procurator
	name = "Procurator"
	tutorial = "TODO"

	outfit = /datum/outfit/job/roguetown/procurator/basic

	category_tags = list(CTAG_MERCH)

	traits_applied = list(
		TRAIT_SMITHING_EXPERT,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_AGENT_MERCHANT,
		TRAIT_SELF_SUSTENANCE
	)

	subclass_stats = list(
		STATKEY_STR = -2,
		STATKEY_INT = 1,
		STATKEY_SPD = 3,
		STATKEY_WIL = 3,
		STATKEY_LCK = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,

		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,

		/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,

		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,

		/datum/skill/labor/lumberjacking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/fishing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/mining = SKILL_LEVEL_APPRENTICE,
	)


/datum/outfit/job/roguetown/procurator/basic/pre_equip(mob/living/carbon/human/H)
	..()

	H.adjust_blindness(-2)

	head = /obj/item/clothing/head/roguetown/headband/monk/barbarian

	cloak = /obj/item/storage/backpack/rogue/satchel/beltpack
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor

	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced

	gloves = /obj/item/clothing/gloves/roguetown/bandages

	belt = /obj/item/storage/backpack/rogue/satchel/short
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/magebag

	backr = /obj/item/storage/backpack/rogue/satchel/procurator

	id = /obj/item/scomstone
	r_hand = /obj/item/storage/keyring/merchant

	backpack_contents = list(
		/obj/item/flint = 1,
		/obj/item/rope = 1,
		/obj/item/storage/belt/rogue/pouch/merchant/coins = 2,
	)

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/appraise/secular)

		H.mind.special_items["Woodcutter's Axe"] = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter
		H.mind.special_items["Pickaxe"] = /obj/item/rogueweapon/pick
		H.mind.special_items["Fishing Rod"] = /obj/item/fishingrod/crafted
		H.mind.special_items["Barter Wine"] = /obj/item/reagent_containers/glass/bottle/rogue/wine

		SStreasury.grant_savings(ECONOMIC_MIDDLE_CLASS, H)

	if(!(H in SStreasury.merchant_agents))
		SStreasury.merchant_agents += H

