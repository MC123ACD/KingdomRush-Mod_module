local log = require("klua.log"):new("modify_dif")

local GS = require("game_settings")
local W = require("wave_db")
local P = require("path_db")

local modify_dif = {}

function modify_dif:init(config)
    self.config = config
end

function modify_dif.apply_factor(t, k, factor)
    if factor == 1 or not t[k] then
        return
    end

    local value = t[k]
    local value_type = type(value)

    if value_type == "table" then
        for i = 1, #value do
            local v = value[i]

            value[i] = v * factor
        end
    elseif value_type == "number" then
        t[k] = math.ceil(value * factor)
    end

    return true
end

function modify_dif:templates()
    local config = self.config

    -- 敌人
    local enemy_templates = E:filter_templates("enemy")

    for _, e in pairs(enemy_templates) do
        -- 赏金
        if e.enemy.gold then
            if band(e.vis.flags, F_FLYING) == 0 then
                self.apply_factor(e.enemy, "gold", config.enemy_gold_factor)
            else
                self.apply_factor(e.enemy, "gold", config.fly_enemy_gold_factor)
            end
        end

        -- 血量
        if e.health and e.health.hp_max then
            if band(e.vis.flags, F_FLYING) == 0 then
                self.apply_factor(e.health, "hp_max", config.enemy_hp_max_factor)
            else
                self.apply_factor(e.health, "hp_max", config.fly_enemy_hp_max_factor)
            end
        end

        -- 速度
        if e.motion and e.motion.max_speed then
            if band(e.vis.flags, F_FLYING) == 0 then
                self.apply_factor(e.motion, "max_speed", config.enemy_speed_factor)
            else
                self.apply_factor(e.motion, "max_speed", config.fly_enemy_speed_factor)
            end
        end
    end

    -- 英雄
    local hero_templates = E:filter_templates("hero")

    for _, h in pairs(hero_templates) do
        for k, skill in pairs(h.hero.skills) do
            if skill.cooldown then
                if k == "ultimate" then
                    self.apply_factor(skill, "ultimate", config.ultimate_cooldown_factor)
                else
                    self.apply_factor(skill, k, config.skill_cooldown_factor)
                end
            end
        end
    end

    local tower_templates = E:filter_templates("tower")

    -- 防御塔
    for _, t in pairs(tower_templates) do
        if t.tower.price then
            self.apply_factor(t.tower, "price", config.tower_price_factor)
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
    local config = self.config

    W.db.cash = W.db.cash * config.cash_factor

    local waves = W.db.groups
    for _, wave in ipairs(waves) do
        wave.interval = wave.interval * config.wave_interval_factor

        local groups = wave.waves
        for _, group in ipairs(groups) do
            local spawns = group.spawns

            for _, spawn in ipairs(spawns) do
                spawn.interval = spawn.interval * config.spawn_interval_factor
                spawn.interval_next = spawn.interval_next * config.spawn_interval_factor
                spawn.max = math.ceil(spawn.max * config.spawn_count_factor)

                if spawn.max_same then
                    spawn.max_same = math.ceil(spawn.max_same * config.spawn_count_factor)
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
