local M = {}

-- Import config and functionality from other modules
local config = require("placeholder.config")
local placeholder = require("placeholder.debug_config")

-- Setup function that allows user configuration
function M.setup(user_config)
	config.setup(user_config)
	placeholder.setup()
	vim.keymap.set("n", config.options.keymap, placeholder.add_debug_configuration, {})

	-- Register keybinding with which-key if it's installed
	if pcall(require, "which-key") then
		local wk = require("which-key")

		wk.add({
			{ config.options.keymap, placeholder.add_debug_configuration, desc = "Add debug configuration" },
		})
	end
end

-- Function to add the debug configuration
function M.add_debug_configuration()
	placeholder.add_debug_configuration()
end

return M
