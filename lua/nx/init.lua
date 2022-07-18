local M = {  }

local core = require("nx.core")

local function parseOpts(opts)
	local cmd_str = ""
	for k,v in pairs(opts)do
		cmd_str = cmd_str.." --"..k.." "..v
	end
	return cmd_str
end

function M.NxListGeneratorOptions(plugin,runner)
	local fzf = require("fzf-lua")

	local opts = {}
	local generator = plugin..":"..runner
	local cmd = 'npx nx g '..generator..' --help | grep -o "\\-\\-[a-zA-Z]*" | sed "s/--//"'


	fzf.fzf_exec(cmd, {
		prompt="Nx ".. generator .." > ",
		preview=fzf.shell.raw_preview_action_cmd(function ()
			local cmd_preview_str = "npx nx g "..generator.." --dryRun"..parseOpts(opts)
			return "echo '"..cmd_preview_str.."' && "..cmd_preview_str
		end),
		actions={
			['default']={
				function (items)
					local opt = string.gsub(items[1],"=.*","")
					vim.ui.input({
						prompt=opt.. " "
					},function (input)
						if input ~= nil or input ~= "" then
							opts[opt]=input
						else
							opts[opt]=nil
						end
					end)
				end,
				fzf.actions.resume
			},
			['ctrl-r']= function ()
				local cmd_str = "npx nx g "..generator..parseOpts(opts)
				vim.api.nvim_exec(":split | terminal "..cmd_str,false)
			end
		},
		fn_transform=function(x)
			local opt = string.gsub(x,"=.*","")
			if opts[opt]~=nil then
				opt = opt.."="..opts[opt]
			end
			return opt
		end
	} )
end
function M.NxListPluginGenerators(plugin)
	local fzf = require("fzf-lua")

	fzf.fzf_exec(core.NxGetPluginGenerators(plugin), {
		prompt="Nx ".. plugin .." > ",
		preview=fzf.shell.raw_preview_action_cmd(function (items)
			local runner = items[1]
			local generator = plugin..":"..runner
			return 'npx nx g '..generator..' --help'
		end),
		actions={
			['default']=function (selected,opts)
				local runner = selected[1]
				M.NxListGeneratorOptions(plugin,runner)
				-- editNxCmd(selected, plugin)
			end
		}
	} )
end
function M.NxListPlugins()
	local fzf = require("fzf-lua")

	fzf.fzf_exec(core.NxGetPlugins(), {
		prompt="Nx > ",
		preview="npx nx list {}",
		actions={
			['default']=function (selected,opts)
				M.NxListPluginGenerators(selected[1])
			end
		}
	} )
end

function M.NxListProjectFiles(project)
	local fzf = require("fzf-lua")
	core.NxGenerateGraph()
	fzf.fzf_exec(function (fzf_cbc)
		for _,file in ipairs( core.NxGetProjectFiles(project) ) do
			fzf_cbc(
				fzf.make_entry.file(file, {file_icons=true, color_icons=true})
			)
		end
		fzf_cbc()
	end,{
		prompt="NX projects > "..project.." > ",
		previewer = "builtin",
		actions={
			['default']=fzf.actions.file_edit,
		}
	})
end

function M.NxListProjects()
	local fzf = require("fzf-lua")
	core.NxGenerateGraph()
	fzf.fzf_exec(function (fzf_cbc)
		for _,proj in ipairs( core.NxGetProjects() ) do
			fzf_cbc(proj)
		end
		fzf_cbc()
	end,{
		prompt="NX projects > ",
		actions={
			['default']=function (items,opts)
				local proj = items[1]
				M.NxListProjectFiles(proj)
			end
		}
	})
end
function M.NxListAllTargets()
	local fzf = require("fzf-lua")
	core.NxGenerateGraph()
	fzf.fzf_exec(function (fzf_cbc)
		for _,target in ipairs( core.NxGetAllTargetsWithDetails() ) do
			fzf_cbc(target)
		end
		fzf_cbc()
	end,{
		prompt="NX run > ",
		actions={
			['default']=function (items,opts)
				local target = items[1]
				vim.ui.input({
					prompt = string.format('Run %s? [y/N] ', target),
				}, function(input)
					if vim.trim(input):lower() == 'y' then
						vim.api.nvim_exec(":split | terminal npx nx run "..target,false)
					end
				end)
			end
		}
	})
end
return M
