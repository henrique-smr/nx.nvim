local M = {
	_NxGraphFilepath='./node_modules/.cache/nx.nvim/graph.json',
	_NxGraph={}
}

local function read_file(path)
	local file = io.open(path, "rb") -- r read mode and b binary mode
	if not file then return nil end
	local content = file:read "*a" -- *a or *all reads the whole file
	file:close()
	return content
end



function M.NxGenerateGraph()
	vim.fn.system("npx nx graph --file="..M._NxGraphFilepath)
	M._NxGraph= vim.json.decode(read_file(M._NxGraphFilepath))
end

function M.NxGetProjects()
	local r = {}
	for proj,_ in pairs( M._NxGraph.graph.nodes ) do
		table.insert(r, proj)
	end
	return r
end

function M.NxGetProjectTargets(project)
	local targets = {}
	if M._NxGraph.graph.nodes[project] == nil then
		return {}
	end
	for target, t_data in pairs(M._NxGraph.graph.nodes[project].data.targets) do
		if t_data.configurations ~=nil then
			for config,_ in pairs(t_data.configurations) do
				table.insert(targets,target..":"..config)
			end
		else
			table.insert(targets, target)
		end
	end
	return targets
end

function M.NxGetAllTargetsWithDetails()
	local targets_details = {}

	for project, p_data in pairs(M._NxGraph.graph.nodes) do
		for target, t_data in pairs(p_data.data.targets) do
			if t_data.configurations ~=nil then
				for config,_ in pairs(t_data.configurations) do
					table.insert(targets_details,project..":"..target..":"..config)
				end
			else
				table.insert(targets_details, project..":"..target)
			end
		end
	end
	return targets_details
end

function M.NxGetProjectFiles(project)
	local files = {}
	if M._NxGraph.graph.nodes[project] == nil then
		return {}
	end
	for _, f_data in ipairs(M._NxGraph.graph.nodes[project].data.files) do
		table.insert(files, f_data.file)
	end
	return files
end

function M.NxGetPlugins()
	local cmd = "npx nx list | grep '(\\(executors\\)\\{0,1\\}[,]\\{0,1\\}\\(generators\\)\\{0,1\\})' | cut -d '(' -f 1 | sed 's/^ *//;s/ *$//'"
	return vim.split(vim.fn.system(cmd),'\n')
end

function M.NxGetPluginGenerators(plugin)
	local cmd = "npx nx list "..plugin.." | grep -o '[a-zA-Z-]* : ' | sed -r 's/ : //g'"
	return vim.split(vim.fn.system(cmd),'\n')
end

return M
