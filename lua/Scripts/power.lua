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

-- PLA to N1/NH curve
local base_pla = { 0, 86, 1.33, 85.76, 2.74, 85.533, 3.95, 85.031, 4.91, 84.396, 5.96, 83.547, 6.73, 82.843, 7.47, 82.104, 8.27, 81.149, 9.02, 80.194, 9.86, 78.97, 10.6, 77.775, 11.17, 76.635, 11.62, 75.526, 11.85, 74.965, 12.11, 74.43, 12.51, 73.833, 12.74, 73.583, 13.32, 73.5, 13.96, 73.582, 22.88, 74.766, 32.09, 76.104, 40.96, 77.451, 42.32, 77.786, 43.73, 78.391, 45.79, 79.483, 48.37, 80.895, 50.45, 82.274, 52.71, 83.612, 54.4, 84.453, 56.41, 85.353, 58.49, 86.103, 61.42, 87.004, 63.9, 87.611, 66.18, 88.054, 69.98, 88.624, 73.87, 88.984, 77.92, 89.338, 87.87, 90.14, 89.26, 90.274, 100, 92 }

-- PLA to power curve
local power_pla = {
	["RTO"] = { 37, 0.02, 62, 0.94, 66, 1.000, 68, 1.000, 74, 1.02, 89, 1.02, 91, 1.15, 100, 1.15 },
	["MCT"] = { 37, 0.02, 54, 0.44, 61, 0.79, 65, 0.909, 68, 0.909, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["TO"]  = { 37, 0.02, 54, 0.44, 61, 0.79, 65, 0.900, 68, 0.900, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["CLB"] = { 37, 0.02, 54, 0.44, 63, 0.76, 65, 0.797, 69, 0.797, 75, 0.96, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 },
	["CRZ"] = { 37, 0.02, 54, 0.44, 63, 0.76, 65, 0.775, 69, 0.775, 75, 0.96, 78, 1.00, 85, 1.00, 89, 1.02, 91, 1.15, 100, 1.15 }
}

-- polynomials coefficients describing EEC power limits at given ALT for OAT for AC off
-- from FCOM tables found by polynomial calculator https://arachnoid.com/polysolve/
local power_eec = {
	["RTO"] = {
		[-1000] = {  1.4516219821256142e+000, -1.1496581966096254e-002,  1.0287448312417405e-005 },
		[00000] = {  1.3854683250412159e+000, -1.0720721323318404e-002,  7.0077121441648748e-006 },
		[01000] = {  1.3265499999996524e+000, -1.0122348484831964e-002,  4.7348484846557772e-006 },
		[02000] = {  1.2842727272725540e+000, -1.0211305361296573e-002,  1.0198135198026546e-005 },
		[03000] = {  1.2335379620377400e+000, -9.8623876123752809e-003,  1.0614385614220145e-005 },
		[04000] = {  1.1727516483515941e+000, -8.8649038461503550e-003,  2.2321428570900740e-006 },
		[05000] = {  1.1189371687136795e+000, -8.1272462831314934e-003, -3.4744667097142307e-006 },
		[06000] = {  1.0557783797729685e+000, -6.5364744582049111e-003, -2.4461429308554694e-005 },
		[07000] = {  1.0053429824561384e+000, -5.6117737525629291e-003, -3.6839257234001207e-005 },
		[08000] = {  9.6390513833992131e-001, -5.3427865612649169e-003, -3.7104743083001180e-005 },
		[08500] = {  9.4452742474916362e-001, -5.3552396878483646e-003, -3.3054626532887866e-005 }
	},
	["TO"] = {
		[-1000] = {  1.4525196745314384e+000, -1.1540560668503362e-002,  1.0726512825214165e-005 },
		[00000] = {  1.3795438106714955e+000, -1.0453208389601199e-002,  3.9548047478202034e-006 },
		[01000] = {  1.3286902356901771e+000, -1.0243265993263204e-002,  6.3131313130986566e-006 },
		[02000] = {  1.2779797979801764e+000, -9.9018389018580722e-003,  6.4750064752435064e-006 },
		[03000] = {  1.2257781107780099e+000, -9.4627594627538763e-003,  5.5500055499307561e-006 },
		[04000] = {  1.1733626373625576e+000, -8.9104853479802827e-003,  2.8617216116458074e-006 },
		[05000] = {  1.1210511024922605e+000, -8.2500448897494198e-003,  1.8180349062926433e-006 },
		[06000] = {  1.0552353514505342e+000, -6.4974271872502796e-003, -2.5136882238254322e-005 },
		[07000] = {  1.0049590643274835e+000, -5.5762512341458034e-003, -3.7499050656948527e-005 },
		[08000] = {  9.6421481899742756e-001, -5.4119925967752430e-003, -3.5314323357799990e-005 },
		[08500] = {  9.4442497212932019e-001, -5.3464325529544001e-003, -3.3491267186916094e-005 }
	},
	["MCT"] = {
		[00000] = {  1.9602310230997284e+000, -3.1036853685272359e-002,  2.2345984598370894e-004 },
		[02000] = {  1.4433189716641146e+000, -1.4262652622440241e-002,  6.7593049011997194e-005 },
		]04000] = {  1.3199310908523822e+000, -1.2622780509906281e-002,  5.8960381526135654e-005 },
		[06000] = {  1.2529025910834244e+000, -1.3091770840700075e-002,  7.1424871464200769e-005 },
		[08000] = {  1.0604119214089749e+000, -6.0606867156208135e-003, -2.2663177675708815e-005 },
		[10000] = {  9.7986577105534856e-001, -5.4802872087750462e-003, -2.5482430862030096e-005 },
		[12000] = {  9.0429888960138793e-001, -5.1410895376039802e-003,  2.2313533065667475e-005 },
		[14000] = {  8.3188288419889189e-001, -4.9182968885306839e-003, -1.0539538746744470e-005 },
		[16000] = {  7.6387626440762035e-001, -4.4941299561257180e-003, -3.3472014593143286e-006 },
		[18000] = {  7.0298149587457404e-001, -4.0682140253707018e-003, -9.9180416311292171e-007 },
		[20000] = {  6.4882853282664943e-001, -3.7038905109471236e-003,  8.9126633120589676e-007 },
		[22000] = {  5.9688249985202957e-001, -3.4326342889835883e-003, -6.3560152073053736e-008 },
		[24000] = {  5.4844710180460132e-001, -3.2152961926797991e-003, -1.7725311666635715e-006 },
		]25000] = {  5.2464058287034754e-001, -2.9926637965813335e-003,  6.2361553919554029e-007 }
	},
	["CLB"] = {
		[00000] = {  1.3562556013620761e+000, -1.3467019179056143e-002,  5.5117404552694283e-005 },
		[02000] = {  1.2148794586841882e+000, -1.0277864910070418e-002,  2.3348344984049019e-005 },
		]04000] = {  1.1342132998745313e+000, -9.8624244325311861e-003,  2.5575310824684918e-005 },
		[06000] = {  1.0482194593361491e+000, -8.8637094816519778e-003,  1.9860680933457775e-005 },
		[08000] = {  9.6575868297323708e-001, -7.6104416286347371e-003,  7.4196506128722308e-006 },
		[10000] = {  8.9357752853095662e-001, -6.4174906667618329e-003, -1.0220205010871874e-005 },
		[12000] = {  8.4076722176686836e-001, -5.7200210121029181e-003, -2.3562240140723996e-005 },
		[14000] = {  8.4469741701626988e-001, -5.7269430759278100e-003, -3.7567082681352746e-005 },
		[16000] = {  7.8614471284379617e-001, -5.4456645958234707e-003, -3.0188616067392172e-005 },
		[18000] = {  7.2747578942607516e-001, -5.0503819648097656e-003, -2.8542613980444041e-005 },
		[20000] = {  6.7204754886205553e-001, -4.6507566356536363e-003, -2.6119393264735381e-005 },
		[22000] = {  6.2020727033493650e-001, -4.2937760550327310e-003, -2.3558753659919592e-005 },
		[24000] = {  5.7277960899069358e-001, -3.9535836657707216e-003, -2.1720464103870506e-005 },
		]25000] = {  5.5027320893096743e-001, -3.7355062180164178e-003, -1.9200134231825863e-005 }
	},
	["CRZ"] = {
		[00000] = {  1.5100413364054015e+000, -1.7578986175109654e-002,  8.2661290322522045e-005 },
 		[05000] = {  1.1916016295598171e+000, -1.1191997381189362e-002,  2.7451863118731792e-005 },
 		[07500] = {  1.1170753844404742e+000, -1.1792177428844810e-002,  4.5993304194162750e-005 },
 		[10000] = {  1.0087653860632575e+000, -9.8134272125166115e-003,  2.6189643193041023e-005 },
 		[12500] = {  9.0915198667910846e-001, -7.1677199668632712e-003, -2.0786946618371492e-005 },
 		[15000] = {  8.4684465813764809e-001, -6.3859151942552064e-003, -3.2034396938533527e-005 },
 		[17500] = {  7.8529604637932515e-001, -6.0421901075959471e-003, -2.8070981233786939e-005 },
 		[20000] = {  7.1821504836736871e-001, -5.5633798455194264e-003, -2.7581295593378559e-005 },
 		[22500] = {  6.5699328432452275e-001, -5.0921915855985317e-003, -2.5531503924119630e-005 },
 		[25000] = {  6.0114454799176931e-001, -4.6517988325283722e-003, -2.2678535942968159e-005 }
 	}	
}


-- polynominals coefficients describing OAT corrections for different AC modes
local power_ac_corr = {
	["RTO"] = {
		["off"] = { 0, 1 },
		["norm"] = {  1.1736134038607378e+001,  8.0617683470385637e-001, -2.4219288414859937e-004 },
		["high"] = {  1.6722668433577898e+001,  7.4749438463760065e-001, -6.4730379431242877e-004 }
	},
	["TO"] = {
		["off"] = { 0, 1 },
		["norm"] = {  1.1736134038607378e+001,  8.0617683470385637e-001, -2.4219288414859937e-004 },
		["high"] = {  1.6722668433577898e+001,  7.4749438463760065e-001, -6.4730379431242877e-004 }
	},
	["MCT"] = {
		["off"] = { 0, 1 },
		["norm"] = {  7.7559510567296979e+000,  9.1553114571746386e-001,  1.2166295884316020e-004 }, 
		["high"] = {  1.3126564299626326e+001,  8.3747107340652382e-001,  1.4279459396597215e-004 }
	},
	["CLB"] = {
		["off"] = { 0, 1 },
		["norm"] = {  9.0858731924360399e+000,  8.7340944303194024e-001, -2.4891248212299436e-004 },
		["high"] = {  1.3237121429096568e+001,  8.2184578913604667e-001, -2.5695407552812184e-004 }
	},
	["CRZ"] = {
		["off"] = { 0, 1 },
		["norm"] = {  6.6858731924360386e+000,  8.4800721039249960e-001,  1.0682752661687596e-003 },
		["high"] = {  1.0843595959480862e+001,  7.8756767322734256e-001,  1.0060873555853382e-003 }
	}
}


-- polynominals coefficients describing EEC power corrections for IAS
local power_ias_corr = {
7.22E+01
-8.23E-15
3.39E-04




	["TO"] = 50,
	["RTO"] = 50,
	["MCT"] = 120
	["CLB"] = 170
	["CZR"] = 210
}



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
	[0] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.0, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 },
	[1] = { ["kp"] = 0.2, ["ki"] = 0.15, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.4, ["cv_max"] = 1, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 }
}
-- controls NP by pitch at alpha
local pvm_pitch_pid = {
	[0] = { ["kp"] = -0.5, ["ki"] = -0.3, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 36, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 },
	[1] = { ["kp"] = -0.5, ["ki"] = -0.3, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0, ["cv_max"] = 36, ["cv_up"] = 10, ["cv_dw"] = 10, ["log"] = 0 }
}
-- controls NP by throttle at beta and reverse
local eec_propspeed_pid = {
	[0] = { ["kp"] = 0.025, ["ki"] = 0.007, ["kd"] = 0, ["ts"] = 0.1, ["cv_min"] = 0.05, ["cv_max"] = 0.6, ["cv_up"] = 0.2, ["cv_dw"] = 0.2, ["log"] = 0 },
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
xdref["hotel_mode"][0] = 0

--engine overrides
set( "sim/operation/override/override_throttles", 1 )
set( "sim/operation/override/override_prop_mode", 1 )
set( "sim/operation/override/override_prop_pitch", 1 )
set( "sim/operation/override/override_mixture", 1 )
--set( "sim/operation/override/override_fuel_flow", 1 )
--set( "sim/operation/override/override_engines", 1 )
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
	if gust_lock == 1 and pdref["power"]["pl"][ind] > 0.34 then
		-- gust lock limit
		pla_gain[ind]["in"] = 0.34
	elseif idle_gate == 1 and pdref["power"]["pl"][ind] < 0.37 then
		--idle gate limit
		pla_gain[ind]["in"] = 0.37
	else
		pla_gain[ind]["in"] = pdref["power"]["pl"][ind]
	end
	gain.run(pla_gain[ind])
	local pla = pla_gain[ind]["out"]

	-- CLA
	cla_gain[ind]["in"] = pdref["power"]["cl"][ind]
	gain.run(cla_gain[ind])
	local cla = cla_gain[ind]["out"]

	local temp_prop_mode = 0
	local temp_prop_pitch = 0
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
	if cla >= 55 then
		-- NP 100% OVRD
		temp_prop_speed = prop_speed_max
	elseif prop_pec[ind] == 1 then
		--PEC on
		if pdref["power"]["pwr_mgmt"][ind] == 0 or pdref["power"]["pwr_mgmt"][ind] == 1 then
			-- TO and MCT
			temp_prop_speed = prop_speed_max
		elseif pdref["power"]["pwr_mgmt"][ind] == 2 or pdref["power"]["pwr_mgmt"][ind] == 3 then
			-- CLB and CRZ
			if pla < 69 then
				temp_prop_speed = prop_speed_max * 0.82
			elseif pla < 75 then
				temp_prop_speed = prop_speed_max - ( ( 0.18 / 16 ) * ( 75 - pla ) )
			else
				temp_prop_speed = prop_speed_max
			end
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
		temp_prop_feather = 1
		prop_pitch_gain[ind]["in"] = 78.5
	elseif cla < 25.7 or eng_autofeather[ind] == 2 then
		--feather
		temp_prop_mode = 0
		temp_eng_mixture = 0.5
		temp_prop_feather = 1
		prop_pitch_gain[ind]["in"] = 78.5
	elseif pla < 13 then
		-- reverse
		temp_prop_mode = 3
		temp_eng_mixture = 1
		temp_prop_feather = 0
		prop_pitch_gain[ind]["in"] = prop_beta["reverse"] + ( ( math.abs(prop_beta["reverse"] - prop_beta["beta"]) / 13 ) * ( pla ) )
	elseif pla < 37 then
		-- ground beta
		temp_prop_mode = 2
		temp_eng_mixture = 0.5
		temp_prop_feather = 0
		prop_pitch_gain[ind]["in"] = prop_beta["beta"] + ( ( math.abs(prop_beta["beta"] - prop_beta["alpha"]) / 24 ) * ( pla - 13 ) )
	elseif pla < 45 then
		-- flight beta
		temp_prop_mode = 2
		temp_eng_mixture = 0.5
		temp_prop_feather = 0
		prop_pitch_gain[ind]["in"] = prop_beta["alpha"]
	else
		-- alpha
		temp_prop_mode = 1
		temp_eng_mixture = 1
		temp_prop_feather = 0
		-- PID to set prop pitch to keep constant prop speed
		pvm_pitch_pid[ind]["cv"] = xdref["prop_pitch"][ind] - prop_beta["alpha"]
		pvm_pitch_pid[ind]["pv"] = xdref["prop_speed"][ind]
		pvm_pitch_pid[ind]["sp"] = temp_prop_speed
		pvm_pitch_pid[ind]["ff"] = ( ( xdref["eng_power"][ind] / temp_prop_speed ) ^ ( 1 / 2.8 ) ) - prop_beta["alpha"]
		pid.run(pvm_pitch_pid[ind])
		prop_pitch_gain[ind]["in"] = prop_beta["alpha"] + pvm_pitch_pid[ind]["cv"]
	end
	--limit prop pitch rate
	gain.run(prop_pitch_gain[ind])
	temp_prop_pitch = prop_pitch_gain[ind]["out"]

	--EEC / HMU
	if eng_eec[ind] == 1 and cla > 33.7 and eng_autofeather[ind] ~= 2 then
		-- PWR_MGMT
		local power_curve
		local eec_curve
		local ac_flow = "off"
		local pressure_alt = (1 - math.pow((xdref["air_pressure"][0]/29.92), 0.190284)) * 145366.45;
		
		if pdref["power"]["pwr_mgmt"][ind] == 0 then
			if eng_uptrim[ind] == 1 then
				-- RTO
				power_curve = power_pla["RTO"]
				eec_curve = power_eec["RTO"]
			else
				-- TO
				power_curve = power_pla["TO"]
				eec_curve = power_eec["TO"]
			end
		elseif pdref["power"]["pwr_mgmt"][ind] == 1 then
			-- MCT
			power_curve = power_pla["MCT"]
			eec_curve = power_eec["MCT"]
		elseif pdref["power"]["pwr_mgmt"][ind] == 2 then
			-- CLB
			power_curve = power_pla["CLB"]
			eec_curve = power_eec["CLB"]
		elseif pdref["power"]["pwr_mgmt"][ind] == 3 then
			-- CRZ
			power_curve = power_pla["CRZ"]
			eec_curve = power_eec["CRZ"]
		end

		--EEC on / HMU top law
		if pla < 45 then
			-- fuel governing - keep constant Np
			eec_propspeed_pid[ind]["cv"] = xdref["eng_throttle"][ind]
			eec_propspeed_pid[ind]["pv"] = xdref["prop_speed"][ind]
			eec_propspeed_pid[ind]["sp"] = temp_prop_speed
			--eec_propspeed_pid[ind]["ff"] = ( temp_prop_speed * math.sin(math.rad(temp_prop_pitch)) ) / 70
			eec_propspeed_pid[ind]["ff"] = 0
			pid.run(eec_propspeed_pid[ind])
			temp_eng_throttle = eec_propspeed_pid[ind]["cv"]
		else
			-- get commanded engine power
			local eng_power_ratio = curve.lookup(pla, power_curve)
			
			local corr_temp = 0
			if ac_flow 
				corr_temp = polyn.lookup(pressure_alt, xdref["air_temperature"][0], eec_curve)
				
			
			end
			
			
			

			-- EEC limits max power by ITT based on TAT and pressure altitude
			eec_limit = polyn.lookup(pressure_alt, xdref["air_temperature"][0], eec_curve)
			
			-- IAS correction
			if pdref["power"]["adc_ias"][0] > 60 then
				local ias_corr = polyn.lookup(pdref["power"]["adc_ias"], eec_curve)
				eec_limit = eec_limit * ias_corr
			end
			
			if eec_limit < 1 then
				eng_power_ratio = eng_power_ratio * eec_limit
			end
			
			-- PID to set engine throttle to produce FADEC commanded power
			eec_power_pid[ind]["cv"] = xdref["eng_throttle"][ind]
			eec_power_pid[ind]["pv"] = xdref["eng_power"][ind]
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
		if pdref["power"]["pwr_mgmt"][ind] == 0 and eng_atpcs ~= 0 then
			-- TO reserved power
			power_curve = power_pla["RTO"]
		end

		-- get PLA notch engine power
		local eng_power_ratio = curve.lookup(67, power_curve)

		-- limit FDAU power by ITT based on OAT and pressure altitude
		-- TODO lookup in power tables and/or provide sensible calculation???
		--air_pressure
		--air_temperature

		--calculate FDAU torque from power and prop speed for given mode
		if pdref["power"]["pwr_mgmt"][ind] == 0 or pdref["power"]["pwr_mgmt"][ind] == 1 then
			-- TO and MCT
			pdref["power"]["eec_fdau"][ind] = eng_power_ratio
		elseif pdref["power"]["pwr_mgmt"][ind] == 2 or ppdref["power"]["wr_mgmt"][ind] == 3 then
			-- CLB and CRZ
			pdref["power"]["eec_fdau"][ind] = eng_power_ratio / 0.82
		end
	else
		if eng_throttle_last[ind] == 0 then
			--EEC off / HMU base law
			-- get commanded engine NH
			local eng_nh_ratio = curve.lookup(pla, base_pla)

			-- PID to set engine throttle to produce NH
			hmu_nhspeed_pid[ind]["cv"] = xdref["eng_throttle"][ind]
			hmu_nhspeed_pid[ind]["pv"] = xdref["eng_nh"][ind]
			hmu_nhspeed_pid[ind]["sp"] = eng_nh_ratio
			--hmu_nhspeed_pid[ind]["ff"] = ( eng_nh_ratio - 70 ) * 30
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
	if cla < 1.7 then
		xdref["eng_igniter"][ind] = 0
	elseif pdref["power"]["start_cmd"][ind] == 1 and pdref["power"]["start_sel"][0] > 1 then
		-- starter inginition
		if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 then
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
	elseif eng_eec[ind] == 1 and cla > 25.7 and eng_autofeather[ind] == 0 and xdref["eng_nh"][ind] > 30 and xdref["eng_nh"][ind] < 60 then
		-- auto relight
		xdref["eng_igniter"][ind] = 3
	elseif pdref["power"]["man_ign"][0] == 1 then
		-- cont relight
		xdref["eng_igniter"][ind] = 3
	else
		xdref["eng_igniter"][ind] = 0
	end
	
	--low pitch
	if xdref["prop_pitch"][ind] < 14 then
		pdref["power"]["low_pitch_ind"][ind] = 1
		if xdref["on_ground"][1] == 0 and xdref["on_ground"][2] == 0 then

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


function pbrake(pla, cla)
	-- prop break ready
	if xdref["on_ground"][1] == 1 and xdref["on_ground"][2] == 1 and cla < 25.7 and pla <= 35 and xdref["hydraulic_pressure_blue"][0] > 2000 then
		pdref["power"]["prop_brake_ind"][1] = 1
	else
		pdref["power"]["prop_brake_ind"][1] = 0
	end

	if prop_brake > 0 and ( pla > 60 or xdref["hydraulic_pressure_blue"][0] < 1500 ) then
		--prop is failing
		if prop_brake == 1 or prop_brake == 2 then
			xdref["hotel_mode"][0] = 0
		end
		prop_brake = -1
		pdref["power"]["prop_brake_ind"][0] = 1
		pdref["power"]["prop_brake_ind"][2] = 0
	end

	if pdref["power"]["prop_brake_cmd"][0] == 1 then
		--command to engage
		if pdref["power"]["prop_brake_ind"][1] == 1 then
			--prop brake ready
			if prop_brake == 0 then
				-- start engage
				xdref["hotel_mode"][0] = 1
				prop_brake_timer = os.clock()
				prop_brake = 1
				pdref["power"]["prop_brake_ind"][0] = 1
				pdref["power"]["prop_brake_ind"][2] = 0
			elseif prop_brake == 1 and prop_speed[1] == 0 then
				-- prop break engaged
				prop_brake_timer = 0
				prop_brake = 2
				pdref["power"]["prop_brake_ind"][0] = 0
				pdref["power"]["prop_brake_ind"][2] = 1
			end
		else
			--prop not ready
			xdref["master_warning"][0] = 1
		end
	elseif prop_brake == 1 or prop_brake == 2 then
		--stop prop brake engage / release prop brake
		xdref["hotel_mode"][0] = 0
		prop_brake_timer = os.clock()
		prop_brake = 3
		pdref["power"]["prop_brake_ind"][0] = 1
	elseif prop_brake == 3 then
		-- unlocking
		if xdref["prop_speed"][1] > prop_speed_max * 0.2 then
			-- unlocked
			prop_brake_timer = 0
			prop_brake = 0
			pdref["power"]["prop_brake_ind"][0] = 0
			pdref["power"]["prop_brake_ind"][2] = 0
		end
	else
		-- prop brake off
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
	if pdref["power"]["atpcs_test"][0] ~= 0 and pdref["power"]["atpcs_cmd"][0] == 1 and pdref["power"]["pec_cmd"][0] == 1 and pdref["power"]["pec_cmd"][1] == 1 and round(cl[0] * 63, 1) < 1.7 and round(cl[1] * 63, 1) < 1.7 and math.abs(round(pl[0] * 100, 1) - 13) < 1 and math.abs(round(pl[1] * 100, 1) - 13) < 1 then
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
	elseif pdref["power"]["atpcs_cmd"][0] == 1 and pdref["power"]["pwr_mgmt"][0] == 0 and pdref["power"]["pwr_mgmt"][1] == 0 and eng_autofeather[0] ~= 2 and eng_autofeather[1] ~= 2 and round(pdref["power"]["pl"][0] * 100, 1) > 49 and round(pdref["power"]["pl"][1] * 100, 1) > 49 then
		if xdref["eng_torque"][0] > eng_torque_max * 0.46 and xdref["eng_torque"][1] > eng_torque_max * 0.46 then
			--arming conditions met
			if xdref["on_ground"][1] == 1 or xdref["on_ground"][2] == 1 then
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
		elseif xdref["eng_torque"][1] < eng_torque_max * 0.46 then
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
	if pdref["power"]["pwr_mgmt"][0] ~= 0 then
		--reset uptrim and autofeather
		eng_uptrim[0] = 0
		eng_autofeather[0] = 0
	end
	if pdref["power"]["pwr_mgmt"][1] ~= 0 then
		--reset uptrim and autofeather
		eng_uptrim[1] = 0
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


function itt(ind)
	pdref["power"]["eng_itt"][ind] = xdref["eng_itt"][ind] * ( 0.6867 + ( xdref["eng_itt"][ind] * 0.000148 ) )
end


function adc()
	if pdref["power"]["adc_cmd"] == 0 then
		pdref["power"]["adc_ias"][0] = xdref["ias1"]
	elseif pdref["power"]["adc_cmd"] == 0 then
		pdref["power"]["adc_ias"][0] = xdref["ias2"]
	end
end


function power()
	adc()

	--idle gate and gust lock function
	gust_lock = pdref["power"]["gust_lock_cmd"][0]
	if ( xdref["on_ground"][1] == 0 and xdref["on_ground"][2] == 0 ) or pdref["power"]["idle_gate_cmd"][0] == 1 then
		-- both landing gears released
		idle_gate = 1
	elseif ( xdref["on_ground"][1] == 1 or xdref["on_ground"][2] == 1 ) or pdref["power"]["idle_gate_cmd"][0] == 0 then
		-- one landing gear compressed
		idle_gate = 0
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

