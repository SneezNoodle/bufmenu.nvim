local bufmenu_api = require("bufmenu")
local M = {}

-- Locals
local function count_or(default)
	local count = vim.v.count
	if count ~= 0 then
		return count
	end
	return default
end

-- Export
M.actions = {
	toggle_menu = {
		mode = "n",
		desc = "Bufmenu: Toggle floating menu",
		rhs = function() bufmenu_api.float_toggle() end,
	},
	refresh_menu = {
		mode = "n",
		desc = "Bufmenu: Toggle floating menu",
		rhs = function() bufmenu_api.refresh_menu() end
	},
	delete_selected = {
		mode = "n",
		desc = "Bufmenu: Delete selected buffer",
		menu_only = true,
		rhs = function()
			bufmenu_api.delete_selected_buf(false)
		end,
	},
	force_delete_selected = {
		mode = "n",
		desc = "Bufmenu: Forcefully delete selected buffer",
		menu_only = true,
		rhs = function()
			bufmenu_api.delete_selected_buf(true)
		end,
	},
	open_selected = {
		mode = "n",
		desc = "Bufmenu: Open selected",
		menu_only = true,
		rhs = function()
			-- Use count as winnr, or previous window if none is given
			bufmenu_api.open_selected_buf(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
			-- Close floating menu if open and no count was provided
			if bufmenu_api.float_is_open() and vim.v.count == 0 then
				bufmenu_api.float_toggle()
			end
		end,
	},
	set_selected_as_altfile = {
		mode = "n",
		desc = "Bufmenu: Set selected as alt file",
		menu_only = true,
		rhs = function()
			-- Use count as winnr, or previous window if none is given
			bufmenu_api.set_selected_as_alt(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
		end,
	},
}

function M.setup(config)
	if config.use_bdelete then
		M.actions.delete_selected.rhs = function()
			bufmenu_api.bdelete_selected_buf(false)
		end
		M.actions.force_delete_selected.rhs = function()
			bufmenu_api.bdelete_selected_buf(true)
		end
	end
end

return M
