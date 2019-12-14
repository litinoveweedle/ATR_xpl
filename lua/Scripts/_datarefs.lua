-- ATR systems simulation
-- 2019 @litinoveweedle


---- ATR PRIVATE DATAREFS ----
pdref = {
	["ccas"] = {},
	["air"] = {},
	["power"] = {},
}

-- power levers
pdref["power"]["pl"] = create_dataref_table("atr/power/pl", "FloatArray")
pdref["power"]["pl"][0] = 0.131
pdref["power"]["pl"][1] = 0.131

-- condition levers
pdref["power"]["cl"] = create_dataref_table("atr/power/cl", "FloatArray")
pdref["power"]["cl"][0] = 0.66
pdref["power"]["cl"][1] = 0.66

-- power mgmt knob
pdref["power"]["pwr_mgmt"] = create_dataref_table("atr/power/pwr_mgmt", "IntArray")
pdref["power"]["pwr_mgmt"][0] = 0
pdref["power"]["pwr_mgmt"][1] = 0

-- EEC switch and indicator
pdref["power"]["eec_cmd"] = create_dataref_table("atr/power/eec_cmd", "IntArray")
pdref["power"]["eec_cmd"][0] = 1
pdref["power"]["eec_cmd"][1] = 1
pdref["power"]["eec_ind"] = create_dataref_table("atr/power/eec_ind", "IntArray")
pdref["power"]["eec_ind"][0] = 0
pdref["power"]["eec_ind"][1] = 0

-- EEC target torque
pdref["power"]["eec_fdau"] = create_dataref_table("atr/power/eec_fdau", "FloatArray")
pdref["power"]["eec_fdau"][0] = 1
pdref["power"]["eec_fdau"][1] = 1

-- start switch and indicator and ignition selector
pdref["power"]["start_cmd"] = create_dataref_table("atr/power/start_cmd", "IntArray")
pdref["power"]["start_cmd"][0] = 0
pdref["power"]["start_cmd"][1] = 0
pdref["power"]["start_ind"] = create_dataref_table("atr/power/start_ind", "IntArray")
pdref["power"]["start_ind"][0] = 0
pdref["power"]["start_ind"][1] = 0
pdref["power"]["start_sel"] = create_dataref_table("atr/power/start_sel", "Int")
pdref["power"]["start_sel"][0] = 0

pdref["power"]["man_ign"] = create_dataref_table("atr/power/start_sel", "Int")
pdref["power"]["man_ign"][0] = 0

-- ATPCS button, indicator and test rotaty selector
pdref["power"]["atpcs_cmd"] = create_dataref_table("atr/power/atpcs_cmd", "Int")
pdref["power"]["atpcs_cmd"][0] = 1
pdref["power"]["atpcs_ind"] = create_dataref_table("atr/power/atpcs_ind", "Int")
pdref["power"]["atpcs_ind"][0] = 0
pdref["power"]["atpcs_test"] = create_dataref_table("atr/power/atpcs_test", "Int")
pdref["power"]["atpcs_test"][0] = 0

-- uptrim and autofeather indicators
pdref["power"]["uptrim_ind"] = create_dataref_table("atr/power/uptrim_ind", "IntArray")
pdref["power"]["uptrim_ind"][0] = 0
pdref["power"]["uptrim_ind"][1] = 0

-- gust lock lever
pdref["power"]["gust_lock_cmd"] = create_dataref_table("atr/power/gust_lock_cmd", "Int")
pdref["power"]["gust_lock_cmd"][0] = 1

-- idle gate lever and indicator
pdref["power"]["idle_gate_cmd"] = create_dataref_table("atr/power/idle_gate_cmd", "Int")
pdref["power"]["idle_gate_cmd"][0] = 0
pdref["power"]["idle_gate_ind"] = create_dataref_table("atr/power/idle_gate_ind", "Int")
pdref["power"]["idle_gate_ind"][0] = 0

-- propeller brake for hotel mode switch
pdref["power"]["prop_brake_cmd"] = create_dataref_table("atr/power/prop_brake_cmd", "Int")
pdref["power"]["prop_brake_cmd"][0] = 0
-- propeller brake indicators [0] - unlock, [1] - ready, [2] - engaged
pdref["power"]["prop_brake_ind"] = create_dataref_table("atr/power/prop_brake_ind", "IntArray")
pdref["power"]["prop_brake_ind"][0] = 0
pdref["power"]["prop_brake_ind"][1] = 0
pdref["power"]["prop_brake_ind"][2] = 0

--low prop pitch indicator
pdref["power"]["low_pitch_ind"] = create_dataref_table("atr/power/low_pitch_ind", "IntArray")
pdref["power"]["low_pitch_ind"][0] = 0
pdref["power"]["low_pitch_ind"][1] = 0

-- prop synchrophaser
pdref["power"]["sync_cmd"] = create_dataref_table("atr/power/sync_cmd", "Int")
pdref["power"]["sync_cmd"][0] = 1
pdref["power"]["sync_ind"] = create_dataref_table("atr/power/sync_ind", "Int")
pdref["power"]["sync_ind"][0] = 0

-- PEC switch and indicator
pdref["power"]["pec_cmd"] = create_dataref_table("atr/power/pec_cmd", "IntArray")
pdref["power"]["pec_cmd"][0] = 1
pdref["power"]["pec_cmd"][1] = 1
pdref["power"]["pec_ind"] = create_dataref_table("atr/power/pec_ind", "IntArray")
pdref["power"]["pec_ind"][0] = 0
pdref["power"]["pec_ind"][1] = 0

pdref["power"]["eng_nl"] = create_dataref_table("atr/power/nl_perc", "FloatArray")

-- DADC computer switch
pdref["power"]["adc_cmd"] = create_dataref_table("atr/power/adc_cmd", "Int")
pdref["power"]["adc_cmd"][0] = 0

pdref["power"]["adc_ias"] = create_dataref_table("atr/power/adc_ias", "Float")
pdref["power"]["adc_ias"][0] = 0


--corrected ITT
pdref["power"]["eng_itt"] = create_dataref_table("atr/power/eng_itt", "FloatArray")
pdref["power"]["eng_itt"][0] = 0
pdref["power"]["eng_itt"][1] = 0

-- eng bleed switch and annunciator
pdref["air"]["bleed_cmd"] = create_dataref_table("atr/air/bleed_cmd", "IntArray")
pdref["air"]["bleed_cmd"][0] = 1
pdref["air"]["bleed_cmd"][1] = 0
pdref["air"]["bleed_ind"] = create_dataref_table("atr/air/bleed_ind", "IntArray")
pdref["air"]["bleed_ind"][0] = 0
pdref["air"]["bleed_ind"][1] = 0


pdref["ccas"]["ccas_ind"] = create_dataref_table("atr/ccas/anuciators", "IntArray")
pdref["ccas"]["ccas_ind"][0] = 0


if PLANE_ICAO ~= "ATR75" then
	return
end


---- XPL DATAREFS ----

xdref = {}

-- sim paused
xdref["paused"] = dataref_table("sim/time/paused")

-- annunciators
xdref["master_warning"] = dataref_table("sim/cockpit/warnings/annunciators/master_warning")
xdref["master_caution"] = dataref_table("sim/cockpit/warnings/annunciators/master_caution")

-- weight on wheels - 0 nose wheel, 1 left main, 2 right main
xdref["on_ground"] = dataref_table("sim/flightmodel2/gear/on_ground")

--prop speed
xdref["prop_speed"] = dataref_table("sim/flightmodel2/engines/prop_rotation_speed_rad_sec")

--prop mode - 0 is feathered, 1 is normal, 2 is beta, 3 is reverse
xdref["prop_mode"] = dataref_table("sim/flightmodel/engine/ENGN_propmode")

--commanded prop pitch
xdref["prop_pitch"] = dataref_table("sim/flightmodel/engine/POINT_pitch_deg_use")

--prop feather command
xdref["prop_feather"] = dataref_table("sim/cockpit2/engine/actuators/manual_feather_prop")

--prop sync switch
xdref["prop_sync"] = dataref_table("sim/cockpit2/switches/prop_sync_on")

-- only 0 - shut off, 0.5 - low idle , 1 - high idle
xdref["eng_mixture"] = dataref_table("sim/flightmodel/engine/ENGN_mixt")

-- commanded throttle
xdref["eng_throttle"] = dataref_table("sim/flightmodel/engine/ENGN_thro_use")

-- engine power produced
xdref["eng_power"] = dataref_table("sim/cockpit2/engine/indicators/power_watts")

-- engine torque produced
xdref["eng_torque"] = dataref_table("sim/cockpit2/engine/indicators/torque_n_mtr")

-- engine NH(N1/power turbine), NL(N2/free turbine) percent
xdref["eng_nh"] = dataref_table("sim/cockpit2/engine/indicators/N1_percent")
xdref["eng_np"] = dataref_table("sim/cockpit2/engine/indicators/N2_percent")

-- engine ITT
xdref["eng_itt"] = dataref_table("sim/flightmodel2/engines/ITT_deg_C")
xdref["eng_itt_corr"] = dataref_table("sim/flightmodel/engine/ENGN_ITT_c")

-- engine igniters
xdref["eng_igniter"] = dataref_table("sim/cockpit2/engine/actuators/igniter_on")

-- engine bleed air
xdref["eng_bleed_val"] = dataref_table("sim/cockpit2/bleedair/actuators/engine_bleed_sov")

xdref["eng_n2"] = dataref_table("sim/cockpit2/engine/indicators/N2_percent")


-- hotel mode prop brake stop ratio
xdref["hotel_mode"] = dataref_table("sim/cockpit2/switches/hotel_mode")

-- hydraulic pressure in blue system
xdref["hydraulic_pressure_blue"] = dataref_table("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")

-- barometric pressure at the point the current flight, 29.92+-
xdref["air_pressure"] = dataref_table("sim/weather/barometer_current_inhg")

-- air temperature outside the aircraft (at altitude)
xdref["air_temperature"] = dataref_table("sim/weather/temperature_ambient_c")

-- indicated air speed
xdref["ias1"] = dataref_table("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
xdref["ias2"] = dataref_table("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")


-- pressurization packs, off or on
xdref["pack_left"] = dataref_table("sim/cockpit2/bleedair/actuators/pack_left")
xdref["pack_right"] = dataref_table("sim/cockpit2/bleedair/actuators/pack_right")

xdref["duct_press_center"] = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_center")
xdref["duct_press_left"] = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_left")
xdref["duct_press_right"] = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_right")

xdref["duct_left_val"] = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_left")
xdref["duct_right_val"] = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_right")
