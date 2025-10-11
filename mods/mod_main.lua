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

--- 初始化所有已启用的模组
---@return nil
function mod_main:init()
    local mods_data = {}

    for _, mod_data in ipairs(mod_utils:get_subdirs("mods")) do
        -- 加载模组配置文件
        local config = require(mod_utils.ppref .. mod_data.path .. ".config")

        -- 检查是否是兼容游戏版本
        if type(config.game_version) == "string" and config.game_version == KR_GAME or type(config.game_version) == "table" and table.contains(config.game_version, KR_GAME) then
            -- 检查模组是否启用且路径存在
            if config.enabled and love.filesystem.exists(mod_data.path) then
                -- 添加优先级信息到模组数据中
                mod_data["priority"] = config.priority
                table.insert(mods_data, mod_data)
            else
                log.error("%s is disabled!", mod_data.name)
            end
        else
            -- 不是兼容的游戏版本
            log.error("Mod '%s' is not compatible. Required game version: %s", config.name,
                mod_utils:table_tostring(config.game_version) or "unknown", config.name)
        end
    end

    if #mods_data > 0 then
        -- 根据优先级对模组进行降序排序（优先级高的先加载）
        table.sort(mods_data, function(a, b)
            return a.priority > b.priority
        end)

        -- 按排序顺序初始化所有模组
        for index, mod_data in ipairs(mods_data) do
            -- 重新加载模组配置（确保获取最新配置）
            local config = require(mod_utils.ppref .. mod_data.path .. ".config")

            -- 添加模组路径到package.path
            mod_utils:add_path(mod_data)
            -- 加载并初始化模组
            local mod = require(mod_data.name)
            mod:init()

            -- 记录模组加载信息
            log.error(mod_utils:get_debug_info(config))
        end
    else
        log.debug("No mods to load.")
    end

    mod_hook:init()
end

return mod_main