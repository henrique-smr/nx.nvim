local M = {}

local nx_fzf = require('nx.fzf')
local nx_panel = require('nx.panels')

function M.setup()
	nx_fzf.setup()
	nx_panel.setup()
end

return M
