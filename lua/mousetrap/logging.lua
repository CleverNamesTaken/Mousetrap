local M = {}

function M.writeCSV(currentLine,time,targetPane,logDir)
	local file = io.open(logDir .. "/mousetrap.csv", "a")
	local paddedCommandIndex = string.format("%04d",vim.g.commandIndex)
	if file then
	    file:write(string.format("%s,%s,%s,%s\n", paddedCommandIndex,time,targetPane,currentLine))
	    file:close()
    end
end

function M.writeLastCommand(output)
	local logDir = require("mousetrap.config").options.logDir
	local file = io.open(logDir .. "/lastCommand.txt", "w")
	for _, line in ipairs(output) do
		local cleanLine = require("mousetrap.stringParsing").cleanText(line)
		file:write(cleanLine .. '\n' )
	end
	file:close()
	return
end

function M.main(currentLine,time,targetPane,paneLineCount)
	local logDir = require("mousetrap.config").options.logDir
	if vim.g.commandIndex == nil then
		M.getLastIndex()
	end

	-- add to csv
	M.writeCSV(currentLine,time,targetPane,logDir)
	-- write yamlFile
	M.writeYaml(currentLine,time,targetPane,logDir,paneLineCount)
end

function M.getOutput(targetPane,paneLineCount)
	-- identify the scripted window
	local scriptedWindow = require("mousetrap.config").options.workDir .. '/scripts/' .. targetPane .. '.script'
	-- Grab whatever is new
	local output = {}
	local currentLine = 0
	for line in io.lines(scriptedWindow) do
		currentLine = currentLine + 1
		if currentLine >= paneLineCount then
			table.insert(output,line)
		end
	end
	-- I think the last line is usually garbage, so I'm going to remove it...
	output[#output] = nil
	return output

end
function M.writeYaml(currentLine,time,targetPane,logDir,paneLineCount)
	-- make sure the directory structure exists
        local paneDir = logDir .. "/" .. targetPane
        -- create scriptDir
        os.execute("mkdir -p " .. paneDir )
	-- grab new output
	local output = M.getOutput(targetPane,paneLineCount)
	-- write yaml file
	local abbrevCommand = M.cleanCommand(currentLine)
	local paddedCommandIndex = string.format("%04d",vim.g.commandIndex)
	local yamlName = paddedCommandIndex .. '_' .. time .. '--' .. abbrevCommand .. '.yaml'
	local file = io.open(paneDir .. "/" .. yamlName, "w")
	local recordTime = os.date ("%Y-%m-%d %H:%M:%S %Z")
	local epochTime = os.time()
	-- TODO add in the explanation for the logging
	if file then
	    file:write(string.format("CommandExecuted: '%s'\n", currentLine))
	    file:write(string.format("TimeExecuted: '%s'\n", time))
	    file:write(string.format("TargetPane: '%s'\n", targetPane))
	    file:write(string.format("TimeRecorded: '%s'\n", recordTime))
	    file:write("Explanation: This yaml file was created right after command execution and may not be complete.\n")
	    file:write(string.format("Output: |\n"))
	    for _, line in ipairs(output) do
		    local cleanLine = require("mousetrap.stringParsing").cleanText(line)
		    file:write("\t " .. cleanLine .. '\n' )
	    end
	    file:write("\n")
	    file:close()

	M.writeLastCommand(output)
	-- save variables for updating the log
	vim.g.mousetrapLastStatus = true
	vim.g.mousetrapLastLog = paneDir .. "/" .. yamlName
	vim.g.mousetrapLastPane = targetPane
	vim.g.mousetrapLastTime = epochTime
	vim.g.mousetrapLastCount = paneLineCount
	end
end

function M.forceUpdate(explanation)
	if not vim.g.mousetrapLastLog then
		print("No mousetrap log to update")
		return
	end
	local newLines = {}
	-- Grab the first three lines of the old yaml file
	local file = io.open(vim.g.mousetrapLastLog,"r")
	local i = 1
	for line in file:lines() do
		if i <= 3 then
			table.insert(newLines,line)
		end
		i = i +1
	end
	file.close()
	local recordTime = os.date ("%Y-%m-%d %H:%M:%S %Z")
	local output = M.getOutput(vim.g.mousetrapLastPane,vim.g.mousetrapLastCount)
	file = io.open(vim.g.mousetrapLastLog,"w")
	for _, line in ipairs(newLines) do
		file:write(line .. "\n")
	end
	file:write(string.format("TimeRecorded: '%s'\n", recordTime))
	file:write("Explanation: " .. explanation .. "\n")
	file:write(string.format("Output: |\n"))
	for _, line in ipairs(output) do
		local cleanLine = require("mousetrap.stringParsing").cleanText(line)
		file:write("\t " .. cleanLine .. "\n")
	end
	file:write("\n")
	file:close()
	M.writeLastCommand(output)
	vim.g.mousetrapLastStatus = false
	return
end

function M.update(time)
	-- Check if it has been less than logTime minutes since I last updated a log.
	-- logTime is defined in mousetrap.config.
	-- If it has been too long, then I assume I went interactive and do not want all the garbage I probably collected
	local logTime = require("mousetrap.config").options.logTime
	if time - vim.g.mousetrapLastTime <= (60 * logTime) then
		local explanation = "This yaml file was updated after another mousetrap keystroke was made within " .. logTime ..
		" minutes, as set in the mousetrap config file.\n"
		M.forceUpdate(explanation)
		return
	else
		print("It has been too long?!")
		return
	end
end

function M.cleanCommand(command)
	-- change spaces to underscores
	local cleanedCommand = command:gsub(" ","_")
	cleanedCommand = cleanedCommand:gsub("/","_")
	if string.len(cleanedCommand) > 50 then
		local startCommand = string.sub(cleanedCommand, 1, 25)
		local endCommand = string.sub(cleanedCommand, -25)
		cleanedCommand = startCommand .. "..." .. endCommand
	end
	return cleanedCommand
end

function M.getLastIndex()
	--Look at the last line in the csv
	local logDir = require("mousetrap.config").options.logDir
	local targetCsv = logDir .. "/mousetrap.csv"
	-- Open the CSV file
	local file = io.open(targetCsv, "r")
	if not file then
		vim.g.commandIndex = 0
		return
	end
	local lastRow = nil
	-- Iterate through each line in the file
	for line in file:lines() do
	    lastRow = line -- Save the current line as the last row
	end
	file:close()
	-- Split the last row by commas to extract columns
	local firstColumn = nil
	if lastRow then
	    local columns = {}
	    for value in string.gmatch(lastRow, '([^,]+)') do
		table.insert(columns, value)
	    end
	    firstColumn = columns[1] -- Get the first column
	end
	vim.g.commandIndex = firstColumn + 1
	return
end
return M
