# nx.nvim
Nx monorepo integration for Neovim.

Interact with generators, projects and runners like [nrwl/nx-console](https://github.com/nrwl/nx-console) for VSCode.

---
This is my first plugin for neovim and a working in progress repository.

My ideia is to have this as a core module that exposes lua functions to integrate with other plugins,
like [fzf-lua](https://github.com/ibhagwan/fzf-lua) and [Telescope](https://github.com/nvim-telescope/telescope.nvim),through extension.

For now, nx.nvim already includes a fzf-lua integration and [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
 for creating side-panels

Wanna help? Reach up with an issue

### Dependencies:
- [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)
- [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim)

### Instalation:

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 
	"henrique-smr/nx.nvim",
	requires = {
		"ibhagwan/fzf-lua",
		"MunifTanjim/nui.nvim"
	},
	config = function()
		require("nx").setup()
	end
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
	"henrique-smr/nx.nvim",
	dependencies = { 
		"ibhagwan/fzf-lua",
		"MunifTanjim/nui.nvim"
	},
	config = function()
		require("nx").setup()
	end
}
```


### Usage
This plugin uses Nx's graph information to generate useful UI for interacting with its core functionality

#### `NxShowPanel {panel}`
Open a tree-structured side panel, like nx-console

Avaliable panels:
- `projects_targets`: List of projects and their target children


##### `:NxFZFListProjects`

Will generate a fzf window with all projects. Selecting one will open another windown containg the project files listed by Nx's graph

##### `:NxFZFListPlugins`

Search through avaliable plugins. Selecting one will list all its generators, and selecting again will open a smart argument picker for the generator command.

The smart-picker is an fzf list of arguments with a preview window being the dryRun result of the current command string.

Selecting any argument will prompt a value that will set the current argument.

For boolean values, a space will suffice.

Typing `ctrl-r` will run the generator with the constructed argument list;

#### `:NxFZFListAllTargets`

Find all targets for `npx nx run`
