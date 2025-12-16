local log = require("klua.log"):new("mod_template")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK

local hook = {}

setmetatable(hook, mod_utils.auto_table_mt)

function hook:init(mod_data)
	-- 可以访问 mod_data.config 来得到模组配置

	HOOK(E, "load", self.E.load)
end

function hook.E.load(load, self)
	load(self)
	package.loaded.mod_template_templates = nil
	package.loaded.mod_template_scripts = nil
	
	local mod_template_templates = require("mod_template_templates")
	local mod_template_scripts = require("mod_template_scripts")
end

return hook