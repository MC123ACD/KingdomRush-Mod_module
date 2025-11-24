local log = require("klua.log"):new("modify_dif")

local GS = require("game_settings")
local W = require("wave_db")
local P = require("path_db")
local mod_utils = require("mod_utils")

local modify_dif = {}

function modify_dif:init(config)
    self.config = config
end

function modify_dif.check_flags_get_factor(flags, config_key)
    config = modify_dif.config

    local factor = config[config_key]
    local matched_flags = 0

    if band(flags, F_BOSS) ~= 0 then
        factor = config["boss_" .. config_key]
        matched_flags = bor(matched_flags, F_BOSS)
    elseif band(flags, F_FLYING) ~= 0 then
        factor = config["fly_" .. config_key]
        matched_flags = bor(matched_flags, F_FLYING)
    end

    factor = factor or 1

    return factor, matched_flags
end

-- 敌人模板
function modify_dif:enemy_templates()
    local config = self.config

    local enemy_templates = E:filter_templates("enemy")

    for _, e in pairs(enemy_templates) do
        local vis_flags = e.vis.flags

        -- 赏金
        if e.enemy.gold then
            local factor = modify_dif.check_flags_get_factor(vis_flags, "enemy_gold_factor")

            mod_utils.apply_factor(e.enemy, "gold", factor, true)
        end

        -- 血量
        if e.health and e.health.hp_max then
            local factor = modify_dif.check_flags_get_factor(vis_flags, "enemy_hp_max_factor")

            mod_utils.apply_factor(e.health, "hp_max", factor)
        end

        -- 速度
        if e.motion and e.motion.max_speed then
            local factor = modify_dif.check_flags_get_factor(vis_flags, "enemy_speed_factor")

            mod_utils.apply_factor(e.motion, "max_speed", factor)
        end

        -- 技能冷却
        local factor = modify_dif.check_flags_get_factor(vis_flags, "enemy_cooldown_factor")

        mod_utils.mixed_apply_factor(e, "cooldown", factor)
    end
end

-- 英雄模板
function modify_dif:hero_templates()
    local config = self.config

    local hero_templates = E:filter_templates("hero")

    for _, h in pairs(hero_templates) do
        for k, skill in pairs(h.hero.skills) do
            if skill.cooldown then
                if k == "ultimate" then
                    mod_utils.apply_factor(skill, "ultimate", config.ultimate_cooldown_factor)
                else
                    mod_utils.apply_factor(skill, k, config.hero_skill_cooldown_factor)
                end
            end
        end
    end
end

-- 防御塔模板
function modify_dif:tower_templates()
    local config = self.config

    local tower_templates = E:filter_templates("tower")

    -- 防御塔
    for _, t in pairs(tower_templates) do
        local tower = t.tower

        if tower.price then
            mod_utils.apply_factor(tower, "price", config.tower_price_factor, true)
        end

        if t.powers then
            local powers = t.powers

            for _, power in pairs(powers) do
                if power.price_base then
                    mod_utils.apply_factor(power, "price_base", config.tower_powers_price_factor, true)
                end
                if power.price_inc then
                    mod_utils.apply_factor(power, "price_inc", config.tower_powers_price_factor, true)
                end
            end
        end
    end

    local barrack_templates = E:filter_templates("barrack")

    -- 兵营
    for _, t in pairs(barrack_templates) do
        local barrack = t.barrack

        if barrack.rally_range then
            mod_utils.apply_factor(barrack, "rally_range", config.barrack_rally_range_factor)
        end

        if barrack.max_soldiers then
            mod_utils.apply_factor(barrack, "max_soldiers", config.barrack_max_soldiers_factor, true)
        end

        if t.spawn_time then
            mod_utils.apply_factor(t, "spawn_time", config.barrack_spawn_time_factor)
        end
    end
end

function modify_dif:game_settings()
    local config = self.config

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

function modify_dif:waves()
    local function apply_spawn_factor(spawn, f)
        f = f or ""

        spawn.interval = spawn.interval * config[f .. "spawn_interval_factor"]
        spawn.interval_next = spawn.interval_next * config[f .. "spawn_interval_factor"]
        spawn.max = math.ceil(spawn.max * config[f .. "spawn_count_factor"])

        if spawn.max_same then
            spawn.max_same = math.ceil(spawn.max_same * config[f .. "spawn_count_factor"])
        end
    end

    local config = self.config

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

function modify_dif:paths()
    local config = self.config

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

return modify_dif
