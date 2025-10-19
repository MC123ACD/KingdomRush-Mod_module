return {
    name = "speed_mod",
    version = "1.0.0",
    game_version = {"kr5", "kr3", "kr2", "kr1"},
    desc = "增加加减速快捷键",
    by = "MC123ACD",
    enabled = true,
    priority = 1,

    -- 加速快捷键
    up_speed_key = "v",
    -- 减速快捷键
    down_speed_key = "c",
    -- 还原快捷键
    reset_speed_key = "x",
    -- 是否按住加减速
    is_down_key = true,
    -- 加速倍数
    up_speed_factor = 3,
    -- 减速倍数
    down_speed_factor = 0.1
}