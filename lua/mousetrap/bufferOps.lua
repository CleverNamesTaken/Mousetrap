local M = {}

function M.writeLine(line)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(0, row, row, false, {line})
	vim.api.nvim_win_set_cursor(0, {row + 1, 0})
	return
end


function M.grabLastOutput()
	-- look in the scripted window to see what was added last time
	local logDir = require("mousetrap.config").options.logDir
	local lastCommandFile = io.open(logDir .. "/lastCommand.txt","r")
	if lastCommandFile then
		local lines = 0
		for _ in lastCommandFile:lines() do
			lines = lines + 1
		end
		-- If there are too many lines, let's not grab it.
		local grabLineMax = require("mousetrap.config").options.grabLineMax
		if lines > grabLineMax then
			M.newTab()
			return
		else
			local lastCommandFile = io.open(logDir .. "/lastCommand.txt","r")
			for line in lastCommandFile:lines() do
				local cleanLine = require("mousetrap.stringParsing").cleanText(line)
				M.writeLine(tostring(cleanLine))
			end
		end
	end
end

function M.newTab()
    local choices = { "Yes", "No" }
    local logDir = require("mousetrap.config").options.logDir
    local grabLineMax = require("mousetrap.config").options.grabLineMax
    vim.ui.select(choices, { prompt = "You tried to pull back more than " .. grabLineMax .. " lines into your buffer.  Do you want to open lastCommand.txt in a new tab?" }, function(choice)
        if choice == "Yes" then
                vim.cmd("tabnew " .. logDir .. "/lastCommand.txt")
        else
            print("Cancelled.")
        end
    end)
    return
end


function M.timestamp()
	local time = os.date ("%Y-%m-%d %H:%M:%S %Z")
	local timestamp = "[[ " .. require("mousetrap.paneOps").activePane() .. " ]] - " .. time
	M.writeLine(timestamp)
end


function M.findLastTag()
	local current_line = vim.fn.line('.')
	for line_num = current_line , 1, -1 do
		local line = vim.fn.getline(line_num)
		local match = line:match("^%[%[ (.-) %]%]")
		if match then
			return match
		end
	end
	vim.notify("No tags found", vim.log.levels.INFO, { timeout = 30 })
	return
end

return M
