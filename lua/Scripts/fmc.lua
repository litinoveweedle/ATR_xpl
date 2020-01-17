-- ATR AIR simulation
-- 2019 @litinoveweedle

if PLANE_ICAO ~= "ATR75" then
	return
end


---- CODE STARTS ----

function dadc()
    pdref["dadc"]["palt"][0] = (1 - math.pow((xdref["air_pressure"][0]/29.92), 0.190284)) * 145366.45;
    pdref["dadc"]["sat"][0] = xdref["sat"][0]
    
    if pdref["dadc"]["adc_cmd"] == 0 then
		pdref["dadc"]["ias"][0] = xdref["ias1"][0]
		pdref["dadc"]["tas"][0] = xdref["tas1"][0]
		pdref["dadc"]["alt"][0] = xdref["alt1"][0]
    else
		pdref["dadc"]["ias"][0] = xdref["ias2"][0]
		pdref["dadc"]["tas"][0] = xdref["tas2"][0]
		pdref["dadc"]["alt"][0] = xdref["alt2"][0]
    end
end



do_often("dadc()")
