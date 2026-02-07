# git-worktree.nvim

A Neovim plugin for managing git worktrees with an intuitive interface.

## Features

- Interactive worktree switching
- Create new worktrees with branch detection
- Remove worktrees safely
- Automatic direnv integration
- Post-add hooks support
- Shared directory copying

## Requirements

- Neovim >= 0.9
- Git
- Optional: `direnv` for automatic environment loading

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/git-worktree.nvim",
  config = function()
    require("git-worktree").setup({
      -- Your configuration
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/git-worktree.nvim",
  config = function()
    require("git-worktree").setup({
      -- Your configuration
    })
  end,
}
```

## Configuration

```lua
require("git-worktree").setup({
  -- Keymaps (nil or false to disable)
  keymaps = {
    switch = "<leader>gw",
    add = "<leader>wa",
    remove = "<leader>wr",
  },
  
  -- Hook configuration
  hooks = {
    -- Shell script to run after adding worktree
    -- Set to false to disable
    after_add = ".hooks/after-worktree-add.sh",
  },
  
  -- Features
  enable_direnv = true,      -- Auto-run direnv allow
  copy_shared = ".shared",   -- Copy directory after add (false to disable)
  
  -- Notifications
  notify = true,
  
  -- Icons (optional)
  icons = {
    worktree = "",
    branch = "",
    active = "→",
  },
})
```

## Commands

The plugin provides three main commands:

### `require("git-worktree").switch()`
Opens an interactive selector to switch between worktrees.

### `require("git-worktree").add()`
Prompts for worktree path and optional branch name. Automatically:
- Detects remote branches
- Creates worktree with proper branch base
- Copies shared directory (if configured)
- Runs direnv allow (if enabled)
- Executes post-add hook (if exists)

### `require("git-worktree").remove()`
Opens an interactive selector to remove a worktree. Safety features:
- Cannot remove active worktree
- Cannot remove locked worktrees
- Prompts for force removal if files exist

## Hooks

Place a shell script at `.hooks/after-worktree-add.sh` in your bare repository:

```bash
#!/bin/bash
# This runs after a new worktree is created
echo "Setting up new worktree..."
```

The script receives the worktree path as working directory.

## License

MIT
