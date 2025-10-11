-- chunkname: @./mods/mod_utils.lua
local log = require("klua.log"):new("mod_utils")
local IS_KR5 = KR_GAME == "kr5"
local FS = love.filesystem
local mod_utils = {}

if love.filesystem.isFused() then
    mod_utils.ppref = ""
else
    mod_utils.ppref = base_dir ~= work_dir and "" or "src/"
end

--- 获取指定路径下的所有子目录名
--- 
--- 返回一个包含子目录信息的表，每个元素包含name(子目录名)和path(完整路径)
---@param path string 要扫描的目录路径
---@return table 包含子目录信息的表
function mod_utils:get_subdirs(path)
    -- 获取目录下所有文件和子目录
    local files = FS.getDirectoryItems(path)

    local folders = {}

    -- 检查路径是否存在
    if not files then
        log.error("Path does not exist: %s", path)
        return {}
        -- 检查目录是否为空
    elseif #files == 0 then
        log.debug("No files found in path: %s", path)
    end

    -- 遍历目录下的所有项目
    for _, file in ipairs(files) do
        -- 构建完整文件路径
        local filepath = path .. "/" .. file

        -- 检查是否为目录
        if FS.isDirectory(filepath) then
            -- 将目录信息添加到结果表中
            table.insert(folders, {
                name = file,    -- 目录名称
                path = filepath -- 目录完整路径
            })
        end
    end

    return folders
end

--- 将模组所有目录添加到 package.path 中，以便 require 能够找到模组文件
---@param mod_data table 模组数据，包含模组路径等信息
---@return nil
function mod_utils:add_path(mod_data)
    -- 自定义格式化函数，将路径与模组名结合
    local function f(str, ...)
        local path = mod_data.path .. "/" .. str
        return path:format(...)
    end

    -- 初始化附加路径表
    local additional_paths = {
        f("?.lua") -- 添加模组根目录的lua文件搜索路径
    }

    -- 将mods根目录添加到路径中，只增加一次（避免重复添加）
    if not package.path:find("^mods/%?%.lua$") then
        table.insert(additional_paths, 1, "mods/?.lua")
        log.debug("Added path at require: %s", "mods/?.lua")
    end

    -- 获取模组下的所有目录，并将其添加到路径中
    local mod_dirs = self:get_subdirs(mod_data.path)

    -- 遍历模组下的所有目录
    for _, dir in ipairs(mod_dirs) do
        -- kui_templates 特例单独处理（KUI模板系统特殊路径）
        if table.contains(self.ignored_path, dir.name) then
            log.debug("Ignored mod path: %s", dir.path)
        elseif dir.name == "kui_templates" then
            local kui_db

            -- 根据运行环境选择不同的KUI数据库模块
            if IS_KR5 then
                kui_db = require("klove.kui_db")
            else
                kui_db = require("kui_db")
            end

            -- 将KUI模板路径添加到KUI数据库路径表中（优先级最高）
            table.insert(kui_db.paths, 1, f("kui_templates"))
            log.debug("Added path in kui_db: %s", f("kui_templates", dir.name))
        else
            -- 其他目录添加到require路径中
            table.insert(additional_paths, f("%s/?.lua", dir.name))
            log.debug("Added path in require: %s", f("%s/?.lua", dir.name))
        end
    end

    -- 更新FS和package的require路径
    FS.setRequirePath(table.concat(additional_paths, ";") .. ";" .. FS.getRequirePath())
    package.path = FS.getRequirePath()
    log.debug("Current package.path: %s", package.path)
end

function mod_utils:table_tostring(t)
    if type(t) ~= "table" then
        return tostring(t)
    end

    local max_items = 5 -- 限制显示的项目数量
    local items = {}
    local count = 0

    for k, v in pairs(t) do
        if count >= max_items then
            table.insert(items, "...")
            break
        end

        local key_str = type(k) == "string" and k or "[" .. tostring(k) .. "]"
        local value_str
        if type(v) == "string" then
            value_str = '"' .. v .. '"'
        elseif type(v) == "table" then
            value_str = "{...}" -- 不递归显示嵌套表
        else
            value_str = tostring(v)
        end

        table.insert(items, key_str .. "=" .. value_str)
        count = count + 1
    end

    return "{" .. table.concat(items, ", ") .. "}"
end

--- 获取模组调试信息
---@param config table 模组配置表
---@return string 格式化的模组信息字符串
function mod_utils:get_debug_info(config)
    local f = string.format
    -- 构建模组信息标题
    local o = f("------------------- LOADED_MOD: %s -----------------------\n", config.name)
    o = o .. f("name:           %s\n", config.name or "unknown")            -- 模组名称
    o = o .. f("desc:           %s\n", config.desc or "unknown")            -- 模组描述
    o = o .. f("version:        %s\n", config.version or "unknown")         -- 模组版本
    o = o .. f("by:             %s\n", config.by or "unknown")              -- 作者信息
    o = o .. f("url:            %s\n", config.url or "unknown")             -- 模组发布地址
    o = o .. f("github_url:     %s\n", config.github_url or "unknown")      -- GitHub地址
    o = o .. f("priority:       %s\n", config.priority or "unknown")   -- 优先级
    o = o .. f("game_version:   %s", self:table_tostring(config.game_version))    -- 兼容游戏版本

    return o
end

--- 替换原函数
--- @param obj table 目标
--- @param fn_name str 函数名
--- @param handler function 替换的函数
--- @return nil
function mod_utils.HOOK(obj, fn_name, handler)
    if not obj._hook_origin_fn then -- 若没有 hook 给定的函数
        obj._hook_origin_fn = {}
    elseif obj._hook_origin_fn[fn_name] then    -- 若已 hook 给定的函数直接返回
        return
    end

    local hook_fn = obj[fn_name]    -- 存储原函数

    obj._hook_origin_fn[fn_name] = hook_fn  -- 标记已 hook

    obj[fn_name] = function(...)
        return handler(hook_fn, ...)    -- 替换原函数
    end
end

--- 移除 hook
--- @param obj table 目标
--- @param fn_name str 函数名
--- @return nil
function mod_utils.UNHOOK(obj, fn_name)
    if not obj._hook_origin_fn then -- 若对应函数未 hook 直接返回
        return
    end

    local hook_fn = obj._hook_origin_fn[fn_name]    -- 存储 hook 后的函数

    if not hook_fn then
        return
    end

    obj[fn_name] = hook_fn  -- 还原
    obj._hook_origin_fn[fn_name] = nil  -- 移除标记

    log.debug("Unhooked function: %s.%s", tostring(obj), fn_name)
end

--[[
以下是将一些模块与函数设为全局便于使用
--]]

require("main_globals")
require("constants")
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
epsilon = 1e-09

E = require("entity_db")
UPGR = require("upgrades")
storage = require("storage")
SU = require("script_utils")
U = require("utils")

if IS_KR5 then
    balance = require("data.balance.balance")
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
--- @return table
--- @see E:register_t
function RT(name, ref)
    return E:register_t(name, ref)
end

--- 增加组件
--- @param name string 模板名
--- @param ... string 组件名
--- @return nil
--- @see E:add_comps
function AC(name, ...)
    return E:add_comps(name, ...)
end

--- 深拷贝组件
--- @param c_name string 组件名
--- @return table
--- @see E:clone_c
function CC(c_name)
    return E:clone_c(c_name)
end

--- 索引模板
--- @param name string 模板名
--- @return table
--- @see E:get_template
function T(name)
    return E:get_template(name)
end

--- 创建实体
--- @param t string 模板名
--- @return table
--- @see E:create_entity
function create_entity(t)
    return E:create_entity(t)
end

--- 将实体放到插入队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
--- @see simulation:queue_insert_entity
function queue_insert(store, e)
    simulation:queue_insert_entity(e)
end

--- 将实体加入移除队列
--- @param store table game.store
--- @param e table 实体表
--- @return nil
--- @see simulation:queue_remove_entity
function queue_remove(store, e)
    simulation:queue_remove_entity(e)
end

--- 将伤害实体加入伤害队列
--- @param store table game.store
--- @param damage table 实体表
--- @return nil
function queue_damage(store, damage)
    table.insert(store.damage_queue, damage)
end

return mod_utils
