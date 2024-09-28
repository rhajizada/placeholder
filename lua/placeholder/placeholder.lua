local M = {}
local config = require("placeholder.config") -- Import the config module

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
	local debugger_type = config.options.dap_config_types[language]
	local console = config.options.console

	if not debugger_type then
		print("Error: No DAP configuration found for " .. language)
		return
	end

	local bp = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
	return {
		name = string.format("%s: %s", capitalize(language), bp),
		type = debugger_type,
		request = "launch",
		program = string.format("${workspaceFolder}/%s", bp),
		args = {},
		console = console,
	}
end

-- Function to add a debug configuration to launch.json
local function add_debug_configuration()
	local project_root = find_git_root() or vim.fn.getcwd()
	local vscode_dir = project_root .. "/.vscode"
	local launch_json_path = vscode_dir .. "/launch.json"

	if vim.fn.isdirectory(vscode_dir) == 0 then
		local ok, err = vim.fn.mkdir(vscode_dir, "p")
		if ok == 0 then
			print("Error creating .vscode directory: " .. err)
			return
		end
	end

	local language = detect_language()
	local debug_config = add_debug_configuration_for_language(language)
	if not debug_config then
		return
	end

	local buf_exists = vim.fn.filereadable(launch_json_path) == 1
	local launch_data
	if buf_exists then
		vim.cmd("edit " .. launch_json_path)
		local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
		launch_data = vim.json.decode(buf_content) or {}
	else
		launch_data = { version = "0.2.0", configurations = {} }
		vim.cmd("edit " .. launch_json_path)
	end

	if not launch_data.configurations then
		launch_data.configurations = {}
	end

	table.insert(launch_data.configurations, debug_config)

	local updated_content = vim.json.encode(launch_data)
	if vim.fn.executable("jq") == 1 then
		updated_content = vim.fn.system("echo '" .. updated_content .. "' | jq .")
	else
		vim.api.nvim_err_writeln("Error: 'jq' is not installed. Cannot format JSON.")
	end

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
