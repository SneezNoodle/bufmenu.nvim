local api = vim.api
local M = {}

-- Locals
local cfg = nil -- Config loaded by setup()
local hl_ns = -1
local menubufnr = -1 -- Bufnr of the buffer containing the menu
local displayed_buffers = {} -- Buffers on the menu, indexed by line number

local function create_buffer()
	menubufnr = api.nvim_create_buf(false, true)
	api.nvim_buf_set_name(menubufnr, cfg.menu_buffer_name)
	api.nvim_buf_set_option(menubufnr, "filetype", cfg.menu_buffer_filetype)
	api.nvim_buf_set_option(menubufnr, "modifiable", false)
end

local function setup_highlight_groups()
	hl_ns = api.nvim_create_namespace("")
	for hl_name, hl_setting in pairs(cfg.highlights) do
		-- If a group name is given then link to it
		local hl_opts = type(hl_setting) == "string" and { link = hl_setting } or hl_setting
		api.nvim_set_hl(hl_ns, hl_name, hl_opts)
	end
end

local function write_to_menu(lines)
	api.nvim_buf_set_option(menubufnr, "modifiable", true)
	api.nvim_buf_set_lines(menubufnr, 0, -1, false, lines)
	api.nvim_buf_set_option(menubufnr, "modifiable", false)
end

local function apply_highlights(line_highlights)
	-- Clear existing highlights
	api.nvim_buf_clear_namespace(menubufnr, hl_ns, 0, -1)

	for linenr, line_chunks in ipairs(line_highlights) do
		for _, chunk in ipairs(line_chunks) do
			if chunk.hl then
				chunk.hl_ns = chunk.hl_ns or hl_ns -- Allow devicons to use global highlights
				api.nvim_buf_add_highlight(menubufnr, chunk.hl_ns, chunk.hl, linenr - 1, chunk.hl_start, chunk.hl_end)
			end
		end
	end
end

local function should_display(bufnr)
	return cfg.filter(bufnr) and api.nvim_buf_get_option(bufnr, "buflisted")
end

local function get_buffer_info_symbols(bufnr)
	local vim_buf_info = vim.fn.getbufinfo(bufnr)[1]

	local symbols = {
		status = vim_buf_info.hidden == 0 and cfg.symbols.active or cfg.symbols.hidden,
		name = vim_buf_info.name == "" and "[No name]" or vim.fn.fnamemodify(vim_buf_info.name, ":~:."),
		modified = (vim_buf_info.changed == 1) and cfg.symbols.modified or "",
		linenr = vim_buf_info.lnum,
		linecount = vim_buf_info.linecount,
	}

	-- Get icons if possible
	local has_devicons, devicons = pcall(require, "nvim-web-devicons")
	if has_devicons then
		local filename = vim.fn.fnamemodify(vim_buf_info.name, ":t")
		local extension = vim.fn.fnamemodify(vim_buf_info.name, ":e")
		local icon, hl = devicons.get_icon(filename, extension, { default = cfg.symbols.default_icon})

		symbols.icon = icon
		symbols.icon_hl_name = hl
	end
	return symbols
end

local function format_buffer(bufnr)
	local buf_symbols = get_buffer_info_symbols(bufnr)

	-- Chunks of text with associated highlight groups
	local format = {
		{ hl = cfg.highlights.buffer_status, text = string.format(" %s [%s]", buf_symbols.status, bufnr) },
		{ hl = nil, text = "\t" },
		{ hl = cfg.highlights.buffer_position, text = string.format("%s/%s", buf_symbols.linenr, buf_symbols.linecount) },
		{ hl = nil, text = "\t" },
		{ hl = cfg.highlights.buffer_name, text = buf_symbols.name .. buf_symbols.modified },
	}
	-- If devicons is installed, add icon before name
	if buf_symbols.icon then
		local icon_format = {
			hl = buf_symbols.icon_hl_name,
			hl_ns = -1, -- Get icons from global namespace
			text = buf_symbols.icon .. " " 
		}
		table.insert(format, 5, icon_format)
	end

	local line = ""
	local highlights = {}

	for i, chunk in ipairs(format) do
		local hl_start = #line
		line = line .. chunk.text
		local hl_end = #line
		highlights[i] = { hl_start = hl_start, hl_end = hl_end, hl = chunk.hl }
	end

	return {
		line = line,
		highlights = highlights,
	}
end

-- Export
function M.setup(opts)
	cfg = opts

	create_buffer()
	setup_highlight_groups()
	M.update()
end

function M.update()
	local buflist = api.nvim_list_bufs()
	local lines = {}
	local line_highlights = {}

	for i = 1, #buflist do
		local buf = buflist[i]
		if should_display(buf) then
			local format = format_buffer(buf)
			lines[#lines+1] = format.line
			displayed_buffers[#lines] = buf
			line_highlights[#lines] = format.highlights
		end
	end

	write_to_menu(lines)
	apply_highlights(line_highlights)
end

function M.get_menu_bufnr()
	return menubufnr
end

function M.get_selected_bufnr()
	if vim.fn.bufnr() ~= menubufnr then
		return nil
	end
	return displayed_buffers[vim.fn.line(".")]
end

return M
