-- ATR PW127 POWER PLANT simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

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
local gust_lock = 1

-- idle gate state
local idle_gate = 0

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


local prop_beta = { ["reverse"] = -14, ["beta"] = 2, ["alpha"] = 14, ["high"] = 50, ["feather"] = 78.5 }


-- PIDs structures

-- controls TQ by throttle at alpha with EEC on
local eec_power_pid = {
	[0] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 },
	[1] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 }
}
-- controls NH by throttle at beta with EEC off
local hmu_nhspeed_pid = {
	[0] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 },
	[1] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 }
}
-- controls NP by pitch at alpha
local pvm_pitch_pid = {
	[0] = { ["kp"] = -0.5, ["ki"] = -0.3, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 36, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 },
	[1] = { ["kp"] = -0.5, ["ki"] = -0.3, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 36, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 }
}
-- controls NP by throttle at beta and reverse
local eec_propspeed_pid = {
	[0] = { ["kp"] = 0.025, ["ki"] = 0.007, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.05, ["cv_max"] = 0.6, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 1 },
	[1] = { ["kp"] = 0.025, ["ki"] = 0.007, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.05, ["cv_max"] = 0.6, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 }
}
-- limits prop pitch speed change
local prop_pitch_gain = {
	[0] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = -14, ["out_max"] = 78.5, ["out_up"] = 7, ["out_dw"] = 7, ["log"] = 0 },
	[1] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = -14, ["out_max"] = 78.5, ["out_up"] = 7, ["out_dw"] = 7, ["log"] = 0 },
}
-- limits pla speed change
local pla_gain = {
	[0] = { ["k"] = 100, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 100, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
	[1] = { ["k"] = 100, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 100, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
}
-- limits cla speed change
local cla_gain = {
	[0] = { ["k"] = 66, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 66, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
	[1] = { ["k"] = 66, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 66, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
}

-- init values
hotel_mode[0] = 0

--engine overrides
set( "sim/operation/override/override_throttles", 1 )
set( "sim/operation/override/override_prop_mode", 1 )
set( "sim/operation/override/override_prop_pitch", 1 )
set( "sim/operation/override/override_mixture", 1 )
--set( "sim/operation/override/override_fuel_flow", 1 )
set( "sim/operation/override/override_itt_egt", 1 )

--set idle ratios to low values
set( "sim/aircraft2/engine/low_idle_ratio", 0.1 )
set( "sim/aircraft2/engine/high_idle_ratio", 0.1 )

--hotel mode prop deceleration ratio
set("sim/cockpit2/switches/hotel_mode_ratio", 0.1)


require "pid"
require "gain"

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


function lookup_table(input, table)
	local result = 0
	for i = 1, #table, 2 do
		if input == table[i] then
			result = table[i+1]
			break
		elseif input < table[i] then
			if i == 1 then
				result = table[i+1]
			else
				result = table[i-1] + ( ( ( table[i+1] - table[i-1] ) / ( table[i] - table[i-2] ) ) * ( input - table[i-2] ) )
			end
			break
		end
	end
	return result
end


function eec(ind)
	-- PLA
	if gust_lock == 1 and pl[ind] > 0.34 then
		-- gust lock limit
		pla_gain[ind]["in"] = 0.34
	elseif idle_gate == 1 and pl[ind] < 0.37 then
		--idle gate limit
		pla_gain[ind]["in"] = 0.37
	else
		pla_gain[ind]["in"] = pl[ind]
	end
	gain.run(pla_gain[ind])
	local pla = pla_gain[ind]["out"]

	-- CLA
	cla_gain[ind]["in"] = cl[ind]
	gain.run(cla_gain[ind])
	local cla = cla_gain[ind]["out"]

	local temp_prop_mode = 0
	local temp_prop_pitch = 0
	local temp_eng_mixture = 0
	local temp_eng_throttle = 0

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

	--PEC
	if cla >= 55 then
		-- NP 100% OVRD
		temp_prop_speed = prop_speed_max
	elseif prop_pec[ind] == 1 then
		--PEC on
		if pwr_mgmt[ind] == 0 or pwr_mgmt[ind] == 1 then
			-- TO and MCT
			temp_prop_speed = prop_speed_max
		elseif pwr_mgmt[ind] == 2 or pwr_mgmt[ind] == 3 then
			-- CLB and CRZ
			temp_prop_speed = prop_speed_max * 0.82
		end
		--keep last value for PEC off
		prop_speed_last[ind] = temp_prop_speed
	else
		--PEC off
		temp_prop_speed = prop_speed_last[ind]
	end
	if pla < 13 then
		temp_prop_speed = prop_speed_max * 0.91
	elseif pla < 37 then
		temp_prop_speed = prop_speed_max * 0.708
	elseif pla < 59 then
		-- prop speed transition mode
		temp_prop_speed = ( prop_speed_max * 0.708 ) + ( ( ( temp_prop_speed - ( prop_speed_max * 0.708 ) ) / 22 ) * ( pla - 37 ) )
	end

	--PVM
	if cla < 1.7 then
		temp_prop_mode = 0
		temp_eng_mixture = 0
		prop_pitch_gain[ind]["in"] = 78.5
		prop_feather[ind] = 1
	elseif cla < 25.7 or eng_autofeather[ind] == 2 then
		--feather
		temp_prop_mode = 0
		temp_eng_mixture = 0.5
		prop_pitch_gain[ind]["in"] = 78.5
		prop_feather[ind] = 1
	elseif pla < 13 then
		-- reverse
		temp_prop_mode = 3
		prop_pitch_gain[ind]["in"] = prop_beta["reverse"] + ( ( math.abs(prop_beta["reverse"] - prop_beta["beta"]) / 13 ) * ( pla ) )
		temp_eng_mixture = 1
	elseif pla < 37 then
		-- ground beta
		temp_prop_mode = 2
		temp_eng_mixture = 0.5
		prop_pitch_gain[ind]["in"] = prop_beta["beta"] + ( ( math.abs(prop_beta["beta"] - prop_beta["alpha"]) / 24 ) * ( pla - 13 ) )
	elseif pla < 45 then
		-- flight beta
		temp_prop_mode = 2
		prop_pitch_gain[ind]["in"] = prop_beta["alpha"]
		temp_eng_mixture = 0.5
	else
		-- alpha
		temp_prop_mode = 1
		-- PID to set prop pitch to keep constant prop speed
		pvm_pitch_pid[ind]["cv"] = prop_pitch[ind] - prop_beta["alpha"]
		pvm_pitch_pid[ind]["pv"] = prop_speed[ind]
		pvm_pitch_pid[ind]["sp"] = temp_prop_speed
		pvm_pitch_pid[ind]["ff"] = ( ( eng_power[ind] / temp_prop_speed ) ^ ( 1 / 2.8 ) ) - prop_beta["alpha"]
		pid.run(pvm_pitch_pid[ind])
		prop_pitch_gain[ind]["in"] = prop_beta["alpha"] + pvm_pitch_pid[ind]["cv"]
		temp_eng_mixture = 1
	end
	--limit prop pitch rate
	gain.run(prop_pitch_gain[ind])
	temp_prop_pitch = prop_pitch_gain[ind]["out"]

	--EEC / HMU
	if eng_eec[ind] == 1 and cla > 33.7 and eng_autofeather[ind] ~= 2 then
		-- PWR_MGMT
		local power_curve
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

		--EEC on / HMU top law
		if pla < 45 then
			-- fuel governing - keep constant Np
			eec_propspeed_pid[ind]["cv"] = eng_throttle[ind]
			eec_propspeed_pid[ind]["pv"] = prop_speed[ind]
			eec_propspeed_pid[ind]["sp"] = temp_prop_speed
			--eec_propspeed_pid[ind]["ff"] = ( temp_prop_speed * math.sin(math.rad(temp_prop_pitch)) ) / 70
			eec_propspeed_pid[ind]["ff"] = 0
			pid.run(eec_propspeed_pid[ind])
			temp_eng_throttle = eec_propspeed_pid[ind]["cv"]
		else
			-- get commanded engine power
			local eng_power_ratio = lookup_table(pla, power_curve)

			-- limit max power by ITT based on OAT and pressure altitude
			-- TODO lookup in power tables and/or provide sensible calculation???
			if eng_bleed_val[ind] == 1 then
			--air_pressure
			--air_temperature
			else

			end
			
			-- PID to set engine throttle to produce FADEC commanded power
			eec_power_pid[ind]["cv"] = eng_throttle[ind]
			eec_power_pid[ind]["pv"] = eng_power[ind]
			eec_power_pid[ind]["sp"] = eng_power_ratio * eng_power_max
			eec_power_pid[ind]["ff"] = eng_power_ratio / 1.15
			pid.run(eec_power_pid[ind])
			temp_eng_throttle = eec_power_pid[ind]["cv"]
		end

		--keep last value for EEC off
		if pla <= 52 then
			--reset EEC frozen (as bellow 52 PLA)
			eng_throttle_last[ind] = 0
		else
			eng_throttle_last[ind] = temp_eng_throttle
		end

		-- FDAU bug - find max torque for given PWR MGMT mode
		if pwr_mgmt[ind] == 0 and eng_atpcs ~= 0 then
			-- TO reserved power
			power_curve = power_pla["RTO"]
		end

		-- get PLA notch engine power
		local eng_power_ratio = lookup_table(67, power_curve)

		-- limit FDAU power by ITT based on OAT and pressure altitude
		-- TODO lookup in power tables and/or provide sensible calculation???
		--air_pressure
		--air_temperature

		--calculate FDAU torque from power and prop speed for given mode
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
			-- get commanded engine NH
			local eng_nh_ratio = lookup_table(pla, base_pla)

			-- PID to set engine throttle to produce NH
			hmu_nhspeed_pid[ind]["cv"] = eng_throttle[ind]
			hmu_nhspeed_pid[ind]["pv"] = eng_nh[ind]
			hmu_nhspeed_pid[ind]["sp"] = eng_nh_ratio * 100
			hmu_nhspeed_pid[ind]["ff"] = ( eng_nh_ratio - 0.7 ) * 0.3
			pid.run(hmu_nhspeed_pid[ind])
			temp_eng_throttle = hmu_nhspeed_pid[ind]["cv"]
		else
			--EEC frozen
			temp_eng_throttle = eng_throttle_last[ind]
			if pla <= 52 then
				--reset EEC frozen (as bellow 52 PLA)
				eng_throttle_last[ind] = 0
			end
		end
	end

	--propeller brake
	if ind == 1 then
		pbrake(pla, cla)
	end

	--low pitch
	if prop_pitch[ind] < 14 then
		low_pitch_ind[ind] = 1
		if on_ground[1] == 0 and on_ground[2] == 0 then

		end
	else
		low_pitch_ind[ind] = 1
	end

	prop_mode[ind] = temp_prop_mode
	prop_pitch[ind] = temp_prop_pitch
	eng_throttle[ind] = temp_eng_throttle
	eng_mixture[ind] = temp_eng_mixture
end


function pbrake(pla, cla)
	-- prop break ready
	if on_ground[1] == 1 and on_ground[2] == 1 and cla < 25.7 and pla <= 35 and hydraulic_pressure_blue[0] > 2000 then
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
			elseif prop_brake == 1 and prop_speed[1] == 0 then
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
		if prop_speed[1] > prop_speed_max * 0.2 then
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
		if eng_torque[0] > eng_torque_max * 0.46 and eng_torque[1] > eng_torque_max * 0.46 then
			--arming conditions met
			if on_ground[1] == 1 or on_ground[2] == 1 then
				--autofeather + uptrim armed
				eng_atpcs = 2
			elseif eng_atpcs ~= 2 then
				--autofeather armed
				eng_atpcs = 1
			end
		elseif eng_atpcs ~= 0 and eng_torque[0] < eng_torque_max * 0.46 and eng_torque[1] < eng_torque_max * 0.46 then
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
		elseif eng_torque[0] < eng_torque_max * 0.18 then
			--schedulle autofeather
			eng_autofeather[0] = 1
			eng_autofeather_timer = os.clock() + 2.15
			if eng_atpcs == 2 then
				--trigger uptrim
				eng_uptrim[1] = 1
			end
		elseif eng_torque[1] < eng_torque_max * 0.46 then
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
	elseif pwr_mgmt[0] ~= 0 and pwr_mgmt[1] ~= 0 and prop_speed[0] > prop_speed_max * 0.7 and prop_speed[1] > prop_speed_max * 0.7 then
		--prop synchrophazer on
		prop_sync[0] = 1
		if math.abs( prop_speed[0] - prop_speed[1] ) / prop_speed_max > 0.025 then
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
	if ( on_ground[1] == 0 and on_ground[2] == 0 ) or idle_gate_cmd[0] == 1 then
		-- both landing gears released
		idle_gate = 0
	elseif ( on_ground[1] == 1 or on_ground[2] == 1 ) or idle_gate_cmd[0] == 0 then
		-- one landing gear compressed
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

