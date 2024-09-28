local M = {}
local config = require("placeholder.config")
local placeholder = require("placeholder.placeholder")

-- Function to handle keymap registration
local function set_keymap()
	-- Remove the old keymap if one exists
	if config.options.previous_keymap then
		pcall(vim.keymap.del, "n", config.options.previous_keymap)
	end

	-- Set the new keymap
	vim.keymap.set(
		"n",
		config.options.keymap,
		placeholder.add_debug_configuration,
		{ desc = "Add debug configuration" }
	)

	-- Update the previous_keymap to the new keymap
	config.options.previous_keymap = config.options.keymap
end

function M.setup(user_config)
	-- Set up user configurations in config.lua
	config.setup(user_config)
	placeholder.setup()

	-- Set the keymap
	set_keymap()
end

-- Function to add the debug configuration
function M.add_debug_configuration()
	placeholder.add_debug_configuration()
end

return M
