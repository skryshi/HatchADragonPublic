-- Copyright 2013 Arman Darini

local GemClass = require("gem_class")
local math = require("math2")

GemsGridClass = {
	displayGroup = nil,
	grid = nil,
	bg = nil,
	gridWidth = nil,
	gridHeight = nil,
	touchBlocked = false,
	processing = false,	--is true when grid is busy calculating gems
	timer = nil,
	
	----------------------------------------------------------
	new = function(self, o)
	  o = o or {}   -- create object if user does not provide one
	  setmetatable(o, self)
	  self.__index = self
	  return o
	end,

	----------------------------------------------------------
	removeSelf = function(self)
		Runtime:removeEventListener("touch", self)
		if self.timer then 
			timer.cancel(self.timer)
			self.timer = nil
		end

		if nil ~= self.displayGroup then
			self.displayGroup:removeSelf()
			self.displayGroup = nil
		end
	end,
	
	----------------------------------------------------------
	initRectGrid = function(self, gridWidth, gridHeight)
		self.gridWidth = gridWidth
		self.gridHeight = gridHeight
		self.displayGroup = display.newGroup()
		self.grid = {}
		self.bg = {}
		local loc
		for i = 1, self.gridWidth, 1 do
			self.bg[i] = {}
			for j = self.gridHeight, 1, -1 do
				self.bg[i][j] = display.newImageRect("images/tile.png", game.cellSize, game.cellSize)
				self.displayGroup:insert(self.bg[i][j])
				self.bg[i][j]:setReferencePoint(display.CenterReferencePoint)
				loc = self:getXYFromGrid(i, j)
				self.bg[i][j]:translate(loc.x, loc.y)
			end
		end

		for i = 1, self.gridWidth, 1 do
			self.grid[i] = {}
			for j = self.gridHeight, 1, -1 do
				self.grid[i][j] = self:addGem(i, j)
			end
		end

		self.displayGroup:addEventListener("touch", self)
		self.touchBlocked = false
		
		--explode any existing random combos
		self.timer = timer.performWithDelay(2000, function() self:processCombosLoop() end)
	end,

	----------------------------------------------------------
	getXYFromGrid = function(self, i, j)
		--returns center x,y of each grid cell
		return { x = (i - 0.5) * game.cellSize, y = (j - 0.5) * game.cellSize }
	end,

	----------------------------------------------------------
	getGemFromGrid = function(self, i, j)
		return self.grid[i][j]
	end,

	----------------------------------------------------------
	getGemFromXY = function(self, x, y)
		return self.grid[math.round(x / game.cellSize + 0.5)][math.round(y / game.cellSize + 0.5)]
	end,

	----------------------------------------------------------
	addGem = function(self, i, j)
		print("GemClass:addGem(self, "..i..", "..j..")")
		local newGem = GemClass:new({ gridX = i, gridY = j, parentGrid = self, parentDisplayGroup = self.displayGroup })
		newGem:init()

		self.grid[i][j] = newGem
		return newGem
	end,

	----------------------------------------------------------
	swap = function(self, gem1, gem2)
		self.grid[gem1.gridX][gem1.gridY], self.grid[gem2.gridX][gem2.gridY] = self.grid[gem2.gridX][gem2.gridY], self.grid[gem1.gridX][gem1.gridY]
		gem1.gridX, gem2.gridX = gem2.gridX, gem1.gridX
		gem1.gridY, gem2.gridY = gem2.gridY, gem1.gridY
		transition.to(gem1.image, { time = 200, x = gem2.image.x, y = gem2.image.y })
		transition.to(gem2.image, { time = 200, x = gem1.image.x, y = gem1.image.y })
	end,
	
	----------------------------------------------------------
	processCombosLoop = function(self)
		self.processing = true
		local comboCounts = { }
		comboCounts["total"] = self:processCombos()
		print("comboCounts.total="..comboCounts["total"])
		if comboCounts["total"] > 0 then
			self.timer = timer.performWithDelay(2000, function() self:processCombosLoop() end)
		else
			self.touchBlocked = false
			self.processing = false
		end
		return comboCounts["total"]
	end,

	----------------------------------------------------------
	processCombos = function(self)
		print("GemsGridClass:processCombos")
		local comboCounts = { total=0, h3=0, h4=0, h5=0, v3=0, v4=0, v5=0 }
		local comboGems = {}

		--check for horizontal combo 5
		for i = 1, self.gridWidth - 4, 1 do
			for j = 1, self.gridHeight, 1 do
				if (self.grid[i][j].gemType == self.grid[i+1][j].gemType and self.grid[i+1][j].gemType == self.grid[i+2][j].gemType and self.grid[i+2][j].gemType == self.grid[i+3][j].gemType and self.grid[i+3][j].gemType == self.grid[i+4][j].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[(i+1)..j] and nil == comboGems[(i+2)..j] and nil == comboGems[(i+3)..j] and nil == comboGems[(i+4)..j]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[(i+1)..j] = self.grid[i+1][j]
						comboGems[(i+2)..j] = self.grid[i+2][j]
						comboGems[(i+3)..j] = self.grid[i+3][j]
						comboGems[(i+4)..j] = self.grid[i+4][j]
						comboCounts.h5 = comboCounts.h5 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match5[math.random(1, #sounds.match5)], { channel = 1 } )
					end
				end
			end
		end

		--check for vertical combo 5
		for i = 1, self.gridWidth, 1 do
			for j = 1, self.gridHeight - 4, 1 do
				if (self.grid[i][j].gemType == self.grid[i][j+1].gemType and self.grid[i][j+1].gemType == self.grid[i][j+2].gemType and self.grid[i][j+2].gemType == self.grid[i][j+3].gemType and self.grid[i][j+3].gemType == self.grid[i][j+4].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[i..(j+1)] and nil == comboGems[i..(j+2)] and nil == comboGems[i..(j+3)] and nil == comboGems[i..(j+4)]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[i..(j+1)] = self.grid[i][j+1]
						comboGems[i..(j+2)] = self.grid[i][j+2]
						comboGems[i..(j+3)] = self.grid[i][j+3]
						comboGems[i..(j+4)] = self.grid[i][j+4]
						comboCounts.v5 = comboCounts.v5 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match5[math.random(1, #sounds.match5)], { channel = 1 } )
					end
				end
			end
		end

		--check for horizontal combo 4
		for i = 1, self.gridWidth - 3, 1 do
			for j = 1, self.gridHeight, 1 do
				if (self.grid[i][j].gemType == self.grid[i+1][j].gemType and self.grid[i+1][j].gemType == self.grid[i+2][j].gemType and self.grid[i+2][j].gemType == self.grid[i+3][j].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[(i+1)..j] and nil == comboGems[(i+2)..j] and nil == comboGems[(i+3)..j]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[(i+1)..j] = self.grid[i+1][j]
						comboGems[(i+2)..j] = self.grid[i+2][j]
						comboGems[(i+3)..j] = self.grid[i+3][j]
						comboCounts.h4 = comboCounts.h4 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match4[math.random(1, #sounds.match4)], { channel = 1 } )
					end
				end
			end
		end

		--check for vertical combo 4
		for i = 1, self.gridWidth, 1 do
			for j = 1, self.gridHeight - 3, 1 do
				if (self.grid[i][j].gemType == self.grid[i][j+1].gemType and self.grid[i][j+1].gemType == self.grid[i][j+2].gemType and self.grid[i][j+2].gemType == self.grid[i][j+3].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[i..(j+1)] and nil == comboGems[i..(j+2)] and nil == comboGems[i..(j+3)]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[i..(j+1)] = self.grid[i][j+1]
						comboGems[i..(j+2)] = self.grid[i][j+2]
						comboGems[i..(j+3)] = self.grid[i][j+3]
						comboCounts.v4 = comboCounts.v4 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match4[math.random(1, #sounds.match4)], { channel = 1 } )
					end
				end
			end
		end

		--check for horizontal combo 3
		for i = 1, self.gridWidth - 2, 1 do
			for j = 1, self.gridHeight, 1 do
				if (self.grid[i][j].gemType == self.grid[i+1][j].gemType and self.grid[i+1][j].gemType == self.grid[i+2][j].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[(i+1)..j] and nil == comboGems[(i+2)..j]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[(i+1)..j] = self.grid[i+1][j]
						comboGems[(i+2)..j] = self.grid[i+2][j]
						comboCounts.h3 = comboCounts.h3 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match3[math.random(1, #sounds.match3)], { channel = 1 } )						
					end
				end
			end
		end
		
		--check for vertical combo 3
		for i = 1, self.gridWidth, 1 do
			for j = 1, self.gridHeight - 2, 1 do
				if (self.grid[i][j].gemType == self.grid[i][j+1].gemType and self.grid[i][j+1].gemType == self.grid[i][j+2].gemType) then
					if (nil == comboGems[i..j] and nil == comboGems[i..(j+1)] and nil == comboGems[i..(j+2)]) then
						comboGems[i..j] = self.grid[i][j]
						comboGems[i..(j+1)] = self.grid[i][j+1]
						comboGems[i..(j+2)] = self.grid[i][j+2]
						comboCounts.v3 = comboCounts.v3 + 1
						comboCounts.total = comboCounts.total + 1
						audio.play(sounds.match3[math.random(1, #sounds.match3)], { channel = 1 } )						
					end
				end
			end
		end

		utils.printTable(comboGems)
		if 0 == comboCounts.total then
			return 0
		end
		for k, v in pairs(comboGems) do
			--animate combo gems to nothing
			transition.to(comboGems[k].image, { time = 1000, alpha = 0.2, xScale = 0.2, yScale = 0.2, onComplete = function(target) comboGems[k]:removeSelf(); comboGems[k] = nil; end})
			--destroy combo gems objects
			self.grid[comboGems[k].gridX][comboGems[k].gridY] = nil
		end
		--increase score
		utils.printTable(comboCounts)
		print("delta score", 90 * comboCounts.h5 + 90 * comboCounts.v5 + 40 * comboCounts.h4 + 40 * comboCounts.v4 + 10 * comboCounts.h3 + 10 * comboCounts.v3)
		Runtime:dispatchEvent({ name = "score", amount = 90 * comboCounts.h5 + 90 * comboCounts.v5 + 40 * comboCounts.h4 + 40 * comboCounts.v4 + 10 * comboCounts.h3 + 10 * comboCounts.v3 })
		--animate shift remaining gems down
		--shift remaining gems objects
		self:shiftDown()
		--animate add new gems at the top
		--add new gems objects at the top
		self:refillGems()
		return comboCounts.total
	end,
	
	----------------------------------------------------------
	shiftDown = function(self)
		print("GemsGridClass:shiftDown")
		local shiftAmount = {}
		for i = 1, self.gridWidth, 1 do
			shiftAmount[i] = {}
			for j = 1, self.gridHeight - 1, 1 do
				shiftAmount[i][j] = 0
				holes = 0
				for k = j + 1, self.gridHeight, 1 do
					if nil == self.grid[i][k] then
						holes = holes + 1
					end
				end
				shiftAmount[i][j] = holes
			end
			shiftAmount[i][self.gridHeight] = 0
		end
		utils.printTable(shiftAmount)

		for i = 1, self.gridWidth, 1 do
			for j = self.gridHeight - 1, 1, -1 do
				if nil ~= self.grid[i][j] and shiftAmount[i][j] > 0 then
					self.grid[i][j + shiftAmount[i][j]] = self.grid[i][j]
					self.grid[i][j] = nil
					self.grid[i][j + shiftAmount[i][j]].gridY = self.grid[i][j + shiftAmount[i][j]].gridY + shiftAmount[i][j]
					transition.to(self.grid[i][j + shiftAmount[i][j]].image, { time = 1000, y = self:getXYFromGrid(i, j + shiftAmount[i][j]).y } )
				end
			end
		end
	end,

	----------------------------------------------------------
	refillGems = function(self)
		print("GemsGridClass:refillGems")
		for i = 1, self.gridWidth, 1 do
			for j = self.gridHeight, 1, -1 do
				if nil == self.grid[i][j] then
					self.grid[i][j] = self:addGem(i, j)
				end
			end
		end
	end,

	----------------------------------------------------------
	touch = function(self, event)
		if event.phase == "began" and not self.touchBlocked then
			gemTouched = self:getGemFromXY(event.x - self.displayGroup.x, event.y - self.displayGroup.y)
			print("x="..event.x..", y="..event.y..", xO="..(event.x - self.displayGroup.x)..", yO="..(event.y - self.displayGroup.y))
			print("gem touched "..gemTouched:toStr())
			-- first we set the focus on the object
			display.getCurrentStage():setFocus(displayGroup, event.id)
			self.isFocus = true
			-- then we store the original x and y position
			self.markX = event.x
			self.markY = event.y
		elseif self.isFocus then
			if event.phase == "moved" and not self.touchBlocked then
				local dX = event.x - self.markX
				local dY = event.y - self.markY
				if dX^2 + dY^2 > game.moveSensitivity then
					local gem1 = self:getGemFromXY(self.markX - self.displayGroup.x, self.markY - self.displayGroup.y)
					local gem2
					if math.abs(dX) > math.abs(dY) then
						gem2 = self:getGemFromGrid(gem1.gridX + math.sign(dX), gem1.gridY)
					else
						gem2 = self:getGemFromGrid(gem1.gridX, gem1.gridY + math.sign(dY))
					end
					--temporarily swap gems
					self.touchBlocked = true
					print("swap attempt: ", gem1:toStr(), gem2:toStr())
					self:swap(gem1, gem2)
					self.timer = timer.performWithDelay(200, function()
						if (0 == self:processCombosLoop()) then
							self:swap(gem1, gem2)
							print("no combos")
--							self.touchBlocked = false
						else
							Runtime:dispatchEvent({ name = "player_swapped_success" })
						end
					end)
					
		      display.getCurrentStage():setFocus(displayGroup, nil)
		      self.isFocus = false
				end
	    elseif event.phase == "ended" or event.phase == "cancelled" then
	      display.getCurrentStage():setFocus(displayGroup, nil)
	      self.isFocus = false
	    end
	  end
	 return true
	end,	
}

return GemsGridClass