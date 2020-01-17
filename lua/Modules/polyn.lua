module("polyn", package.seeall)


function lookup(vars, poly)
	local result = 0
	
	for expn, coef in pairs(poly) do
		local expns = polyn.split(expn, ":")
		if #expns == #vars then
			local term = 1
			for i = 1, #expns do
				term = term * ( vars[i] ^ expns[i] )
			end
			result = result + ( coef * term )
		end
	end
	return result
end


function split(s, delimiter)
    local result = {};
    
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
