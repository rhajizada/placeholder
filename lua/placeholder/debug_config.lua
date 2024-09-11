local M = {}

-- Setup function for the plugin
local function setup()
	if vim.fn.executable("jq") == 0 then
		print("Error: 'jq' is not installed. Please install 'jq' to use this plugin.")
		return
	end
end

-- Helper function to capitalize strings
local function capitalize(str)
	return (str:sub(1, 1):upper() .. str:sub(2))
end

-- Function to detect the current file's language
local function detect_language()
	return vim.bo.filetype
end

-- Map of filetypes to DAP configuration types
local dap_config_types = {
	-- c = "cppdbg",
	-- cpp = "cppdbg",
	-- cs = "coreclr",
	-- d = "cppdbg",
	-- dart = "dart",
	-- elixir = "elixir",
	-- erlang = "erlang",
	-- fortran = "cppdbg",
	go = "go",
	-- haskell = "haskell",
	-- java = "java",
	javascript = "pwa-node",
	-- kotlin = "java",
	-- lua = "lua",
	-- ocaml = "ocaml",
	-- perl = "perl",
	-- php = "php",
	-- powershell = "PowerShell",
	python = "debugpy",
	-- ruby = "ruby",
	-- rust = "codelldb",
	-- swift = "codelldb",
	typescript = "pwa-node",
	-- zig = "codelldb",
}

-- Find the root of the project by searching for the .git directory
local function find_git_root()
	local path = vim.fn.expand("%:p:h")
	while path and path ~= "" and path ~= "/" do
		if vim.fn.isdirectory(path .. "/.git") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil -- No .git directory found, fallback logic can be applied
end

-- Function to add a language-specific debug configuration to launch.json
local function add_debug_configuration_for_language(language)
	local dap_type = dap_config_types[language]

	if not dap_type then
		-- If it doesn't exist, return an error
		print("Error: No DAP configuration found for " .. language)
		return
	end

	local bp = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
	return {
		name = string.format("%s: %s", capitalize(language), bp),
		type = dap_type,
		request = "launch",
		program = string.format("${workspaceFolder}/%s", bp),
		args = {},
		console = "integratedTerminal",
	}
end

-- Function to add a debug configuration to launch.json
local function add_debug_configuration()
	local project_root = find_git_root() or vim.fn.getcwd() -- Fallback to current working directory if no .git found
	local vscode_dir = project_root .. "/.vscode"
	local launch_json_path = vscode_dir .. "/launch.json"

	-- Ensure the .vscode directory exists
	if vim.fn.isdirectory(vscode_dir) == 0 then
		local ok, err = vim.fn.mkdir(vscode_dir, "p")
		if ok == 0 then
			print("Error creating .vscode directory: " .. err)
			return
		end
	end

	-- Detect the current file's language
	local language = detect_language()
	local debug_config = add_debug_configuration_for_language(language)
	if not debug_config then
		return -- If no debug configuration was added, return early
	end

	-- Open the .vscode/launch.json buffer or create a new one if it doesn't exist
	local buf_exists = vim.fn.filereadable(launch_json_path) == 1

	-- Read the current contents or create a default table if the file does not exist
	local launch_data
	if buf_exists then
		vim.cmd("edit " .. launch_json_path) -- Open the launch.json in the current buffer
		local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
		launch_data = vim.json.decode(buf_content) or {}
	else
		launch_data = { version = "0.2.0", configurations = {} }
		vim.cmd("edit " .. launch_json_path) -- Open (and create) the file if it does not exist
	end

	-- Ensure "configurations" exists in the JSON
	if not launch_data.configurations then
		launch_data.configurations = {}
	end

	-- Add the new debug configuration
	table.insert(launch_data.configurations, debug_config)

	-- Encode the updated table back into JSON
	local updated_content = vim.json.encode(launch_data)
	if vim.fn.executable("jq") == 1 then
		updated_content = vim.fn.system("echo '" .. updated_content .. "' | jq .")
	else
		vim.api.nvim_err_writeln("Error: 'jq' is not installed. Cannot format JSON.")
	end

	-- Write the updated content back to the buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(updated_content, "\n"))

	print(language .. " debug configuration added to " .. launch_json_path)
end

function M.setup()
	setup()
end

function M.add_debug_configuration()
	add_debug_configuration()
end

return M
