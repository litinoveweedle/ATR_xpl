-- ATR systems simulation
-- 2019 @litinoveweedle


---- ATR PRIVATE DATAREFS ----

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


eng_nl = create_dataref_table("atr/power/nl_perc", "FloatArray")

--corrected ITT
--eng_itt_corr = create_dataref_table("atr/power/eng_itt", "FloatArray")
--eng_itt_corr[0] = 0
--eng_itt_corr[1] = 0

-- eng bleed switch and annunciator
bleed_cmd = create_dataref_table("atr/air/bleed_cmd", "IntArray")
bleed_cmd[0] = 1
bleed_cmd[1] = 0
bleed_ind = create_dataref_table("atr/air/bleed_ind", "IntArray")
bleed_ind[0] = 0
bleed_ind[1] = 0


ccas_ind = create_dataref_table("atr/ccas/anuciators", "IntArray")
ccas_ind[0] = 0


if PLANE_ICAO ~= "ATR75" then
	return
end


---- XPL DATAREFS ----

-- sim paused
paused = dataref_table("sim/time/paused")

-- annunciators
master_warning = dataref_table("sim/cockpit/warnings/annunciators/master_warning")
master_caution = dataref_table("sim/cockpit/warnings/annunciators/master_caution")

-- weight on wheels - 0 nose wheel, 1 left main, 2 right main
on_ground = dataref_table("sim/flightmodel2/gear/on_ground")

--prop speed
prop_speed = dataref_table("sim/flightmodel2/engines/prop_rotation_speed_rad_sec")

--prop mode - 0 is feathered, 1 is normal, 2 is beta, 3 is reverse
prop_mode = dataref_table("sim/flightmodel/engine/ENGN_propmode")

--commanded prop pitch
prop_pitch = dataref_table("sim/flightmodel/engine/POINT_pitch_deg_use")

--prop feather command
prop_feather = dataref_table("sim/cockpit2/engine/actuators/manual_feather_prop")

--prop sync switch
prop_sync = dataref_table("sim/cockpit2/switches/prop_sync_on")

-- only 0 - shut off, 0.5 - low idle , 1 - high idle
eng_mixture = dataref_table("sim/flightmodel/engine/ENGN_mixt")

-- commanded throttle
eng_throttle = dataref_table("sim/flightmodel/engine/ENGN_thro_use")

-- engine power produced
eng_power = dataref_table("sim/cockpit2/engine/indicators/power_watts")

-- engine torque produced
eng_torque = dataref_table("sim/cockpit2/engine/indicators/torque_n_mtr")

-- engine NH(N1/power turbine), NL(N2/free turbine) percent
eng_nh = dataref_table("sim/cockpit2/engine/indicators/N1_percent")
eng_np = dataref_table("sim/cockpit2/engine/indicators/N2_percent")

-- engine ITT
eng_itt = dataref_table("sim/flightmodel2/engines/ITT_deg_C")
eng_itt_corr = dataref_table("sim/flightmodel/engine/ENGN_ITT_c")

-- engine bleed air
eng_bleed_val = dataref_table("sim/cockpit2/bleedair/actuators/engine_bleed_sov")

eng_n2 = dataref_table("sim/cockpit2/engine/indicators/N2_percent")


-- hotel mode prop brake stop ratio
hotel_mode = dataref_table("sim/cockpit2/switches/hotel_mode")

-- hydraulic pressure in blue system
hydraulic_pressure_blue = dataref_table("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")

-- barometric pressure at the point the current flight, 29.92+-
air_pressure = dataref_table("sim/weather/barometer_current_inhg")

-- air temperature outside the aircraft (at altitude)
air_temperature = dataref_table("sim/weather/temperature_ambient_c")




-- pressurization packs, off or on
pack_left = dataref_table("sim/cockpit2/bleedair/actuators/pack_left")
pack_right = dataref_table("sim/cockpit2/bleedair/actuators/pack_right")

duct_press_center = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_center")
duct_press_left = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_left")
duct_press_right = dataref_table("sim/cockpit2/bleedair/indicators/bleed_available_right")

duct_left_val = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_left")
duct_right_val = dataref_table("sim/cockpit2/bleedair/actuators/isol_valve_right")
