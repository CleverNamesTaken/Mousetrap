local M = {}

function M.smartPane()
	-- find the last terminal tag, including where I am right now
	local lastTag = require("mousetrap.bufferOps").findLastTag()
	-- compare it to my current tag
	local activePane = M.activePane()
	-- if it is the same, do nothing
	if activePane ~= lastTag then

		-- Look through our tags and go to the paneId
		local file = assert(io.open("/tmp/.mousetrap.yaml", "r"))
		for line in file:lines() do
			local s = line:match("^%s*(.-)%s*$")
			local key, value = s:match("^(%S+)%s*:%s*(.+)$")
			if value == lastTag then
				-- first lets go to the window
				local windowId = value:match("^(.-)~")
				os.execute("tmux select-window -t Mousetrap:" .. windowId)
				-- removing mousetrap session information...  This could introduce an issue if there are multiple sessions open
				os.execute("tmux select-pane -t " .. key)
				-- then focus on that pane
				return
			end
		end
		file:close()

		--If we do not have a matching pane title already...
		vim.ui.input({ prompt = 'A pane called "' .. lastTag ..
				'" does not exist.  Press Enter or Esc to create it, or anything else to return.\n'},
			function(input)
			if input == nil or input == '' then
        -- If input is nil or empty (Enter pressed), create the pane
				M.smartPaneCreate(lastTag)
			else
        -- If any other input is given, consider it as a cancellation
				print("Cancelled")
			end
		end)
	end

	--If we got here, then the activePane is the same as before, so we can just keep rolling.
	return
end

function M.smartPaneCreate(targetTerminal)
	-- Check if the pane name has the elements we want
	if not require("mousetrap.stringParsing").checkPaneName(targetTerminal) then
		return
	end
	local targetWindow = require("mousetrap.stringParsing").split(targetTerminal,"~",1)
	local targetPane = require("mousetrap.stringParsing").split(targetTerminal,"~",2)
	local windowId = require("mousetrap.windowOps").searchWindow(targetWindow)
	-- check if the window exists.
	if windowId then
		-- If yes, go to it.  And create the new pane.
		os.execute("tmux select-window -t Mousetrap:" .. windowId)
		M.newPane(targetWindow,targetPane)
	else
		-- If no, create new window with that pane name
		require("mousetrap.windowOps").newWindow(targetWindow,targetPane)
	end
	return
end



function M.searchPane(targetPane)
	-- list all the panes

	local file = assert(io.open("/tmp/.mousetrap.yaml", "r"))
	for line in file:lines() do
		local s = line:match("^%s*(.-)%s*$")
		local key, value = s:match("^(%S+)%s*:%s*(.+)$")
		if value == targetPane then
			os.execute("tmux select-pane -t Mousetrap: -T '" .. value .. "'" )
			break
		end
	end
	file:close()



	local tmuxCommand = 'tmux list-panes -t Mousetrap -s -F "#{pane_title},#{window_id},#{pane_id}"'
        local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        f:close()
	local paneTable = {}
	for line in output:gmatch("[^\r\n]+") do
		table.insert(paneTable,line)
	end
	-- check if targetPane is in the list
	for _,pane in ipairs(paneTable) do
		local parsedPane = require("mousetrap.stringParsing").split(pane,",",1)
		local parsedWindowId = require("mousetrap.stringParsing").split(pane,',',2)
		local parsedPaneId = require("mousetrap.stringParsing").split(pane,',',3)
		if targetPane == parsedPane then
			return parsedWindowId,parsedPaneId
		end
	end
	return false
end



function M.namePane(name)
        os.execute("tmux select-pane -t Mousetrap: -T '" .. name .. "'")
	return
end

function M.nextPane()
        os.execute("tmux select-pane -t Mousetrap:.+")
	return
end


function M.getPaneName()
	while true do
		local paneName = vim.fn.input({ prompt = 'Enter the name of the new pane: ' })
		if paneName ~= "" and not require("mousetrap.stringParsing").has_special_chars(paneName) then
			return paneName
		else
			print("\nBlank names and special characters are not permitted.")
		end
	end
end

function M.focusPane()
        os.execute("tmux resize-pane -t Mousetrap: -Z")
	return
end

function M.resetPane()
        os.execute("tmux send-keys -t Mousetrap: -R")
	return
end




function M.activePane()
        -- grab the active pane
        local tmuxCommand = "tmux display-message -t Mousetrap: -p -F '#T'"
        local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        -- remove newline
        local activePane = output:gsub("\n", "")
        f:close()
        return activePane
end

function M.newPane(windowName,paneName)
	if paneName == nil or paneName == "" or require("mousetrap.stringParsing").has_special_chars(paneName) then
		paneName = M.getPaneName()
	end

	local workDir = require("mousetrap.config").options.workDir
        local scriptDir = workDir .. "/scripts"
        -- create scriptDir
        os.execute("mkdir -p " .. scriptDir )

        local terminalName = windowName .. "~" .. paneName
        local scriptName = terminalName .. ".script"
        local scriptCommand = "script -af " .. scriptDir .. "/" .. scriptName

        local vim_pwd = vim.fn.getcwd()
        os.execute("tmux split-window -t Mousetrap: -c " .. vim_pwd .. " '" .. scriptCommand .. "'")
        M.namePane(terminalName)
	M.createYaml()
        return
end

function M.createYaml()
	-- get paneId and create reference yaml
	local tmuxCommand = "tmux display-message -t Mousetrap: -p -F '#D: #T'| tr -d '%'"
        local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        -- remove newline
        f:close()

	file = io.open("/tmp/.mousetrap.yaml", "a")
	file:write(output)
	file:close()
		return
	end


function M.checkPaneName()
	--check if the pane title changed, and revert it back if it has
	
	--first grab the current pane_id and title
	local tmuxCommand = "tmux display-message -t Mousetrap: -p -F '#D: #T'| tr -d '%'"
	local f = io.popen(tmuxCommand, "r")
        local output = f:read("*a")
        f:close()

	local pane_id, pane_title = output:match("^(%S+)%s*:%s*(.+)$")

	--compare the values with what mousetrap expects it to be

	local file = assert(io.open("/tmp/.mousetrap.yaml", "r"))
	for line in file:lines() do
		local s = line:match("^%s*(.-)%s*$")
		local key, value = s:match("^(%S+)%s*:%s*(.+)$")
		if key == pane_id and value ~= pane_title then
			os.execute("tmux select-pane -t Mousetrap: -T '" .. value .. "'" )
			break
		end
	end
	file:close()
	return
end

return M
