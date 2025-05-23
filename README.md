# placeholder

![License](https://img.shields.io/badge/License-MIT-green.svg)

Neovim plugin that generates `.vscode/launch.json` debug configurations based on
filetype, with fully customizable settings.

![Preview](https://i.imgur.com/2NiKlZX.gif)

## Installation

Use your favorite plugin manager to install:

```lua
use {
  'rhajizada/placeholder',
  config = function()
    require('placeholder').setup({
      keymap = "<leader>cj", -- Customize keymap,
      }
    })
  end
}
```

> `dap_config_types` follow [dapconfig-schema](https://codeberg.org/mfussenegger/dapconfig-schema/raw/branch/master/dapconfig-schema.json).

## Configuration

### Default configuration

```lua
options = {
  keymap = "<leader>cj",
  dap_config_types = {
    go = { debugger = "go" },
    python = { debugger = "debugpy" },
    lua = { debugger = "nlua" },
  },
}
```

### Customize

When customizing a debugger entry, you may use any of these keys according to
the VS Code schema:

#### Common

- **`debugger`** (string): Adapter identifier (e.g. `"go"`, `"debugpy"`, `"nlua"`)
- **`name`** (string): Human-readable name shown in the debug UI
- **`request`** (`"launch"` or `"attach"`): Whether to start or attach the debugger
- **`noDebug`** (boolean): If `true`, run without stopping for debugging
- **`console`** (`"internalConsole"`, `"integratedTerminal"`): Where I/O is displayed
- **`program`** (string): Path to the executable or script to debug
- **`args`** (array of strings): Command-line arguments to pass
- **`cwd`** (string): Working directory for the debugged process
- **`env`** (table of key–value pairs): Environment variables

#### GDB

##### attach

- **`pid`** (number): Process ID to attach GDB to
- **`target`** (string): Remote target string for `target remote` connection

##### launch

- **`stopAtBeginningOfMainSubprogram`** (boolean): Break at C `main` function start
- **`stopOnEntry`** (boolean): Break at the first instruction

#### Java

##### attach

- **`hostName`** (string): Host to connect for debugging
- **`port`** (number): Port to connect for debugging
- **`processId`** (number): PID of the running JVM to attach to
- **`stepFilters`** (object): Skip classes or synthetic methods when stepping

##### launch

- **`mainClass`** (string): Fully qualified main class name
- **`projectName`** (string): Which project to use in multi-project workspaces
- **`stopOnEntry`** (boolean): Break at the first instruction
- **`stepFilters`** (object): Skip classes or synthetic methods when stepping
- **`vmArgs`** (string): JVM options (system properties, memory settings)

#### Python (debugpy)

- **`code`** (string): Inline Python code to execute
- **`django`** (boolean): Enable Django template debugging
- **`gevent`** (boolean): Support gevent-monkey-patched code
- **`jinja`** (boolean): Enable Jinja2 template debugging (e.g. Flask)
- **`justMyCode`** (boolean): Only step through user code
- **`module`** (string): Python module name to launch

### Example

```lua
return {
  {
    "rhajizada/placeholder",
    config = function()
      require("placeholder").setup({
        keymap = "<leader>cj",
        dap_config_types = {
          go = {
            debugger = "go",
          },
          python = {
            debugger = "debugpy",
          },
          lua = {
            debugger = "nlua",
          },
          javascript = {
            debugger = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            args = {},
            env = { NODE_ENV = "development" },
          },

          typescript = {
            debugger = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            args = {},
            env = { NODE_ENV = "development" },
          },
        },
      })
    end,
  },
}
```

> _Tip_ VS Code supports variables like `${workspaceFolder}`, `${file}`, `${fileBasenameNoExtension}`, and `${env:VAR}`.
