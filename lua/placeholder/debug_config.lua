local M = {}

-- Detect the language of the current open file
local function detect_language()
	return vim.bo.filetype
end

-- Check if a file exists
local function file_exists(path)
	local f = io.open(path, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- Find the project root based on .git or fallback to Neovim's initial argument
local function find_project_root()
	-- Try to find .git directory first and stop at the first match
	local git_root = vim.fn.finddir(".git", ".;")
	if git_root and git_root ~= "" then
		return vim.fn.fnamemodify(git_root, ":h")
	end

	-- If no .git directory, fallback to the first argument passed to Neovim
	if vim.fn.argc() > 0 then
		return vim.fn.fnamemodify(vim.fn.argv(0), ":p:h")
	end

	-- Fallback to the current working directory
	return vim.fn.getcwd()
end

-- Create a directory if it doesn't exist
local function create_directory_if_needed(dir_path)
	if vim.fn.isdirectory(dir_path) == 0 then
		local result = vim.fn.mkdir(dir_path, "p")
		if result == 0 then
			print("Failed to create directory: " .. dir_path)
			return false
		else
			print("Directory created: " .. dir_path)
			return true
		end
	else
		return true -- Directory already exists
	end
end

-- Create the .vscode/launch.json file in the project root if it doesn't exist
local function create_launch_json_if_needed()
	local root_path = find_project_root() .. "/.vscode"
	local path = root_path .. "/launch.json"

	-- Ensure the .vscode directory exists or is created
	if not create_directory_if_needed(root_path) then
		return false
	end

	-- Check if the launch.json file already exists
	if file_exists(path) then
		return true -- File already exists, no need to create
	end

	-- Now try to create the launch.json file
	local file, err = io.open(path, "w")
	if not file then
		print("Error opening or creating launch.json: " .. err)
		return false
	end

	-- Write the initial structure of launch.json
	file:write([[{
  "version": "0.2.0",
  "configurations": []
}]])
	file:close()

	print("launch.json created successfully at: " .. path)
	return true
end

-- Add Python debug configuration
local function add_python_debug_configuration()
	local root_path = find_project_root() .. "/.vscode/launch.json"

	-- Check if the file exists before trying to open it
	if not file_exists(root_path) then
		print("Error: launch.json does not exist. Please run 'create_launch_json_if_needed()' first.")
		return
	end

	-- Open the file for reading
	local file, err = io.open(root_path, "r")
	if not file then
		print("Error opening file for reading: " .. err)
		return
	end

	-- Read the entire content of the launch.json
	local content = file:read("*a")
	file:close()

	-- Decode the JSON content into a Lua table
	local launch_data = vim.fn.json_decode(content)

	-- Ensure there is a "configurations" list in the file
	if not launch_data.configurations then
		print("Error: Configurations list not found in launch.json")
		return
	end

	-- Define the new Python configuration
	local new_config = {
		name = "Python: Current File",
		type = "python",
		request = "launch",
		program = "${file}",
		console = "integratedTerminal",
	}

	-- Add the new configuration to the "configurations" list
	table.insert(launch_data.configurations, new_config)

	-- Encode the Lua table back into JSON format
	local new_content = vim.fn.json_encode(launch_data)

	-- Open the file for writing and update it with the new configuration
	file, err = io.open(root_path, "w")
	if not file then
		print("Error opening file for writing: " .. err)
		return
	end

	file:write(new_content)
	file:close()

	print("Python debug configuration added to launch.json.")
end

-- Main function to add debug configuration based on language
function M.add_debug_configuration()
	-- Ensure the launch.json file exists or is created
	if not create_launch_json_if_needed() then
		print("Failed to create or access launch.json")
		return
	end

	-- Detect the language of the current file
	local language = detect_language()

	-- Add a debug configuration based on the detected language
	if language == "python" or language == "lua" then
		add_python_debug_configuration()
	else
		print("Language not supported yet!")
	end
end

return M
