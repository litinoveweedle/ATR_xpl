-- ATR AIR simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

local bleed_pressure = { [0] = 0, [1] = 0 }
local pack_pressure = { [0] = 0, [1] = 0 }
local bleed_loss = { [0] = 0, [1] = 0 }
local pressurization = { ["takeoff_alt"] = nil, ["cabin_alt"] = nil, ["landing_elev"] = 0 }

local cabin_alt_pid = { ["kp"] = 1, ["ki"] = 0, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = -500, ["cv_max"] = 500, ["cv_up"] = 100, ["cv_dw"] = 100, ["log"] = 0 }

local cabin_rate_pid = { ["kp"] = -0.025, ["ki"] = -0.005, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.1, ["cv_dw"] = 0.1, ["log"] = 1 }


-- center pack used only for compatibility reason, set off
set("sim/cockpit2/bleedair/actuators/pack_center", 0)
-- engine overrides
--set( "sim/operation/override/override_pressurization", 1 )


function bleed(ind)

	if pdref["power"]["fire_handle"][ind] == 0 and xdref["eng_nh"][ind] > 40 then
		xdref["eng_airextr_val"][ind] = 1
		bleed_pressure[ind] = 1
	elseif pdref["power"]["fire_handle"][ind] == 1 or ( xdref["eng_airextr_val"][ind] == 1 and xdref["eng_nh"][ind] < 35 ) then
		xdref["eng_airextr_val"][ind] = 0
		bleed_pressure[ind] = 0
	end

	-- bleed valve off
	if pdref["air"]["bleed_valve_cmd"][ind] == 0 then
		bleed_pressure[ind] = 0
	end

	-- engine uptrim
	if ind == 0 and pdref["power"]["uptrim_ind"][1] == 1 then
		bleed_pressure[ind] = 0
	elseif ind == 1 and pdref["power"]["uptrim_ind"][0] == 1 then
		bleed_pressure[ind] = 0
	end

	-- bleed on left eng off when in hotel mode
	if ind == 1 and pdref["power"]["prop_brake_ind"][2] == 1 then
		bleed_pressure[ind] = 0
	end

	-- bleed valve indicator
	if pdref["air"]["bleed_valve_cmd"][ind] == 1 and bleed_pressure[ind] == 1 then
		pdref["air"]["bleed_valve_ind"][ind] = 0
	elseif pdref["air"]["bleed_valve_cmd"][ind] == 0 then
		pdref["air"]["bleed_valve_ind"][ind] = 2
	else
		pdref["air"]["bleed_valve_ind"][ind] = 1
	end
end


function pack(ind)

	-- pack valve indicator
	if pdref["air"]["pack_valve_cmd"][ind] == 1 and pack_pressure[ind] == 1 then
		pdref["air"]["pack_valve_ind"][ind] = 0
		xdref["pack_valve"][ind][0] = 1
		-- calculate bleed air loss from engine
		if pdref["air"]["pack_flow_cmd"] == 1 then
			bleed_loss[ind] = 30
		else
			bleed_loss[ind] = 20
		end
	elseif pdref["air"]["pack_valve_cmd"][ind] == 0 then
		pdref["air"]["pack_valve_ind"][ind] = 2
		xdref["pack_valve"][ind][0] = 0
	else
		pdref["air"]["pack_valve_ind"][ind] = 1
		xdref["pack_valve"][ind][0] = 0
	end


end


function cabin()

	if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
		-- update takeoff altitude
		pressurization["takeoff_alt"] = pdref["dadc"]["alt"][0]
		if pressurization["cabin_alt"] ~= nil and xdref["outflow_valve"][0] == 1 then
			-- after landing outflow valve fully open
			pressurization["cabin_alt"] = nil
		end
	else
		if pdref["dadc"]["alt"][0] < 5000 then
			pressurization["cabin_alt"] = ( 0.3 * pdref["dadc"]["alt"][0] ) - 1500
		elseif pdref["dadc"]["alt"][0] < 15000 then
			pressurization["cabin_alt"] = ( 0.275 * pdref["dadc"]["alt"][0] ) - 1375
		elseif pdref["dadc"]["alt"][0] < 20000 then
			pressurization["cabin_alt"] = ( 0.29 * pdref["dadc"]["alt"][0] ) - 1600
		else
			pressurization["cabin_alt"] = ( 0.508 * pdref["dadc"]["alt"][0] ) - 5960
		end
		local landing_alt
		if pressurization["takeoff_alt"] ~= nil and pressurization["takeoff_alt"] + 3500 < pdref["dadc"]["alt"][0] then
			landing_alt = pressurization["takeoff_alt"]
		else
			pressurization["takeoff_alt"] = nil
			landing_alt = pressurization["landing_elev"]
		end
		if landing_alt - 300 > pressurization["cabin_alt"] then
			pressurization["cabin_alt"] = landing_alt - 300
		end
	end

	if pdref["air"]["press_ditch_cmd"][0] == 1 then
		-- outflow valve fully closed
		--xdref["outflow_valve"][0] = 0
	elseif pdref["air"]["press_mode_cmd"][0] == 0 then
		-- automatic mode
		if pdref["air"]["press_dump_cmd"][0] == 1 then
			-- outflow valve fully open
			--xdref["outflow_valve"][0] = 1
		elseif pressurization["cabin_alt"] ~= nil then
			if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
				cabin_alt_pid["sp"] = 550
			else
				-- set maximum cabin climb rate
				if pdref["dadc"]["alt"][0] < 20000 then
					cabin_alt_pid["cv_max"] = 550
				else
					cabin_alt_pid["cv_max"] = 620
				end
				-- set min cabin descent rate
				if pdref["air"]["press_fast_cmd"][0] == 1 then
					cabin_alt_pid["cv_min"] = -500
				else
					cabin_alt_pid["cv_min"] = -400
				end
				-- PID to calculate desired cabin rate
				cabin_alt_pid["cv"] = xdref["cabin_rate_ind"][0]
				cabin_alt_pid["pv"] = xdref["cabin_alt_ind"][0]
				cabin_alt_pid["sp"] = pressurization["cabin_alt"]
				pid.run(cabin_alt_pid)
				-- PID to calculate outflow valve position
				cabin_rate_pid["sp"] = cabin_alt_pid["cv"]
			end
			--cabin_rate_pid["cv"] = xdref["outflow_valve"][0]
			--cabin_rate_pid["pv"] = xdref["cabin_rate"][0]
			--pid.run(cabin_rate_pid)
			--xdref["outflow_valve"][0] = cabin_rate_pid["cv"]
			xdref["cabin_alt_cmd"][0] = pressurization["cabin_alt"]
			xdref["cabin_rate_cmd"][0] = math.abs(cabin_alt_pid["cv"])
		else
			-- outflow valve fully open
			--xdref["outflow_valve"][0] = 1
		end
	else
		-- manual mode
		--cabin_rate_pid["cv"] = xdref["outflow_valve"][0]
		--cabin_rate_pid["pv"] = xdref["cabin_rate_ind"][0]
		--cabin_rate_pid["sp"] = pdref["air"]["press_rate_cmd"][0]
		--pid.run(cabin_rate_pid)
		--xdref["outflow_valve"][0] = cabin_rate_pid["cv"]
		--xdref["cabin_rate_cmd"][0] = pdref["air"]["press_rate_cmd"][0]
		--manual cabin alt set
		xdref["cabin_alt_cmd"][0] = xdref["cabin_alt_ind"] + pdref["air"]["press_rate_cmd"][0]
		xdref["cabin_rate_cmd"][0] = math.abs(pdref["air"]["press_rate_cmd"][0])
	end

	-- test mode
	if pdref["air"]["test_elev_cmd"][0] == 1 then
		if pdref["air"]["landing_elev_ind"][0] == 18800 then
			pdref["air"]["landing_elev_ind"][0] = -8800
		else
			pdref["air"]["landing_elev_ind"][0] = 18800
		end
		if pdref["air"]["press_mode_cmd"][0] == 0 then
			pdref["air"]["press_mode_ind"][0] = 2
		else
			pdref["air"]["press_mode_ind"][0] = 3
		end
	else
		pdref["air"]["landing_elev_ind"][0] = pressurization["landing_elev"]
		if pdref["air"]["press_mode_cmd"][0] == 0 then
			pdref["air"]["press_mode_ind"][0] = 0
		else
			pdref["air"]["press_mode_ind"][0] = 1
		end
	end
end


function air()
	-- simulate bleed valves
	bleed(0)
	bleed(1)

	-- open XPL isolation valves for ATR anti ice
	if xdref["eng_airextr_val"][0] ~= xdref["eng_airextr_val"][1] == 0 then
		xdref["isol_valve"][0][0] = 1
		xdref["isol_valve"][1][0] = 1
	else
		xdref["isol_valve"][0][0] = 0
		xdref["isol_valve"][1][0] = 0
	end

	if bleed_pressure[0] == 1 and bleed_pressure[1] == 1 then
		-- both bleed valve open and duct pressurized
		pdref["air"]["cross_valve_ind"][0] = 0
		pack_pressure[0] = 1
		pack_pressure[1] = 1
	elseif bleed_pressure[0] == 1 then
		-- engine 1 bleed valve open and duct pressurized
		if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
			-- cross feed valve could open on the ground
			pdref["air"]["cross_valve_ind"][0] = 1
			pack_pressure[0] = 1
			pack_pressure[1] = 1
		else
			-- cross feed valve is closed in flight
			pdref["air"]["cross_valve_ind"][0] = 0
			pack_pressure[0] = 1
			pack_pressure[1] = 0
		end
	elseif bleed_pressure[1] == 1 then
		-- engine2 bleed valve open and duct pressurized
		if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
			-- cross feed valve could open on the ground
			pdref["air"]["cross_valve_ind"][0] = 1
			pack_pressure[0] = 1
			pack_pressure[1] = 1
		else
			-- cross feed valve is closed in flight
			pdref["air"]["cross_valve_ind"][0] = 0
			pack_pressure[0] = 0
			pack_pressure[1] = 1
		end
	else
		-- both bleed valve closed or no pressure
		pdref["air"]["cross_valve_ind"][0] = 0
		pack_pressure[0] = 0
		pack_pressure[1] = 0
	end

	-- simulate pack valves
	pack(0)
	pack(1)

	--TODO bleead air ratio for engine power
end

do_often("air()")
do_every_frame("cabin()")

