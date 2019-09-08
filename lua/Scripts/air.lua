-- ATR AIR simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

-- used only for compatibility reason, set off
set("sim/cockpit2/bleedair/actuators/pack_center", 0)

pack_left[0] = 1
pack_right[0] = 1


function bleed(ind)
	local temp_bleed = 0
	
	if bleed_cmd[ind] == 1 then
		temp_bleed = 1
	end
		
	if eng_bleed_val[ind] == 0 and eng_n2[ind] > 40 then
		temp_bleed = 1
	elseif eng_bleed_val[ind] == 1 and eng_n2[ind] > 35 then
		temp_bleed = 0
	end

	-- bleed off on uptrim
	if ind == 0 and uptrim_ind[1] == 1 then
		temp_bleed = 0
	elseif ind == 1 and uptrim_ind[0] == 1 then
		temp_bleed = 0
	end
	
	-- bleed on left eng off when in hotel mode
	if ind == 0 and prop_brake_cmd[0] == 1 then
		temp_bleed = 0
	end

	eng_bleed_val[ind] = temp_bleed
	--eng_bleed_ind[ind] = 
end




function air()
	bleed(0)
	bleed(1)
	
	-- open crossfeed as it is needed for wing antice, but shut corresponding pack
	if eng_bleed_val[0] == 1 and eng_bleed_val[1] == 0 and duct_press_center == 1 and duct_press_left == 1 then
		pack_right[0] = 0
		duct_left_val[0] = 1
		duct_right_val[0] = 1
	elseif eng_bleed_val[0] == 0 and eng_bleed_val[1] == 1 and duct_press_center == 1 and duct_press_right == 1 then
		pack_left[0] = 0
		duct_left_val[0] = 1
		duct_right_val[0] = 1
	else
		duct_left_val[0] = 0
		duct_right_val[0] = 0
	end
end

do_often("air()")

