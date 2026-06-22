/datum/job/roguetown/neophyte
	title = "Neophyte"
	flag = NEOPHYTE
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	allowed_sexes = list(MALE, FEMALE)
	forbidden_races = list(RACES_DESPISED)
	tutorial = "You are a Neophyte, a junior servant of the Holy Otavan Inquisition and apprentice to its agents. Though entrusted with little authority, you are expected to assist all in their duties, whether that be maintaining records, carrying out errands, or learning the sacred doctrines of Psydon."
	outfit = /datum/outfit/job/roguetown/neophyte
	display_order = JDO_NEOPHYTE
	give_bank_account = TRUE
	min_pq = -10
	max_pq = null
	round_contrib_points = 1
	advclass_cat_rolls = list(CTAG_ORTHODOXIST = 20)
	job_subclasses = list(
		/datum/advclass/neophyte/scribe,
		/datum/advclass/neophyte/initiate,
		/datum/advclass/neophyte/page,
		/datum/advclass/neophyte/flagellant,
	)

/datum/outfit/job/roguetown/neophyte
	has_loadout = TRUE

//////////////////////////////////////////////////////////
// SCRIBE
//////////////////////////////////////////////////////////

/datum/advclass/neophyte/scribe
	name = "Scribe"
	tutorial = "The first lesson of a Confessor is observation. You serve as a copyist, archivist, messenger, and record-keeper for the Orthodoxy. Though lacking the authority of a true Confessor, your eyes and ears are expected to remain open at all times for heresy."
	category_tags = list(CTAG_ORTHODOXIST)

	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_PER = 2,
		STATKEY_SPD = 1,
	)

	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/magic/holy = SKILL_LEVEL_NOVICE,
	)

//////////////////////////////////////////////////////////
// INITIATE
//////////////////////////////////////////////////////////

/datum/advclass/neophyte/initiate
	name = "Initiate"
	tutorial = "You have only begun walking the path of Psydon's Disciples. Your duties are humble: tending shrines, studying scripture, assisting clergy, and spreading the word of the Allfather. One day your body may become a weapon. Today, your voice must suffice."
	category_tags = list(CTAG_ORTHODOXIST)

	subclass_stats = list(
		STATKEY_WIL = 1,
		STATKEY_CON = 1,
		STATKEY_INT = 1,
	)

	subclass_skills = list(
		/datum/skill/magic/holy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
	)

//////////////////////////////////////////////////////////
// PAGE
//////////////////////////////////////////////////////////

/datum/advclass/neophyte/page
	name = "Page"
	tutorial = "Every Adjudicator once carried another's shield. Pages serve as attendants, squires, and assistants to the holy warriors of the Orthodoxy. You clean armor, carry equipment, and learn the principles of righteous judgment."
	category_tags = list(CTAG_ORTHODOXIST)

	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_PER = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_NOVICE,
	)

//////////////////////////////////////////////////////////
// FLAGELLANT
//////////////////////////////////////////////////////////

/datum/advclass/neophyte/flagellant
	name = "Flagellant"
	tutorial = "Pain is the whetstone of the soul. Through hardship, fasting, and self-denial, you seek to emulate the Absolvers who bear the suffering of others. You tend wounds, preach repentance, and endure discomfort so that others may not have to."
	category_tags = list(CTAG_ORTHODOXIST)

	subclass_stats = list(
		STATKEY_WIL = 2,
		STATKEY_CON = 1,
		STATKEY_INT = 1,
	)

	subclass_skills = list(
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/holy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
	)
