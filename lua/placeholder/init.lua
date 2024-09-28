local M = {}

-- Import config and functionality from other modules
local config = require("placeholder.config")
local placeholder = require("placeholder.placeholder")

-- Setup function that allows user configuration
function M.setup(user_config)
	-- Set up user configurations in config.lua
	config.setup(user_config)
	placeholder.setup()

	-- Set the keymap using the updated configuration
	vim.keymap.set(
		"n",
		config.options.keymap,
		placeholder.add_debug_configuration,
		{ desc = "Add debug configuration" }
	)

	-- Register keybinding with which-key if it's installed
	if pcall(require, "which-key") then
		local wk = require("which-key")
		wk.add({
			[config.options.keymap] = { placeholder.add_debug_configuration, desc = "Add debug configuration" },
		})
	end
end

-- Function to add the debug configuration
function M.add_debug_configuration()
	placeholder.add_debug_configuration()
end

return M
