local M = {
	_NxGraphFilepath = './node_modules/.cache/nx.nvim/graph.json',
	_NxGraph = {}
}

local function sortStrings(list)
	table.sort(list, function(a, b) return a:upper() < b:upper() end)
end

local function read_file(path)
	local file = io.open(path, "rb") -- r read mode and b binary mode
	if not file then return nil end
	local content = file:read "*a" -- *a or *all reads the whole file
	file:close()
	return content
end

function M.NxGenerateGraph()
	vim.fn.system("npx nx graph --file=" .. M._NxGraphFilepath)
	M._NxGraph = vim.json.decode(read_file(M._NxGraphFilepath))
end

function M.NxGetProjects()
	local projects = {}
	for proj, _ in pairs(M._NxGraph.graph.nodes) do
		table.insert(projects, proj)
	end
	table.sort(projects, function(a, b)
		local a_n = 0
		local b_n = 0
		if M._NxGraph.graph.nodes[a].type == "app" or
			M._NxGraph.graph.nodes[a].type == "e2e"
		then
			a_n = a_n + 2
		end
		if M._NxGraph.graph.nodes[b].type == "app" or
			M._NxGraph.graph.nodes[b].type == "e2e"
		then
			b_n = b_n + 2
		end
		if a:upper() < b:upper() then
			a_n = a_n + 1
		else
			b_n = b_n + 1
		end

		return a_n > b_n
	end)
	return projects
end

function M.NxGetProjectTargets(project)
	local targets = {}
	if M._NxGraph.graph.nodes[project] == nil then
		return {}
	end
	for target, t_data in pairs(M._NxGraph.graph.nodes[project].data.targets) do
		if t_data.configurations ~= nil then
			for config, _ in pairs(t_data.configurations) do
				table.insert(targets, target .. ":" .. config)
			end
		else
			table.insert(targets, target)
		end
	end
	sortStrings(targets)
	return targets
end

function M.NxGetAllTargetsWithDetails()
	local targets_details = {}

	for project, p_data in pairs(M._NxGraph.graph.nodes) do
		for target, t_data in pairs(p_data.data.targets) do
			if t_data.configurations ~= nil then
				for config, _ in pairs(t_data.configurations) do
					table.insert(targets_details, project .. ":" .. target .. ":" .. config)
				end
			else
				table.insert(targets_details, project .. ":" .. target)
			end
		end
	end
	sortStrings(targets_details)
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
	return vim.split(vim.fn.system(cmd), '\n')
end

function M.NxGetPluginGenerators(plugin)
	local cmd = "npx nx list " .. plugin .. " | grep -o '[a-zA-Z-]* : ' | sed -r 's/ : //g'"
	return vim.split(vim.fn.system(cmd), '\n')
end

function M.NxGetGeneratorsOptions(plugin, runner)
	local generator = plugin .. ":" .. runner
	local cmd = 'npx nx g ' .. generator .. ' --help | grep -o "\\-\\-[a-zA-Z]*" | sed "s/--//"'
	return vim.split(vim.fn.system(cmd), '\n')
end

function M.NxRunTarget(target)
	vim.ui.input(
		{
			prompt = string.format('Run %s? [y/N] ', target),
		},
		function(input)
			if vim.trim(input):lower() == 'y' then
				vim.api.nvim_exec(":terminal npx nx run " .. target, false)
			end
		end
	)
end

return M
