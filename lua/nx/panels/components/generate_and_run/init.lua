local litee_tree      = require('litee.lib.tree')
local litee_tree_node = require('litee.lib.tree.node')
-- local litee_util_win  = require('litee.lib.util.window')
-- local litee_panel     = require('litee.lib.panel')
-- local core            = require('nx.core')

local panels_core = require('nx.panels.core')

local M = {
	component = 'nx.generate_and_run'
}


function M.show()
	local icon_set = require('litee.lib').icon_set_update(nil, "nerd")

	local tree = litee_tree.new_tree(M.component)

	local root = litee_tree_node.new_node("Nx Generate & Run", "NX_GENERATE_AND_RUN", 0)

	-- core.NxGenerateGraph()

	local function createNode(name, key)
		local node = litee_tree_node.new_node(name, key, 1)
		node.icon = icon_set["Constructor"]
		return node
	end

	local generate_node = createNode("Generate", "NX_GENERATE")
	local run_node = createNode("Run", "NX_RUN")
	local test_node = createNode("Test", "NX_TEST")
	local lint_node = createNode("Lint", "NX_LINT")

	local commands = {
		generate_node,
		run_node,
		test_node,
		lint_node,
	}


	litee_tree.add_node(tree, root, commands)


	panels_core.upsert_component_panel(M.component, tree)
end

local function register()

	panels_core.register_component(M.component, "NxGenerateAndRun", {
		['<C-r>'] = function()
			print("Hey")
		end
	})
end

function M.setup()

	register()

end

return M
