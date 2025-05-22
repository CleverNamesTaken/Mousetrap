local M = {}

function M.smartPane()
	-- find the last terminal tag, including where I am right now
	local lastTag = require("mousetrap.bufferOps").findLastTag()
	-- compare it to my current tag
	local activePane = M.activePane()
	-- if it is the same, do nothing
	if activePane ~= lastTag then
		-- check if lastTag exists
		local windowId,paneId = M.searchPane(lastTag)
		if paneId then
			os.execute("tmux select-window -t Mousetrap:" .. windowId)
			-- removing mousetrap session information...  I think this should work regardless.
			os.execute("tmux select-pane -t ".. paneId)
			return
		else
			--print("No pane name provided.  Try appending '~PaneName' to your terminal tag.")
			--return
		end
		vim.ui.input({ prompt = 'A pane called "' .. lastTag ..
				'" does not exist.  Press Enter to create it, or anything else to return.\n'},
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
	return
end

function M.smartPaneCreate(targetTerminal)
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
	-- could not find a way to notify without causing me to press enter.
	--vim.api.nvim_echo({{"New pane created: " .. terminalName, "Normal"}}, false, {})
	--vim.notify("New pane created with notification: " .. terminalName, vim.log.levels.INFO, {})
        return
end

return M
