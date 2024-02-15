local NuiTree  = require("nui.tree")
local NuiLine  = require("nui.line")
local NuiSplit = require("nui.split")
local event    = require("nui.utils.autocmd").event

local core = require('nx.core')

-- local panels_core = require('nx.panels.core')

local M = {
	component = 'nx.projects.targets',
	_component_split = nil,
	_tree = nil,
}

local function set_panel_tree_maps(panel_split, tree)
	local map_options = { noremap = true, nowait = true }
	-- print current node
	panel_split:map("n", "<CR>", function()
		local node = tree:get_node()
		if node:has_children() then
			if node:is_expanded() then
				if node:collapse() then
					tree:render()
				end
			elseif node:expand() then
				tree:render()
			end
			return
		end
		if node.target ~= nil then

			local cmd_split = NuiSplit({
				relative = "editor",
				position = "bottom",
				size = "20%",
				enter = true,
			})
			-- vim.api.nvim_buf_set_name  (cmd_split.bufnr, name .. ":" .. tab)
			cmd_split:on({ event.BufEnter }, function()
				vim.cmd(':startinsert')
			end)
			cmd_split:on({ event.BufDelete }, function()
				cmd_split:unmount()
			end)
			cmd_split:mount()
			core.NxRunTarget(node.target)
		end
	end, map_options)

	-- collapse current node
	panel_split:map("n", "h", function()
		local node = tree:get_node()

		if node:collapse() then
			tree:render()
		end
	end, map_options)

	-- collapse all nodes
	panel_split:map("n", "H", function()
		local updated = false

		for _, node in pairs(tree.nodes.by_id) do
			updated = node:collapse() or updated
		end

		if updated then
			tree:render()
		end
	end, map_options)

	-- expand current node
	panel_split:map("n", "l", function()
		local node = tree:get_node()

		if node:expand() then
			tree:render()
		end
	end, map_options)

	-- expand all nodes
	panel_split:map("n", "L", function()
		local updated = false

		for _, node in pairs(tree.nodes.by_id) do
			updated = node:expand() or updated
		end

		if updated then
			tree:render()
		end
	end, map_options)
end

local function create_panel_split(name)
	local split = NuiSplit({
		relative = "editor",
		position = "right",
		size = 50,
		buf_options = {
			modifiable = false,
			readonly = true,
			filetype = 'nx',
			buftype = 'nofile',
			swapfile = false,
			textwidth = 0,
			wrapmargin = 0,
		},
		win_options = {
			number = false,
			relativenumber = false,
			signcolumn = "no"
		}
	})
	vim.api.nvim_buf_set_name(split.bufnr, name)
	return split
end

local function create_tree(bufnr)
	return NuiTree({
		bufnr = bufnr,
		nodes = {},
		prepare_node = function(node)
			local line = NuiLine()

			line:append(string.rep("  ", node:get_depth() - 1))

			if node:has_children() then
				line:append(node:is_expanded() and " " or " ", "SpecialChar")
			else
				line:append("  ")
			end

			line:append(node.text)

			return line
		end,
	})
end

function M.show()

	local should_regen_nodes = false

	if M._component_split == nil then


		M._component_split = create_panel_split("Nx Targets")
		M._component_split:on({ event.BufWinLeave }, function()
			vim.schedule(function()
				local panel = M._component_split;
				M._component_split = nil
				M._tree = nil
				pcall(function()
					panel:unmount()
				end)
			end)
		end, { once = true })
	end

	if M._tree == nil then
		should_regen_nodes = true
		M._tree = create_tree(M._component_split.bufnr)

		set_panel_tree_maps(M._component_split, M._tree)

	end

	-- if should_mount_panel then
	-- else
	-- 	M._component_split:show()
	-- end

	M._component_split:mount()

	if should_regen_nodes then
		core.NxGenerateGraph()

		for _, proj in ipairs(core.NxGetProjects()) do

			local proj_node = NuiTree.Node({ text = proj })
			M._tree:add_node(proj_node)

			for _, target in ipairs(core.NxGetProjectTargets(proj)) do
				-- target_node.icon = icon_set["Constructor"]
				M._tree:add_node(
					NuiTree.Node({
						text = proj .. ":" .. target,
						target = proj .. ":" .. target,
					}),
					proj_node:get_id()
				)
			end

		end

	end

	M._tree:render()

end

function M.setup()


end

return M
