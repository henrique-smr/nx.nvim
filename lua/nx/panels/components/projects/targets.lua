local litee_tree      = require('litee.lib.tree')
local litee_tree_node = require('litee.lib.tree.node')
local core            = require('nx.core')

local panels_core = require('nx.panels.core')

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


	panels_core.upsert_component_panel(M.component, tree)
end

function M.default_handler(ctx)

	if not ctx.node then
		return
	elseif #ctx.node.children ~= 0 then
		panels_core.expand_component_node(M.component)
	elseif ctx.node.target ~= nil then
		vim.api.nvim_set_current_win(ctx.state[M.component].invoking_win)
		core.NxRunTarget(ctx.node.target)
	end

end

local function register()

	panels_core.register_component(M.component, "NxTargets", {
		['<CR>'] = M.default_handler
	})
end

function M.setup()

	register()

end

return M
