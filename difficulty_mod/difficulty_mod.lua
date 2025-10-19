local log = require("klua.log"):new("difficulty_mod")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local screen_map_dif = require("screen_map_dif")
local screen_map = require("screen_map")
local S = require("sound_db")
local GS = require("game_settings")
local game = require("game")
local game_gui = require("game_gui")
local DI = require("difficulty")
balance = require("balance.balance")

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
	-- HOOK(E, "load", self.E.load)
	HOOK(screen_map, "init", self.screen_map.init)
end

function hook.E.load(load, self)
    package.loaded["game_scripts-1"] = nil
    package.loaded["game_scripts-2"] = nil
    package.loaded["game_scripts-4"] = nil
    package.loaded["game_scripts-5"] = nil

	load(self)
end

-- 修改地图按钮
function hook.screen_map.init(init, self, w, h, done_callback)
	init(self, w, h, done_callback)

	local sw = self.sw
	local sh = self.sh

	self.option_dif_panel = OptionsDifficultyView:new(sw, sh)

	self.window:add_child(self.option_dif_panel)

	-- 设置按钮
	self.o_dif_button = GGButton:new("map_configBtn_0001", "map_configBtn_0002", "map_configBtn_0003")

	self.o_dif_button.anchor = v(self.o_dif_button.size.x / 2, self.o_dif_button.size.y / 2)
	self.o_dif_button.pos = v(80, 840)

	function self.o_dif_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.option_dif_panel:show()
	end

	self.window:add_child(self.o_dif_button)
end

return hook