/datum/patron/old_god
	name = "Psydon"
	domain = "Otava, Naledi, Rockhill, and most of Psydonia's outermost fiefs."
	desc = "PSYDON, the Allfather and God of Creation, was said to be beloved beyond measure, broad of shoulder, mighty of arm, and gentle of heart. He was the sort to kneel in the mud to comfort a crying child, to laugh alongside His people at their merrymaking, and to stand between the helpless and any harm without a moment's hesitation. No soul was too lowly for His affection, no burden too small for His concern, and no sinner too wretched for His mercy. He was strength without cruelty, wisdom without arrogance, and love without condition. The world was His home, mortalkind His children, and their happiness His greatest joy.<br><br>Though He has fallen silent since the Comet Syon, His children remember the warmth of His embrace, the certainty of His protection, and the boundless kindness of the Father who never asked them to bear a burden He would not bear Himself. ENDURE, for He would have wished you to live."
	worshippers = "Commonfolk, Zealots, Heroes, Villains, and the Esoteric"
	associated_faith = /datum/faith/old_god
	mob_traits = list(TRAIT_PSYDONIAN_GRIT) //Assigned to all mobs with Psydon as the chosen patron. Gives a Willpower-scaling chance to resist succumbing to pain.
	miracles = list(/datum/action/cooldown/spell/touch/orison		= CLERIC_ORI,
					/datum/action/cooldown/spell/psydon/bootcheck	= CLERIC_T0, //Personal spell - summons a completely random item upon use. Your mileage might vary.
					/datum/action/cooldown/spell/psydon/endure		= CLERIC_T1, //External spell - seals bleeding wounds and helps to save people who've been critically injured.
					/datum/action/cooldown/spell/psydon/prayer		= CLERIC_T1, //Internal spell - minor self-regeneration, repeatedly casted while still.
					/datum/action/cooldown/spell/psydon/respite		= CLERIC_T2, //Ditto, but stronger. The original variant, intended for dedicated - non-Adventuring - combat classes.
					/datum/action/cooldown/spell/psydon/persist		= CLERIC_T3, //Ditto-ditto. Intended for non-combative devotee classes, such as the Missionary and Absolver.
	)
	traits_tier = list(TRAIT_PSYDONITE = CLERIC_T0) //Requires a minimal holy skill or the 'Devotee' virtue to unlock. Offers passive wound regeneration, but prevents healing from most miracles.
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON YET LYVES! PSYDON YET ENDURES!",
		"REBUKE THE HEATHEN, SUNDER THE MONSTER!",
		"MY GOD - WITH EVERY BROKEN BONE, I SWORE I LYVED!",
		"EVEN NOW, THERE IS STILL HOPE FOR MAN! AVE PSYDONIA!",
		"WITNESS ME, PSYDON; THE SACRIFICE MADE MANIFEST!",
	)

	titles = list(
		"God", // people call him this for. some reason. he has a name, y'all
		"Architect",
		"Allfather",
		"Creator",
		"Father",
		"Saidon",
		"Saidun" // lingyue
	)

/////////////////////////////////
// Does God Hear Your Prayer ? //
/////////////////////////////////
// no he's dead - ok maybe he does

/datum/patron/old_god/can_pray(mob/living/follower)
	. = ..()
	. = TRUE
	// Allows prayer near psycross.
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if raining and outside. Psydon weeps.
	// this is a gpt'd fix after we updated our weather system. im pretty sure i get how it works, just didnt know how to call the SSParticleWeather.
	var/datum/particle_weather/W = SSParticleWeather?.runningWeather
	if(istype(W, /datum/particle_weather/rain_gentle) || istype(W, /datum/particle_weather/rain_storm))
		if(istype(get_area(follower), /area/rogue/outdoors))
			return TRUE
	if(istype(W, /datum/particle_weather/blood_rain_gentle) || istype(W, /datum/particle_weather/blood_rain_storm))
		if(istype(get_area(follower), /area/rogue/outdoors))
			follower.add_stress(/datum/stressevent/something_stirs)
			follower.playsound_local(follower, 'sound/magic/psydonbleeds.ogg', 40, TRUE)
			return TRUE
	// Allows prayer if bleeding.
	if(follower.bleed_rate > 0)
		return TRUE
	// Allows prayer if holding silver psycross.
	if(istype(follower.get_active_held_item(), /obj/item/clothing/neck/roguetown/psicross/silver))
		return TRUE
	to_chat(follower, span_danger("..yet, I feel incomplete. To complete my prayer, I must stand before a structured cross, be grasping a silvered psycross, be bleeding from a wound, or be standing in the rain. Just as He weeps, so must I."))
	return FALSE
