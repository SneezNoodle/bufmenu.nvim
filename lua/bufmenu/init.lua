local api = vim.api
local menu = require("bufmenu.menu")
local view = require("bufmenu.view")
local config = require("bufmenu.default_config")
local M = {}

-- Locals
local function count_or(default)
	local count = vim.v.count
	if count ~= 0 then
		return count
	end
	return default
end

local function set_keybinds()
	local actions = {
		toggle_menu = {
			mode = "n",
			opts = { desc = "Bufmenu: Toggle floating menu" },
			lhs = function() M.float_toggle() end,
		},
		refresh_menu = {
			mode = "n",
			opts = { desc = "Bufmenu: Toggle floating menu" },
			lhs = function() M.refresh_menu() end
		},
		delete_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Delete selected buffer" },
			lhs = config.use_bdelete and function()
				M.bdelete_selected_buf(false)
			end or function()
				M.delete_selected_buf(false)
			end,

		},
		force_delete_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Forcefully delete selected buffer" },
			lhs = config.use_bdelete and function()
				M.bdelete_selected_buf(true)
			end or function()
				M.delete_selected_buf(true)
			end,
		},
		open_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Open selected" },
			lhs = function()
				-- Close floating menu if open
				if M.float_is_open() then M.float_toggle() end
				-- Use count as winnr, or previous window if none is given
				M.open_selected_buf(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
			end,
		},
		set_selected_as_altfile = {
			mode = "n",
			opts = { desc = "Bufmenu: Set selected as alt file" },
			lhs = function()
				-- Use count as winnr, or previous window if none is given
				M.set_selected_as_alt(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
			end,
		},
	}

	for action_name, keycode in pairs(config.keybinds) do
		local action = actions[action_name]
		if action and keycode then
			vim.keymap.set(action.mode, keycode, action.lhs, action.opts)
		elseif keycode then -- No action with action_name
			vim.fn.notify(string.format("Bufmenu: Unknown keybind '%s'"), vim.log.levels.WARN)
		end
	end
end

local function get_fallback_buffer()
	local fallback = nil
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_get_option(buf, "buflisted") then
			fallback = buf
			break
		end
	end
	return fallback or api.nvim_create_buf(true, false)
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

-- API
function M.float_toggle()
	local menubuf = menu.get_menu_bufnr()
	view.toggle_float(menubuf)
	M.refresh_menu()
	return view.is_float_open(menubuf)
end

function M.float_is_open()
	return view.is_float_open(menu.get_menu_bufnr())
end

function M.get_selected_bufnr()
	return menu.get_selected_bufnr()
end

function M.refresh_menu()
	menu.update()
end

function M.open_selected_buf(winid)
	winid = winid or 0

	vim.api.nvim_win_set_buf(winid, M.get_selected_bufnr())
	M.refresh_menu()
end

function M.set_selected_as_alt(winid)
	winid = winid or 0

	local selected_buf = M.get_selected_bufnr()
	local current_buf = api.nvim_win_get_buf(winid)

	api.nvim_win_set_buf(winid, selected_buf)
	api.nvim_win_set_buf(winid, current_buf)
	M.refresh_menu()
end

function M.delete_selected_buf(force)
	local selected_buf = M.get_selected_bufnr()

	local unloaded, error = pcall(api.nvim_buf_delete, selected_buf, { force = force, unload = true })
	if not unloaded and error then
		vim.notify(error, vim.log.levels.ERROR)
		return false
	end

	api.nvim_buf_set_option(selected_buf, "buflisted", false)
	-- Set all windows containing the deleted buffer to a fallback buffer
	for _, win in ipairs(vim.fn.win_findbuf(selected_buf) or {}) do
		api.nvim_win_set_buf(win, get_fallback_buffer())
	end

	M.refresh_menu()
	return true
end

function M.bdelete_selected_buf(force)
	local selected_buf = M.get_selected_bufnr()
	local menu_winid = vim.fn.win_getid()

	-- Switch to previous window (bdel sometimes breaks when the float is open)
	api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr("#")))
	vim.cmd("bdelete" .. (force and "! " or " ") .. selected_buf)
	api.nvim_set_current_win(menu_winid)

	M.refresh_menu()
end

return M
