-- chunkname: @./mods/mod_main.lua

local log = require("klua.log"):new("mod_main")
local IS_KR5 = KR_GAME == "kr5"
local FS = love.filesystem

local additional_paths = {
    "mods/?.lua",
    "mods/all/?.lua"
}

FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())
package.path = FS.getRequirePath()

local mod_hook = require("mod_hook")
local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")

local mod_main = {}

function mod_main:init(director)
    local config = require("config")

    local mods_data = mod_utils.check_get_available_mods(config)
    self.mods_data = mods_data
    mod_hook.mods_data = mods_data

    if config.enabled then
        self:front_init()

        director:init(main.params)

        self:after_init()
    else
        director:init(main.params)
    end
end

function mod_main:front_init(mods_data)
    mod_hook:front_init()
end

--- 初始化所有已启用的模组
---@return nil
function mod_main:after_init()
    local loaded_mods = {}

    -- 正序加载所有模组，确保加载模块顺序正确
    for i = 1, #self.desc_mods_data do
        local mod_data = self.desc_mods_data[i]

        -- 添加模组路径到package.path
        mod_utils.add_path(mod_data)

        -- 加载模组
        local mod = require(mod_data.name)

        if type(mod) ~= "table" then
            log.error(string.format("Must return table, mod: %s", mod_data.name))
        else
            table.insert(loaded_mods, {
                mod,
                mod_data
            })
        end
    end

    -- 倒序初始化模组，确保高优先级覆盖低优先级
    for i = #loaded_mods, 1, -1 do
        local loaded_mod, mod_data = unpack(loaded_mods[i])

        -- 初始化模组
        loaded_mod[1]:init(mod_data)

        -- 打印模组加载信息
        log.error(mod_utils.get_debug_info(mod_data.config))
    end

    mod_hook:after_init()
end

return mod_main
