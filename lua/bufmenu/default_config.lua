return {
	use_default_keybinds = true,
	use_bdelete = true,
	keybinds = {
		toggle_menu = "<A-f>",
		refresh_menu = "<F5>",
		delete_selected = "x",
		force_delete_selected = "X",
		open_selected = "<cr>",
		set_selected_as_altfile = "<a-cr>",
		-- TODO save_selected = "<c-s>",
	},
	view = {
		width = 0.6, -- decimal: fraction of container
		height = 0.5,
		row = -1, -- -1: center
		col = -1,
		relative_to_window = true, -- False to make relative to editor
		border = "single",
		title = "Buffer menu",
		title_pos = "center",

		winhighlight = {
			-- Good for default colorscheme where the whole menu gets turned purple
			-- "NormalFloat:Normal"
		},
	},
	menu = {
		menu_buffer_name = "Bufmenu",
		menu_buffer_filetype = "bufmenu",

		symbols = {
			hidden = "",
			active = "",

			modified = " {+}",

			default_icon = "? " -- default filetype icon for nvim-web-devicons
		},
		highlights = {
			buffer_status = "Title",
			buffer_position = "Question",
			buffer_name = "String",
		},

		filter = function(bufnr) -- Return false to hide the buffer with [bufnr]
			return true
		end,

		-- TODO
		-- show_inactive = false
		-- inactive = " "
	},
}
