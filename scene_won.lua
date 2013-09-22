-- Copyright 2013 Arman Darini

local widget = require( "widget" )
local storyboard = require("storyboard")
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true
local helpers = require("helpers")
local layers

----------------------------------------------------------
function scene:createScene(event)
	layers = display.newGroup()
	layers.bg = display.newGroup()
	layers.content = display.newGroup()
	layers.hud = display.newGroup()
	layers:insert(layers.bg)
	layers:insert(layers.content)
	layers:insert(layers.hud)
	self.view:insert(layers)

	layers.bg.wallpaper = display.newImageRect(layers.bg, "images/UI/scene_won_scene_lost/bg.png", 360, 570)
	layers.bg.wallpaper:setReferencePoint(display.CenterReferencePoint)
	layers.bg.wallpaper.x = game.centerX
	layers.bg.wallpaper.y = game.centerY

	layers.bg.header = display.newImageRect(layers.bg, "images/UI/scene_won_scene_lost/header_won.png", 145, 31)
	layers.bg.header:setReferencePoint(display.CenterReferencePoint)
	layers.bg.header.x = game.centerX
	layers.bg.header.y = game.centerY - 170

	layers.hud.stars = display.newImageRect(layers.hud, "images/UI/scene_won_scene_lost/star_" .. math.floor(helpers.computeStars(game.score, game.level)) .. ".png", 168, 59)
	layers.hud.stars:setReferencePoint(display.CenterReferencePoint)
	layers.hud.stars.x = game.centerX
	layers.hud.stars.y = game.centerY - 110

	layers.hud.scoreCaption = display.newText(layers.hud, "SCORE", 0, 0, game.font, 24)
	layers.hud.scoreCaption:setTextColor(0)
	layers.hud.scoreCaption:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreCaption.x = game.centerX
	layers.hud.scoreCaption.y = game.centerY
	
	layers.hud.scoreAmount = display.newText(layers.hud, "0", 0, 0, game.font, 24)
	layers.hud.scoreAmount:setTextColor(0)
	layers.hud.scoreAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreAmount.x = game.centerX
	layers.hud.scoreAmount.y = game.centerY + 25

	----------------------------------------------------------
	layers.hud.continueButton = widget.newButton {
		defaultFile = "images/UI/scene_won_scene_lost/button_next.png",
		overFile = "images/UI/scene_won_scene_lost/button_next_pressed.png",
		left = game.centerX - 135,
		top = game.centerY + 110,
		onRelease = function()
			audio.play(sounds.click, { channel = 1 } )
			storyboard.gotoScene("scene_levels", "slideLeft", 400)
			return true
		end	
	}
	layers.hud:insert(layers.hud.continueButton)	
end

----------------------------------------------------------
function scene:willEnterScene(event)
	print("scene_won:scene:willEnterScene")
	storyboard.purgeScene("scene_play")
	audio.play(sounds.won, { channel = 1 } )

	layers.hud.scoreAmount.text = game.score
	layers.hud.scoreAmount:setReferencePoint(display.CenterReferencePoint)
	layers.hud.scoreAmount.x = game.centerX
end


scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)

return scene