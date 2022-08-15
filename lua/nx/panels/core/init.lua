local litee_state = require('litee.lib.state')
local litee_tree  = require('litee.lib.tree')
local litee_panel = require('litee.lib.panel')

local panels_core_buffer = require('nx.panels.core.buffer')
local panels_core_marshal_func = require('nx.panels.core.marshal').marshal_func
local panles_core_context = require('nx.panels.core.context')

local M = {}

function M.upsert_component_panel(component, tree_handle)
	local ctx = panles_core_context.ui_req_ctx(component)
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
			panels_core_marshal_func
		)
	else
		litee_panel.open_to(component, global_state)
	end
end

function M.expand_component_node(component, status)
	local ctx = panles_core_context.ui_req_ctx(component)

	if ctx.node == nil then
		return
	end

	local component_state = ctx.state[component]

	if component_state == nil then
		vim.api.nvim_err_writeln("no component state found")
		return
	end
	if status ~= nil then
		ctx.node.expanded = not not status
	else
		ctx.node.expanded = true
	end

	litee_tree.write_tree_no_guide_leaf(
		component_state.buf,
		component_state.tree,
		panels_core_marshal_func
	)

	vim.api.nvim_win_set_cursor(component_state.win, ctx.cursor)
end

function M.register_component(component, buf_name, actions)

	litee_panel.register_component(
		component,
		function(state)
			if state[component].tree == nil then
				return false
			end

			local buf = panels_core_buffer.setup_component_buffer(buf_name, state[component].buf, state[component].tab)
			panels_core_buffer.setup_component_buffer_default_cmds(buf, component)
			panels_core_buffer.setup_component_buffer_custom_cmds(buf, component, actions)

			state[component].buf = buf

			litee_tree.write_tree_no_guide_leaf(
				state[component].buf,
				state[component].tree,
				panels_core_marshal_func
			)
			return true
		end
	)
end

return M
