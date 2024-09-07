local M = {}

-- Import config and functionality from other modules
local config = require("placeholder.config")
local debug_config = require("placeholder.debug_config")

-- Setup function that allows user configuration
function M.setup(user_config)
	config.setup(user_config)

	-- Set the keybinding using Neovim's API
	vim.api.nvim_set_keymap(
		"n",
		config.options.keymap,
		[[<cmd>lua require'placeholder'.add_debug_configuration()<CR>]],
		{ noremap = true, silent = true }
	)

	-- Register keybinding with which-key if it's installed
	if pcall(require, "which-key") then
		local wk = require("which-key")

		-- Optionally configure which-key (can be removed if not needed)
		wk.setup({})

		-- Register the label for the keybinding in which-key
		wk.register({
			[config.options.keymap] = { "Add debug configuration" },
		}, { mode = "n" }) -- Register for normal mode
	end
end

-- Function to add the debug configuration
function M.add_debug_configuration()
	debug_config.add_debug_configuration()
end

return M
