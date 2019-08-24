-- ATR PW127 POWER PLANT simulation
-- 2019 @litinoveweedle

---- ATR DATAREFS ----

-- power levers
pl = create_dataref_table("atr/power/pl", "FloatArray")
pl[0] = 0.131
pl[1] = 0.131

-- condition levers
cl = create_dataref_table("atr/power/cl", "FloatArray")
cl[0] = 0.66
cl[1] = 0.66

-- power mgmt knob
pwr_mgmt = create_dataref_table("atr/power/pwr_mgmt", "IntArray")
pwr_mgmt[0] = 0
pwr_mgmt[1] = 0

-- EEC switch and indicator
eec_cmd = create_dataref_table("atr/power/eec_cmd", "IntArray")
eec_cmd[0] = 1
eec_cmd[1] = 1
eec_ind = create_dataref_table("atr/power/eec_ind", "IntArray")
eec_ind[0] = 0
eec_ind[1] = 0

-- EEC target torque
eec_fdau = create_dataref_table("atr/power/eec_fdau", "FloatArray")
eec_fdau[0] = 1
eec_fdau[1] = 1

-- ATPCS button, indicator and test rotaty selector
atpcs_cmd = create_dataref_table("atr/power/atpcs_cmd", "Int")
atpcs_cmd[0] = 1
atpcs_ind = create_dataref_table("atr/power/atpcs_ind", "Int")
atpcs_ind[0] = 0
atpcs_test = create_dataref_table("atr/power/atpcs_test", "Int")
atpcs_test[0] = 0

-- uptrim and autofeather indicators
uptrim_ind = create_dataref_table("atr/power/uptrim_ind", "IntArray")
uptrim_ind[0] = 0
uptrim_ind[1] = 0

-- gust lock lever
gust_lock_cmd = create_dataref_table("atr/power/gust_lock_cmd", "Int")
gust_lock_cmd[0] = 1

-- idle gate lever and indicator
idle_gate_cmd = create_dataref_table("atr/power/idle_gate_cmd", "Int")
idle_gate_cmd[0] = 0
idle_gate_ind = create_dataref_table("atr/power/idle_gate_ind", "Int")
idle_gate_ind[0] = 0

-- propeller brake for hotel mode switch
prop_brake_cmd = create_dataref_table("atr/power/prop_brake_cmd", "Int")
prop_brake_cmd[0] = 0
-- propeller brake indicators [0] - unlock, [1] - ready, [2] - engaged
prop_brake_ind = create_dataref_table("atr/power/prop_brake_ind", "IntArray")
prop_brake_ind[0] = 0
prop_brake_ind[1] = 0
prop_brake_ind[2] = 0

--low prop pitch indicator
low_pitch_ind = create_dataref_table("atr/power/low_pitch_ind", "IntArray")
low_pitch_ind[0] = 0
low_pitch_ind[1] = 0

-- prop synchrophaser
sync_cmd = create_dataref_table("atr/power/sync_cmd", "Int")
sync_cmd[0] = 1
sync_ind = create_dataref_table("atr/power/sync_ind", "Int")
sync_ind[0] = 0

-- PEC switch and indicator
pec_cmd = create_dataref_table("atr/power/pec_cmd", "IntArray")
pec_cmd[0] = 1
pec_cmd[1] = 1
pec_ind = create_dataref_table("atr/power/pec_ind", "IntArray")
pec_ind[0] = 0
pec_ind[1] = 0

--corrected ITT
eng_itt_corr = create_dataref_table("atr/power/eng_itt", "FloatArray")
eng_itt_corr[0] = 0
eng_itt_corr[1] = 0

---- ATR SHARED DATAREFS ----

--CCAS anunicator panel
ccas_ind = dataref_table("atr/ccas/anuciators")



---- XPL DATAREFS ----

-- annunciators
master_warning = dataref_table("sim/cockpit/warnings/annunciators/master_warning")
master_caution = dataref_table("sim/cockpit/warnings/annunciators/master_caution")

on_ground = dataref_table("sim/flightmodel/failures/onground_all")

--commanded/actual prop speed
prop_speed_cmd = dataref_table("sim/cockpit2/engine/actuators/prop_rotation_speed_rad_sec")
prop_speed_act = dataref_table("sim/flightmodel2/engines/prop_rotation_speed_rad_sec")

--prop mode - 0 is feathered, 1 is normal, 2 is beta, 3 is reverse
prop_mode = dataref_table("sim/cockpit2/engine/actuators/prop_mode")

--actual prop pitch
prop_pitch = dataref_table("sim/flightmodel2/engines/prop_pitch_deg")

--prop feather command
prop_feather = dataref_table("sim/cockpit2/engine/actuators/manual_feather_prop")

--prop sync switch
prop_sync = dataref_table("sim/cockpit2/switches/prop_sync_on")

-- only 0 - shut off, 0.5 - low idle , 1 - high idle
eng_mixture = dataref_table("sim/cockpit2/engine/actuators/mixture_ratio")

-- commanded throttle
eng_throttle = dataref_table("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio")
fix_throttle_bug = dataref_table("sim/flightmodel/engine/ENGN_thro_use")

-- engine power produced
eng_power_act = dataref_table("sim/cockpit2/engine/indicators/power_watts")

-- engine torque produced
eng_torque_act = dataref_table("sim/cockpit2/engine/indicators/torque_n_mtr")

-- engine ITT
eng_itt = dataref_table("sim/flightmodel2/engines/ITT_deg_C")

-- engine bleed air
eng_bleed_val = dataref_table("sim/cockpit2/bleedair/actuators/engine_bleed_sov")

-- hotel mode prop brake stop ratio
hotel_mode = dataref_table("sim/cockpit2/switches/hotel_mode")
hotel_mode_ratio = dataref_table("sim/cockpit2/switches/hotel_mode_ratio")

-- hydraulic pressure in blue system
hydraulic_pressure_blue = dataref_table("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")

--fuel_gover = dataref_table("sim/cockpit2/engine/actuators/idle_speed_ratio")
--fadec_on = dataref_table("sim/cockpit/engine/fadec_on")
--reverser_ready = dataref_table("sim/cockpit2/annunciators/reverser_not_ready")
--DataRef("engine_critalt", "sim/aircraft/engine/acf_critalt", "writable")
--DataRef("engine_power", "sim/aircraft2/engine/max_power_limited_watts", "writable")
--engine_critalt = dataref_table("sim/aircraft/engine/acf_critalt")
--engine_power = dataref_table("sim/aircraft2/engine/max_power_limited_watts")

-- nominal propeller speed rad/sec
local prop_speed_max = 125.6637

-- PEC status
local prop_pec = { ["0"] = 1, ["1"] = 1 }

-- last PEC commanded prop speed
local prop_speed_last = { ["0"] = prop_speed_max, ["1"] = prop_speed_max }

-- nominal rated engine power in watts
local eng_power_max = 2050675

-- nominal rated torque in Nm
local eng_torque_max = 960

-- PLA to power curve
local power_pla = {
	["RTO"] = { 37, 0.02, 62, 0.94, 66, 1.00, 68, 1.00, 74, 1.02, 89, 1.02, 91, 1.15, 100, 1.15 },
	["MCT"] = { 37, 0.02, 54, 0.44, 61, 0.79, 65, 0.91, 68, 0.91, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["TO"]  = { 37, 0.02, 54, 0.44, 61, 0.79, 65, 0.90, 68, 0.90, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["CLB"] = { 37, 0.02, 54, 0.44, 63, 0.76, 65, 0.80, 69, 0.80, 75, 0.96, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["CRZ"] = { 37, 0.02, 54, 0.44, 63, 0.76, 65, 0.77, 69, 0.77, 75, 0.96, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 }
}

local base_pla = { 0, 0.884, 2.257, 0.881, 4.643, 0.877, 6.689, 0.871, 8.307, 0.863, 10.09, 0.853, 11.389, 0.844, 12.641, 0.835, 13.996, 0.824, 15.26, 0.812, 16.687, 0.797, 17.923, 0.783, 18.894, 0.769, 19.661, 0.755, 20.038, 0.748, 20.483, 0.742, 21.169, 0.735, 21.745, 0.732, 22.533, 0.732, 23.291, 0.733, 26.676, 0.742, 40.971, 0.778, 42.314, 0.783, 43.725, 0.79, 45.79, 0.803, 48.364, 0.82, 50.452, 0.837, 52.706, 0.853, 54.398, 0.864, 56.409, 0.875, 58.484, 0.884, 61.421, 0.895, 63.895, 0.902, 66.178, 0.907, 69.977, 0.914, 73.871, 0.919, 77.923, 0.923, 87.873, 0.933, 89.259, 0.934, 100, 0.955 }

-- EEC status
local eng_eec = { ["0"] = 1, ["1"] = 1 }

-- last EEC commanded throttle
local eng_throttle_last = { ["0"] = 0, ["1"] = 0 }

-- gust lock state
--local gust_lock = 1

-- idle gate state
--local idle_gate = 0

-- propeller brake state 0 - off, 1 - engaging, 2 - engaged, 3 - releasing, -1 - failed
local prop_brake = 0
-- propeller brake timer
local prop_brake_timer = 0

-- ATPCS status
local eng_atpcs = 0
-- engine uptrim status
local eng_uptrim = { ["0"] = 0, ["1"] = 0 }
-- engine autofeather status
local eng_autofeather = { ["0"] = 0, ["1"] = 0 }
local eng_autofeather_timer = 0

-- PIDs structures
local mixture_pid = {
	[0] = { ["kp"] = 0.4, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_sup"] = 0.2, ["cv_sdw"] = 0.2 },
	[1] = { ["kp"] = 0.4, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_sup"] = 0.2, ["cv_sdw"] = 0.2 }
}
local throttle_pid = {
	[0] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2 },
	[1] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2 }
	--	[1] = { ["kp"] = 0.0000002, ["ki"] = 0.00000007, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.3, ["cv_dw"] = 0.3 }
}



-- init values

--prop_mode[0] = 1
--prop_mode[1] = 1

--prop_speed_cmd[0] = prop_speed_max
--prop_speed_cmd[1] = prop_speed_max

--eng_throttle[0] = 0.637
--eng_throttle[1] = 0.637

hotel_mode_ratio[0] = 0.1
hotel_mode[0] = 0


require "pid"


function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


function eec(ind)
	local pla = round(pl[ind] * 100, 1)
	local cla = round(cl[ind] * 63, 1)

	local temp_prop_mode = 0
	local temp_eng_mix = 0
	local temp_eng_throttle = 0
	local temp_prop_speed = 0

	-- PLA
	if gust_lock == 1 and pla > 34 then
		-- gust lock limit
		pla = 34
	elseif idle_gate == 1 and pla > 37 then
		--idle gate limit
		pla = 37
	end

	--PEC status
	if pec_cmd[ind] == 1 then
		--todo FAILURES
		prop_pec[ind] = 1
		pec_ind[ind] = 0
	else
		prop_pec[ind] = 0
		pec_ind[ind] = 1
	end

	--EEC status
	if eec_cmd[ind] == 1 then
		--todo FAILURES
		eng_eec[ind] = 1
		eec_ind[ind] = 0
	else
		eng_eec[ind] = 0
		eec_ind[ind] = 1
	end

	if pla < 13 then
		-- reverse
		--PEC
		if prop_pec[ind] == 1 then
			--PEC on
			temp_prop_speed = prop_speed_max
			temp_prop_mode = 3
			temp_eng_mix = 1
			temp_eng_throttle = -2.0 - ( ( -1.0 / 13 ) * pla )
		else
			--PEC off - no reverse
			temp_prop_speed = prop_speed_max * 0.708
			temp_prop_mode = 2
			temp_eng_mix = 0.5
			temp_eng_throttle = -1
		end

		--reset EEC frozen (as bellow 52 PLA)
		eng_throttle_last[ind] = 0
	elseif pla < 37 then
		-- beta range
		temp_prop_speed = prop_speed_max * 0.708
		temp_prop_mode = 2
		temp_eng_throttle = -1.0 - ( ( -1.0 / 24 ) * ( pla - 13 ) )

		--EEC
		if eng_eec[ind] == 1 then
			--EEC on
			-- fuel governing - mixture to simulate high and low idle with PID to keep constant Np 70.8%
			mixture_pid[ind]["cv"] = eng_mixture[ind]
			mixture_pid[ind]["pv"] = prop_speed_act[ind]
			mixture_pid[ind]["sp"] = prop_speed_max * 0.708
			pid.run(mixture_pid[ind])
			temp_eng_mix = mixture_pid[ind]["cv"]
		else
			--EEC off
			temp_eng_mix = 0.5 + ( ( 0.5 / 24 ) * ( pla - 13 ) )
		end

		--reset EEC frozen (as bellow 52 PLA)
		eng_throttle_last[ind] = 0
	else
		-- alpha range
		temp_prop_mode = 1
		temp_eng_mix = 1
		eng_mixture[ind] = 1

		--PEC
		if prop_pec[ind] == 1 then
			--PEC on
			if pwr_mgmt[ind] == 0 or pwr_mgmt[ind] == 1 then
				-- TO and MCT
				temp_prop_speed = prop_speed_max
			elseif pwr_mgmt[ind] == 2 or pwr_mgmt[ind] == 3 then
				-- CLB and CRZ
				temp_prop_speed = prop_speed_max * 0.82
			end
			if pla < 59 then
				-- prop speed transition mode
				temp_prop_speed = ( prop_speed_max * 0.708 ) + ( ( ( temp_prop_speed - ( prop_speed_max * 0.708 ) ) / 22 ) * ( pla - 37 ) )
			end
			--keep last value for PEC off
			prop_speed_last[ind] = temp_prop_speed
		else
			--PEC off
			temp_prop_speed = prop_speed_last[ind]
		end

		--EEC
		if eng_eec[ind] == 1 then
			--EEC on / HMU top law
			-- PWR_MGMT
			if pwr_mgmt[ind] == 0 then
				if eng_uptrim[ind] == 1 then
					-- RTO
					power_curve = power_pla["RTO"]
				else
					-- TO
					power_curve = power_pla["TO"]
				end
			elseif pwr_mgmt[ind] == 1 then
				-- MCT
				power_curve = power_pla["MCT"]
			elseif pwr_mgmt[ind] == 2 then
				-- CLB
				power_curve = power_pla["CLB"]
			elseif pwr_mgmt[ind] == 3 then
				-- CRZ
				power_curve = power_pla["CRZ"]
			end

			-- get commanded engine power
			local eng_power_ratio = 0
			for i = 1, #power_curve, 2 do
				if pla == power_curve[i] then
					eng_power_ratio = power_curve[i+1]
					break
				elseif pla < power_curve[i] then
					eng_power_ratio = power_curve[i-1] + ( ( ( power_curve[i+1] - power_curve[i-1] ) / ( power_curve[i] - power_curve[i-2] ) ) * ( pla - power_curve[i-2] ) )
					break
				end
			end

			-- PID to set engine throttle to produce FADEC commanded power
			throttle_pid[ind]["cv"] = eng_throttle[ind]
			throttle_pid[ind]["pv"] = eng_power_act[ind]
			throttle_pid[ind]["sp"] = eng_power_ratio * eng_power_max
			throttle_pid[ind]["ff"] = eng_power_ratio / 1.15
			pid.run(throttle_pid[ind])
			temp_eng_throttle = throttle_pid[ind]["cv"]

			--keep last value for EEC off
			if pla <= 52 then
				--reset EEC frozen (as bellow 52 PLA)
				eng_throttle_last[ind] = 0
			else
				eng_throttle_last[ind] = temp_eng_throttle
			end

			-- FDAU bug
			if pwr_mgmt[ind] == 0 and eng_atpcs ~= 0 and pla > 66 and pla < 68 then
				-- TO reserved power
				power_curve = power_pla["RTO"]
			end

			-- get PLA notch engine power
			local eng_power_ratio = 0
			for i = 1, #power_curve, 2 do
				if pla == power_curve[i] then
					eng_power_ratio = power_curve[i+1]
					break
				elseif pla < power_curve[i] then
					eng_power_ratio = power_curve[i-1] + ( ( ( power_curve[i+1] - power_curve[i-1] ) / ( power_curve[i] - power_curve[i-2] ) ) * ( 67 - power_curve[i-2] ) )
					break
				end
			end
			-- limit max power by ITT based on OAT and air density/pressure
			-- TODO lookup in power tables and/or provide sensible calculation???
			if eng_bleed_val[ind] == 1 then

			else

			end

			--calculate maximum notch torque from power and prop speed for given mode
			if pwr_mgmt[ind] == 0 or pwr_mgmt[ind] == 1 then
				-- TO and MCT
				eec_fdau[ind] = eng_power_ratio
			elseif pwr_mgmt[ind] == 2 or pwr_mgmt[ind] == 3 then
				-- CLB and CRZ
				eec_fdau[ind] = eng_power_ratio / 0.82
			end
		else
			if eng_throttle_last[ind] == 0 then
				--EEC off / HMU base law
				power_curve = base_pla
				-- get commanded engine throttle
				local eng_power_ratio = 0
				for i = 1, #power_curve, 2 do
					if pla == power_curve[i] then
						temp_eng_throttle = power_curve[i+1]
						break
					elseif pla < power_curve[i] then
						temp_eng_throttle = power_curve[i-1] + ( ( ( power_curve[i+1] - power_curve[i-1] ) / ( power_curve[i] - power_curve[i-2] ) ) * ( pla - power_curve[i-2] ) )
						break
					end
				end
			else
				--EEC frozen
				temp_eng_throttle = eng_throttle_last[ind]
				if pla <= 52 then
					--reset EEC frozen (as bellow 52 PLA)
					eng_throttle_last[ind] = 0
				end
			end
		end
		-- to fix 11.35 reverse runaway bug which shall be fixed in 11.40
		fix_throttle_bug[ind] = temp_eng_throttle
	end

	--CLA
	if cla < 1.7 then
		-- shutdown + feather
		temp_prop_mode = 0
		temp_eng_mix = 0
		prop_feather[ind] = 1
	elseif cla < 25.7 or eng_autofeather[ind] == 2 then
		-- feather
		temp_prop_mode = 0
		--temp_eng_mix = 0.5
		prop_feather[ind] = 1
	elseif cla < 33.7 then
		-- NP governing cancel
		temp_prop_mode = 2
		--temp_eng_mix = 0.5
		prop_feather[ind] = 0
	elseif cla < 55 then
		-- CL AUTO
		prop_feather[ind] = 0
	else
		-- NP 100% OVRD
		temp_prop_speed = prop_speed_max
		prop_feather[ind] = 0
	end

	--propeller brake
	if ind == 1 then
		pbrake(pla, cla)
	end

	--low pitch
	if prop_pitch[ind] < 14 then
		low_pitch_ind[ind] = 1
		if on_ground == 0 then

		end
	else
		low_pitch_ind[ind] = 1
	end

	prop_mode[ind] = temp_prop_mode
	prop_speed_cmd[ind] = temp_prop_speed
	eng_throttle[ind] = temp_eng_throttle
	eng_mixture[ind] = temp_eng_mix
end


function pbrake(pla, cla)
	-- prop break ready
	if on_ground[0] == 1 and cla < 25.7 and pla <= 35 and hydraulic_pressure_blue[0] > 2000 then
		prop_brake_ind[1] = 1
	else
		prop_brake_ind[1] = 0
	end

	if prop_brake > 0 and ( pla > 60 or hydraulic_pressure_blue[0] < 1500 ) then
		--prop is failing
		if prop_brake == 1 or prop_brake == 2 then
			hotel_mode[0] = 0
		end
		prop_brake = -1
		prop_brake_ind[0] = 1
		prop_brake_ind[2] = 0
	end

	if prop_brake_cmd[0] == 1 then
		--command to engage
		if prop_brake_ind[1] == 1 then
			--prop brake ready
			if prop_brake == 0 then
				-- start engage
				hotel_mode[0] = 1
				prop_brake_timer = os.clock()
				prop_brake = 1
				prop_brake_ind[0] = 1
				prop_brake_ind[2] = 0
			elseif prop_brake == 1 and prop_speed_act[1] == 0 then
				-- prop break engaged
				prop_brake_timer = 0
				prop_brake = 2
				prop_brake_ind[0] = 0
				prop_brake_ind[2] = 1
			end
		else
			--prop not ready
			master_warning[0] = 1
		end
	elseif prop_brake == 1 or prop_brake == 2 then
		--stop prop brake engage / release prop brake
		hotel_mode[0] = 0
		prop_brake_timer = os.clock()
		prop_brake = 3
		prop_brake_ind[0] = 1
	elseif prop_brake == 3 then
		-- unlocking
		if prop_speed_act[1] > prop_speed_max * 0.2 then
			-- unlocked
			prop_brake_timer = 0
			prop_brake = 0
			prop_brake_ind[0] = 0
			prop_brake_ind[2] = 0
		end
	else
		-- prop brake off
		prop_brake = 0
		prop_brake_timer = 0
		prop_brake_ind[0] = 0
		prop_brake_ind[2] = 0
	end

	if ( prop_brake == 1 or prop_brake == 3 ) and prop_brake_timer and os.clock() - prop_brake_timer > 15 then
		-- not fully lock or unlock in 15sec
		master_warning[0] = 1
	end
end


function atpcs()
	--ATPCS test/arming/disarming conditions
	if atpcs_test[0] ~= 0 and atpcs_cmd[0] == 1 and pec_cmd[0] == 1 and pec_cmd[1] == 1 and round(cl[0] * 63, 1) < 1.7 and round(cl[1] * 63, 1) < 1.7 and math.abs(round(pl[0] * 100, 1) - 13) < 1 and math.abs(round(pl[1] * 100, 1) - 13) < 1 then
		--ATPCS test
		if atpcs_test[0] == -1 then
			atpcs_ind[0] = 1
			eng_autofeather_timer = 0
		elseif atpcs_test[0] == -2 then
			uptrim_ind[1] = 1
			if eng_autofeather_timer ~= 0 then
				if eng_autofeather_timer < os.clock() then
					atpcs_ind[0] = 0
				end
			else
				eng_autofeather_timer = os.clock() + 2.15
			end
		elseif atpcs_test[0] == 1 then
			atpcs_ind[0] = 1
			eng_autofeather_timer = 0
		elseif atpcs_test[0] == 2 then
			uptrim_ind[0] = 1
			if eng_autofeather_timer ~= 0 then
				if eng_autofeather_timer < os.clock() then
					atpcs_ind[0] = 0
				end
			else
				eng_autofeather_timer = os.clock() + 2.15
			end
		end
		return
	elseif atpcs_cmd[0] == 1 and pwr_mgmt[0] == 0 and pwr_mgmt[1] == 0 and eng_autofeather[0] ~= 2 and eng_autofeather[1] ~= 2 and round(pl[0] * 100, 1) > 49 and round(pl[1] * 100, 1) > 49 then
		if eng_torque_act[0] > eng_torque_max * 0.46 and eng_torque_act[1] > eng_torque_max * 0.46 then
			--arming conditions met
			if on_ground[0] == 1 then
				--autofeather + uptrim armed
				eng_atpcs = 2
			elseif eng_atpcs ~= 2 then
				--autofeather armed
				eng_atpcs = 1
			end
		elseif eng_atpcs ~= 0 and eng_torque_act[0] < eng_torque_max * 0.46 and eng_torque_act[1] < eng_torque_max * 0.46 then
			--disarm conditions met
			eng_atpcs = 0
		end
	elseif eng_atpcs ~= 0 then
		--disarm conditions met
		eng_atpcs = 0
	end

	--ATPCS triggering conditions
	if eng_atpcs ~= 0 then
		if eng_autofeather_timer ~= 0 then
			if eng_autofeather_timer < os.clock() then
				--trigger autofeather
				if eng_autofeather[0] == 1 then
					eng_autofeather[0] = 2
				elseif eng_autofeather[1] == 1 then
					eng_autofeather[1] = 2
				end
				eng_autofeather_timer = 0
			end
		elseif eng_torque_act[0] < eng_torque_max * 0.18 then
			--schedulle autofeather
			eng_autofeather[0] = 1
			eng_autofeather_timer = os.clock() + 2.15
			if eng_atpcs == 2 then
				--trigger uptrim
				eng_uptrim[1] = 1
			end
		elseif eng_torque_act[1] < eng_torque_max * 0.46 then
			--schedulle autofeather
			eng_autofeather[1] = 1
			eng_autofeather_timer = os.clock() + 2.15
			if eng_atpcs == 2 then
				--trigger uptrim
				eng_uptrim[0] = 1
			end
		end
	else
		eng_autofeather_timer = 0
	end

	--reset triggers
	if pwr_mgmt[0] ~= 0 then
		--reset uptrim and autofeather
		eng_uptrim[0] = 0
		eng_autofeather[0] = 0
	end
	if pwr_mgmt[1] ~= 0 then
		--reset uptrim and autofeather
		eng_uptrim[1] = 0
		eng_autofeather[1] = 0
	end

	--indicators
	atpcs_ind[0] = eng_atpcs
	uptrim_ind[0] = eng_uptrim[0]
	uptrim_ind[1] = eng_uptrim[1]
end


function sync()
	if sync_cmd[0] == 0 then
		--prop synchrophazer off
		prop_sync[0] = 0
		sync_ind[0] = 1
	elseif pwr_mgmt[0] ~= 0 and pwr_mgmt[1] ~= 0 and prop_speed_act[0] > prop_speed_max * 0.7 and prop_speed_act[1] > prop_speed_max * 0.7 then
		--prop synchrophazer on
		prop_sync[0] = 1
		if math.abs( prop_speed_act[0] - prop_speed_act[1] ) / prop_speed_max > 0.025 then
			--prop synchrophazer out of authority
			sync_ind[0] = 2
		else
			sync_ind[0] = 0
		end
	else
		prop_sync[0] = 0
		sync_ind[0] = 0
	end
end


function itt(ind)
	eng_itt_corr[ind] = eng_itt[ind] * ( 0.6867 + ( eng_itt[ind] * 0.000148 ) )
end


function power()
	--idle gate and gust lock function
	gust_lock = gust_lock_cmd[0]
	if on_ground[0] or idle_gate_cmd[0] then
		idle_gate = 0
	else
		idle_gate = 1
	end

	--atpcs function
	atpcs()

	--prop synchrophazer function
	sync()

	--eec functions
	eec(0)
	eec(1)

	--itt function
	itt(0)
	itt(1)
end


do_every_frame("power()")

