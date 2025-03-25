local M = {}

function M.checkMode()
  -- Avoid sending keys to copy mode.  Should incorporate check for view mode too.
	local tmuxCommand = [[tmux display-message -t Mousetrap -p -F '#{pane_in_mode}']]
    local commandHandler = assert(io.popen(tmuxCommand,'r'))
    -- Parsing of the output
    local output = string.gsub(assert(commandHandler:read('*a')),'[\n\r]+','')
    commandHandler:close()
    -- Check if it return 1, if so, then send 'q' to exit
    if output == '1' then
      os.execute('tmux send-keys -t Mousetrap -X cancel ')
    end
  return
end

function M.SafetyToggle()
	if vim.g.MousetrapSafety == false then
		vim.g.MousetrapSafety = true
		print("Mousetrap safety on")
	else
		vim.g.MousetrapSafety = false
		print("Mousetrap safety off")

	end
	return
end

function M.blockSend(command)
	if vim.g.MousetrapSafety == false then
		return false
	end

	-- identify what looks like it should not be sent.  Probably going to want to add to this over time.
	local prependMeta = {'[[ ','```'}
	-- check if my command has it
	for _,pattern in ipairs(prependMeta) do
		if command:sub(1,#pattern) == pattern then
			return true
		end
	end
	return false
end

function M.sendKeys(consume,returnOutput,currentLine)
	-- Check if the line looks like it should be blocked
	if M.blockSend(currentLine) then
		print("Line not sent -- contains a dirty string.  See sendKeys.lua for more info.")
		return
	end
    -- Make sure pane isn't in copy mode
    M.checkMode()
	-- Grab variables needed for logging
	local targetPane = require("mousetrap.paneOps").activePane()
	local epochTime = os.time()
	-- Update the last yaml file, if necessary
	if vim.g.mousetrapLastStatus then
		require("mousetrap.logging").update(epochTime)
	end
	-- Grab the line count of the window before I send it
	local scriptedWindow = require("mousetrap.config").options.workDir .. '/scripts/' .. targetPane .. '.script'
	local paneLineCount = require("mousetrap.stringParsing").linecount(scriptedWindow) + 1
	local tmuxCommand = string.format([[tmux send-keys -t Mousetrap: %s Enter]], vim.fn.shellescape(currentLine))
	os.execute(tmuxCommand)
	-- log it
	local time = os.date ("%Y-%m-%d_%H-%M-%S_%Z")
	require("mousetrap.logging").main(currentLine,time,targetPane,paneLineCount)
	local vimMessage = vim.g.commandIndex .. ": [[ " .. targetPane .. " ]]" 
	vim.g.commandIndex = vim.g.commandIndex + 1
	vim.notify(vimMessage, vim.log.levels.INFO, { timeout = 30 })

	if consume == true then
		vim.cmd('normal! dd')
	elseif returnOutput == false then
		vim.cmd('normal! j')
	else
		os.execute("sleep 1")
		local explanation = "Forced update after 1 second"
		require("mousetrap.logging").forceUpdate(explanation)
	end
	return
end

function M.sendSafe(consume,returnOutput)
	-- grab the current line
	local currentLine = vim.api.nvim_get_current_line()
	if vim.g.MousetrapSafety == false then
		M.sendKeys(consume,returnOutput,currentLine)
		return
	end
	-- find the last tag
	local lastTag = require("mousetrap.bufferOps").findLastTag()
	if not lastTag then
		return
	end
	-- find the current window
	local activePane = require("mousetrap.paneOps").activePane()
	-- compare them
	if activePane == lastTag then
		M.sendKeys(consume,returnOutput,currentLine)
	else
		print("You tried to send a command intended for " .. lastTag ..
		"' to '" .. activePane .. "'.\nEither fix your last tag with a new timestamp," ..
		" or go to the correct pane with Ctrl+k to send.")
	end
end

return M
