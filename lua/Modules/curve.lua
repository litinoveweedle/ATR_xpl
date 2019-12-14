module("curve", package.seeall)


function lookup(input, ltable)
	local result = 0
	
	for i = 1, #ltable, 2 do
		if input == ltable[i] then
			result = ltable[i+1]
			break
		elseif input < ltable[i] then
			if i == 1 then
				result = ltable[i+1]
			else
				result = ltable[i-1] + ( ( ( ltable[i+1] - ltable[i-1] ) / ( ltable[i] - ltable[i-2] ) ) * ( input - ltable[i-2] ) )
			end
			break
		end
	end
	return result
end
