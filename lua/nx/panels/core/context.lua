local litee_state = require('litee.lib.state')
local litee_tree  = require('litee.lib.tree')

local M = {}

function M.ui_req_ctx(component)
	local buf         = vim.api.nvim_get_current_buf()
	local win         = vim.api.nvim_get_current_win()
	local tab         = vim.api.nvim_win_get_tabpage(win)
	local linenr      = vim.api.nvim_win_get_cursor(win)
	local tree_type   = litee_state.get_type_from_buf(tab, buf)
	local tree_handle = litee_state.get_tree_from_buf(tab, buf)
	local state       = litee_state.get_state(tab)

	local cursor = nil
	local node = nil
	if state ~= nil then
		if state[component] ~= nil and state[component].win ~= nil and
			vim.api.nvim_win_is_valid(state[component].win) then
			cursor = vim.api.nvim_win_get_cursor(state[component].win)
		end
		if cursor ~= nil then
			node = litee_tree.marshal_line(cursor, state[component].tree)
		end
	end

	return {
		-- the current buffer when the request is made
		buf = buf,
		-- the current win when the request is made
		win = win,
		-- the current tab when the request is made
		tab = tab,
		-- the current cursor pos when the request is made
		linenr = linenr,
		-- the type of tree if request is made in a litee_panel
		-- window.
		tree_type = tree_type,
		-- a hande to the tree if the request is made in a litee_panel
		-- window.
		tree_handle = tree_handle,
		-- the pos of the nx item cursor if a valid caltree exists.
		cursor = cursor,
		-- the current state provided by litee_state
		state = state,
		-- the current marshalled node if there's a valid nx
		-- window present.
		node = node
	}
end

return M