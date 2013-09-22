-- Copyright 2013 Arman Darini

helpers = {
	----------------------------------------------------------
	computeStars = function(score, level)
		return math.min(3, score / game.levels[level].targetScore)
	end,
	
	----------------------------------------------------------
	isLevelUnlocked = function(level)
		if 1 == level or player.levels[level].highScore > game.levels[level].targetScore or player.levels[level - 1].highScore > game.levels[level - 1].targetScore then
			return true
		else
			return false
		end
	end,
}

return helpers