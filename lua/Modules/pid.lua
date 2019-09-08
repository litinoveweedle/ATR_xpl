module("pid", package.seeall)


function run(var)
	var["t"] = os.clock()
	if var["t_n"] == nil or var["pv_n"] == nil or var["cv_n"] == nil then
		pid.init(var)
		return
	end
	if paused == 1 then
		var["t_n"] = var["t"]
		return
	end
	local sample_time = var["t"] - var["t_n"]
	if sample_time > 3 * var["ts"] then
		pid.init(var)
		return
	end

	--get limits
	local max_up
	local max_dw
	if var["cv_up"] ~= nil then
		max_up = var["cv_n"] + ( var["cv_up"] * sample_time )
	end
	if var["cv_max"] ~= nil and ( max_up == nil or max_up > var["cv_max"] ) then
		max_up = var["cv_max"]
	end
	if var["cv_dw"] ~= nil then
		max_dw = var["cv_n"] - ( var["cv_dw"] * sample_time )
	end
	if var["cv_min"] ~= nil and ( max_dw == nil or max_dw < var["cv_min"] ) then
		max_dw = var["cv_min"]
	end

	local input_error = var["sp"] - var["pv"]
	local error_der = input_error * sample_time
	local input_der = ( var["pv"] - var["pv_n"] ) / sample_time
	local int_inc = var["ki"] * error_der
	output = var["ff"] + ( var["kp"] * input_error ) + ( var["int"] + int_inc ) - ( var["kd"] * input_der )

	--limit output + integrator clipping
	if max_up ~= nil and output > max_up then
		if output - int_inc < max_up then
			var["int"] = var["int"] + int_inc - ( output - max_up )
		end
		output = max_up
	elseif max_dw ~= nil and output < max_dw then
		if output - int_inc > max_dw then
			var["int"] = var["int"] + int_inc + ( max_dw - output )
		end
		output = max_dw
	else
		var["int"] = var["int"] + int_inc
	end

	var["cv_n"] = output
	var["pv_n"] = var["pv"]
	var["t_n"] = var["t"]
	var["cv"] = output

	if var["log"] == 1 then
		logMsg("PID:" .. round(var["sp"], 5) .. ":" .. round(var["pv"], 5) .. ":" .. round(input_error, 5) .. ":" .. round(var["ff"], 5) .. ":"  .. round(( var["kp"] * input_error ), 5) .. ":" .. round(var["int"], 5) .. ":" .. round(( var["kd"] * input_der ), 5) .. ":" .. round(var["cv"],5))
	end
end


function init(var)
	if var["log"] == nil then
		var["log"] = 0
	end
	if var["ff"] == nil then
		var["ff"] = 0
	end
	if var["ki"] ~= 0 then
		var["int"] = var["cv"] - var["ff"]
		--var["int"] = 0
		--var["int"] = var["cv"]
	else
		var["int"] = 0
	end
	if var["cv_max"] ~= nil and var["cv"] > var["cv_max"] then
		var["cv_n"] = var["cv_max"]
	elseif var["cv_min"] ~= nil and var["cv"] < var["cv_min"] then
		var["cv_n"] = var["cv_min"]
	else
		var["cv_n"] = var["cv"]
	end
	var["t_n"] = var["t"]
	var["pv_n"] = var["pv"]

	if var["log"] == 1 then
		logMsg("PID RESET")
	end
end
