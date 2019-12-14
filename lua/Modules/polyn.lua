module("polyn", package.seeall)


function lookup(input1, input2, ltable)
	local result = 0
	local keys = {}
	
	for key in pairs(ltable) do
		table.insert(keys, key)
	end
	table.sort(keys)
	
	for i = 1, #keys do
		if input1 == keys[i] then
			result = calculate_polynomial(input2, ltable[keys[i]])
			break
		elseif input1 < keys[i] then
			if i == 1 then
				-- extrapolate first polynomial
				local diff = keys[i+1] - keys[i]
				local weight = ( input1 - keys[i] ) / diff
				local polynomial = polyn.extrapolate(weigh, keys[i], keys[i+1])
				result = polyn.calculate(input2, polynomial)
			else
				-- aproximate between two polynomials 
				local diff = keys[i] - keys[i-1]
				local weight1 = ( input1 - keys[i-1] ) / diff
				local weight2 = ( keys[i] - input1 ) / diff
				result = ( polyn.calculate(input2, ltable[keys[i-1]]) * weight1 ) + ( polyn.calculate(input2, ltable[keys[i]]) * weight2 )
			end
			break
		elseif i == #keys then
			-- extrapolate last polynomial
			local diff = keys[i] - keys[i-1]
			local weight = ( keys[i] - input1 ) / diff
			local polynomial = extrapolate_polynomial(weigh, keys[i], keys[i-1])
			result = calculate_polynomial(input2, polynomial)
			break
		end
	end
	return result
end


function calculate(input, ltable)
	local result = 0
	local inpexp = 1
	
	for i = 1, #ltable do
		result = result + ( ltable[i] * inpexp )
		inpexp = inpexp * input
	end
	return result
end


function extrapolate(weight, ltable1, ltable2)
	local ltable = {}
	
	if #ltable1 ~= #ltable2 then
		return ltable1
	end
	for i = 1, #ltable do
		local coeff = ltable1[i] + ( ( ltable1[i] - ltable2[i] ) * weight )
		table.insert(ltable, coeff)
	end
	return ltable
end
