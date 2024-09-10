local M = {}

-- Import config and functionality from other modules
local config = require("placeholder.config")
local placeholder = require("placeholder.debug_config")

-- Setup function that allows user configuration
function M.setup(user_config)
	config.setup(user_config)
	placeholder.setup()

	-- Set the keybinding using Neovim's API
	-- vim.api.nvim_set_keymap(
	-- 	"n",
	-- 	config.options.keymap,
	-- 	[[<cmd>lua require'placeholder'.add_debug_configuration()<CR>]],
	-- 	{ noremap = true, silent = true }
	-- )
	--
	vim.keymap.set("n", config.options.keymap, placeholder.add_debug_configuration, {})

	-- Register keybinding with which-key if it's installed
	if pcall(require, "which-key") then
		local wk = require("which-key")

		-- Optionally configure which-key (can be removed if not needed)
		wk.add({
			{ config.options.keymap, placeholder.add_debug_configuration, desc = "Add debug configuration" },
		})

		-- Register the label for the keybinding in which-key
	end
end

-- Function to add the debug configuration
function M.add_debug_configuration()
	placeholder.add_debug_configuration()
end

return M
