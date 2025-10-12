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

function mod_main:init(director)
    local descending_mods_data, ascending_mods_data = mod_utils:check_get_available_mods()
    mod_hook.desc_mods_data = descending_mods_data
    mod_hook.asc_mods_data = ascending_mods_data

    local function director_init(params)
        self:front_init(ascending_mods_data)
        director:init(main.params)
        self:after_init(ascending_mods_data)
    end

    director_init(main.params)
end

function mod_main:front_init(mods_data)
    mod_hook:front_init()
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init(mods_data)
    -- 按排序顺序初始化所有模组
    for _, mod_data in ipairs(mods_data) do
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