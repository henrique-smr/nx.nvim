local litee_tree      = require('litee.lib.tree')
local litee_tree_node = require('litee.lib.tree.node')
local litee_util_win  = require('litee.lib.util.window')
local litee_panel     = require('litee.lib.panel')
local core            = require('nx.core')

local panel_utils = require('nx.panels.utils')

local M = {
	component = 'nx.projects.targets'
}


function M.show()
	local icon_set = require('litee.lib').icon_set_update(nil, "nerd")

	local tree = litee_tree.new_tree(M.component)

	local root = litee_tree_node.new_node("Nx Targets", "NX_PROJECTS_TARGETS", 0)

	core.NxGenerateGraph()


	local projects = {}
	for _, proj in ipairs(core.NxGetProjects()) do

		local proj_node = litee_tree_node.new_node(proj, proj, 1)
		proj_node.expanded = false
		proj_node.icon = icon_set["GitRepo"]

		for _, target in ipairs(core.NxGetProjectTargets(proj)) do
			local target_node = litee_tree_node.new_node(target, proj_node.name .. ":" .. target, 2)
			target_node.icon = icon_set["Constructor"]
			target_node.target = proj .. ":" .. target
			table.insert(proj_node.children, target_node)
		end

		table.insert(projects, proj_node)
	end

	litee_tree.add_node(tree, root, projects)


	panel_utils.create_component_panel(M.component, tree, panel_utils.marshal_func)
end

function M.expand(status)
	local ctx = panel_utils.ui_req_ctx(M.component)

	if ctx.node == nil then
		return
	end

	local component_state = ctx.state[M.component]

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
		panel_utils.marshal_func
	)

	vim.api.nvim_win_set_cursor(component_state.win, ctx.cursor)
end

function M.default_handler()
	local ctx = panel_utils.ui_req_ctx(M.component)

	if not ctx.node then
		return
	elseif #ctx.node.children ~= 0 then
		M.expand(not ctx.node.expanded)
	elseif ctx.node.target ~= nil then
		vim.api.nvim_set_current_win(ctx.state[M.component].invoking_win)
		core.NxRunTarget(ctx.node.target)
	end

end

local function setup_buffer_cmds(buf)
	vim.api.nvim_buf_set_keymap(buf, 'n', 'l', '<cmd>lua require("nx.panels.projects.targets").expand()<CR>',
		{ noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, 'n', 'h', '<cmd>lua require("nx.panels.projects.targets").expand(false)<CR>',
		{ noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '<cmd>lua require("nx.panels.projects.targets").default_handler()<CR>',
		{ noremap = true, silent = true })
end

local function register_component()

	litee_panel.register_component(
		M.component,
		function(state)
			if state[M.component].tree == nil then
				return false
			end

			local buf_name = "NxTargets"
			local buffer = panel_utils.setup_buffer(buf_name, state[M.component].buf, state[M.component].tab)
			setup_buffer_cmds(buffer)

			state[M.component].buf = buffer

			litee_tree.write_tree_no_guide_leaf(
				state[M.component].buf,
				state[M.component].tree,
				panel_utils.marshal_func
			)
			return true
		end,
		function(state)
			litee_util_win.set_tree_highlights()
		end
	)
end

function M.setup()

	register_component()

end

return M
