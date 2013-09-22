-- Copyright 2013 Arman Darini

local widget = require("widget")
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

	layers.bg.wallpaper = display.newImageRect(layers.bg, "images/UI/scene_menu/bg.png", 360, 570)
	layers.bg.wallpaper:setReferencePoint(display.CenterReferencePoint)
	layers.bg.wallpaper.x = game.centerX
	layers.bg.wallpaper.y = game.centerY

	layers.bg.header = display.newImageRect(layers.bg, "images/UI/scene_menu/header.png", 240, 182)
	layers.bg.header:setReferencePoint(display.CenterReferencePoint)
	layers.bg.header.x = game.centerX
	layers.bg.header.y = game.centerY - 180

	----------------------------------------------------------
	layers.hud.continueButton = widget.newButton {
		defaultFile = "images/UI/scene_menu/button_play.png",
		overFile = "images/UI/scene_menu/button_play_pressed.png",
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
function scene:willEnterScene( event )
	storyboard.purgeScene("scene_play")
end
 
scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
 
return scene