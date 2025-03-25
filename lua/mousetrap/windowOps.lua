local M = {}


function M.activeWindow()
        -- grab the active pane
        local tmuxCommand = "tmux display-message -t Mousetrap: -p -F '#W'"
        local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        -- remove newline
        local activeWindow = output:gsub("\n", "")
        f:close()
        return activeWindow
end

function M.changeWindow(targetWindowNumber)
        local tmuxCommand = "tmux select-window -t Mousetrap:" .. targetWindowNumber .. " 2>/dev/null"
	os.execute(tmuxCommand)
	return
end

function M.formatWindows()
        local tmuxCommand = "tmux next-layout -t Mousetrap:"
	os.execute(tmuxCommand)
	return
end


function M.searchWindow(targetWindow)
	-- list all the panes
        local tmuxCommand = 'tmux list-windows -a -F "#{window_name},#{window_index}"'
        local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        f:close()
	local windowTable = {}
	for line in output:gmatch("[^\r\n]+") do
		table.insert(windowTable,line)
	end
	-- check if targetWindow is in the list
	for _,window in ipairs(windowTable) do
		local parsedWindow = require("mousetrap.stringParsing").split(window,",",1)
		local parsedWindowId = require("mousetrap.stringParsing").split(window,',',2)
		if targetWindow == parsedWindow then
			return parsedWindowId
		end
	end
	return false
end



function M.getWindowName()
	while true do
		local windowName = vim.fn.input({ prompt = 'Enter the name of the new window: ' })
		if windowName ~= "" and not require("mousetrap.stringParsing").has_special_chars(windowName) then
			return windowName
		else
			print("\nBlank names and special characters are not permitted.")
		end
	end
end

function M.newWindow(windowName,paneName)
	local workDir = require("mousetrap.config").options.workDir
	if windowName == nil or windowName == "" or require("mousetrap.stringParsing").has_special_chars(windowName) then
		windowName = M.getWindowName()
	end
        local scriptDir = workDir .. "/scripts"

        -- create scriptDir
        os.execute("mkdir -p " .. scriptDir )
        local terminalName = windowName .. "~" .. paneName
        local scriptName = terminalName .. ".script"
        local scriptCommand = "script -af " .. scriptDir .. "/" .. scriptName

        local vim_pwd = vim.fn.getcwd()
        os.execute("tmux new-window -t Mousetrap: -c " .. vim_pwd ..
			" -n '" .. windowName .. "' '" .. scriptCommand .. "'")
        require("mousetrap.paneOps").namePane(terminalName)
	--vim.api.nvim_echo({{"New window created: " .. windowName, "Normal"}}, false, {})
        return
end
return M
