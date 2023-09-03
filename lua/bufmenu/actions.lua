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
function M.get(config)
	return {
		toggle_menu = {
			mode = "n",
			opts = { desc = "Bufmenu: Toggle floating menu" },
			lhs = function() bufmenu_api.float_toggle() end,
		},
		refresh_menu = {
			mode = "n",
			opts = { desc = "Bufmenu: Toggle floating menu" },
			lhs = function() bufmenu_api.refresh_menu() end
		},
		delete_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Delete selected buffer" },
			lhs = config.use_bdelete and function()
				bufmenu_api.bdelete_selected_buf(false)
				end or function()
					bufmenu_api.delete_selected_buf(false)
			end,
		},
		force_delete_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Forcefully delete selected buffer" },
			lhs = config.use_bdelete and function()
				bufmenu_api.bdelete_selected_buf(true)
				end or function()
					bufmenu_api.delete_selected_buf(true)
			end,
		},
		open_selected = {
			mode = "n",
			opts = { desc = "Bufmenu: Open selected" },
			lhs = function()
				-- Close floating menu if open
				if bufmenu_api.float_is_open() then M.float_toggle() end
				-- Use count as winnr, or previous window if none is given
				bufmenu_api.open_selected_buf(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
			end,
		},
		set_selected_as_altfile = {
			mode = "n",
			opts = { desc = "Bufmenu: Set selected as alt file" },
			lhs = function()
				-- Use count as winnr, or previous window if none is given
				bufmenu_api.set_selected_as_alt(vim.fn.win_getid(count_or(vim.fn.winnr("#"))))
			end,
		},
	}
end

return M
