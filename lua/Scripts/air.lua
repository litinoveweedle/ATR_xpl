-- ATR AIR simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

-- used only for compatibility reason, set off
set("sim/cockpit2/bleedair/actuators/pack_center", 0)

xdref["pack_left"][0] = 1
xdref["pack_right"][0] = 1


function bleed(ind)
	local temp_bleed = 0
	
	if pdref["air"]["bleed_cmd"][ind] == 1 then
		temp_bleed = 1
	end
		
	if xdref["eng_bleed_val"][ind] == 0 and xdref["eng_n2"][ind] > 40 then
		temp_bleed = 1
	elseif xdref["eng_bleed_val"][ind] == 1 and xdref["eng_n2"][ind] > 35 then
		temp_bleed = 0
	end

	-- bleed off on uptrim
	if ind == 0 and pdref["power"]["uptrim_ind"][1] == 1 then
		temp_bleed = 0
	elseif ind == 1 and pdref["power"]["uptrim_ind"][0] == 1 then
		temp_bleed = 0
	end
	
	-- bleed on left eng off when in hotel mode
	if ind == 0 and pdref["power"]["prop_brake_cmd"][0] == 1 then
		temp_bleed = 0
	end

	xdref["eng_bleed_val"][ind] = temp_bleed
	--eng_bleed_ind[ind] = 
end




function air()
	bleed(0)
	bleed(1)
	
	-- open crossfeed as it is needed for wing antice, but shut corresponding pack
	if xdref["eng_bleed_val"][0] == 1 and xdref["eng_bleed_val"][1] == 0 and xdref["duct_press_center"][0] == 1 and xdref["duct_press_left"][0] == 1 then
		xdref["pack_right"][0] = 0
		xdref["duct_left_val"][0] = 1
		xdref["duct_right_val"][0] = 1
	elseif xdref["eng_bleed_val"][0] == 0 and xdref["eng_bleed_val"][1] == 1 and xdref["duct_press_center"][0] == 1 and xdref["duct_press_right"][0] == 1 then
		xdref["pack_left"][0] = 0
		xdref["duct_left_val"][0] = 1
		xdref["duct_right_val"][0] = 1
	else
		xdref["duct_left_val"][0] = 0
		xdref["duct_right_val"][0] = 0
	end
end

do_often("air()")

