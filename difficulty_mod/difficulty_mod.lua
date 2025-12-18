local log = require("klua.log"):new("difficulty_mod")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local S = require("sound_db")
local GS = require("game_settings")
local sys = require("systems")
local W = require("wave_db")
local P = require("path_db")
local game = require("game")
local game_gui = require("game_gui")
local DI = require("difficulty")
local config = require("difficulty_mod.config")

local hook = hook_utils:new()

function hook:init(mod_data)
	self.mod_data = mod_data

	HOOK(E, "load", self.E.load)
	HOOK(W, "load", self.W.load)
	HOOK(P, "load", self.P.load)
end

function hook.E.load(load, self)
	load(self)

	package.loaded.difficulty_templates = nil
	require("difficulty_templates")
	
	-- 血量倍数
	if config.enemy_hp_max_factor ~= 1 or config.fly_enemy_speed_factor ~= 1 then
		for i = 1, #GS.difficulty_enemy_hp_max_factor do
			GS.difficulty_enemy_hp_max_factor[i] = 1
		end
	end

	-- 速度倍数
	if config.enemy_speed_factor ~= 1 or config.fly_enemy_speed_factor ~= 1 then
		for i = 1, #GS.difficulty_enemy_speed_factor do
			GS.difficulty_enemy_speed_factor[i] = 1
		end
	end

	-- 英雄经验倍数
	if config.hero_xp_factor ~= 1 then
		for i = 1, #GS.hero_xp_gain_per_difficulty_mode do
			GS.hero_xp_gain_per_difficulty_mode[i] = config.hero_xp_factor
		end
	end
end

function hook.W.load(load, self, level_name, game_mode, wave_ss_data)
	load(self, level_name, game_mode, wave_ss_data)

	local function apply_spawn_factor(spawn, f)
		f = f or ""

		spawn.interval = spawn.interval * config[f .. "spawn_interval_factor"]
		spawn.interval_next = spawn.interval_next * config[f .. "spawn_interval_factor"]
		spawn.max = math.ceil(spawn.max * config[f .. "spawn_count_factor"])

		if spawn.max_same then
			spawn.max_same = math.ceil(spawn.max_same * config[f .. "spawn_count_factor"])
		end
	end

	W.db.cash = W.db.cash * config.cash_factor

	local waves = W.db.groups
	for _, wave in ipairs(waves) do
		wave.interval = wave.interval * config.wave_interval_factor

		local groups = wave.waves
		for _, group in ipairs(groups) do
			local spawns = group.spawns

			for _, spawn in ipairs(spawns) do
				local tt = T(spawn.creep)

				if tt.vis then
					local flags = tt.vis.flags

					if band(flags, F_BOSS) ~= 0 then
						apply_spawn_factor(spawn, "boss_")
					elseif band(flags, F_FLYING) ~= 0 then
						apply_spawn_factor(spawn, "fly_")
					else
						apply_spawn_factor(spawn)
					end
				end
			end
		end
	end
end

function hook.P.load(load, self, name, visible_coords)
	load(self, name, visible_coords)

	if config.reversed_path then
		if not P.paths then
			return
		end

		for _, path in ipairs(P.paths) do
			for _, subpath in ipairs(path) do
				if type(subpath) == "table" then
					local n = #subpath

					for k = 1, math.floor(n * 0.5) do
						subpath[k], subpath[n - k + 1] = subpath[n - k + 1], subpath[k]
					end
				end
			end
		end
	end
end

return hook