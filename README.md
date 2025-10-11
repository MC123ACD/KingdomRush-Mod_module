## 概述

本模块旨在为 KingdomRush 游戏提供一套完整的、非侵入式的二次改版开发解决方案。通过模块化架构，可在不修改原始源代码的前提下，实现对游戏功能的扩展、修改和定制。

## 技术特性

### 1. 模块搜索与加载
```lua
-- 自动扫描 mods 目录下的所有模块
-- 模块结构要求：
-- mods/
--   ├── example_mod/
--   │   ├── config.lua        -- 模块配置文件
--   │   └── example_mod.lua   -- 模块主文件
```

### 2. 配置驱动
每个模块必须包含 `config.lua` 配置文件：
```lua
return {
    name = "示例模块",         -- 模块显示名称
    desc = "功能描述",         -- 模块详细描述
    version = "1.0.0",        -- 版本号
    game_version = "kr5",	  -- 兼容的游戏版本
    by = "作者名",             -- 作者信息
    url = "模块主页",           -- 相关链接
    enabled = true,           -- 启用状态
    priority = 100            -- 加载优先级（数值越大优先级越高）
}
```

### 3. 路径管理机制
自动处理模块路径注册：
- 模块根目录添加到 `package.path`
- 子目录自动注册为 Lua 模块搜索路径
- 特殊目录（如 `kui_templates`）进行专门处理

### 4. 优先级系统
模块按优先级降序加载：
- 高优先级模块后执行，可覆盖低优先级模块的功能
- 确保功能修改的正确顺序和预期行为

## 使用方法

### 1. 基础模块结构
创建模块目录并实现必要文件：

```
mods/
└── your_mod/
    ├── config.lua          -- 模块配置
    ├── your_mod.lua        -- 模块主逻辑，名称务必与当前目录相同
    └── subfolder/          -- 可选子目录
        └── helper.lua      -- 辅助模块
```

### 2. 导入模块
将 `main` 的 `love.update`（前三代为 `load_director`） 函数的 `director:init(main.params)` 字段修改为：
```lua
local mod_main = require("mods.mod_main")
local mod_utils = require("mods.mod_utils")
local mod_hook = require("mods.mod_hook")
local mods_data = mod_utils:check_get_available_mods()
mod_hook.mods_data = mods_data

local function director_init(params)
    mod_main:front_init(mods_data)
    director:init(main.params)
    mod_main:after_init(mods_data)
end

director_init(main.params)
```

### 3. 配置示例
```lua
-- config.lua
return {
    name = "UI增强模块",
    desc = "提供额外的用户界面功能",
    version = "1.0.0",
    game_version = "kr5",
    by = "开发者",
    url = "https://example.com",
    enabled = true,
    priority = 150
}
```

### 4. 模块实现
```lua
-- your_mod.lua
local M = {}

function M:init()
    -- 模块初始化逻辑
    -- 在此处实现HOOK、事件监听等功能
    HOOK(E, "load", self.E_load)
end

function M.E_load(origin, self, ...)
	--	在此处增加前逻辑...
	origin(...)	-- 执行原函数
	--	在此处增加后逻辑...
end

return M
```

## 开发规范

### 1. 错误处理
- 模块加载失败不应影响其他模块
- 提供详细的日志输出便于调试
- 对关键操作进行异常捕获

### 2. 兼容性考虑
- 此模块覆盖实现方法为直接增加高优先级模块搜索路径，应避免覆盖源代码
- 避免使用可能与其他模块冲突的全局变量
- 提供模块间的通信接口

## 调试与日志
模块加载时会自动输出详细信息，包括：
- 模块配置信息
- 路径注册状态
- 加载顺序和优先级

## 故障排除

### 常见问题
1. **模块未加载**：检查 `enabled` 配置和文件路径
2. **路径冲突**：确认模块名称唯一性
3. **加载顺序异常**：调整优先级数值

