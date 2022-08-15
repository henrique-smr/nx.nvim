local panels_core_context = require('nx.panels.core.context')

local M = {
	_component_actions_ = {}
}

function M.setup_component_buffer(name, buf, tab)
	-- see if we can reuse a buffer that currently exists.
	if buf == nil or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, false)
		if buf == 0 then
			vim.api.nvim_err_writeln("nx.panels.buffer: buffer create failed")
			return
		end
	else
		return buf
	end

	-- set buf options
	vim.api.nvim_buf_set_name(buf, name .. ":" .. tab)
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
	vim.api.nvim_buf_set_option(buf, 'filetype', 'nx')
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'textwidth', 0)
	vim.api.nvim_buf_set_option(buf, 'wrapmargin', 0)

	vim.cmd("au BufEnter,WinEnter <buffer=" .. buf .. "> stopinsert")
	-- au to clear jump highlights on window close
	vim.cmd("au BufWinLeave <buffer=" .. buf .. "> lua require('litee.lib.jumps').set_jump_hl(false)")

	-- hide the cursor if possible since there's no need for it, resizing the panel should be used instead.
	-- if config.hide_cursor then
	vim.cmd("au WinLeave <buffer=" .. buf .. "> lua require('litee.lib.util.buffer').hide_cursor(false)")
	vim.cmd("au WinEnter <buffer=" .. buf .. "> lua require('litee.lib.util.buffer').hide_cursor(true)")

	return buf
end

function M.setup_component_buffer_default_cmds(buf, component)
	M.setup_component_buffer_custom_cmds(buf, component, {
		['l'] = function()
			require('nx.panels.core').expand_component_node(component)
		end,
		['h'] = function()
			require('nx.panels.core').expand_component_node(component, false)
		end,
		['<CR>'] = function()
			require('nx.panels.core').expand_component_node(component)
		end,
	})
end

function M.setup_component_buffer_custom_cmds(buf, component, actions)
	if actions == nil then
		return
	end
	for key, action in pairs(actions) do
		if M._component_actions_[component] == nil then
			M._component_actions_[component] = {}
		end
		M._component_actions_[component][key] = function()
			if type(action) == 'function' then
				action(panels_core_context.ui_req_ctx(component))
			end
		end
		-- We only escape `<` - I couldn't be bothered to deal with how <lt>/<gt> have angle brackets in themselves
		-- And this works well-enough anyways
		local key_escaped = key:gsub("<", "<lt>")

		vim.api.nvim_buf_set_keymap(
			buf,
			'n',
			key,
			string.format(
				'<cmd>lua require("nx.panels.core.buffer")._component_actions_["%s"]["%s"]()<CR>',
				component,
				key_escaped
			),
			{ noremap = true, silent = true }
		)
	end
end

return M
