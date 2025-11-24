return {
    name = "difficulty_mod",
    version = "1.3.0",
    game_version = {"kr5", "kr3", "kr2", "kr1"},
    desc = "增加额外难度设置",
    url = "https://tieba.baidu.com/p/10139965218",
    by = "MC123ACD",
    enabled = true,
    priority = 1,

    --[[
        ================================================
        数值方面设置======================================
        ================================================
    --]]

    -- 初始金币倍数
    cash_factor = 1,
    -- 波次间隔倍数
    wave_interval_factor = 1,
    
    -- 敌人生成间隔倍数
    spawn_interval_factor = 1,
    -- 敌人数量倍数（向上取整）
    spawn_count_factor = 1,
    -- 敌人赏金倍数（向上取整）
    enemy_gold_factor = 1,
    -- 敌人血量倍数（向上取整）
    enemy_hp_max_factor = 1,
    -- 敌人速度倍数
    enemy_speed_factor = 1,
    -- 敌人冷却倍数
    enemy_cooldown_factor = 1,

    -- 飞行敌人生成间隔倍数
    fly_spawn_interval_factor = 1,
    -- 飞行敌人数量倍数（向上取整）
    fly_spawn_count_factor = 1,
    -- 飞行敌人赏金倍数（向上取整）
    fly_enemy_gold_factor = 1,
    -- 飞行敌人血量倍数（向上取整）
    fly_enemy_hp_max_factor = 1,
    -- 飞行敌人速度倍数
    fly_enemy_speed_factor = 1,
    -- 飞行敌人冷却倍数
    fly_enemy_cooldown_factor = 1,
    
    -- Boss敌人生成间隔倍数
    boss_spawn_interval_factor = 1,
    -- Boss敌人数量倍数（向上取整，仅支持场外出场的Boss）
    boss_spawn_count_factor = 1,
    -- Boss敌人血量倍数（向上取整）
    boss_enemy_hp_max_factor = 1,
    -- Boss敌人速度倍数
    boss_enemy_speed_factor = 1,
    -- Boss敌人冷却倍数
    boss_enemy_cooldown_factor = 1,

    -- 英雄经验倍数
    hero_xp_factor = 1,
    -- 英雄大招冷却倍数
    ultimate_cooldown_factor = 1,
    -- 英雄技能冷却倍数
    hero_skill_cooldown_factor = 1,

    --[[
        防御塔
    --]]

    -- 防御塔价格倍数（向上取整）
    tower_price_factor = 1,
    -- 防御塔技能价格倍数（向上取整）
    tower_powers_price_factor = 1,

    -- 兵营集结点范围倍数
    barrack_rally_range_factor = 1,
    -- 兵营人数倍数（向上取整）
    barrack_max_soldiers_factor = 1,
    -- 兵营士兵复活时间倍数
    barrack_spawn_time_factor = 1,

    --[[
        ================================================
        机制方面设置======================================
        ================================================
    --]]

    -- 是否启用相反路径
    reversed_path = false,
}