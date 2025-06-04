local M = {}

function M.split(str, sep, index)
	local result = {}
	for str_sub in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(result, str_sub)
	end
	for i, v in ipairs(result) do
		if i == index then
			result = v
		end
	end
	return result
end

function M.backSlashEscape(currentLine)
	-- count how many backslashes are at the end of the string
	local count = 0
	local length = #currentLine

	for i = length, 1, -1 do
		if currentLine:sub(i, i) == "\\" then
			count = count + 1
		else
			break
		end
	end
	-- escape each one of them
	if count > 0 then
		return currentLine .. string.rep("\\", count)
	else
		return currentLine
	end
end
function M.has_special_chars(s)
	return s:find("[^%w.]") ~= nil
end

function M.linecount(targetFile)
	local count = 0
	for _ in io.lines(targetFile) do
		count = count +1
	end
	return count
end

function M.cleanText(string)
	-- strip out color codes
	local cleanString =  string:gsub('\27%[%d+;*%d*m','')
	--local cleanString = string:gsub("\\x1B(?:[a-zA-Z0-9]*|[0-9]+m", "")
	-- strip out carriage returns
	cleanString = cleanString:gsub('\r','')
	-- strip out ansi escapes
	cleanString = cleanString:gsub('\27%[%?2004[hl]','')
	cleanString = cleanString:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "")
	return cleanString
end


function M.checkPaneName(targetTerminal)
	-- check if the smart pane passed to us meets the requirements
	-- only two requirements
	-- needs to have exactly one ~ in the name separating the window title and pane title
	local _,count = string.gsub(targetTerminal,"~","")
	if count ~= 1 then
		print("Terminal tags must have exactly one ~ separating the window and pane titles")
		return false
	end
	-- no other special characters except for period is allowed
	local non_special_chars = "[^%^%$%(%)%%%[%]%*%+%-%?~]"
	local pattern = "^" .. non_special_chars .. "+~" .. non_special_chars .. "+$"
	if string.match(targetTerminal,pattern) and select(2,string.gsub(targetTerminal,"~","")) == 1 then
		return true
	end
	print("No special characters are allowed in window or pane titles besides '.'.  Additionally, ~ must separate the window and pane titles.  For example 'Foo~Bar'")
	return false
end
return M
