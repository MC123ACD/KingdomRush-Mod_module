-- chunkname: @./mods/mod_hook.lua
local log = require("klua.log"):new("mod_hook")
local IS_KR5 = KR_GAME == "kr5"
local I = require("klove.image_db")
local S = require("sound_db")
local FS = love.filesystem
local mod_utils = require("mods.mod_utils")
local HOOK = mod_utils.HOOK

local hook = {}

-- 元表：自动创建不存在表
auto_table_mt = {
    __index = function(table, key)
        local new = {}
        setmetatable(new, auto_table_mt)

        rawset(table, key, new)
        return new
    end
}
setmetatable(hook, auto_table_mt)

function hook:init()
    HOOK(I, "load_atlas", self.I.load_atlas)
    HOOK(S, "init", self.S.init)
end

-- 增加图像资源覆盖路径
function hook.I.load_atlas(origin, self, ref_scale, path, name, yielding)
    origin(self, ref_scale, path, name, yielding)

    for _, mod_data in ipairs(mod_utils:get_subdirs("mods")) do
        local mod_assets_path = mod_data.path .. "/_assets/images"
        local group_file = mod_assets_path .. "/" .. name .. ".lua"

        if FS.isFile(group_file) then
            local name_scale = string.format("%s-%.6f", name, ref_scale)

            if self.atlas_uses and self.atlas_uses[name_scale] then
                self.atlas_uses[name_scale] = nil
            end
        end

        self:preload_atlas(ref_scale, mod_assets_path, name)

        log.info("Found atlas override %s in mod %s", group_file, mod_data.name)
    end
end

return hook
