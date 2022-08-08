local M = {}

function M.parseOpts(opts)
	local cmd_str = ""
	for k, v in pairs(opts) do
		cmd_str = cmd_str .. " --" .. k .. " " .. v
	end
	return cmd_str
end

return M
