local menu = nil
local view = nil
local M = {}

-- Locals
local function menu_map(key, func, desc)
	vim.keymap.set("n", key, func, { buffer = menu.get_menu_bufnr(), desc = desc })
end

local function close_float()
	local float_open = view.is_float_open(menu.get_menu_bufnr())
	if float_open then view.toggle_float(menu.get_menu_bufnr()) end
	return float_open
end

local function reopen_float(was_open)
	if not was_open or view.is_float_open(menu.get_menu_bufnr()) then return end
	view.toggle_float(menu.get_menu_bufnr())
end

local function cmd(cmdstr, errormsg, successmsg)
	-- For some reason vim refuses to delete the current buffer if the float is open
	local float_open = close_float()
	local success, default_err = pcall(vim.cmd, cmdstr)
	reopen_float(float_open)

	if not success then
		vim.notify(errormsg or default_err, vim.log.levels.ERROR)
	else
		vim.notify(successmsg or "")
	end
end

-- Export
function M.setup(menu_mod, view_mod)
	menu = menu_mod
	view = view_mod
end

function M.toggle_menu(key)
	vim.keymap.set("n", key, function()
		menu.update()
		view.toggle_float(menu.get_menu_bufnr())
	end, { desc = "Bufmenu: Toggle floating menu" })
end

function M.refresh_menu(key)
	menu_map(key, function()
		menu.update()
	end, "Bufmenu: Refresh menu")
end

function M.open_selected(key)
	menu_map(key, function()
		local sel = menu.get_selected_bufnr()
		if not sel then return end

		close_float()

		vim.cmd("b " .. sel)
	end, "Bufmenu: Open selected buffer")
end
function M.delete_selected(key)
	menu_map(key, function()
		local sel = menu.get_selected_bufnr()
		if not sel then return end

		cmd("bdel " .. sel, "Failed to delete buffer, most likely due to unsaved changes", "Deleted buffer [" .. sel .. "]")

		menu.update()
	end, "Bufmenu: Delete selected buffer")
end
function M.force_delete_selected(key)
	menu_map(key, function ()
		local sel = menu.get_selected_bufnr()
		if not sel then return end

		cmd("bdel! " .. sel, "Failed to force delete buffer (not sure how)", "Forcefully deleted buffer [" .. sel .. "]")

		menu.update()
	end, "Bufmenu: Delete selected buffer and discard changes")
end
function M.set_selected_as_altfile(key)
	menu_map(key, function()
		local sel = menu.get_selected_bufnr()
		if not sel then return end

		-- Open file then switch to alt
		cmd("b " .. sel .. " | b #", "Failed to set altfile", "Set altfile to [" .. sel .. "]")
	end, "Bufmenu: Set selected buffer as alternate file")
end

return M
