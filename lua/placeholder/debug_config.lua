local M = {}

-- Setup function for the plugin
function M.setup()
	-- Check if prettier is installed using vim.fn.executable
	if vim.fn.executable("jq") == 0 then
		-- If jq is not found, throw an error message
		vim.api.nvim_err_writeln("Error: 'jq' is not installed. Please install 'jq' to use this plugin.")
		return
	end

	print("Plugin setup complete")
end

-- Helper function to capitalize strings
local function capitalize(str)
	return (str:sub(1, 1):upper() .. str:sub(2))
end

-- Function to format JSON using Prettier
local function format_json_file(launch_json_path)
	-- Check if prettier is available before running the formatting command
	if vim.fn.executable("jq") == 1 then
		-- Format the launch.json file using jq
		vim.cmd("edit " .. launch_json_path)
		-- Run :%!jq to format the content with jq
		vim.cmd("%!jq")
		print("Formatted launch.json")
	else
		-- Error message if prettier is not installed
		vim.api.nvim_err_writeln("Error: 'jq' is not installed. Cannot format JSON.")
	end
end

-- Function to detect the current file's language
local function detect_language()
	return vim.bo.filetype
end

-- Find the root of the project by searching for the .git directory
local function find_git_root()
	local path = vim.fn.expand("%:p:h")
	while path and path ~= "" do
		if vim.fn.isdirectory(path .. "/.git") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil -- No .git directory found, fallback logic can be applied
end

-- Function to add a language-specific debug configuration to launch.json
local function add_debug_configuration_for_language(language)
	return {
		name = string.format("%s: Current File", capitalize(language)),
		type = language,
		request = "launch",
		program = "${file}",
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

	-- Try to open the launch.json file
	local file, err = io.open(launch_json_path, "r")
	if not file then
		-- If the file doesn't exist, create it with default content
		file, err = io.open(launch_json_path, "w")
		if not file then
			print("Error creating launch.json: " .. err)
			return
		end
		file:write([[{
  "version": "0.2.0",
  "configurations": []
}]])
		file:close()
		-- Reopen the file for reading after creation
		file, err = io.open(launch_json_path, "r")
		if not file then
			print("Error reopening launch.json after creation: " .. err)
			return
		end
	end

	-- Read the file content
	local content = file:read("*a")
	file:close()

	-- Decode JSON content
	local launch_data = vim.json.decode(content)

	-- Ensure "configurations" exists in the JSON
	if not launch_data.configurations then
		launch_data.configurations = {}
	end

	-- Detect the current file's language
	local language = detect_language()

	-- Get the language-specific debug configuration
	local debug_config = add_debug_configuration_for_language(language)
	if debug_config then
		-- Add the debug configuration
		table.insert(launch_data.configurations, debug_config)
	else
		return -- If no debug configuration was added, return early
	end

	-- Encode JSON content
	local updated_content = vim.json.encode(launch_data)

	-- Write the updated JSON content back to the file
	file, err = io.open(launch_json_path, "w")
	if not file then
		print("Error opening file for writing: " .. err)
		return
	end
	file:write(updated_content)
	file:close()

	-- Format the launch.json file using Prettier
	format_json_file(launch_json_path)

	print(language .. " debug configuration added to " .. launch_json_path)
end

-- Main function to trigger adding the debug configuration
function M.add_debug_configuration()
	add_debug_configuration()
end

return M
