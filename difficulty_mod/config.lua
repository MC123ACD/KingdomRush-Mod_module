return {
    name = "difficulty_mod",
    version = "1.0.0",
    game_version = {"kr5", "kr3", "kr2", "kr1"},
    desc = "增加额外难度设置",
    url = nil,
    github_url = nil,
    by = "MC123ACD",
    enabled = true,
    priority = 1,

    --[[
        数值方面设置
    --]]

    -- 初始金币倍数
    cash_factor = 1,
    -- 波次间隔倍数
    wave_interval_factor = 1,
    -- 生成敌人间隔倍数
    spawn_interval_factor = 1,
    -- 敌人数量倍数
    spawn_count_factor = 1,

    -- 敌人赏金倍数
    enemy_gold_factor = 1,
    -- 敌人血量倍数
    enemy_hp_max_factor = 1,
    -- 敌人速度倍数
    enemy_speed_factor = 1,

    -- 英雄经验倍数
    hero_xp_factor = 1,
    -- 英雄大招冷却倍数
    ultimate_cooldown_factor = 1,
    -- 英雄技能冷却倍数
    skill_cooldown_factor = 1,

    -- 防御塔价格倍数
    tower_price_factor = 1,

    --[[
        机制方面设置
    --]]

    -- 是否启用相反路径
    reversed_path = true,
}