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
        return s:find("%W") ~= nil
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
	-- strip out carriage returns
	cleanString =  cleanString:gsub('\r','')
	-- strip out ansi escapes
	cleanString =  cleanString:gsub('\27%[%?2004[hl]','')
	return cleanString
end
return M
