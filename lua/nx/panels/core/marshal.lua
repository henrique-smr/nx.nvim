local M = {}

function M.marshal_func(node)
	local name, detail, icon = node.name, " ", node.icon
	if #node.children == 0 then
		return name, detail, icon, " "
	end
	return name, detail, icon
end

return M
