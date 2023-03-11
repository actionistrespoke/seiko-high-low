local Vec2 = require("/lib/vec2")

local Cutscene = {}
Cutscene.__index = Cutscene

function Cutscene:new(filepath)
	local ch = love.filesystem.load(filepath)
	local data = ch()
	
	local cutscene = {}

	cutscene.sounds = {}
	cutscene.images = {}
	cutscene.border = nil
	cutscene.params = data.frames

	cutscene.cIndex = 0
	cutscene.currentFrame = 1
	
	cutscene.finished = false
	cutscene.isPlaying = false
	cutscene.playingSound = false
	
	cutscene.timeStarted = nil
	cutscene.timePlaying = 0
	
	for f = 1, #data.frames do
		cutscene.images[f] = love.graphics.newImage('/'..data.imageSrc..f..".png")
		
		if data.frames[f].sound then
			cutscene.sounds[f] = love.audio.newSource(data.frames[f].sound, "static")
		else
			cutscene.sounds[f] = nil
		end
	end
	
	if data.imageBorderSrc then
		cutscene.border = love.graphics.newImage('/'..data.imageBorderSrc)
	end
	
	if data.imageBackgroundSrc then
		cutscene.background = love.graphics.newImage('/'..data.imageBackgroundSrc)
	end
	
	return setmetatable(cutscene, Cutscene)
end

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Cutscene:next()
	local pms = self.params[self.currentFrame]
		
	if type(pms.caption) == "string" then
		if self.currentFrame >= #self.params then
			self:stop()
			return
		end
		self.timeStarted = -pms.duration
	else
		if self.currentFrame >= #self.params and self.cIndex >= #pms.caption then
			self:stop()
			return
		end
		self.timePlaying = self.timePlaying + (pms.duration/#pms.caption)
	end
end

function Cutscene:play()
	local t = love.timer.getTime()
	local dt = love.timer.getDelta()
	local duration = self.params[self.currentFrame].duration
	
	if self.isPlaying then
		self.timePlaying = self.timePlaying + dt
	
		local offStart, offEnd = self.params[self.currentFrame].offsetStart, self.params[self.currentFrame].offsetEnd
		local frameOffset
		
		if offStart and offEnd then
			frameOffset = Vec2:lerp(offStart, offEnd, self.timePlaying/duration)
		else
			frameOffset = {x = 0, y = 0}
		end
		
		if self.params[self.currentFrame].withBackground then
			love.graphics.draw(self.background, 0, 0)
		end
		
		love.graphics.draw(self.images[self.currentFrame], frameOffset.x, frameOffset.y)
		
		if self.params[self.currentFrame].overlayBorder then 
			love.graphics.draw(self.border, 0, 0)
		end
		
		local cap = self.params[self.currentFrame].caption
		if type(cap) == "string" then
			love.graphics.printf(cap, 25, 500, 750, "center")
		else
			self.cIndex = math.min(round(#cap * self.timePlaying/duration + .5), #cap) --Do not ask me about this! :)
			love.graphics.printf(cap[self.cIndex], 25, 500, 750, "center")
		end
		
		if self.sounds[self.currentFrame] and not self.playingSound then
			self.playingSound = true
			self.sounds[self.currentFrame]:setVolume(self.params[self.currentFrame].volume or 1)
			self.sounds[self.currentFrame]:play()
		end
		
		if t > (self.timeStarted + duration) then
			if self.currentFrame >= #self.params then
				self:stop()
			else
				self.currentFrame = self.currentFrame + 1
				self.playingSound = false
			end
			self.timeStarted = t
			self.timePlaying = 0
		end
	else
		self.isPlaying = true
		
		self.timeStarted = t
		self.timePlaying = 0
	end
end

function Cutscene:stop()
	self.finished = true
	self.isPlaying = false
	for s = 1, #self.sounds do
		if self.sounds[s] and self.sounds[s]:isPlaying() then
			self.sounds[s]:stop()
		end
	end
end

return Cutscene