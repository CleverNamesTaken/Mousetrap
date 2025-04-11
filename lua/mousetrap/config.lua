
---@class Config
local M = {}

---@class Options
-- need to use full paths, aliases or relative paths will not work
local homeDir = os.getenv("HOME")
M.options = {
	workDir = homeDir .. "/work/mousetrap/",
	logDir = homeDir .. "/work/mousetrap/logs/",
	logTime = 5,
	grabLineMax = 100
}

return M

