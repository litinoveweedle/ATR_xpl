-- ATPCS button, indicator and test rotaty selector
bleed_cmd = create_dataref_table("atr/air/bleed_cmd", "Int")
bleed_cmd[0] = 1
bleed_ind = create_dataref_table("atr/air/bleed_ind", "Int")
bleed_ind[0] = 0




-- pressurization packs, off or on
pack_center = dataref_table("sim/cockpit2/bleedair/actuators/pack_center")
pack_left = dataref_table("sim/cockpit2/bleedair/actuators/pack_left")
pack_right = dataref_table("sim/cockpit2/bleedair/actuators/pack_right")

duct_press_center = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_center")
duct_press_left = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_left")
duct_press_right = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_right")

duct_left_val = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_left")
duct_right_val = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_right")

-- engine bleed air
eng_bleed_val = dataref_table("sim/cockpit2/bleedair/actuators/engine_bleed_sov")


eng_n2 = dataref_table("sim/cockpit2/engine/indicators/N2_percent")



prop_brake_cmd = create_dataref_table("atr/power/prop_brake_cmd", "Int")


-- used only for compatibility reason, set off
pack_center[0] = 0
pack_left[0] = 1
pack_right[0] = 1


uptrim_ind = create_dataref_table("atr/power/uptrim_ind", "IntArray")


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

