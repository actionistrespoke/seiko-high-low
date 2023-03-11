local Vec2 = {}
Vec2.__index = Vec2

function Vec2:new(x, y)
	local vector = {}
	
	vector.x = x or 0
	vector.y = y or 0
	
	return setmetatable(vector, Vec2)
end

function Vec2:add(v1, v2)
	return Vec2:new(v1.x + v2.x, v1.y + v2.y)
end

function Vec2:sub(v1, v2)
	return Vec2:new(v1.x - v2.x, v1.y - v2.y)
end

function Vec2:mul(v1, v2)
	return Vec2:new(v1.x * v2.x, v1.y * v2.y)
end

local function lerp(a,b,t) return (1-t)*a + t*b end

function Vec2:lerp(v1, v2, s)
	local f = f or 0
	return Vec2:new(lerp(v1.x, v2.x, s), lerp(v1.y, v2.y, s))
end

return Vec2