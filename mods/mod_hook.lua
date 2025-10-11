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

function hook:front_init()
    HOOK(S, "init", self.S.init)
end

function hook:after_init()
    HOOK(I, "load_atlas", self.I.load_atlas)
    HOOK(S, "load_group", self.S.load_group)
end

-- 增加图像资源覆盖路径
function hook.I.load_atlas(origin, self, ref_scale, path, name, yielding)
    origin(self, ref_scale, path, name, yielding)

    for _, mod_data in ipairs(hook.mods_data) do
        local mod_assets_path = mod_data.path .. "/_assets/images"

        if FS.isDirectory(mod_assets_path) then
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
end

-- 增加声音资源覆盖路径
function hook.S.init(origin, self, path, overrides)
    origin(self, path, overrides)
    
    for _, mod_data in ipairs(hook.mods_data) do
        local mod_assets_path = mod_data.path .. "/_assets/sounds"

        if FS.isDirectory(mod_assets_path) then
            -- 由于原函数实现逻辑缺少路径检查，所以只能写低兼容性代码

            if FS.isFile(mod_assets_path .. "/settings.lua") then
                local f_settings = FS.load(path .. "/settings.lua")()

                if f_settings.source_groups then
                    for gid, group in pairs(f_settings.source_groups) do
                        self.source_groups[gid] = {
                            max_sources = group.max_sources or 1
                        }
                        self.active_sources[gid] = self.active_sources[gid] or {}
                    end
                end
            end

            if FS.isFile(mod_assets_path .. "/sounds.lua") then
                self.sounds = FS.load(mod_assets_path .. "/sounds.lua")()

                log.info("Found sound's sounds override in mod %s", mod_data.name)
            end

            if FS.isFile(mod_assets_path .. "/groups.lua") then
                self.groups = FS.load(mod_assets_path .. "/groups.lua")()

                log.info("Found sound's groups override in mod %s", mod_data.name)
            end

            if FS.isFile(mod_assets_path .. "/extra.lua") then
                local f_extra

                f_extra = FS.load(mod_assets_path .. "/extra.lua")()

                if f_extra and f_extra.sounds then
                    for k, v in pairs(f_extra.sounds) do
                        self.sounds[k] = v
                    end
                end

                for id, sd in pairs(self.sounds) do
                    self.sound_extras[id] = {}
                end

                if f_extra and f_extra.groups then
                    for k, v in pairs(f_extra.groups) do
                        if v.append then
                            if v.sounds then
                                for _, s in pairs(v.sounds) do
                                    local sound = self.sounds[s]

                                    for _, f in pairs(sound.files) do
                                        if not table.contains(self.groups[k].files, f) then
                                            table.insert(self.groups[k].files, f)
                                        end
                                    end
                                end
                            end

                            if v.files then
                                for _, f in pairs(v.files) do
                                    if not table.contains(self.groups[k].files, f) then
                                        table.insert(self.groups[k].files, f)
                                    end
                                end
                            end
                        elseif v.alias then
                            self.groups[k] = self.groups[v.alias]
                        else
                            self.groups[k] = v
                        end
                    end
                end
            end
        end
    end
end

function hook.S.load_group(origin, self, name, yielding, filter)
    origin(self, name, yielding, filter)

    for _, mod_data in ipairs(hook.mods_data) do
        local mod_files_path = mod_data.path .. "/_assets/sounds/files"

        if FS.isDirectory(mod_files_path) then
            if self.sounds_uses and self.sounds_uses[name] then
                self.sounds_uses[name] = nil
            end

            if self.sources then
                local sound_files = self.groups[name].files
                for _, file_name in ipairs(sound_files) do
                    if self.sources and self.sources[file_name] then
                        self.sources[file_name] = nil
                    end
                end
            end

            local origin_path = self.files_path
            self.files_path = mod_files_path

            origin(self, name, yielding, filter)

            self.files_path = origin_path
        end
    end
end

return hook
