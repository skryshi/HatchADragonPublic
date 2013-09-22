-- Copyright 2013 Arman Darini

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

	layers.bg.wallpaper = display.newImageRect(layers.bg, "images/UI/scene_levels/bg.png", 360, 570)
	layers.bg.wallpaper:setReferencePoint(display.CenterReferencePoint)
	layers.bg.wallpaper.x = game.centerX
	layers.bg.wallpaper.y = game.centerY

	layers.bg.header = display.newImageRect(layers.bg, "images/UI/scene_levels/logo_s.png", 275, 32)
	layers.bg.header:setReferencePoint(display.CenterReferencePoint)
	layers.bg.header.x = game.centerX
	layers.bg.header.y = game.centerY - 235

	local level = 1
	layers.content.levels = display.newGroup()
	layers.content:insert(layers.content.levels)
	for j = 1, 3 do
		for i = 1, 3 do
			layers.content.levels[level] = display.newGroup()
			layers.content.levels:insert(display.newGroup())	--bug?!? i shouldn't need this call, but without it, i get an error in the next line
			
			if helpers.isLevelUnlocked(level) then
				layers.content.levels[level].egg = display.newImageRect(layers.content.levels[level], "images/UI/scene_levels/level_egg.png", 95, 114)

				layers.content.levels[level].num = display.newText(layers.content.levels[level], level, 0, 0, game.font, 32)
				layers.content.levels[level].num:setTextColor(255)
				layers.content.levels[level].num:setReferencePoint(display.CenterReferencePoint)
				layers.content.levels[level].num.x = 5
				layers.content.levels[level].num.y = -10

				layers.content.levels[level].stars = display.newImageRect(layers.content.levels[level], "images/UI/scene_levels/star_" .. math.floor(helpers.computeStars(player.levels[level].highScore, level)) .. ".png", 62, 20)
				layers.content.levels[level].stars.y = 30

				layers.content.levels[level]:addEventListener("tap", gotoLevel)
			else
				layers.content.levels[level].egg = display.newImageRect(layers.content.levels[level], "images/UI/scene_levels/level_egg_locked.png", 95, 114)
			end
			
			layers.content.levels:insert(layers.content.levels[level])
			
			layers.content.levels[level]:translate((i - 1) * (95 + 10), (j - 1) * (114 + 10))
			layers.content.levels[level].level = level
			
			level = level + 1
		end
	end
	
	layers.content.levels:setReferencePoint(display.CenterReferencePoint)
	layers.content.levels.x = game.centerX
	layers.content.levels.y = game.centerY + 50
end
 
----------------------------------------------------------
gotoLevel = function(self, event)
	print("going to level ", self.target.level)
	audio.play(sounds.click, { channel = 1 } )
	player.currentLevel = self.target.level
	storyboard.gotoScene("scene_play", "slideLeft", 400)		
	return true
end

----------------------------------------------------------
function scene:willEnterScene( event )
	storyboard.purgeScene("scene_play")
end
 
scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
 
return scene