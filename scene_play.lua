-- Copyright 2013 Arman Darini

local math = require ("math2")
local helpers = require("helpers")
local utils = require("utils")
local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local layers

local sheetUIInfo = require("images.UI.scene_play.button_settings")
local sheetUI = graphics.newImageSheet("images/UI/scene_play/button_settings.png", sheetUIInfo:getSheet())

local GemsGridClass = require("gems_grid_class")
local gemsGrid = GemsGridClass:new()

local timers = {}

----------------------------------------------------------
local function checkForCompletion()
	if game.time >= game.targetTime or game.moves >= game.targetMoves then
		gemsGrid.touchBlocked = true
		if true == gemsGrid.processing then
			timer.performWithDelay(1000, checkForCompletion)
		else
			player.levels[player.currentLevel].highScore = math.max(player.levels[player.currentLevel].highScore, game.score)
			player.levels[player.currentLevel].attempts = player.levels[player.currentLevel].attempts + 1
			utils.saveTable(player, "player")

			if game.score >= game.targetScore then
				player.currentLevel = player.currentLevel + 1
				storyboard.gotoScene("scene_won", "slideLeft", 400)
			else
				storyboard.gotoScene("scene_lost", "slideLeft", 400)
			end
		end
	end
end

----------------------------------------------------------
local function scoreListener(event)
	print("scoreListener", event.amount)
	game.score = game.score + event.amount
	layers.hud.scoreAmount.text = game.score
	layers.hud.scoreAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreAmount.x = game.w - 60

	layers.hud.progressBar.bar.maskScaleX = (layers.hud.progressBar.bar.width / (328/2)) * (helpers.computeStars(game.score, game.level) / 3) --math.min(1, game.score / game.targetScore)
end

----------------------------------------------------------
local function movesListener(event)
	print("movesListener", event.amount)
	game.moves = game.moves + 1
	if "moves" == game.mode then
		layers.hud.movesAmount.text = game.targetMoves - game.moves
		layers.hud.movesAmount:setReferencePoint(display.CenterReferencePoint)
		layers.hud.movesAmount.x = 40
		checkForCompletion()
	end
end

----------------------------------------------------------
local function timeListener(event)
	print("movesListener", event.amount)
	game.time = math.min(game.time + 1, game.targetTime)
	layers.hud.timeAmount.text = game.targetTime - game.time
	layers.hud.timeAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.timeAmount.x = 40	
	checkForCompletion()
end

----------------------------------------------------------
local function achievementPopupListener(event)
	local txt
	if event.amount >= 180 then
		txt = game.achievements[5]
	elseif event.amount >= 90 then
		txt = game.achievements[4]
	elseif event.amount >= 60 then
		txt = game.achievements[3]
	elseif event.amount >= 30 then
		txt = game.achievements[2]
	elseif event.amount >= 20 then
		txt = game.achievements[1]
	else
		return
	end
	print("achievementPopupListener", event.amount, txt)

	layers.overlay.achievement = display.newGroup()
	layers.overlay:insert(layers.overlay.achievement)
	
	layers.overlay.achievement.wallpaper = display.newRoundedRect(layers.overlay.achievement, 0, 0, 200, 60, 12)
	layers.overlay.achievement.wallpaper.strokeWidth = 3
	layers.overlay.achievement.wallpaper:setFillColor(243, 95, 179)
	layers.overlay.achievement.wallpaper:setStrokeColor(254, 191, 199)
	layers.overlay.achievement.wallpaper.x = game.centerX
	layers.overlay.achievement.wallpaper.y = game.centerY

	layers.overlay.achievement.header = display.newText(layers.overlay.achievement, txt, 0, 0, game.font, 32)
	layers.overlay.achievement.header.x = layers.overlay.achievement.wallpaper.x
	layers.overlay.achievement.header.y = layers.overlay.achievement.wallpaper.y

	transition.to(layers.overlay.achievement, { alpha = 0, time = 1000, delay = 500, onComplete = 
		function()
			if layers.overlay.achievement ~= nil then layers.overlay.achievement:removeSelf()
				layers.overlay.achievement = nil
			end
		end
	})
end


----------------------------------------------------------
function scene:createScene(event)
	game.mode = game.levels[player.currentLevel].mode
	game.targetScore = game.levels[player.currentLevel].targetScore
	if "moves" == game.mode then
		game.targetMoves = game.levels[player.currentLevel].targetMoves
	else
		game.targetTime = game.levels[player.currentLevel].targetTime
	end
	game.score = 0
	game.moves = 0
	game.time = 0
	game.level = player.currentLevel
	
	layers = display.newGroup()
	layers.bg = display.newGroup()
	layers.content = display.newGroup()
	layers.hud = display.newGroup()
	layers.overlay = display.newGroup()
	layers:insert(layers.bg)
	layers:insert(layers.content)
	layers:insert(layers.hud)
	layers:insert(layers.overlay)
	self.view:insert(layers)

	layers.bg.wallpaper = display.newImageRect(layers.bg, "images/UI/scene_play/bg.png", 360, 570)
	layers.bg.wallpaper:setReferencePoint(display.CenterReferencePoint)
	layers.bg.wallpaper.x = game.centerX
	layers.bg.wallpaper.y = game.centerY

	layers.hud.progressBar = display.newGroup()
	layers:insert(layers.hud.progressBar)
	layers.hud.progressBar.bg = display.newImageRect(layers.hud.progressBar, "images/UI/scene_play/progress_bar_empty.png", 168, 59)
	layers.hud.progressBar.bg:setReferencePoint(display.TopLeftReferencePoint)

	layers.hud.progressBar.bar = display.newImageRect(layers.hud.progressBar, "images/UI/scene_play/progress_bar_full.png", 168, 59)
	layers.hud.progressBar.bar:setReferencePoint(display.TopLeftReferencePoint)
	local mask = graphics.newMask("images/mask_frame_328x328.png")
	layers.hud.progressBar.bar:setMask(mask)
	layers.hud.progressBar.bar.maskX = -(layers.hud.progressBar.bar.width/2)
	layers.hud.progressBar.bar.maskScaleX = 0.01	--should be =0, but there is a bug in corona	
	
	layers.hud.progressBar:translate(game.w - 85, 80)

	if "moves" == game.mode then
		layers.hud.movesCaption = display.newText(layers.hud, "MOVES", 0, 0, game.font, 24)
		layers.hud.movesCaption:setTextColor(0)
		layers.hud.movesCaption:setReferencePoint(display.CenterReferencePoint)
		layers.hud.movesCaption.x = 50
		layers.hud.movesCaption.y = 10
	
		layers.hud.movesAmount = display.newText(layers.hud, "0", 0, 0, game.font, 24)
		layers.hud.movesAmount:setTextColor(0)
		layers.hud.movesAmount:setReferencePoint(display.CenterReferencePoint)
		layers.hud.movesAmount.x = 40
		layers.hud.movesAmount.y = 35
	elseif "time" == game.mode then
		layers.hud.timeCaption = display.newText(layers.hud, "TIME", 0, 0, game.font, 24)
		layers.hud.timeCaption:setTextColor(0)
		layers.hud.timeCaption:setReferencePoint(display.CenterReferencePoint)
		layers.hud.timeCaption.x = 50
		layers.hud.timeCaption.y = 10
	
		layers.hud.timeAmount = display.newText(layers.hud, "0", 0, 0, game.font, 24)
		layers.hud.timeAmount:setTextColor(0)
		layers.hud.timeAmount:setReferencePoint(display.CenterReferencePoint)
		layers.hud.timeAmount.x = 40
		layers.hud.timeAmount.y = 35
	end

	layers.hud.scoreCaption = display.newText(layers.hud, "SCORE", 0, 0, game.font, 24)
	layers.hud.scoreCaption:setTextColor(0)
	layers.hud.scoreCaption:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreCaption.x = game.w - 50
	layers.hud.scoreCaption.y = 10
	
	layers.hud.scoreAmount = display.newText(layers.hud, "0", 0, 0, game.font, 24)
	layers.hud.scoreAmount:setTextColor(0)
	layers.hud.scoreAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreAmount.x = game.w - 60
	layers.hud.scoreAmount.y = 35

	----------------------------------------------------------
	layers.hud.exitButton = widget.newButton
	{
		sheet = sheetUI,
		defaultFrame = sheetUIInfo:getFrameIndex("button_settings_exit"),
		overFrame = sheetUIInfo:getFrameIndex("button_settings_exit_pressed"),
		left = 80,
		top = game.h - 50,
		onRelease = function()
			audio.play(sounds.click, { channel = 1, onComplete = function()
				storyboard.gotoScene("scene_levels", "slideLeft", 400)
			end })
			return true
		end	
	}
	layers.hud:insert(layers.hud.exitButton)


	layers.hud.soundButton = display.newGroup()
	layers.hud:insert(layers.hud.soundButton)
	----------------------------------------------------------
	layers.hud.soundButton.on = widget.newButton
	{
		sheet = sheetUI,
		defaultFrame = sheetUIInfo:getFrameIndex("button_settings_sound"),
		overFrame = sheetUIInfo:getFrameIndex("button_settings_sound_pressed"),
		left = 20,
		top = game.h - 50,
		onRelease = function()
			player.soundVolume = 1 - player.soundVolume
			utils.saveTable(player, "player")
			audio.setVolume(1, { channel = 1 })
			audio.play(sounds.click, { channel = 1, onComplete = function()
				audio.setVolume(player.soundVolume, { channel = 1 })
			end })
			layers.hud.soundButton.on.alpha = 0
			layers.hud.soundButton.off.alpha = 1
			return true
		end	
	}
	layers.hud.soundButton:insert(layers.hud.soundButton.on)
	
	----------------------------------------------------------
	layers.hud.soundButton.off = widget.newButton
	{
		sheet = sheetUI,
		defaultFrame = sheetUIInfo:getFrameIndex("button_settings_sound_pressed"),
		overFrame = sheetUIInfo:getFrameIndex("button_settings_sound"),
		left = 20,
		top = game.h - 50,
		onRelease = function()
			player.soundVolume = 1 - player.soundVolume
			utils.saveTable(player, "player")
			audio.setVolume(1, { channel = 1 })
			audio.play(sounds.click, { channel = 1, onComplete = function()
				audio.setVolume(player.soundVolume, { channel = 1 })
			end })
			layers.hud.soundButton.on.alpha = 1
			layers.hud.soundButton.off.alpha = 0
			return true
		end	
	}
	layers.hud.soundButton:insert(layers.hud.soundButton.off)

	if 0 == player.soundVolume then
		layers.hud.soundButton.on.alpha = 0
		layers.hud.soundButton.off.alpha = 1
	else
		layers.hud.soundButton.on.alpha = 1
		layers.hud.soundButton.off.alpha = 0
	end	

	gemsGrid:initRectGrid(game.gridWidth, game.gridHeight)
	layers.content:insert(gemsGrid.displayGroup)
	local mask = graphics.newMask("images/mask_frame_328x328.png")
	gemsGrid.displayGroup:setMask(mask)
	--need to set reference point manually, b/c the grid extends into negative y axis, b/c gems start above the grid for animation
	gemsGrid.displayGroup.maskX = game.cellSize * game.gridWidth / 2
	gemsGrid.displayGroup.maskY = game.cellSize * game.gridHeight / 2

--	print("gemsGrid.displayGroup X:", gemsGrid.displayGroup.xOrigin, gemsGrid.displayGroup.xReference, gemsGrid.displayGroup.x, gemsGrid.displayGroup.contentWidth, gemsGrid.displayGroup.width)
--	print("gemsGrid.displayGroup Y:", gemsGrid.displayGroup.yOrigin, gemsGrid.displayGroup.yReference, gemsGrid.displayGroup.y, gemsGrid.displayGroup.contentHeight, gemsGrid.displayGroup.height)

	gemsGrid.displayGroup:translate(0, 120)
	
	Runtime:addEventListener("score", scoreListener)
	Runtime:addEventListener("score", achievementPopupListener)
	Runtime:addEventListener("player_swapped_success", movesListener)
end
 

----------------------------------------------------------
function scene:willEnterScene(event)
	storyboard.purgeScene("scene_levels")

	layers.hud.progressBar.bar.maskScaleX = 0.01	--should be =0, but there is a bug in corona

	layers.hud.scoreAmount.text = game.score
	layers.hud.scoreAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreAmount.x = game.w - 60

	if "moves" == game.mode then
		layers.hud.movesAmount.text = game.targetMoves
		layers.hud.movesAmount:setReferencePoint(display.CenterReferencePoint)
		layers.hud.movesAmount.x = 40
	elseif "time" == game.mode then
		layers.hud.timeAmount.text = game.targetTime
		layers.hud.timeAmount:setReferencePoint(display.CenterReferencePoint)
		layers.hud.timeAmount.x = 40
		timers.everySecond = timer.performWithDelay(1000, timeListener, 0)
	end
end

----------------------------------------------------------
function scene:exitScene(event)
	print("scene_play:scene:exitScene")
	Runtime:removeEventListener("score", scoreListener)
	Runtime:removeEventListener("score", achievementPopupListener)
	Runtime:removeEventListener("player_swapped_success", movesListener)

	gemsGrid:removeSelf()

	if timers.everySecond then
		timer.cancel(timers.everySecond)
		timers.everySecond = nil
	end
end


scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("exitScene", scene)

if game.debug then
	timer.performWithDelay(1000, utils.printMemoryUsed, 0)
end

return scene