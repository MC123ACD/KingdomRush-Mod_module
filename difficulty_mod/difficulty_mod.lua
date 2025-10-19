local log = require("klua.log"):new("difficulty_mod")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local modify_dif = require("modify_dif")
local S = require("sound_db")
local GS = require("game_settings")
local sys = require("systems")
local W = require("wave_db")
local P = require("path_db")
local game = require("game")
local game_gui = require("game_gui")
local DI = require("difficulty")

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end
local function CJK(default, zh, ja, kr)
	return i18n:cjk(default, zh, ja, kr)
end

local hook = {}

setmetatable(hook, mod_utils.auto_table_mt)

function hook:init()
	modify_dif:init(hook.config)

	HOOK(E, "load", self.E.load)
	HOOK(W, "load", self.W.load)
	HOOK(P, "load", self.P.load)
	--HOOK(sys)
end

function hook.E.load(load, self)
	load(self)

	modify_dif:templates()
	modify_dif:game_settings()
end

function hook.W.load(load, self, level_name, game_mode, wave_ss_data)
	load(self, level_name, game_mode, wave_ss_data)

	modify_dif:waves()
end

function hook.P.load(load, self, name, visible_coords)
	load(self, name, visible_coords)

	modify_dif:paths()
end

return hook