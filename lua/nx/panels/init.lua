local M = {}

function M.setup()
	require('nx.panels.projects').setup()
	vim.api.nvim_create_user_command(
		"NxShowPanel",
		function(opts)
			local panel = opts.args
			if panel == 'projects_targets' then
				require('nx.panels.projects.targets').show()
			end
		end,
		{
			nargs = 1,
			complete = function()
				return { "projects_targets" }
			end
		}
	)
end

return M
