module ("util", package.seeall)

function vectorNorm(x, y)
	return math.sqrt (math.pow (x, 2) + math.pow (y, 2) )
end

function pointDistance(x1, y1, x2, y2)
    return vectorNorm (x2 - x1, y2 - y1)
end

function normalizeVector (x, y, size)
	-- normalizes a vector to have norm == size
	local norm = vectorNorm (x, y) / (size or 1) 
	if norm == 0 then 
		return x, y
	end
	return x / norm, y / norm
end

function vectorAngle(v1, v2, u1, u2)
	return math.acos ( (v1*u1 + v2*u2) / (vectorNorm (v1, v2) * vectorNorm (u1, u2) ) )	
end