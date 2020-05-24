-- ATR PW127 POWER PLANT simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

-- nominal propeller speed rad/sec
local prop_speed_max = 125.6637

-- nominal rated engine power in watts (RTO power)
local eng_power_max = 2050675

-- nominal rated engine torque in Nm (100% NP)
local eng_torque_max = ( eng_power_max / prop_speed_max ) / xdref["prop_gear_rat"][0]

-- PLA to N1/NH curve
local base_pla = { 0, 86, 1.33, 85.76, 2.74, 85.533, 3.95, 85.031, 4.91, 84.396, 5.96, 83.547, 6.73, 82.843, 7.47, 82.104, 8.27, 81.149, 9.02, 80.194, 9.86, 78.97, 10.6, 77.775, 11.17, 76.635, 11.62, 75.526, 11.85, 74.965, 12.11, 74.43, 12.51, 73.833, 12.74, 73.583, 13.32, 73.5, 13.96, 73.582, 22.88, 74.766, 32.09, 76.104, 40.96, 77.451, 42.32, 77.786, 43.73, 78.391, 45.79, 79.483, 48.37, 80.895, 50.45, 82.274, 52.71, 83.612, 54.4, 84.453, 56.41, 85.353, 58.49, 86.103, 61.42, 87.004, 63.9, 87.611, 66.18, 88.054, 69.98, 88.624, 73.87, 88.984, 77.92, 89.338, 87.87, 90.14, 90, 90.274 }

-- PLA to power curve
local power_pla = {
	["RTO"] = { 31, 0.02, 52, 0.44, 62, 0.94, 65.5, 1.000, 68.5, 1.000, 73.5, 1.02, 83.5, 1.02, 84, 1.15, 87, 1.15 },
	["MCT"] = { 31, 0.02, 52, 0.44, 61, 0.79, 65.5, 0.909, 68.5, 0.909, 78, 1.00, 81, 1.00, 83, 1.04, 84, 1.15, 87, 1.15 },
	["TO"]  = { 31, 0.02, 52, 0.44, 61, 0.79, 65.5, 0.900, 68.5, 0.900, 78, 1.00, 81, 1.00, 83, 1.04, 84, 1.15, 87, 1.15 },
	["CLB"] = { 31, 0.02, 52, 0.44, 63, 0.76, 65.5, 0.797, 68.5, 0.797, 75, 0.96, 78, 1.00, 81, 1.00, 83, 1.04, 84, 1.15, 87, 1.15 },
	["CRZ"] = { 31, 0.02, 52, 0.44, 63, 0.76, 65.5, 0.775, 68.5, 0.775, 75, 0.96, 78, 1.00, 81, 1.00, 83, 1.04, 84, 1.15, 87, 1.15 }
}

-- polynomials coefficients describing EEC power limits at given ALT and TAT for AC off
-- from FCOM tables found by pollynomial fitting using polyfitn in GNU octave
local power_eec = {
	["RTO"] = {
		["ias"] = 60,
		["polyn"] = { ["2:0"] = -3.2254e-05, ["1:1"] = 2.2839e-07, ["1:0"] = -7.3721e-03, ["0:2"] = 4.4843e-10, ["0:1"] = -4.7348e-05, ["0:0"] = 1.3153e+00 },
	},
	["TO"] = {
		["ias"] = 60,
		["polyn"] = { ["2:0"] = -3.2254e-05, ["1:1"] = 2.2839e-07, ["1:0"] = -7.3721e-03, ["0:2"] = 4.4843e-10, ["0:1"] = -4.7348e-05, ["0:0"] = 1.3153e+00 },
	},
	["MCT"] = {
		["ias"] = 120,
		["polyn"] = { ["2:0"] = -1.0456e-05, ["1:1"] = 1.7499e-07, ["1:0"] = -7.4846e-03, ["0:2"] = 4.4330e-10, ["0:1"] = -4.5096e-05, ["0:0"] = 1.3773e+00 },
	},
	["CLB"] = {
		["ias"] = 170,
		["polyn"] = { ["2:0"] = -2.5244e-05, ["1:1"] = 1.8407e-07, ["1:0"] = -8.4256e-03, ["0:2"] = 3.3883e-10, ["0:1"] = -3.8979e-05, ["0:0"] = 1.3155e+00 },
	},
	["CRZ"] = {
		["ias"] = 210,
		["polyn"] = { ["2:0"] = -2.0029e-05, ["1:1"] = 1.7819e-07, ["1:0"] = -9.1393e-03, ["0:2"] = 3.7255e-10, ["0:1"] = -3.8750e-05, ["0:0"] = 1.3388e+00 },
	}
}


-- polynominals coefficients describing TAT corrections for different AC modes
local power_ac_corr = {
	["RTO"] = {
		["OFF"]  = { ["0"] = 0, ["1"] = 1 },
		["NORM"] = { ["0"] = 1.1736134038607378e+001, ["1"] = 8.0617683470385637e-001, ["2"] = -2.4219288414859937e-004 },
		["HIGH"] = { ["0"] = 1.6722668433577898e+001, ["1"] = 7.4749438463760065e-001, ["2"] = -6.4730379431242877e-004 }
	},
	["TO"] = {
		["OFF"]  = { ["0"] = 0, ["1"] = 1 },
		["NORM"] = { ["0"] = 1.1736134038607378e+001, ["1"] = 8.0617683470385637e-001, ["2"] = -2.4219288414859937e-004 },
		["HIGH"] = { ["0"] = 1.6722668433577898e+001, ["1"] = 7.4749438463760065e-001, ["2"] = -6.4730379431242877e-004 }
	},
	["MCT"] = {
		["OFF"]  = { ["0"] = 0, ["1"] = 1 },
		["NORM"] = { ["0"] = 7.7559510567296979e+000, ["1"] = 9.1553114571746386e-001, ["2"] = 1.2166295884316020e-004 },
		["HIGH"] = { ["0"] = 1.3126564299626326e+001, ["1"] = 8.3747107340652382e-001, ["2"] = 1.4279459396597215e-004 }
	},
	["CLB"] = {
		["OFF"]  = { ["0"] = 0, ["1"] = 1 },
		["NORM"] = { ["0"] = 9.0858731924360399e+000, ["1"] = 8.7340944303194024e-001, ["2"] = -2.4891248212299436e-004 },
		["HIGH"] = { ["0"] = 1.3237121429096568e+001, ["1"] = 8.2184578913604667e-001, ["2"] = -2.5695407552812184e-004 }
	},
	["CRZ"] = {
		["OFF"]  = { ["0"] = 0, ["1"] = 1 },
		["NORM"] = { ["0"] = 6.6858731924360386e+000, ["1"] = 8.4800721039249960e-001, ["2"] = 1.0682752661687596e-003 },
		["HIGH"] = { ["0"] = 1.0843595959480862e+001, ["1"] = 7.8756767322734256e-001, ["2"] = 1.0060873555853382e-003 }
	}
}


-- polynominals coefficients describing EEC power corrections for IAS squared at given ALT and TAT
local power_ias_corr = { ["2:0"] = -1.4073e-10, ["1:1"] = -1.0986e-12, ["1:0"] = -1.1454e-08, ["0:2"] = -2.3022e-15, ["0:1"] = 8.5163e-11, ["0:0"] = 3.2155e-06 }

-- PLA angle
local pla = { [0] = 0, [1] = 0 }

-- CLA angle
local cla = { [0] = 0, [1] = 0 }

-- PEC status
local prop_pec = { [0] = 1, [1] = 1 }

-- EEC status
local eng_eec = { [0] = 1, [1] = 1 }

-- last EEC commanded throttle
local eng_throttle_last = { [0] = 0, [1] = 0 }

-- weight on wheels signal
local weight_on_wheels = -1
local weight_on_wheels_last = -1

-- gust lock state
local gust_lock = 1

-- idle gate state
local idle_gate = 0

-- propeller automatic changeover system timer
local prop_apcs_timer = { [0] = 0, [1] = 0 }
-- propeller brake state 0 - off, 1 - engaging, 2 - engaged, 3 - releasing, -1 - failed
local prop_brake = 0
-- propeller brake timer
local prop_brake_timer = 0

-- ATPCS status
local eng_atpcs = 0
-- engine uptrim status
local eng_uptrim = { [0] = 0, [1] = 0 }
-- engine autofeather status
local eng_autofeather = { [0] = 0, [1] = 0 }
local eng_autofeather_timer = 0

-- propeller angles
local prop_beta = { ["reverse"] = -14, ["beta"] = 2, ["alpha"] = 14, ["high"] = 55, ["feather"] = 78.5 }


-- PIDs structures

-- controls TQ by throttle at alpha with EEC on
local eec_power_pid = {
	[0] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 },
	[1] = { ["kp"] = 0.0000002, ["ki"] = 0.000000125, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 1, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 }
}
-- controls NH by throttle at beta with EEC off
local hmu_nhspeed_pid = {
	[0] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.0, ["cv_max"] = 1, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 },
	[1] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 }
}
-- controls NP by pitch at alpha
local pvm_pitch_pid = {
	[0] = { ["kp"] = -0.3, ["ki"] = -0.35, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 8, ["cv_max"] = 55, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 },
	[1] = { ["kp"] = -0.3, ["ki"] = -0.35, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 8, ["cv_max"] = 55, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 }
}
-- controls NP by throttle at beta and reverse
local eec_propspeed_pid = {
	[0] = { ["kp"] = 0.015, ["ki"] = 0.0015, ["kd"] = 0.007, ["ts"] = 0.1, ["cv_min"] = 0.05, ["cv_max"] = 0.6, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 },
	[1] = { ["kp"] = 0.015, ["ki"] = 0.0015, ["kd"] = 0.007, ["ts"] = 0.1, ["cv_min"] = 0.05, ["cv_max"] = 0.6, ["cv_up"] = 0.08, ["cv_dw"] = 0.08, ["log"] = 0 }
}
-- limits prop pitch speed change
local prop_pitch_gain = {
	[0] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = -14, ["out_max"] = 78.5, ["out_up"] = 1, ["out_dw"] = 1, ["log"] = 0 },
	[1] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = -14, ["out_max"] = 78.5, ["out_up"] = 1, ["out_dw"] = 1, ["log"] = 0 },
}
-- limits repotred torque change
local eng_tq_gain = {
	[0] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 100, ["out_up"] = 10, ["out_dw"] = 10, ["log"] = 0 },
	[1] = { ["k"] = 1, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 100, ["out_up"] = 10, ["out_dw"] = 10, ["log"] = 0 },
}
-- limits pla range and rate of change
local pla_gain = {
	[0] = { ["k"] = 87, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 87, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
	[1] = { ["k"] = 87, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 87, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
}
-- limits cla range and rate of change
local cla_gain = {
	[0] = { ["k"] = 66, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 66, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
	[1] = { ["k"] = 66, ["ts"] = 0.1, ["out_min"] = 0, ["out_max"] = 66, ["out_up"] = 15, ["out_dw"] = 15, ["log"] = 0 },
}

-- init values
xdref["hotel_mode"][0] = 0

--engine overrides
set( "sim/operation/override/override_throttles", 1 )
set( "sim/operation/override/override_prop_mode", 1 )
set( "sim/operation/override/override_prop_pitch", 1 )
set( "sim/operation/override/override_mixture", 1 )
--set( "sim/operation/override/override_fuel_flow", 1 )
--set( "sim/operation/override/override_engines", 1 )
--set( "sim/operation/override/override_torque_motors", 1 )
set( "sim/operation/override/override_itt_egt", 1 )

--set idle ratios to low values
set( "sim/aircraft2/engine/low_idle_ratio", 0.1 )
set( "sim/aircraft2/engine/high_idle_ratio", 0.1 )

--hotel mode prop deceleration ratio
set("sim/cockpit2/switches/hotel_mode_ratio", 0.1)


require "pid"
require "gain"
require "curve"
require "polyn"

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end



function eec(ind)
	-- PLA
	if gust_lock == 1 then
		-- gust lock limit
		pla_gain[ind]["out_max"] = 34
	else
		pla_gain[ind]["out_max"] = 87
	end
	if idle_gate == 1 then
		--idle gate limit
		pla_gain[ind]["out_min"] = 31
	else
		pla_gain[ind]["out_min"] = 0
	end
	pla_gain[ind]["in"] = pdref["power"]["pl"][ind]
	gain.run(pla_gain[ind])
	pla[ind] = pla_gain[ind]["out"]

	-- CLA
	cla_gain[ind]["in"] = pdref["power"]["cl"][ind]
	gain.run(cla_gain[ind])
	cla[ind] = cla_gain[ind]["out"]

	local temp_prop_mode = 0
	local temp_prop_pitch = 0
	local temp_prop_speed = 0
	local temp_prop_feather = 0
	local temp_eng_mixture = 0
	local temp_eng_throttle = 0

	--PEC status
	if pdref["power"]["pec_cmd"][ind] == 1 then
		--todo FAILURES
		prop_pec[ind] = 1
		pdref["power"]["pec_ind"][ind] = 0
	else
		prop_pec[ind] = 0
		pdref["power"]["pec_ind"][ind] = 1
	end

	--EEC status
	if pdref["power"]["eec_cmd"][ind] == 1 then
		--todo FAILURES
		eng_eec[ind] = 1
		pdref["power"]["eec_ind"][ind] = 0
	else
		eng_eec[ind] = 0
		pdref["power"]["eec_ind"][ind] = 1
	end

	--PEC
	if cla[ind] >= 55 then
		-- NP 100% OVRD
		temp_prop_speed = prop_speed_max
	elseif prop_pec[ind] == 1 then
		--PEC on
		if pdref["power"]["pwr_mgmt"][ind] == 0 then
			-- TO
			if prop_apcs_timer[ind] and pla[ind] < 62 then
				-- Automatic Propeller Changeover System
				if weight_on_wheels == 0 then
					prop_apcs_timer[ind] = os.clock()
					temp_prop_speed = prop_speed_max * 0.82
				elseif os.clock() - prop_apcs_timer[ind] > 16 then
					prop_apcs_timer[ind] = 0
					temp_prop_speed = prop_speed_max
				end
			else
				prop_apcs_timer[ind] = 0
				temp_prop_speed = prop_speed_max
			end
		elseif pdref["power"]["pwr_mgmt"][ind] == 1 then
			-- MCT
			temp_prop_speed = prop_speed_max
		elseif pdref["power"]["pwr_mgmt"][ind] == 2 or pdref["power"]["pwr_mgmt"][ind] == 3 then
			-- CLB and CRZ
			if pla[ind] < 69 then
				temp_prop_speed = prop_speed_max * 0.82
			elseif pla[ind] < 75 then
				temp_prop_speed = prop_speed_max - ( ( 0.18 / 16 ) * ( 75 - pla[ind] ) )
			else
				temp_prop_speed = prop_speed_max
			end
			-- Automatic Propeller Changeover System
			if weight_on_wheels == 0 then
				prop_apcs_timer[ind] = os.clock()
			else
				prop_apcs_timer[ind] = 0
			end
		end
	else
		--PEC off
		temp_prop_speed = prop_speed_max
	end
	if pla[ind] < 13 then
		-- reverse prop speed
		-- temp_prop_speed = ( prop_speed_max * 0.91 )
		temp_prop_speed = ( prop_speed_max * 0.91 ) - ( ( ( prop_speed_max * 0.202 ) / 13 ) * pla[ind] )
	elseif pla[ind] < 31 then
		-- prop speed underspeed control
		temp_prop_speed = prop_speed_max * 0.708
	elseif pla[ind] < 52 then
		-- prop speed transition mode
		temp_prop_speed = ( prop_speed_max * 0.708 ) + ( ( ( temp_prop_speed - ( prop_speed_max * 0.708 ) ) / 21 ) * ( pla[ind] - 31 ) )
	end

	--PVM
	if cla[ind] < 1.7 then
		-- shutoff
		temp_prop_mode = 0
		temp_eng_mixture = 0
		temp_prop_feather = 1
		temp_prop_pitch = 78.5
	elseif cla[ind] < 25.7 or eng_autofeather[ind] == 2 then
		-- feather
		temp_prop_mode = 0
		temp_eng_mixture = 0.5
		temp_prop_feather = 1
		temp_prop_pitch = 78.5
	elseif xdref["prop_feather"][ind] == 1 and xdref["eng_power"][ind] < eng_power_max * 0.001 then
		-- keep feathered
		temp_prop_mode = 0
		temp_eng_mixture = 1
		temp_prop_feather = 1
		temp_prop_pitch = 78.5
	elseif pla[ind] < 13 then
		-- reverse
		temp_prop_mode = 3
		temp_eng_mixture = 1
		temp_prop_feather = 0
		prop_pitch_gain[ind]["in"] = prop_beta["reverse"] + ( ( math.abs(prop_beta["reverse"] - prop_beta["beta"]) / 13 ) * ( pla[ind] ) )
		--limit prop pitch rate
		gain.run(prop_pitch_gain[ind])
		temp_prop_pitch = prop_pitch_gain[ind]["out"]
	elseif pla[ind] < 31 then
		-- ground beta
		temp_prop_mode = 2
		temp_eng_mixture = 0.5
		temp_prop_feather = 0
		prop_pitch_gain[ind]["in"] = prop_beta["beta"] + ( ( math.abs(prop_beta["beta"] - prop_beta["alpha"]) / 18 ) * ( pla[ind] - 13 ) )
		--limit prop pitch rate
		gain.run(prop_pitch_gain[ind])
		temp_prop_pitch = prop_pitch_gain[ind]["out"]
	else
		-- alpha
		temp_prop_mode = 1
		temp_eng_mixture = 1
		temp_prop_feather = 0
		-- PID to set prop pitch to keep constant prop speed
		pvm_pitch_pid[ind]["cv"] = xdref["prop_pitch"][ind]
		pvm_pitch_pid[ind]["pv"] = xdref["prop_speed"][ind]
		pvm_pitch_pid[ind]["sp"] = temp_prop_speed
		if xdref["eng_power"][ind] < eng_power_max * 0.001 then
			pvm_pitch_pid[ind]["ff"] = 1
		else
			pvm_pitch_pid[ind]["ff"] = ( ( xdref["eng_power"][ind] / temp_prop_speed ) ^ ( 1 / 2.8 ) )
		end
		pid.run(pvm_pitch_pid[ind])
		temp_prop_pitch = pvm_pitch_pid[ind]["cv"]
	end

	local eng_power_ratio = 0
	if eng_eec[ind] == 1 then
		-- EEC operative
		-- get AC flow mode
		local pack_flow = "OFF"
		if xdref["pack_valve"][ind][0] == 1 and pdref["air"]["pack_flow_cmd"][0] == 0 then
			pack_flow = "NORM"
		elseif xdref["pack_valve"][ind][0] == 1 and pdref["air"]["pack_flow_cmd"][0] == 1 then
			pack_flow = "HIGH"
		end

		-- PWR MGMT
		local pwr_mgmt = "TO"
		local pwr_mgmt_fdau = "RTO"
		if pdref["power"]["pwr_mgmt"][ind] == 0 and eng_uptrim[ind] == 1 then
			-- RTO
			pwr_mgmt = "RTO"
		elseif pdref["power"]["pwr_mgmt"][ind] == 1 then
			-- MCT
			pwr_mgmt = "MCT"
			pwr_mgmt_fdau = "MCT"
		elseif pdref["power"]["pwr_mgmt"][ind] == 2 then
			-- CLB
			pwr_mgmt = "CLB"
			pwr_mgmt_fdau = "CLB"
		elseif pdref["power"]["pwr_mgmt"][ind] == 3 then
			-- CRZ
			pwr_mgmt = "CRZ"
			pwr_mgmt_fdau = "CRZ"
		end

		local eng_power_ratio_fdau = eec_limit(67, pwr_mgmt_fdau, pack_flow)

		-- calculate FDAU torque from power and prop speed for given mode
		if pwr_mgmt_fdau == "CLB" or pwr_mgmt_fdau == "CRZ" then
			-- CLB and CRZ
			pdref["power"]["eec_fdau"][ind] = ( eng_power_ratio_fdau / 0.82 ) * 100
		else
			-- TO, RTO and MCT
			pdref["power"]["eec_fdau"][ind] = eng_power_ratio_fdau * 100
		end

		-- HMU top law power calculation
		if xdref["eng_power"][ind] > eng_power_max * 0.001 and cla[ind] > 33.7 and xdref["prop_feather"][ind] ~= 1 then
			eng_power_ratio = eec_limit(pla[ind], pwr_mgmt, pack_flow)
		end
	else
		-- FDAU INOP
		pdref["power"]["eec_fdau"][ind] = 0
	end

	if pla[ind] < 31 then
		-- fuel governing - keep constant Np
		eec_propspeed_pid[ind]["cv"] = xdref["eng_throttle"][ind]
		eec_propspeed_pid[ind]["pv"] = xdref["prop_speed"][ind]
		eec_propspeed_pid[ind]["sp"] = temp_prop_speed
		eec_propspeed_pid[ind]["ff"] = 0.25 + ( temp_prop_speed * 0.005 * math.sin(math.rad(math.abs(temp_prop_pitch))) )
		pid.run(eec_propspeed_pid[ind])
		temp_eng_throttle = eec_propspeed_pid[ind]["cv"]
		-- reset EEC frozen (as bellow 52 PLA)
		eng_throttle_last[ind] = 0
	else
		-- HMU top law / HMU base law
		-- get requested engine power for HMU top law
		local eng_power = eng_power_ratio * eng_power_max

		-- get requested engine NH for HMU base law
		local eng_nh_ratio = curve.lookup(pla[ind], base_pla)

		-- TODO find better transition function between HMU modes
		if eng_power == 0 then
			if pla[ind] <= 52 and eng_throttle_last[ind] ~= 0 then
				-- frozen EEC reversion to HMU base law
				eng_throttle_last[ind] = 0
			end
		elseif eng_throttle_last[ind] ~= 0 then
			if pla[ind] < 52 and eng_nh_ratio >= xdref["eng_nh"][ind] then
				-- transition to HMU base law
				eng_power = 0
				eng_throttle_last[ind] = 0
			end
		elseif pla[ind] > 52 or eng_power >= xdref["eng_power"][ind] then
			-- transition to HMU top law
			eng_throttle_last[ind] = 0
		else
			-- keep in HMU base law
			eng_power = 0
		end

		if eng_power ~= 0 then
			-- HMU top law
			-- PID to set engine throttle to produce FADEC commanded power
			eec_power_pid[ind]["cv"] = xdref["eng_throttle"][ind]
			eec_power_pid[ind]["pv"] = xdref["eng_power"][ind]
			eec_power_pid[ind]["sp"] = eng_power
			eec_power_pid[ind]["ff"] = 0.25 + ( eng_power_ratio / 1.4 )
			pid.run(eec_power_pid[ind])
			temp_eng_throttle = eec_power_pid[ind]["cv"]
			-- keep last value for EEC off
			eng_throttle_last[ind] = temp_eng_throttle
		elseif eng_throttle_last[ind] == 0 then
			-- HMU base law
			-- PID to set engine throttle to produce NH
			hmu_nhspeed_pid[ind]["cv"] = xdref["eng_throttle"][ind]
			hmu_nhspeed_pid[ind]["pv"] = xdref["eng_nh"][ind]
			hmu_nhspeed_pid[ind]["sp"] = eng_nh_ratio
			--hmu_nhspeed_pid[ind]["ff"] = ( eng_nh_ratio - 70 ) * 30
			pid.run(hmu_nhspeed_pid[ind])
			temp_eng_throttle = hmu_nhspeed_pid[ind]["cv"]
		else
			-- EEC frozen
			temp_eng_throttle = eng_throttle_last[ind]
		end
	end

	-- start sequence
	if pdref["power"]["start_cmd"][ind] == 1 then
		if ind == 1 and prop_brake ~= 0 and gust_lock == 0 then
			pdref["power"]["start_cmd"][ind] = 0
			pdref["power"]["start_ind"][ind] = 2
		elseif pdref["power"]["start_sel"][0] == 0 or xdref["eng_nh"][ind] > 45 then
			-- end start sequence
			pdref["power"]["start_cmd"][ind] = 0
			pdref["power"]["start_ind"][ind] = 0
		else
			pdref["power"]["start_ind"][ind] = 1
			command_once("sim/starters/engage_starter_" .. (ind + 1))
		end
	else
		pdref["power"]["start_ind"][ind] = 0
	end

	-- ignition
	if cla[ind] < 1.7 then
		xdref["eng_igniter"][ind] = 0
	elseif pdref["power"]["start_cmd"][ind] == 1 and pdref["power"]["start_sel"][0] > 1 then
		-- starter inginition
		if weight_on_wheels == 2 then
			if pdref["power"]["start_sel"][0] == 2 then
				xdref["eng_igniter"][ind] = 1
			elseif pdref["power"]["start_sel"][0] == 3 then
				xdref["eng_igniter"][ind] = 2
			elseif pdref["power"]["start_sel"][0] == 4 then
				xdref["eng_igniter"][ind] = 3
			end
		else
			xdref["eng_igniter"][ind] = 3
		end
	elseif eng_eec[ind] == 1 and cla[ind] > 25.7 and eng_autofeather[ind] == 0 and xdref["eng_nh"][ind] > 30 and xdref["eng_nh"][ind] < 60 then
		-- auto relight
		xdref["eng_igniter"][ind] = 3
	elseif pdref["power"]["man_ign"][0] == 1 then
		-- cont relight
		xdref["eng_igniter"][ind] = 3
	else
		xdref["eng_igniter"][ind] = 0
	end

	--low pitch
	if xdref["prop_pitch"][ind] < 8 then
		pdref["power"]["low_pitch_ind"][ind] = 1
		if weight_on_wheels == 0 then
			-- TODO low pitch warning
		end
	else
		pdref["power"]["low_pitch_ind"][ind] = 1
	end

	xdref["prop_mode"][ind] = temp_prop_mode
	xdref["prop_pitch"][ind] = temp_prop_pitch
	xdref["prop_feather"][ind] = temp_prop_feather
	xdref["eng_throttle"][ind] = temp_eng_throttle
	xdref["eng_mixture"][ind] = temp_eng_mixture
end


function eec_limit(pla, pwr_mgmt, pack_flow)
	-- AC mode corection to TAT
	local corr_temp = polyn.lookup({ pdref["dadc"]["tat"][0] }, power_ac_corr[pwr_mgmt][pack_flow])

	-- IAS correction to EEC limits
	local corr_eec
	if pdref["dadc"]["ias"][0] > 60 then
		corr_eec = polyn.lookup({ corr_temp, pdref["dadc"]["palt"][0] }, power_ias_corr) * ( ( pdref["dadc"]["ias"][0] ^ 2 ) - ( power_eec[pwr_mgmt]["ias"] ^ 2 ) )
	else
		corr_eec = polyn.lookup({ corr_temp, pdref["dadc"]["palt"][0] }, power_ias_corr) * ( ( 60 ^ 2 ) - ( power_eec[pwr_mgmt]["ias"] ^ 2 ) )
	end

	-- EEC thermodynamic limits based on TAT and pressure altitude
	local eec_limit = polyn.lookup({ corr_temp, pdref["dadc"]["palt"][0] }, power_eec[pwr_mgmt]["polyn"])

	-- apply IAS correction for EEC
	eec_limit = eec_limit + corr_eec

	-- get PLA engine power
	local eng_power_ratio = curve.lookup(pla, power_pla[pwr_mgmt])

	-- EEC mechanical limit
	if eec_limit < 1 then
		eng_power_ratio = eng_power_ratio * eec_limit
	end

	return eng_power_ratio
end


function pbrake()
	-- prop break ready
	if weight_on_wheels == 2 and cla[1] < 25.7 and gust_lock == 1 and xdref["hydraulic_pressure_blue"][0] > 2000 then
		pdref["power"]["prop_brake_ind"][1] = 1
	else
		pdref["power"]["prop_brake_ind"][1] = 0
	end

	if prop_brake > 0 and ( pla[1] > 60 or xdref["hydraulic_pressure_blue"][0] < 1500 ) then
		--prop is failing
		if prop_brake == 1 or prop_brake == 2 then
			xdref["hotel_mode"][0] = 0
		end
		prop_brake = -1
		pdref["power"]["prop_brake_ind"][0] = 1
		pdref["power"]["prop_brake_ind"][2] = 0
	elseif prop_brake > 0 and gust_lock == 0 then


	end

	if pdref["power"]["prop_brake_cmd"][0] == 1 then
		-- command to engage
		if pdref["power"]["prop_brake_ind"][1] == 1 then
			-- prop brake ready
			if prop_brake == 0 then
				-- start engage
				xdref["hotel_mode"][0] = 1
				prop_brake_timer = os.clock()
				prop_brake = 1
				pdref["power"]["prop_brake_ind"][0] = 1
				pdref["power"]["prop_brake_ind"][2] = 0
			elseif prop_brake == 1 and xdref["prop_speed"][1] == 0 then
				-- prop break engaged
				prop_brake_timer = 0
				prop_brake = 2
				pdref["power"]["prop_brake_ind"][0] = 0
				pdref["power"]["prop_brake_ind"][2] = 1
			end
		else
			-- prop not ready
			xdref["master_warning"][0] = 1
		end
	elseif prop_brake > 0 then
		-- command to disengage
		if pdref["power"]["prop_brake_ind"][1] == 1 then
			-- prop brake ready
			if prop_brake == 1 or prop_brake == 2 then
				-- stop prop brake engage / release prop brake
				xdref["hotel_mode"][0] = 0
				prop_brake_timer = os.clock()
				prop_brake = 3
				pdref["power"]["prop_brake_ind"][0] = 1
			elseif prop_brake == 3 and xdref["prop_speed"][1] > prop_speed_max * 0.2 then
				-- unlocked
				prop_brake_timer = 0
				prop_brake = 0
				pdref["power"]["prop_brake_ind"][0] = 0
				pdref["power"]["prop_brake_ind"][2] = 0
			end
		else
			-- prop not ready
			xdref["master_warning"][0] = 1
		end
	else
		-- prop brake default off
		prop_brake = 0
		prop_brake_timer = 0
		pdref["power"]["prop_brake_ind"][0] = 0
		pdref["power"]["prop_brake_ind"][2] = 0
	end

	if ( prop_brake == 1 or prop_brake == 3 ) and prop_brake_timer and os.clock() - prop_brake_timer > 15 then
		-- not fully lock or unlock in 15sec
		xdref["master_warning"][0] = 1
	end
end


function atpcs()
	--ATPCS test/arming/disarming conditions
	if pdref["power"]["atpcs_test"][0] ~= 0 and pdref["power"]["atpcs_cmd"][0] == 1 and pdref["power"]["pec_cmd"][0] == 1 and pdref["power"]["pec_cmd"][1] == 1 and cla[0] < 1.7 and cla[1] < 1.7 and math.abs(pla[0] - 13) < 1 and math.abs(pla[1] - 13) < 1 then
		--ATPCS test
		if pdref["power"]["atpcs_test"][0] == -1 then
			pdref["power"]["atpcs_ind"][0] = 1
			eng_autofeather_timer = 0
		elseif atpcs_test[0] == -2 then
			pdref["power"]["uptrim_ind"][1] = 1
			if eng_autofeather_timer ~= 0 then
				if eng_autofeather_timer < os.clock() then
					pdref["power"]["atpcs_ind"][0] = 0
				end
			else
				eng_autofeather_timer = os.clock() + 2.15
			end
		elseif pdref["power"]["atpcs_test"][0] == 1 then
			pdref["power"]["atpcs_ind"][0] = 1
			eng_autofeather_timer = 0
		elseif pdref["power"]["atpcs_test"][0] == 2 then
			pdref["power"]["uptrim_ind"][0] = 1
			if eng_autofeather_timer ~= 0 then
				if eng_autofeather_timer < os.clock() then
					pdref["power"]["atpcs_ind"][0] = 0
				end
			else
				eng_autofeather_timer = os.clock() + 2.15
			end
		end
		return
	elseif pdref["power"]["atpcs_cmd"][0] == 1 and pdref["power"]["pwr_mgmt"][0] == 0 and pdref["power"]["pwr_mgmt"][1] == 0 and xdref["prop_feather"][0] == 0 and xdref["prop_feather"][0] == 0 and pla[0] > 49 and pla[1] > 49 then
		if xdref["eng_torque"][0] > eng_torque_max * 0.46 and xdref["eng_torque"][1] > eng_torque_max * 0.46 then
			--arming conditions met
			if weight_on_wheels > 0 then
				--autofeather + uptrim armed
				eng_atpcs = 2
			elseif eng_atpcs ~= 2 then
				--autofeather armed
				eng_atpcs = 1
			end
		elseif eng_atpcs ~= 0 and xdref["eng_torque"][0] < eng_torque_max * 0.46 and xdref["eng_torque"][1] < eng_torque_max * 0.46 then
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
		elseif xdref["eng_torque"][0] < eng_torque_max * 0.18 then
			--schedulle autofeather
			eng_autofeather[0] = 1
			eng_autofeather_timer = os.clock() + 2.15
			if eng_atpcs == 2 then
				--trigger uptrim
				eng_uptrim[1] = 1
			end
		elseif xdref["eng_torque"][1] < eng_torque_max * 0.18 then
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

	--reset triggered ATCPS
	if pdref["power"]["atpcs_cmd"][0] == 0 or pdref["power"]["pwr_mgmt"][0] ~= 0 and pdref["power"]["pwr_mgmt"][1] ~= 0 or pla[0] < 49 or pla[1] < 49 or ( xdref["eng_torque"][0] < eng_torque_max * 0.46 and xdref["eng_torque"][1] < eng_torque_max * 0.46 ) then
		eng_uptrim[0] = 0
		eng_uptrim[1] = 0
		eng_autofeather[0] = 0
		eng_autofeather[1] = 0
	end

	--indicators
	pdref["power"]["atpcs_ind"][0] = eng_atpcs
	pdref["power"]["uptrim_ind"][0] = eng_uptrim[0]
	pdref["power"]["uptrim_ind"][1] = eng_uptrim[1]
end


function sync()
	if pdref["power"]["sync_cmd"][0] == 0 then
		--prop synchrophazer off
		xdref["prop_sync"][0] = 0
		pdref["power"]["sync_ind"][0] = 1
	elseif pdref["power"]["pwr_mgmt"][0] ~= 0 and pdref["power"]["pwr_mgmt"][1] ~= 0 and xdref["prop_speed"][0] > prop_speed_max * 0.7 and xdref["prop_speed"][1] > prop_speed_max * 0.7 then
		--prop synchrophazer on
		xdref["prop_sync"][0] = 1
		if math.abs( xdref["prop_speed"][0] - xdref["prop_speed"][1] ) / prop_speed_max > 0.025 then
			--prop synchrophazer out of authority
			pdref["power"]["sync_ind"][0] = 2
		else
			pdref["power"]["sync_ind"][0] = 0
		end
	else
		xdref["prop_sync"][0] = 0
		pdref["power"]["sync_ind"][0] = 0
	end
end


function engine(ind)
	-- ITT calculation
	--pdref["power"]["eng_itt"][ind] = xdref["sat"][0] + ( 29.92 * xdref["eng_ff"][ind] / ( xdref["eng_nh"][ind] * xdref["eng_nh"][ind] * xdref["air_pressure"][0] ) )

	-- torque indicator
	if xdref["prop_pitch"][ind] > 55 then
		eng_tq_gain[ind]["in"] = 0
	else
		eng_tq_gain[ind]["in"] = ( xdref["eng_torque"][ind] / eng_torque_max ) * 100
	end
	gain.run(eng_tq_gain[ind])
	pdref["power"]["eng_tq"][ind] = eng_tq_gain[ind]["out"]
end


function wow()
	weight_on_wheels_last = weight_on_wheels
	if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
		-- both landing gear compressed
		weight_on_wheels = 2
	elseif xdref["on_ground"][1] == 1 or xdref["on_ground"][2] == 1 then
		-- one landing gear compressed
		weight_on_wheels = 1
	else
		-- both landing gears released
		weight_on_wheels = 0
	end
end


function gate_lock()
	-- gust lock position
	gust_lock = pdref["power"]["gust_lock_cmd"][0]

	-- idle gate manual override
	if idle_gate == 0 and pdref["power"]["idle_gate_cmd"][0] == 1 and ( pla[0] < 40 or pla[1] < 40 ) then
		-- idle gate could not be pushed bellow 40deg PLA
		pdref["power"]["idle_gate_cmd"][0] = 0
	end

	-- idle gate automatic position
	if weight_on_wheels ~= weight_on_wheels_last then
		if idle_gate == 0 and weight_on_wheels == 0 and ( pla[0] >= 40 or pla[1] >= 40 ) then
			-- push idle gate
			pdref["power"]["idle_gate_cmd"][0] = 1
		elseif idle_gate == 1 and weight_on_wheels ~= 0 then
			-- pull idle gate
			pdref["power"]["idle_gate_cmd"][0] = 0
		end
	end

	idle_gate = pdref["power"]["idle_gate_cmd"][0]

	-- idle gate warning
	if ( weight_on_wheels == 0 and idle_gate == 0 ) or ( weight_on_wheels == 2 and idle_gate == 1 ) then
		pdref["power"]["idle_gate_ind"][0] = 1
		xdref["master_caution"][0] = 1
	else
		pdref["power"]["idle_gate_ind"][0] = 0
	end
end


function power()
	-- weight on wheels function
	wow()

	-- idle gate and gust lock function
	gate_lock()

	-- atpcs function
	atpcs()

	-- prop synchrophazer function
	sync()

	-- eec functions
	eec(0)
	eec(1)

	-- prop brake
	pbrake()

	-- engine simulation
	engine(0)
	engine(1)
end


do_every_frame("power()")

