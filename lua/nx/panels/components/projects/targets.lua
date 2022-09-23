local NuiTree = require("nui.tree")
local NuiLine = require("nui.line")
local Split   = require("nui.split")
local event   = require("nui.utils.autocmd").event
local core    = require('nx.core')

-- local panels_core = require('nx.panels.core')

local M = {
	component = 'nx.projects.targets',
	_panel_split = nil,
	_tree = nil,
}

local function set_panel_tree_maps()
	local map_options = { noremap = true, nowait = true }
	-- print current node
	M._panel_split:map("n", "<CR>", function()
		local node = M._tree:get_node()
		if node:has_children() then
			if node:is_expanded() then
				if node:collapse() then
					M._tree:render()
				end
			elseif node:expand() then
				M._tree:render()
			end
			return
		end
		if node.target ~= nil then

			local cmd_split = Split({
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
		print(vim.inspect(node))
	end, map_options)

	-- collapse current node
	M._panel_split:map("n", "h", function()
		local node = M._tree:get_node()

		if node:collapse() then
			M._tree:render()
		end
	end, map_options)

	-- collapse all nodes
	M._panel_split:map("n", "H", function()
		local updated = false

		for _, node in pairs(M._tree.nodes.by_id) do
			updated = node:collapse() or updated
		end

		if updated then
			M._tree:render()
		end
	end, map_options)

	-- expand current node
	M._panel_split:map("n", "l", function()
		local node = M._tree:get_node()

		if node:expand() then
			M._tree:render()
		end
	end, map_options)

	-- expand all nodes
	M._panel_split:map("n", "L", function()
		local updated = false

		for _, node in pairs(M._tree.nodes.by_id) do
			updated = node:expand() or updated
		end

		if updated then
			M._tree:render()
		end
	end, map_options)
end

local function set_panel_split()
	M._panel_split = Split({
		relative = "win",
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
	M._panel_split:on({ event.WinClosed }, function()
		M._panel_split:unmount()
		M._panel_split = nil
		M._tree = nil
	end)
end

local function set_tree(winid, bufnr)
	M._tree = NuiTree({
		winid = winid,
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

	if M._panel_split == nil then
		set_panel_split()
		set_tree(M._panel_split.winid, M._panel_split.bufnr)
		set_panel_tree_maps()
		M._panel_split:mount()

		core.NxGenerateGraph()

		for _, proj in ipairs(core.NxGetProjects()) do

			local proj_node = NuiTree.Node({ text = proj })
			M._tree:add_node(proj_node)
			-- table.insert(projects, proj_node)

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

		M._tree:render()
	end


end

function M.setup()


end

return M
