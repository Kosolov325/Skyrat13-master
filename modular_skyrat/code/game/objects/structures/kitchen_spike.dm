#define VIABLE_MOB_CHECK(X) (isliving(X) && !issilicon(X) && !isbot(X))
/obj/structure/kitchenspike/cross
	name = "cross"
	icon = 'modular_skyrat/icons/obj/cross.dmi'
	icon_state = "cross"
	desc = "Degenerates like you belong on one of these."
	anchored = TRUE

/obj/structure/kitchenspike/cross/crowbar_act(mob/living/user, obj/item/I)
	if(has_buckled_mobs())
		to_chat(user, "<span class='notice'>You can't do that while something's on the cross!</span>")
		return FALSE
	if(I.use_tool(src, user, 20, volume=100))
		deconstruct()
	return TRUE

/obj/structure/kitchenspike/cross/deconstruct()
	new /obj/item/stack/sheet/mineral/wood(src.loc, 10)
	qdel(src)

/obj/structure/kitchenspike/cross/attack_hand(mob/user)
	if(VIABLE_MOB_CHECK(user.pulling) && user.a_intent == INTENT_GRAB && !has_buckled_mobs())
		var/mob/living/L = user.pulling
		if(do_mob(user, src, 120))
			if(has_buckled_mobs()) //to prevent spam/queing up attacks
				return
			if(L.buckled)
				return
			if(user.pulling != L)
				return
			playsound(src.loc, "modular_skyrat/sound/misc/crossed.ogg", 20, 1) // thanks hippie
			L.visible_message("<span class='danger'>[user] ties [L] to the cross!</span>", "<span class='userdanger'>[user] ties you to the cross!</span>")
			L.forceMove(drop_location())
			L.setDir(2)
			buckle_mob(L, force=1)
			L.pixel_y = 26
			L.overlays += image('modular_skyrat/icons/obj/cross.dmi', "lashing")
		to_chat(user, "<span class='danger'>You can't use that on the cross!</span>")
	else if (has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
		..()

/obj/structure/kitchenspike/cross/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user] tries to pull [M] free of the [src]!",\
				"<span class='notice'>[user.name] is trying to pull you off the [src], opening up fresh wounds!</span>",\
				"<span class='italics'>You hear rope being unraveled.</span>")
			if(!do_after(user, 300, target = src))
				if(M && M.buckled)
					M.visible_message(\
					"[user] fails to free [M]!",\
					"<span class='notice'>[user] fails to pull you off of the [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M] struggles to break free from the [src]!</span>",\
			"<span class='notice'>You struggle to break free from the [src], exacerbating your wounds! (Stay still for two minutes.)</span>",\
			"<span class='italics'>You hear violent scraping and struggling.</span>")
			M.adjustBruteLoss(20)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to free yourself!</span>")
				return
		if(!M.buckled)
			return
		untie_mob(M)

/obj/structure/kitchenspike/cross/proc/untie_mob(mob/living/M)
	M.pixel_y = M.get_standard_pixel_y_offset()
	M.adjustBruteLoss(15)
	src.visible_message(text("<span class='danger'>[M] falls free of [src]!</span>"))
	unbuckle_mob(M,force=1)
	M.emote("collapse")
	M.overlays -= image('modular_skyrat/icons/obj/cross.dmi', "lashing")

/obj/structure/kitchenspike/cross/Destroy()
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			untie_mob(L)
	return ..()

#undef VIABLE_MOB_CHECK