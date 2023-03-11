local Vec2 = require("/lib/vec2")

local Card = {}
Card.__index = Card

local COLORS =
	{
		["RED"] = {1, 0, 0},
		["GREEN"] = {0, 1, 0},
		["BLUE"] = {0, 0, 1},
		["PURPLE"] = {1, 0, 1},
		["GRAY"] = {.5, .5, .5}
	}

local CARDS_IMG_FRONT_DIR = "/sprites/cards/front/"
local CARDS_IMG_FRONT = 
	{
		["DEFAULT"] = love.graphics.newImage(CARDS_IMG_FRONT_DIR.."default.png"),
		["RED"] = love.graphics.newImage(CARDS_IMG_FRONT_DIR.."red.png"),
		["GREEN"] = love.graphics.newImage(CARDS_IMG_FRONT_DIR.."green.png"),
		["BLUE"] = love.graphics.newImage(CARDS_IMG_FRONT_DIR.."blue.png"),
		["PURPLE"] = love.graphics.newImage(CARDS_IMG_FRONT_DIR.."purple.png")
	}

local CARDS_IMG_BACK_DIR = "/sprites/cards/back/"
local CARDS_IMG_BACK = 
	{
		["RED"] = love.graphics.newImage(CARDS_IMG_BACK_DIR.."red.png"),
		["GREEN"] = love.graphics.newImage(CARDS_IMG_BACK_DIR.."green.png"),
		["BLUE"] = love.graphics.newImage(CARDS_IMG_BACK_DIR.."blue.png"),
		["PURPLE"] = love.graphics.newImage(CARDS_IMG_BACK_DIR.."purple.png")
	}
	

local CWIDTH, CHEIGHT = CARDS_IMG_FRONT["DEFAULT"]:getWidth() / 2, CARDS_IMG_FRONT["DEFAULT"]:getHeight() / 2

function Card:new(x, y, w, h, color, text, textColor, textOutline, isImage, flipped)
	local btn = {}

	btn.pos = Vec2:new(x or 0,y or 0)
	btn.w, btn.h = w, h
	
	btn.color = color or "RED"
	
	btn.text = text or ""
	if type(textColor) == "string" then
		btn.textColor = COLORS[textColor] or {1, 1, 1}
	else
		btn.textColor = textColor or {1, 1, 1}
	end
	btn.textOutline = textOutline
	
	btn.swaying = false
	btn.disabled = false
	
	btn.flipped = flipped or false
	btn.isImage = isImage or false
	
	btn.rotation = 0
	
	return setmetatable(btn, Card)
end

function Card:setTextColor(textColor)
	if type(textColor) == "string" then
		self.textColor = COLORS[textColor] or {1, 1, 1}
	else
		self.textColor = textColor or {1, 1, 1}
	end
end

function Card:disable()
	self.disabled = true

	self.color = "GRAY"
	self.textColor = {.5, .5, .5}
end

function Card:draw()
	local r, g, b, a = love.graphics.getColor()
	
	if self.isImage then
		if self.flipped then
			if self.swaying then
				local t = love.timer.getTime()
				self.rotation = math.sin(t) * .125
				love.graphics.draw(CARDS_IMG_BACK[self.color], self.pos.x, self.pos.y, self.rotation, 1, 1, CWIDTH, CHEIGHT)
			else
				love.graphics.draw(CARDS_IMG_BACK[self.color], self.pos.x - CWIDTH, self.pos.y - CHEIGHT)
			end
		else
			love.graphics.draw(CARDS_IMG_FRONT[self.color], self.pos.x - CWIDTH, self.pos.y - CHEIGHT)
		end
	else
		love.graphics.setColor(COLORS[self.color])
		love.graphics.rectangle("fill", self.pos.x - self.w / 2, self.pos.y - self.h / 2, self.w, self.h, 5, 5)
	end
	
	local f = love.graphics.getFont()
    local fw = f:getWidth(self.text)
    local fh = f:getHeight()
	
	if self.textOutline then
		love.graphics.setColor(self.textOutline)
		love.graphics.print(self.text, (self.pos.x - fw / 2) + 10, (self.pos.y - fh / 2) + 10)
	end
	love.graphics.setColor(self.textColor)
	love.graphics.print(self.text, self.pos.x - fw / 2, self.pos.y - fh / 2)
	love.graphics.setColor(r, g, b, a)
end

return Card