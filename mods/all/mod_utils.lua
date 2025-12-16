-- chunkname: @./mods/all/mod_utils.lua
local log = require("klua.log"):new("mod_utils")
local FS = love.filesystem
local hook_utils = require("hook_utils")
local mod_main_config = require("mod_main_config")

local A
if IS_KR5 then
    A = require("klove.animation_db")
else
    A = require("animation_db")
end

local mod_utils = {}

-- 元表：自动创建不存在表
mod_utils.auto_table_mt = {
    __index = function(table, key)
        local new = {}
        setmetatable(new, auto_table_mt)

        rawset(table, key, new)
        return new
    end
}

--- 获取指定路径下的所有子目录名
---
--- 返回一个包含子目录信息的表，每个元素包含name(子目录名)和path(完整路径)
---@param path string 要扫描的目录路径
---@param is_mods boolean 是否为mods目录
---@param filter_fn function 过滤函数
---@return table 包含子目录信息的表
function mod_utils.get_subdirs(path, is_mods, filter_fn)
    -- 获取目录下所有文件和子目录
    local files = FS.getDirectoryItems(path)

    -- 检查路径是否存在
    if not files then
        log.error("Path does not exist: %s", path)
        return {}
    end

    local files_count = #files
    -- 检查目录是否为空
    if files_count == 0 then
        log.debug("No files found in path: %s", path)
    end

    local file_datas = {}

    -- 遍历目录下的所有项目
    for i = 1, files_count do
        local file = files[i]

        -- 构建完整文件路径
        local filepath = path .. "/" .. file

        -- 过滤
        if (not filter_fn or filter_fn(file, filepath)) and not table.contains(mod_main_config.ignored_path, file) and FS.isDirectory(filepath) then
            local file_data = {
                name = file,
                path = filepath,
                check_paths = {},
            }

            if is_mods then
                local check_paths = mod_main_config.check_paths
                for i = 1, #check_paths do
                    local check_path = check_paths[i]
                    local full_check_path = filepath .. check_path

                    if FS.exists(full_check_path) then
                        file_data.check_paths[check_path] = full_check_path
                    end
                end
            end

            table.insert(file_datas, file_data)
        end
    end

    return file_datas
end

--- 将表转化为字符串，返回的字符串无键值与大括号
---@param t table 表
---@return string 字符串
function mod_utils.table_tostring(t)
    if type(t) ~= "table" then
        return tostring(t)
    end

    local items = {}

    for k, v in pairs(t) do
        local value_str
        if type(v) == "string" then
            value_str = v
        elseif type(v) == "table" then
            value_str = "{" .. self:table_tostring(t) .. "}"
        else
            value_str = tostring(v)
        end

        table.insert(items, value_str)
    end

    return table.concat(items, ", ")
end

---根据表修改指定动画
---
---若动画表中removed为真将会移除动画
---@param t table 表
---@return table 增加的动画, table 删除的动画
function mod_utils.a_db_reset(t)
    local added_a = {}
    local deleted_k = {}

    for k, v in pairs(t) do
        if v.removed then
            table.insert(deleted_k, k)

            goto skip_add
        end

        if v.layer_from and v.layer_to and v.layer_prefix then
            for i = v.layer_from, v.layer_to do
                local nk = string.gsub(k, "layerX", "layer" .. i)
                local nv = {
                    fps = v.fps,
                    group = v.group,
                    pre = v.pre,
                    post = v.post,
                    from = v.from,
                    to = v.to,
                    ranges = v.ranges,
                    frames = v.frames,
                    prefix = string.format(v.layer_prefix, i)
                }

                added_a[nk] = nv

                table.insert(deleted_k, k)
            end
        else
            added_a[k] = v
        end

        ::skip_add::
    end

    for k, v in pairs(added_a) do
        if IS_KR5 and not v.frames then
            A:expand_frames(v)
        end

        if not A.db[k] then
            A.db[k] = v
        else
            table.merge(A.db[k], v)
        end
    end

    for _, v in ipairs(deleted_k) do
        A.db[v] = nil
    end

    return added_a, deleted_k
end

---应用因子，根据是否为表智能赋值
---@param t table 表
---@param k string 键
---@param factor number 因子
---@param is_int? boolean 是否向上取整
---@return boolean 是否成功
function mod_utils.apply_factor(t, k, factor, is_int)
    if factor == 1 or not t[k] then
        return false
    end

    local value = t[k]
    local value_type = type(value)

    if value_type == "table" then
        for i = 1, #value do
            local v = value[i]

            if is_int then
                value[i] = math.ceil(v * factor)
            else
                value[i] = v * factor
            end
        end
    elseif value_type == "number" then
        if is_int then
            t[k] = math.ceil(value * factor)
        else
            t[k] = value * factor
        end
    end

    return true
end

---应用因子，赋值所有近战攻击，远程攻击，技能
---@param t table 表
---@param k string 键
---@param factor number 因子
---@return boolean 是否成功
function mod_utils.mixed_apply_factor(t, k, factor)
    if not t[k] or factor == 1 then
        return false
    end

    local success = false

    if t.melee then
        for _, a in ipairs(t.melee.attacks) do
            if a.cooldown then
                success = mod_utils.apply_factor(a, k, factor)
            end
        end
    end

    if t.ranged then
        for _, a in ipairs(t.ranged.attacks) do
            if a.cooldown then
                success = mod_utils.apply_factor(a, k, factor)
            end
        end
    end

    if t.timed_attacks then
        for _, a in ipairs(t.timed_attacks.list) do
            if a.cooldown then
                success = mod_utils.apply_factor(a, k, factor)
            end
        end
    end

    if not success then
        return false
    end

    return true
end

--[[
以下是将一些模块与函数设为全局便于使用
--]]

require("klove.kui")
require("klua.table")
signal = require("hump.signal")
km = require("klua.macros")
SH = require("klove.shader_db")
V = require("klua.vector")
class = require("middleclass")
bit = require("bit")
band = bit.band
bor = bit.bor
bnot = bit.bnot
copy = table.deepclone
clone = table.clone

E = require("entity_db")
UPGR = require("upgrades")
storage = require("storage")
SU = require("script_utils")
U = require("utils")

if not IS_KR5 then
    require("gg_views_custom")
end

--- 帧转秒
--- @param v number 帧
--- @return number 秒
function fts(v)
    return v / FPS
end

--- 角度转弧度
--- @param d number 角度
--- @return number 弧度
function d2r(d)
    return d * math.pi / 180
end

--- 创建模板
--- @param name string 模板名
--- @param ref string 派生的模板
--- @return table 模板引用
function RT(name, ref)
    return E:register_t(name, ref)
end

--- 增加组件
--- @param name string 模板名
--- @param ... string 组件名
--- @return nil
function AC(name, ...)
    return E:add_comps(name, ...)
end

--- 深拷贝组件
--- @param c_name string 组件名
--- @return table
function CC(c_name)
    return E:clone_c(c_name)
end

--- 索引模板
--- @param name string 模板名
--- @return table
function T(name)
    return E:get_template(name)
end

--- 创建实体
--- @param t string 模板名
--- @return table 实体引用
function create_entity(t)
    return E:create_entity(t)
end

--- 将实体增加到插入队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
function queue_insert(store, e)
    return simulation:queue_insert_entity(e)
end

--- 将实体加入移除队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
function queue_remove(store, e)
    return simulation:queue_remove_entity(e)
end

--- 将伤害实体加入伤害队列
--- @param store table game.store
--- @param damage table 实体表
--- @return nil
function queue_damage(store, damage)
    return table.insert(store.damage_queue, damage)
end

return mod_utils
