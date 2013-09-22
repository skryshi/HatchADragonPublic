-- Copyright 2013 Arman Darini

display.setStatusBar( display.HiddenStatusBar )
local utils = require("utils")
local math = require("math")

--hold global vars
game = {
	debug = false,
	w = display.contentWidth,
	h = display.contentHeight,
	centerX = display.contentCenterX,
	centerY = display.contentCenterY,
	font = "Helvetica",
	moveSensitivity = 100,
	achievements = { "Not Bad!", "Rockin' It!", "On Steroids!", "Unbelievable!", "Divine!" },
	mode = "moves",
	level = 1,
	score = 0,
	moves = 0,
	time = 0,
	targetScore = 20,
	targetMoves = 1,
	targetTime = 5,
	gridWidth = 6,
	gridHeight = 6,
	gemTypes = 6,
	levels = {
		{ mode = "moves", targetMoves = 2, targetScore = 20 },
		{ mode = "time", targetTime = 10, targetScore = 20 },
		{ mode = "moves", targetMoves = 4, targetScore = 40 },
		{ mode = "time", targetTime = 20, targetScore = 40 },	--lvl4
		{ mode = "moves", targetMoves = 6, targetScore = 60 },
		{ mode = "time", targetTime = 40, targetScore = 80 },
		{ mode = "moves", targetMoves = 8, targetScore = 80 },
		{ mode = "time", targetTime = 80, targetScore = 160 },	--lvl8
		{ mode = "moves", targetMoves = 10, targetScore = 1000 },
	}
}
game.gemRadius = math.floor(game.w / (2 * game.gridWidth)) - 2	--for circle gems
game.cellSize = math.floor(game.w / game.gridWidth)


local playerDefaults = {
	soundVolume = 1,
	musicVolume = 1,
	currentLevel = 1,
	levels = {
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
		{ attempts = 0, highScore = 0 },
	},
	version = 4,
}
player = utils.loadTable("player")
if nil == player or player.version ~= playerDefaults.version then
	player = playerDefaults
	utils.saveTable("player")
end

utils.printTable(player)

sounds = {
	match3 = {
		audio.loadSound("sounds/match3_1.mp3"),
		audio.loadSound("sounds/match3_2.mp3"),
		audio.loadSound("sounds/match3_3.mp3"),
		audio.loadSound("sounds/match3_4.mp3"),
		audio.loadSound("sounds/match3_5.mp3"),
	},
	match4 = { audio.loadSound("sounds/match4.mp3") },
	match5 = { audio.loadSound("sounds/match5.mp3") },
	lost = audio.loadSound("sounds/lost.mp3"),
	won = audio.loadSound("sounds/won.mp3"),
	click = audio.loadSound("sounds/click.mp3"),
	selectLevel = audio.loadSound("sounds/select_level.mp3"),
}

audio.setVolume(player.soundVolume, { channel = 1 })	--sfx
audio.setVolume(player.musicVolume, { channel = 2 })	--music

--music = audio.loadStream("sounds/theme_song.mp3")
--audio.play(music, { channel = 2, loops=-1, fadein=1000 })

local storyboard = require "storyboard"
storyboard.gotoScene("scene_menu")

