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