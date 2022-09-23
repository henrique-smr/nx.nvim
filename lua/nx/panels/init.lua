local M = {}


function M.setup()
	require('nx.panels.components.projects').setup()
	-- require('nx.panels.components.generate_and_run').setup()
	vim.api.nvim_create_user_command(
		"NxShowPanel",
		function(opts)
			local panel = opts.args
			if panel == 'projects_targets' then
				require('nx.panels.components.projects.targets').show()
			end
		end
		,
		{
			nargs = 1,
			complete = function()
				return { "projects_targets", "generate_and_run" }
			end
		}
	)
end

return M
