module("pid", package.seeall)


function run(var)
	var["t"] = os.clock()
	if var["t_n"] == nil or var["pv_n"] == nil or var["cv_n"] == nil then	
		pid.init(var)
		return
	end
	local sample_time = var["t"] - var["t_n"]
	--logMsg("sample_time: " .. sample_time)
	if sample_time > 10 * var["ts"] or sample_time < var["ts"] then
		pid.init(var)
		return
	end
	--logMsg("set_point: " .. var["sp"])
	--logMsg("proc_var: " .. var["pv"])
	--logMsg("feed_fwd: " .. var["ff"])
	--logMsg("ctrl_var: " .. var["cv"])
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
	--logMsg("max_up: " .. max_up)
	--logMsg("max_dw: " .. max_dw)

	local input_error = var["sp"] - var["pv"]
	--logMsg("input_error: " .. input_error)
	local error_der = input_error * sample_time
	--logMsg("error_der: " .. error_der)
	local input_der = ( var["pv"] - var["pv_n"] ) / sample_time
	--logMsg("input_der: " .. input_der)
	local int_inc = var["ki"] * error_der
	--logMsg("proportion: " .. ( var["kp"] * input_error ))
	--logMsg("integral: " .. var["int"])
	--logMsg("integral inc: " .. int_inc )
	--logMsg("derivative: " .. ( var["kd"] * input_der ))
					
	output = var["ff"] + ( var["kp"] * input_error ) + ( var["int"] + int_inc ) - ( var["kd"] * input_der )
	--logMsg("output 1: " .. output)
	
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
	--logMsg("output 2: " .. var["cv"])
end


function init(var)
	if var["ff"] == nil then
		var["ff"] = 0
	end
	if var["ki"] ~= 0 then
		--var["int"] = var["cv"] - var["ff"]
		var["int"] = 0
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
end
