local menu = require("bufmenu.menu")
local view = require("bufmenu.view")
local M = {}

local config = require("bufmenu.default_config")

-- Locals
local function test_keybinds()
	-- Menu
	vim.keymap.set("n", "<A-o>", function() -- Open menu in current window
		vim.cmd("b" .. menu.get_menu_bufnr())
	end)

	vim.keymap.set("n", "U", function() -- Update menu while inside it
		menu.update()
	end, { buffer = menu.get_menu_bufnr() })

	vim.keymap.set("n", "P", function() -- Print selected buffer
		local buf = menu.get_selected_bufnr()
		print(buf .. "\t" .. vim.fn.bufname(buf))
	end, { buffer = menu.get_menu_bufnr() })

	-- View
	vim.keymap.set("n", "<A-f>", function() -- Toggle float
		view.toggle_float(menu.get_menu_bufnr())
	end)
end

local function set_keybinds()
	-- Shortcuts
	local keys = config.keybinds
	local function map(lhs, rhs, opts)
		if lhs then
			vim.keymap.set("n", lhs, rhs, opts)
		end
	end
	local function menu_buf_desc(desc)
		return { desc = desc, buffer = menu.get_menu_bufnr() }
	end

	-- Global
	map(keys.toggle_menu, M.toggle_menu, { desc = "Bufmenu: Toggle floating window" })

	-- Only in menu
	map(keys.refresh_buffers, M.refresh_menu, menu_buf_desc("Bufmenu: Refresh buffer list"))
	map(keys.delete_selected_buffer, M.delete_selected_buffer, menu_buf_desc("Bufmenu: Delete selected buffer"))
end

-- Export
function M.setup(opts)
	opts = opts or { }
	config = vim.tbl_deep_extend("force", config, opts)
	if not config.use_default_keybinds then config.keybinds = opts.keybinds or {} end

	menu.setup(config.menu)
	view.setup(config.view)

	set_keybinds()
end

-- Mappable functions
function M.toggle_menu()
	menu.update()
	view.toggle_float(menu.get_menu_bufnr())
end
function M.refresh_menu()
	menu.update()
end
function M.delete_selected_buffer()
	local selected = menu.get_selected_bufnr()
	if selected then
		vim.cmd.bdel(selected)
	end
end

return M
