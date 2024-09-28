# placeholder

A Neovim plugin that detects the language of the current file and adds a
VSCode-style debug configuration to `.vscode/launch.json`.

## Installation

Use your favorite plugin manager to install:

```lua
use {
  'rhajizada/placeholder',
  config = function()
    require('placeholder').setup({
      keymap = "<leader>cj", -- Customize keymap,
      console = "internalConsole", -- Customize console
      -- Customize debug configuration types for different languages
      dap_config_types = {
        go = "go",
        python = "debugpy",
      }
    })
  end
}
```
