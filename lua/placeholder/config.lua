local M = {}

-- Default configuration options
M.options = {
	keymap = "<leader>cj",
}

-- Setup function to allow users to override default configuration
function M.setup(user_config)
	M.options = vim.tbl_deep_extend("force", M.options, user_config or {})
end

return M
