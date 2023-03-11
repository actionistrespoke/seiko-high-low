require("/lib/animation")
require("/lib/rand2")
local mtw = twister()

local Vec2 = require("/lib/vec2")
local Card = require("/lib/card")
local Cutscene = require("/lib/cutscene")
local function lerp(a,b,t) return (1-t)*a + t*b end

-- CONSTANTS --
CARDS = {}
CARD_ROW_COLORS = {
	"RED",
	"GREEN",
	"BLUE",
	"PURPLE"
}

CARD_ANIM_SPEED = 2
SPEECH_ANIM_SPEED = 1.5
NOTICE_DISPLAY_SPEED = 1

CARDS_POSITION_X = 60
CARDS_POSITION_Y = 80

CARDS_BG_POSITION_X = 40
CARDS_BG_POSITION_Y = 40

MAIN_CARD_POSITION_X = 325
MAIN_CARD_POSITION_Y = 350

GUESS_CARD_POSITION_X = 125
GUESS_CARD_POSITION_Y = 350

TWINDOW_ICON_DIR = "/sprites/title/titleicon.png"

CUTSCENE_DIR = "/sprites/cutscene/introcutscene.lua"
W_CUTSCENE_DIR = "/sprites/cutscene/wincutscene.lua"

TITLE_COINS_DIR = "/sprites/title/coins.png"
TITLE_SCREEN_DIR = "/sprites/title/seiko.png"
TITLE_TEXT_DIR = "/sprites/title/title.png"

WIN_COINS_DIR = "/sprites/title/coinsnobg.png"
WIN_SCREEN_DIR = "/sprites/title/seikowin.png"
WIN_BG_DIR = "/sprites/title/winbg.png"

BG_GUN_DIR = "/sprites/bg/gun.png"
BG_LIGHT_DIR = "/sprites/bg/spotlight.png"
BG_CARDS_DIR = "/sprites/bg/bloodbg.png"

SBUBBLE_HIGH_DIR = "/sprites/bg/high.png"
SBUBBLE_LOW_DIR = "/sprites/bg/low.png"
NOTICE_WIN_DIR = "/sprites/bg/win.png"
NOTICE_LOSE_DIR = "/sprites/bg/lose.png"

SPRITE_DIR = "/sprites/seiko/sprite.lua"
SWEAT_DIR = "/sprites/seiko/sweat.png"

SPRITE_POSITION_X = 400
SPRITE_POSITION_Y = 100

SPRITE_MAX_FRAMES = 15

GUN_POSITION_X = 255
GUN_POSITION_Y = 70

SBUBBLE_POSITION_X = 650
SBUBBLE_POSITION_Y = 250

NOTICE_POSITION_X = 50
NOTICE_POSITION_Y = 80

FONTS = {
	["SYS"] = love.graphics.newFont("/font/times.ttf", 24, "mono"),
	["DEFAULT"] = love.graphics.newFont("/font/runescape_uf.ttf", 32, "mono"),
	["SMALL"] = love.graphics.newFont("/font/runescape_uf.ttf", 16, "mono"),
	["MEDIUM"] = love.graphics.newFont("/font/runescape_uf.ttf", 64, "mono"),
	["BIG"] = love.graphics.newFont("/font/runescape_uf.ttf", 160, "mono")
}

SFX = {
	["BADCARD"] = love.audio.newSource("/sfx/bad_card.wav", "static"),
	["GOODCARD"] = love.audio.newSource("/sfx/good_card.wav", "static"),

	["GUNFIRED"] = love.audio.newSource("/sfx/gun.wav", "static"),
	["GUNEMPTY"] = love.audio.newSource("/sfx/gun_empty.wav", "static"),

	["WIN"] = love.audio.newSource("/sfx/youwin.mp3", "static")
}

BGM = {
	["TITLE"] = love.audio.newSource("/bgm/titletheme.wav", "stream"),
	["GAME"] = love.audio.newSource("/bgm/seikoend.wav", "stream"),
	["GAME_FINAL"] = love.audio.newSource("/bgm/konimidnight.wav", "stream"),
	["WIN"] = love.audio.newSource("/bgm/win.wav", "stream"),
	["ENDING"] = love.audio.newSource("/bgm/ending.wav", "stream")
}

BGM["TITLE"]:setVolume(0.5)
BGM["TITLE"]:setLooping(true)

BGM["GAME"]:setVolume(0.5)
BGM["GAME"]:setLooping(true)

BGM["GAME_FINAL"]:setVolume(0)
BGM["GAME_FINAL"]:setLooping(true)

BGM["WIN"]:setVolume(0.6)
BGM["ENDING"]:setVolume(0.3)
----------------------

-- VARS --
mainCard = nil
guessCard = nil
mainCardPosition = nil
guessCardPosition = nil

cardCurrentRow = 1
cardCurrentCol = 1

guessCurrentRow = 1
guessCurrentCol = 1

playerMoney = 5
currentRound = 1
spriteCounter = 0

gameState = -2
gameTimer = -1
gameDifficulty = 0

bubbleGuess = 0
bubbleTimer = -1

noticeStatus = 0
noticeTimer = -1

rouletteChance = 6
rouletteTimer = -1

fMusicTimer = 0
fMusicVolume = 0
----------------------

-- FUNCTIONS --
function initializeIntroCutscene()
	introCutscene = Cutscene:new(CUTSCENE_DIR)
	--We'll do this here too, I guess.
	winCutscene = Cutscene:new(W_CUTSCENE_DIR)
end

function initializeTitleScreen()
	local wIconImageData = love.image.newImageData(TWINDOW_ICON_DIR)
	love.window.setIcon(wIconImageData)
	
	titleScreen = love.graphics.newImage(TITLE_SCREEN_DIR)
	
	titleCoins = love.graphics.newImage(TITLE_COINS_DIR)
	titleCoinsW, titleCoinsH = titleCoins:getWidth(), titleCoins:getHeight()
	coinPosition = 0
	
	titleText = love.graphics.newImage(TITLE_TEXT_DIR)
	titleTextW, titleTextH = titleText:getWidth(), titleText:getHeight()
	
	winCoins = love.graphics.newImage(WIN_COINS_DIR)
	winScreen = love.graphics.newImage(WIN_SCREEN_DIR)
	winBackground = love.graphics.newImage(WIN_BG_DIR)
end

function renderTitleScreen()
	local t = love.timer.getTime()
	
	local coinSpeed = 25
	local coinPosition = (coinPosition + coinSpeed*t) % titleCoinsH
	love.graphics.draw(titleCoins, 0, coinPosition)
	love.graphics.draw(titleCoins, 0, coinPosition - titleCoinsH)
	
	love.graphics.draw(titleScreen, 0, 0)
	
	local rotation = math.sin(t) * .125
	love.graphics.draw(titleText, 200, 200, rotation, 1.5, 1.5, titleTextW/2, titleTextH/2)
	
	love.graphics.setFont(FONTS["DEFAULT"])
	if math.floor(t) % 2 == 0 then 
		love.graphics.printf("PRESS ANY KEY TO START!", 50, 450, 999, "left")
	end
end

function renderWinScreen()
	local t = love.timer.getTime()
	
	love.graphics.draw(winBackground, 0, 0)
	
	local coinSpeed = 75
	local coinPosition = (coinPosition + coinSpeed*t) % titleCoinsH
	love.graphics.draw(winCoins, 0, coinPosition)
	love.graphics.draw(winCoins, 0, coinPosition - titleCoinsH)
	
	love.graphics.draw(winScreen, 0, 0)
	
	love.graphics.setFont(FONTS["DEFAULT"])
	if math.floor(t) % 2 == 0 then 
		love.graphics.printf("YOU WIN!", 0, 550, 800, "center")
	end
end

function initializeGame()
	CARDS = {
		{},
		{},
		{},
		{}
	}
	
	mainCard = nil
	guessCard = nil
	
	gameState = 0
	playerMoney = 5
	currentRound = 1
	spriteCounter = 0
	rouletteChance = 6
	gameTimer, rouletteTimer, bubbleTimer, noticeTimer = -1, -1, -1, -1

	makeCards()
	shuffleCards()
	makeSprite()
	
	if not BGM["GAME"]:isPlaying() then
		BGM["GAME"]:play()
	end
	BGM["GAME_FINAL"]:stop()
	fMusicTimer = 0
	fMusicVolume = 0
end

function makeSprite()
	cardsBg = love.graphics.newImage(BG_CARDS_DIR)
	backGun = love.graphics.newImage(BG_GUN_DIR)
	backLight = love.graphics.newImage(BG_LIGHT_DIR)
	
	speechBubble = {
		love.graphics.newImage(SBUBBLE_HIGH_DIR),
		love.graphics.newImage(SBUBBLE_LOW_DIR)
	}
	
	gameNotice = {
		love.graphics.newImage(NOTICE_WIN_DIR),
		love.graphics.newImage(NOTICE_LOSE_DIR)
	}
	
	sprite = LoveAnimation.new(SPRITE_DIR)
	sprite:setSpeedMultiplier(1)
	sprite:setPosition(SPRITE_POSITION_X, SPRITE_POSITION_Y)
	states = sprite:getAllStates()
	
	spriteSweat = love.graphics.newImage(SWEAT_DIR)
end

function makeCards()
	for row = 1, 4 do
		for col = 1, 9 do
			CARDS[row][col] = Card:new(CARDS_POSITION_X + (col * 22), CARDS_POSITION_Y + (row * 26), 20, 25, CARD_ROW_COLORS[row], col)
		end
	end
	
	mainCard = Card:new(MAIN_CARD_POSITION_X , MAIN_CARD_POSITION_Y, 125, 175, nil, nil, nil, {0,0,0,1}, true, false)
	guessCard = Card:new(GUESS_CARD_POSITION_X , GUESS_CARD_POSITION_Y, 125, 175, nil, nil, nil, {0,0,0,1}, true, true) 
end

function renderCards()
	love.graphics.draw(cardsBg, CARDS_BG_POSITION_X, CARDS_BG_POSITION_Y)

	love.graphics.setFont(FONTS["SMALL"])
	for row = 1, 4 do
		for col = 1, 9 do
			CARDS[row][col]:draw()
		end
	end
end

function renderHudElements()
	love.graphics.draw(backLight, 0, 0)
	
	love.graphics.setFont(FONTS["DEFAULT"])
	
	local w, g, r, gry = {1,1,1,1}, {0,1,0,1}, {1,0,0,1}, {.75,.75,.75,1}
	if gameState == 0 then
		love.graphics.printf({w,"IS THIS CARD ", g, "HIGH ", w, "OR ", r, "LOW", w, '?'}, 45, 215, 999, "left")
	end
	
	if currentRound < 22 then
		love.graphics.printf("ROUND  "..currentRound, 25, 475, 999, "left")
	else
		local t = love.timer.getTime()
		if math.floor(t) % 2 == 0 then 
			love.graphics.printf({r, "ROUND  "..currentRound}, 25, 475, 999, "left")
		end
	end
	
	love.graphics.printf("MONEY  ", 25, 500, 999, "left")
	
	love.graphics.setFont(FONTS["SYS"])
	love.graphics.printf({gry,"[↑] HIGH	[↓] LOW	[R] RESET"}, 20, 10, 999, "left")
	
	love.graphics.setFont(FONTS["MEDIUM"])
	love.graphics.printf(playerMoney, 25, 525, 999, "left")
end

function renderGun()
	if rouletteTimer > -1 then
		love.graphics.draw(backGun, GUN_POSITION_X, GUN_POSITION_Y)
	end
end

function renderSpeechBubble()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, bubbleTimer)
	love.graphics.draw(speechBubble[bubbleGuess+1], SBUBBLE_POSITION_X, SBUBBLE_POSITION_Y)
	love.graphics.setColor(r, g, b, a)
end

function renderGameNotice()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, noticeTimer)
	love.graphics.draw(gameNotice[noticeStatus+1], NOTICE_POSITION_X, NOTICE_POSITION_Y, 0, 1.25, 1.25)
	love.graphics.setColor(r, g, b, a)
end

function renderFlash()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1, rouletteTimer)
	love.graphics.rectangle("fill", 0, 0, 800, 600)
	love.graphics.setColor(r, g, b, a)
end

function shuffleCards()
	cardCurrentRow = mtw:random(1, 4)
	cardCurrentCol = mtw:random(1, 9)
	
	mainCard.color = CARD_ROW_COLORS[cardCurrentRow]
	mainCard.text = cardCurrentCol
	mainCard:setTextColor(CARD_ROW_COLORS[cardCurrentRow])
	
	CARDS[cardCurrentRow][cardCurrentCol]:disable()
	
	shuffleGuessCard()
end

function pickGuessCard(highlow)
	gameTimer = CARD_ANIM_SPEED
	bubbleTimer = SPEECH_ANIM_SPEED
	
	bubbleGuess = highlow
	
	guessCard.text = guessCurrentCol
	guessCard.flipped = false

	if (highlow == 0 and not (guessCurrentCol >= cardCurrentCol)) or (highlow == 1 and not (guessCurrentCol <= cardCurrentCol)) then 
		rouletteTimer = 2

		noticeStatus = 1
		noticeTimer = NOTICE_DISPLAY_SPEED
		SFX["BADCARD"]:play()
		
		spriteCounter = 6 - rouletteChance
		sprite:setState("warning")
		
		return false 
	end

	playerMoney = playerMoney * 2
	
	if sprite:getCurrentState() == "losing" then
		spriteCounter = 0
		sprite:setState("idle")
	end
	if spriteCounter < SPRITE_MAX_FRAMES then
		spriteCounter = spriteCounter + 1
	end
	
	noticeStatus = 0
	noticeTimer = NOTICE_DISPLAY_SPEED
	SFX["GOODCARD"]:play()
	return true
end

function shuffleGuessCard()
	guessCurrentRow = mtw:random(1, 4)
	guessCurrentCol = mtw:random(1, 9)
	mtw:randomseed()
	
	local selected = CARDS[guessCurrentRow][guessCurrentCol]
	if selected.disabled then return shuffleGuessCard() end
	
	guessCard.swaying = true
	guessCard.color = CARD_ROW_COLORS[guessCurrentRow]
	guessCard:setTextColor(CARD_ROW_COLORS[guessCurrentRow])
end

function reassignMainCard()
	currentRound = currentRound + 1
	if currentRound == 22 then
		BGM["GAME"]:stop()

		BGM["GAME_FINAL"]:play()
	end
	
	if currentRound >= 36 then 
		gameState = 1
		
		BGM["GAME_FINAL"]:stop()
		
		SFX["WIN"]:play()
		BGM["WIN"]:play()
		return 
	end
	
	CARDS[guessCurrentRow][guessCurrentCol]:disable()
	mainCard.color = guessCard.color
	mainCard.text = guessCurrentCol
	mainCard:setTextColor(guessCard.color)
	
	cardCurrentCol = guessCurrentCol
end

function renderPrimaryCards()
	love.graphics.setFont(FONTS["BIG"])
	mainCard:draw()
	guessCard:draw()
end

function renderSprite()
	sprite:draw()
	if (currentRound > 17 or rouletteChance < 4) and gameState == 0 then
		love.graphics.draw(spriteSweat, SPRITE_POSITION_X, SPRITE_POSITION_Y)
	end
end
----------------------

function love.load()
	love.window.setTitle("Seiko - High! Low!")
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	initializeIntroCutscene()
	initializeTitleScreen()
end

function love.update(dt)
	--Fix this and make it its own thing later. (Or don't I guess?)
	if gameState == 2 then
		if rouletteTimer > 0 then
			rouletteTimer = rouletteTimer - dt
		end
		return 
	end
	
	if currentRound > 21 and fMusicVolume < 0.2 then
		fMusicTimer = fMusicTimer + dt
		fMusicVolume = lerp(fMusicVolume, 0.2, fMusicTimer / 1600)
		BGM["GAME_FINAL"]:setVolume(fMusicVolume)
	end
		
	if bubbleTimer > 0 then
		bubbleTimer = bubbleTimer - dt
	end
	
	if noticeTimer > 0 then
		noticeTimer = noticeTimer - dt
	end
	
	if rouletteTimer > 0 then 
		rouletteTimer = rouletteTimer - dt
		return
	elseif rouletteTimer > -1 then
		rouletteTimer = -1
		rouletteChance = rouletteChance - 1
		
		if mtw:random(1, rouletteChance) == 1 then
			gameState = 2
			gameTimer = -1
			
			rouletteTimer = 1
			
			SFX["GUNFIRED"]:play()
			
			BGM["GAME"]:stop()
			BGM["GAME_FINAL"]:stop()
			return
		else
			sprite:setState("losing")
			SFX["GUNEMPTY"]:play()
		end
	end
	
	if gameTimer > 0 then
		guessCard.pos = Vec2:lerp(guessCard.pos, mainCard.pos, (CARD_ANIM_SPEED - gameTimer)/CARD_ANIM_SPEED)
		gameTimer = gameTimer - dt
	elseif gameTimer > -1 then
		gameTimer = -1
		
		reassignMainCard()
		shuffleGuessCard()
		
		sprite:setCurrentFrame(spriteCounter)
		guessCard.text = ""
		guessCard.flipped = true
		guessCard.pos.x, guessCard.pos.y = GUESS_CARD_POSITION_X, GUESS_CARD_POSITION_Y
	end
end

function love.draw()
	if gameState == -2 then
		love.graphics.setFont(FONTS["DEFAULT"])
		introCutscene:play()

		if introCutscene.currentFrame == 1 then
			local blk, gry = {0,0,0}, {.75,.75,.75}
			love.graphics.printf({blk, "[SPACE] NEXT	[ENTER]  SKIP"}, -35, 27, 750, "right")
			love.graphics.printf({gry, "[SPACE] NEXT	[ENTER]  SKIP"}, -33, 25, 750, "right")
		end
		
		if introCutscene.finished then
			gameState = -1
			BGM["TITLE"]:play()
		end
		return
	elseif gameState == -1 then
		renderTitleScreen()
		return 
	end	
		
    if gameState == 0 then
		renderCards()
		renderHudElements()
		renderPrimaryCards()
	elseif gameState == 1 then
		renderWinScreen()
		return
	elseif gameState == 2 then
		renderCards()
		renderHudElements()
		
		local t = love.timer.getTime()
		if math.floor(t) % 2 == 0 then 
			love.graphics.setFont(FONTS["DEFAULT"])
			love.graphics.printf("YOU LOSE!", 0, 300, 800, "center")
		end
		
		sprite:setState("gameover")
	elseif gameState == 3 then
		winCutscene:play()
		if winCutscene.finished then
			gameState = -1
			BGM["ENDING"]:stop()
			BGM["TITLE"]:play()
			
			winCutscene.finished = false
		end
		return
	end
	
	renderSprite()
	
	if bubbleTimer > 0 and gameState == 0 then
		renderSpeechBubble()
	end
	if rouletteTimer > -1 and gameState ~= 2 then
		renderGun()
	end
	if noticeTimer > 0 and gameState == 0 then
		renderGameNotice()
	end
	if rouletteTimer > 0 and gameState == 2 then
		renderFlash()
	end
end

function love.keypressed(key)
	if gameState == -2 then
		if key == "return" then
			introCutscene:stop()
		elseif key == "space" then
			introCutscene:next()
		end
	elseif gameState == -1 then
		if key then
			initializeGame()
			BGM["TITLE"]:stop()
		end
	elseif gameState == 0 then
	   if gameTimer > 0 then return end
	
	   if key == "up" then
			pickGuessCard(0)
	   elseif key == "down" then
			pickGuessCard(1)
	   elseif key == "r" then
			initializeGame()
	   end
	elseif gameState == 1 then
		if key then
			gameState = 3
			SFX["WIN"]:stop()
			BGM["WIN"]:stop()
			BGM["ENDING"]:play()
		end
	elseif gameState == 3 then
	
	else
		if key == "r" then
			initializeGame()
		end
	end
end