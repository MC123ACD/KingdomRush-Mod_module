-- chunkname: @./mods/mod_main.lua
local log = require("klua.log"):new("mod_main")
local IS_KR5 = KR_GAME == "kr5"
local FS = love.filesystem
local mod_utils = require("mods.mod_utils")
local mod_hook = require("mods.mod_hook")

mod_utils.ignored_path = {
    "_assets"
}

local mod_main = {}

function mod_main:front_init(mods_data)
    mod_hook:front_init()
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init(mods_data)
    -- 按排序顺序初始化所有模组
    for index, mod_data in ipairs(mods_data) do
        -- 重新加载模组配置（确保获取最新配置）
        local config = require(mod_utils.ppref .. mod_data.path .. ".config")

        -- 添加模组路径到package.path
        mod_utils:add_path(mod_data)
        -- 加载并初始化模组
        local mod = require(mod_data.name)
        mod:init()

        -- 打印模组加载信息
        log.error(mod_utils:get_debug_info(config))
    end

    mod_hook:after_init()
end

return mod_main