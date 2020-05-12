module("gain", package.seeall)


function run(var)
	var["t"] = os.clock()
	if var["out_n"] == nil then
		gain.init(var)
		return
	end
	if paused == 1 then
		var["t_n"] = var["t"]
		return
	end
	local sample_time = var["t"] - var["t_n"]
	if sample_time > 3 * var["ts"] then
		gain.init(var)
		return
	end

	--get limits
	local max_up
	local max_dw
	if var["out_up"] ~= nil then
		max_up = var["out_n"] + ( var["out_up"] * sample_time )
	end
	if var["out_max"] ~= nil and ( max_up == nil or max_up > var["out_max"] ) then
		max_up = var["out_max"]
	end
	if var["out_dw"] ~= nil then
		max_dw = var["out_n"] - ( var["out_dw"] * sample_time )
	end
	if var["out_min"] ~= nil and ( max_dw == nil or max_dw < var["out_min"] ) then
		max_dw = var["out_min"]
	end

	output = var["k"] * var["in"]
	
	-- discrete low pass filter, cuts out the high frequency noise
	if var["rc"] ~= nil then
		local filter = sample_time / ( var["rc"] +  sample_time )
		output = var["out_n"] + ( filter * ( output - var["out_n"] ) )
	end

	--limit output + integrator clipping
	if max_up ~= nil and output > max_up then
		var["out"] = max_up
	elseif max_dw ~= nil and output < max_dw then
		var["out"] = max_dw
	else
		var["out"] = output
	end

	var["out_n"] = var["out"]
	var["t_n"] = var["t"]

	if var["log"] == 1 then
		logMsg("GAIN:" .. var["in"] .. ":" .. var["out"])
	end
end


function init(var)
	if var["log"] == nil then
		var["log"] = 0
	end

	if var["out_max"] ~= nil and var["in"] * var["k"] > var["out_max"] then
		var["out"] = var["out_max"]
	elseif var["out_min"] ~= nil and var["in"] * var["k"] < var["out_min"] then
		var["out"] = var["out_min"]
	else
		var["out"] = var["k"] * var["in"]
	end
	
	if var["rc"] == nil and var["frq"] ~= nil and var["frq"] ~= 0 then
		var["rc"] = 1 / ( var["frq"] * 2 * pi )
	end

	var["out_n"] = var["out"]

	var["t_n"] = var["t"]

	if var["log"] == 1 then
		logMsg("GAIN RESET")
	end
end
