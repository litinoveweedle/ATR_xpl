-- ATR joystick mapping
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- ATR DATAREFS ----


---- ATR SHARED DATAREFS ----


---- XPL DATAREFS ----

local axis = dataref_table("sim/joystick/joystick_axis_values")


---- CODE STARTS ----

local axis_pl1 = 0
local axis_pl2 = 0
local axis_cl1 = 0
local axis_cl2 = 0


function joystick()
	if axis[axis_pl1] ~= nil then
		pl[0] = axis[axis_pl1]
	end
	if axis[axis_pl2] ~= nil then
		pl[1] = axis[axis_pl2]
	end
	if axis[axis_cl1] ~= nil then
		cl[0] = axis[axis_cl1]
	end
	if axis[axis_cl2] ~= nil then
		cl[1] = axis[axis_cl2]
	end
end

do_every_frame("joystick()")

