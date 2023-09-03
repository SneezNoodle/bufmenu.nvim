local api = vim.api
local menu = require("bufmenu.menu")
local view = require("bufmenu.view")
local config = require("bufmenu.default_config")
local M = {}

-- Locals
local function set_keybinds(actions)
	for action_name, keycode in pairs(config.keybinds) do
		local action = actions[action_name]
		if action and keycode then
			vim.keymap.set(action.mode, keycode, action.lhs, action.opts)
		elseif keycode then -- No action with action_name
			vim.fn.notify(string.format("Bufmenu: Unknown keybind '%s'"), vim.log.levels.WARN)
		end
	end
end

local function replace_buffer_in_layout(bufnr)
	-- Search for a listed and loaded buffer as a fallback
	local fallback = nil
	for _, buf in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_get_option(buf, "buflisted") and api.nvim_buf_is_loaded(buf) then
			fallback = buf
			break
		end
	end
	-- If none is found, create a scratch buffer
	fallback = fallback or api.nvim_create_buf(true, true)

	-- Replace bufnr with the fallback
	for _, win in ipairs(vim.fn.win_findbuf(bufnr) or {}) do
		api.nvim_win_set_buf(win, fallback)
	end
end

-- Export
function M.setup(opts)
	opts = opts or { }
	config = vim.tbl_deep_extend("force", config, opts)
	if not config.use_default_keybinds then config.keybinds = opts.keybinds or {} end

	menu.setup(config.menu)
	view.setup(config.view)

	set_keybinds(require("bufmenu.actions").get(config))
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
	if not api.nvim_win_is_valid(winid) then return false end

	vim.api.nvim_win_set_buf(winid, M.get_selected_bufnr())
	M.refresh_menu()
	return true
end

function M.set_selected_as_alt(winid)
	winid = winid or 0
	if not api.nvim_win_is_valid(winid) then return false end

	local selected_buf = M.get_selected_bufnr()
	local current_buf = api.nvim_win_get_buf(winid)

	api.nvim_win_set_buf(winid, selected_buf)
	api.nvim_win_set_buf(winid, current_buf)
	M.refresh_menu()
	return true
end

function M.delete_selected_buf(force)
	local selected_buf = M.get_selected_bufnr()

	local unloaded, error = pcall(api.nvim_buf_delete, selected_buf, { force = force, unload = true })
	if not unloaded and error then
		vim.notify(error, vim.log.levels.ERROR)
		return false
	end

	-- Set all windows containing the deleted buffer to a fallback buffer
	api.nvim_buf_set_option(selected_buf, "buflisted", false)
	replace_buffer_in_layout(selected_buf)

	M.refresh_menu()
	return true
end

function M.bdelete_selected_buf(force)
	local selected_buf = M.get_selected_bufnr()

	vim.cmd("silent bdelete" .. (force and "! " or " ") .. selected_buf)
	M.refresh_menu()
end

return M
