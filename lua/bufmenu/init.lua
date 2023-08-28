local menu = require("bufmenu.menu")
local view = require("bufmenu.view")
local bind = require("bufmenu.bind")
local config = require("bufmenu.default_config")
local M = {}

-- Locals
local function set_keybinds()
	for action, key in pairs(config.keybinds) do
		if key then
			bind[action](key)
		end
	end
end

-- Export
function M.setup(opts)
	opts = opts or { }
	config = vim.tbl_deep_extend("force", config, opts)
	if not config.use_default_keybinds then config.keybinds = opts.keybinds or {} end

	menu.setup(config.menu)
	view.setup(config.view)
	bind.setup(menu, view)

	set_keybinds()
end

return M
