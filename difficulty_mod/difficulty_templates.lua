local config = require("difficulty_mod.config")
local mod_utils = require("mod_utils")

local function FT(...)
    return E:filter_templates(...)
end

local function check_flags_get_factor(flags, config_key)
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
for _, e in pairs(FT("enemy")) do
    local vis_flags = e.vis.flags

    -- 赏金
    if e.enemy.gold then
        local factor = check_flags_get_factor(vis_flags, "enemy_gold_factor")

        mod_utils.apply_factor(e.enemy, "gold", factor, true)
    end

    -- 血量
    if e.health and e.health.hp_max then
        local factor = check_flags_get_factor(vis_flags, "enemy_hp_max_factor")

        mod_utils.apply_factor(e.health, "hp_max", factor)
    end

    -- 速度
    if e.motion and e.motion.max_speed then
        local factor = check_flags_get_factor(vis_flags, "enemy_speed_factor")

        mod_utils.apply_factor(e.motion, "max_speed", factor)
    end

    -- 技能冷却
    local factor = check_flags_get_factor(vis_flags, "enemy_cooldown_factor")

    mod_utils.mixed_apply_factor(e, "cooldown", factor)
end

-- 英雄模板
for _, h in pairs(FT("hero")) do
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

-- 防御塔模板
-- 防御塔
for _, t in pairs(FT("tower")) do
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

-- 兵营
for _, b in pairs(FT("barrack")) do
    local barrack = b.barrack

    if barrack.rally_range then
        mod_utils.apply_factor(barrack, "rally_range", config.barrack_rally_range_factor)
    end

    if barrack.max_soldiers then
        mod_utils.apply_factor(barrack, "max_soldiers", config.barrack_max_soldiers_factor, true)
    end

    if b.spawn_time then
        mod_utils.apply_factor(b, "spawn_time", config.barrack_spawn_time_factor)
    end
end
