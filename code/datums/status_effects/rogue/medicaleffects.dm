/*The way sleephealing works now:
- Can only heal if you are below certain damage thresholds. So sleep-healing off smaller wounds is possible.
- To sleep off bigger damage and wounds, you need to be treated, which will consume the buff after you're done sleeping.
*/

/// This will let you heal twice as much from what you naturally can.
/atom/movable/screen/alert/status_effect/buff/first_aid
	name = "Patched Up"
	desc = "Someone who knows what they're doing have seen to me, I'm certain to recover from my ailments after a good sleep now!"
	icon_state = "buff"
/datum/status_effect/buff/first_aid
	id = "first_aid"
	alert_type = /atom/movable/screen/alert/status_effect/buff/first_aid
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE

/// This will let you fully heal.
/atom/movable/screen/alert/status_effect/buff/medical_aid
	name = "Medical Treatment"
	desc = "Someone who absolutely knows what they're doing have seen to me, I'm certain to recover from my ailments after a good sleep now!"
	icon_state = "buff"
/datum/status_effect/buff/medical_aid
	id = "medical_aid"
	alert_type = /atom/movable/screen/alert/status_effect/buff/first_aid
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE

/*Wounds:
- Open wounds will eventually become infected after 5 minutes of exposure to the elements.
- Bandaged wounds will never become infected.
*/
