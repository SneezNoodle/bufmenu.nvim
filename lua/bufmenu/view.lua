local api = vim.api
local M = {}

-- Locals
local cfg = nil
local float_id = nil

local function get_float_rect(container_dims)
	local rect = { }

	rect.width = cfg.width >= 1 and cfg.width or math.ceil(container_dims.width * cfg.width)
	rect.height = cfg.height >= 1 and cfg.height or math.ceil(container_dims.height * cfg.height)

	-- Ensure properly centred (Wholely unnecessary but I know it would bug me otherwise)
	if (container_dims.width - rect.width) % 2 ~= 0 then rect.width = rect.width - 1 end
	if (container_dims.height - rect.height) % 2 ~= 0 then rect.height = rect.height - 1 end

	rect.row = cfg.row >= 0 and cfg.row or (container_dims.height - rect.height) / 2
	rect.col = cfg.col >= 0 and cfg.col or (container_dims.width - rect.width) / 2

	return rect
end
local function open_float(bufnr)
	local container_dims = {
		width = (cfg.relative_to_window) and vim.fn.winwidth(0) or vim.o.columns,
		height = (cfg.relative_to_window) and vim.fn.winheight(0) or vim.o.lines,
	}
	local rect = get_float_rect(container_dims)

	local opts = {
		relative = cfg.relative_to_window and "win" or "editor",
		border = cfg.border,
		title = cfg.title,
		title_pos = cfg.title_pos,
		style = "minimal",

		col = rect.col,
		row = rect.row,
		width = rect.width,
		height = rect.height,
	}

	return api.nvim_open_win(bufnr, true, opts)
end

local function close_float()
	api.nvim_win_close(float_id, true)
	float_id = nil
end

local function set_local_options()
	-- Force more space between buffer number and name
	vim.opt_local.tabstop = 8

	-- For some reason winhighlight:append(cfg.winhighlight) also prepends "1:" and breaks it
	for _, hl_opt in pairs(cfg.winhighlight or {}) do
		vim.opt_local.winhighlight:append(hl_opt)
	end
end

-- Export
function M.setup(opts)
	cfg = opts
end

function M.toggle_float(bufnr)
	-- close float already open and containing the desired buffer
	if M.is_float_open(bufnr) then
		close_float()
	else
		local float_opened, id = pcall(open_float, bufnr)
		if float_opened then
			float_id = id
			set_local_options()
		end
	end
end

function M.is_float_open(bufnr)
	return float_id and api.nvim_win_get_buf(float_id) == bufnr
end

return M

