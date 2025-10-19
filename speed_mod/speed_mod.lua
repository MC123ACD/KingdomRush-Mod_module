local log = require("klua.log"):new("speed_mod")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local game = require("game")
local key_is_down = love.keyboard.isDown

local hook = {}

setmetatable(hook, auto_table_mt)

function hook:init()
	HOOK(game, "keypressed", self.game.keypressed)
	HOOK(game, "update", self.game.update)
end

-- 加减速快捷键
function hook.game.keypressed(keypressed, self, key, isrepeat)
	keypressed(self, key, isrepeat)

	local config = hook.config

	if config.is_down_key then
		if key_is_down(config.up_speed_key) then
			self.DBG_TIME_MULT = config.up_speed_factor
		elseif key_is_down(config.down_speed_key) then
			self.DBG_TIME_MULT = config.down_speed_factor
		end
	else
		if key == config.up_speed_key then
			self.DBG_TIME_MULT = config.up_speed_factor
		elseif key == config.down_speed_key then
			self.DBG_TIME_MULT = config.down_speed_factor
		elseif key == config.reset_speed_key then
			self.DBG_TIME_MULT = 1
		end
	end
end

function hook.game.update(update, self, dt)
	update(self, dt)

	local config = hook.config

	if config.is_down_key and not (key_is_down(config.up_speed_key) or key_is_down(config.down_speed_key)) then
		self.DBG_TIME_MULT = 1
	end

	if not IS_KR5 then
		if self.DBG_TIME_MULT < 1 then
			local new_dt = dt * self.DBG_TIME_MULT

			self.simulation:update(new_dt)
		end
	end
end

return hook