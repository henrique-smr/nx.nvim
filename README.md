# nx.nvim
A Nx monorepo integration for Neovim.

Interact with generators, projects and runners like [nrwl/nx-console](https://github.com/nrwl/nx-console) for VSCode.

---
This is my first plugin for neovim and a working in progress repository.

My ideia is to have this as a core module that exposes lua functions to integrate with other plugins,
like [fzf-lua](https://github.com/ibhagwan/fzf-lua) and [Telescope](https://github.com/nvim-telescope/telescope.nvim),through extension.

For now nx.nvim already includes a fzf-lua integration

Wanna help? Reach up with an issue

### Usage (fzf-lua integration)

Those are the currently avaliable stand-alone functions:

	require('nx.nvim').NxListAllTargets()

	require('nx.nvim').NxListProjects()
	
	require('nx.nvim').NxListPlugins()
