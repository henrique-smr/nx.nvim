local litee_state = require('litee.lib.state')
local litee_tree  = require('litee.lib.tree')
local litee_panel = require('litee.lib.panel')

local M = {}

function M.marshal_func(node)
	local name, detail, icon = node.name, " ", node.icon
	if #node.children == 0 then
		return name, detail, icon, " "
	end
	return name, detail, icon
end

function M.setup_buffer(name, buf, tab)
	-- see if we can reuse a buffer that currently exists.
	if buf == nil or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, false)
		if buf == 0 then
			vim.api.nvim_err_writeln("nx.panels.buffer: buffer create failed")
			return
		end
	else
		return buf
	end

	-- set buf options
	vim.api.nvim_buf_set_name(buf, name .. ":" .. tab)
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
	vim.api.nvim_buf_set_option(buf, 'filetype', 'nx')
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'textwidth', 0)
	vim.api.nvim_buf_set_option(buf, 'wrapmargin', 0)

	vim.cmd("au BufEnter,WinEnter <buffer=" .. buf .. "> stopinsert")
	-- au to clear jump highlights on window close
	vim.cmd("au BufWinLeave <buffer=" .. buf .. "> lua require('litee.lib.jumps').set_jump_hl(false)")

	-- hide the cursor if possible since there's no need for it, resizing the panel should be used instead.
	-- if config.hide_cursor then
	vim.cmd("au WinLeave <buffer=" .. buf .. "> lua require('litee.lib.util.buffer').hide_cursor(false)")
	vim.cmd("au WinEnter <buffer=" .. buf .. "> lua require('litee.lib.util.buffer').hide_cursor(true)")

	return buf
end

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

function M.create_component_panel(component, tree_handle, marshal_func)
	local ctx = M.ui_req_ctx(component)
	local state = litee_state.get_component_state(ctx.tab, component)
	local state_was_nil = false
	if state == nil then
		state_was_nil = true
		state = {}

		state.invoking_win = ctx.win
		state.tab = ctx.tab
	end

	if state.tree ~= nil then
		litee_tree.remove_tree(state.tree)
	end

	if marshal_func == nil then
		marshal_func = M.marshal_func
	end

	state.tree = tree_handle

	local global_state = litee_state.put_component_state(ctx.tab, component, state)

	if not state_was_nil
		and state.win ~= nil
		and vim.api.nvim_win_is_valid(state.win)
		and state.buf ~= nil
		and vim.api.nvim_buf_is_valid(state.buf)
	then
		litee_tree.write_tree_no_guide_leaf(
			state.buf,
			state.tree,
			marshal_func
		)
	else
		litee_panel.toggle_panel(global_state, true, false)
	end
end

return M
