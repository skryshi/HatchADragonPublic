-- Copyright 2013 Arman Darini

local utils = require("utils")

GemsClass = {
	gridX = nil, gridY = nil,
	gemType = nil,
	image = nil,
	parentDisplayGroup = nil,
	parentGrid = nil,
	
	----------------------------------------------------------
	new = function(self, o)
		print("GemsClass:new")
--		utils.printTable(o)
		o = o or {}   -- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		return o
	end,

	----------------------------------------------------------
	init = function(self)
		print("GemsClass:init")
		local originCoordinates = self.parentGrid:getXYFromGrid(self.gridX, -5)
		local destinationCoordinates = self.parentGrid:getXYFromGrid(self.gridX, self.gridY)
--		self:useCircle()
		self:useImage()
		self.image:translate(originCoordinates.x, originCoordinates.y)
		self.parentDisplayGroup:insert(self.image)
		transition.to(self.image, { time = 500, delay = (game.gridHeight - self.gridY) * 100, transition = easing.inQuad, y = destinationCoordinates.y })
	end,

	----------------------------------------------------------
	useImage = function(self)
		local roll = math.random(1, game.gemTypes)
		self.image = display.newImageRect("images/egg_"..roll..".png", game.cellSize, game.cellSize)
		self.image:setReferencePoint(display.CenterReferencePoint)
		self.gemType = "egg"..roll
	end,

	----------------------------------------------------------
	useCircle = function(self)
		self.image = display.newCircle(0, 0, game.gemRadius)

		local roll = math.random(1, game.gemTypes)
		if (1 == roll) then
			self.image:setFillColor(200, 0, 0)
			self.gemType = "red"
		elseif (2 == roll) then 
			self.image:setFillColor(0, 200, 0)
			self.gemType = "green"
		elseif (3 == roll) then 
			self.image:setFillColor(0, 0, 200)
			self.gemType = "blue"
		elseif (4 == roll) then 
			self.image:setFillColor(200, 200, 0)
			self.gemType = "yellow"
		elseif (5 == roll) then 
			self.image:setFillColor(250, 250, 250)
			self.gemType = "white"
		elseif (6 == roll) then
			self.image:setFillColor(100, 100, 100)
			self.gemType = "gray"
		else
			self.image:setFillColor(roll*10, roll*15, roll*20)
			self.gemType = "type"..roll
		end
	end,
	
	----------------------------------------------------------
	touch = function(self, event)
--		onGemTouch(self, event)
	end,
	
	----------------------------------------------------------
	toStr = function(self)
		return "["..self.gridX..","..self.gridY..","..self.gemType..","..self.image.x..","..self.image.y.."]"
	end,

	----------------------------------------------------------
	removeSelf = function(self)
		if self.image ~= nil then self.image:removeSelf() end
--		return self.image and self.image:removeSelf()
	end,
}

return GemsClass
