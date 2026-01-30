local M = {}

-- Check if Mousetrap is already running
function M.checkRunning()
	local success = os.execute("tmux has-session -t Mousetrap 2>/dev/null")
	return success
end

function M.start ()
	require("mousetrap.startMousetrap").start()
end

function M.sendCtrlC()
	local currentLine = 'C-c'
	local consume = false
	local returnOutput = false
	require("mousetrap.sendKeys").sendKeys(consume,returnOutput,currentLine)
end

function M.stop ()
	if M.checkRunning() then
		require("mousetrap.startMousetrap").stop()
	else
		print("Mousetrap not started")
		return
	end
end


-- Add timestamp to buffer
function M.timestamp()
	if M.checkRunning() then
		require("mousetrap.bufferOps").timestamp()
	else
		print("Mousetrap not started")
		return
	end
end


-- Start new tmux window
function M.newWindow(windowName)
	if M.checkRunning() then
		local paneName = "Admin"
		require("mousetrap.windowOps").newWindow(windowName,paneName)
	else
		print("Mousetrap not started")
		return
	end
end

-- Start new tmux pane
function M.newPane(paneName)
	if M.checkRunning() then
		-- calling a new pane, just assume it is for the current window
		local windowName = require("mousetrap.windowOps").activeWindow()
		require("mousetrap.paneOps").newPane(windowName,paneName)
	else
		print("Mousetrap not started")
		return
	end
end

-- Send a command and save the sent line
function M.sendSave()
	if M.checkRunning() then
		require("mousetrap.sendKeys").sendSafe(false,false)
	else
		print("Mousetrap not started")
		return
	end
end

-- Send a command and remove it
function M.sendConsume()
	if M.checkRunning() then
		require("mousetrap.sendKeys").sendSafe(true,false)
	else
		print("Mousetrap not started")
		return
	end
end

-- Turn off the safety checking
function M.safetyToggle()
	if M.checkRunning() then
		require("mousetrap.sendKeys").SafetyToggle()
	else
		print("Mousetrap not started")
		return
	end
end

-- Change the number of lines to cut from the saved output
function M.OutputCut()
	if M.checkRunning() then
		require("mousetrap.logging").OutputCut()
	else
		print("Mousetrap not started")
		return
	end
end


-- Send a command and return the output to your buffer.
function M.sendFetch()
	if M.checkRunning() then
		require("mousetrap.sendKeys").sendSafe(false,true)
		local explanation = "This yaml file was manually "..
		"updated after about one second when the operator "..
		"executed a sendFetch command"
		M.fetchOutput(explanation)
	else
		print("Mousetrap not started")
		return
	end
end

-- Pull the last output to your buffer
function M.fetchOutput()
	if M.checkRunning() then
		local explanation = "This yaml file was manually "..
		"updated by the operator when it appeared that all command output had been returned."
		M.forceUpdate(explanation)
		require("mousetrap.bufferOps").grabLastOutput()
	else
		print("Mousetrap not started")
		return
	end
end

-- Force an update to the command yaml and last command. 
function M.forceUpdate()
	if M.checkRunning() then
		local epochTime = os.time()
		local explanation = "This yaml file was manually "..
		"updated by the operator when it appeared that all command output had been returned."
		require("mousetrap.logging").forceUpdate(explanation)
	else
		print("Mousetrap not started")
		return
	end
end

-- Try to navigate to the pane tag above your cursor in your buffer
function M.smartPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").smartPane()
	else
		print("Mousetrap not started")
		return
	end
end

-- Change tmux focus to another window
function M.changeWindow(targetWindowNumber)
	if M.checkRunning() then
		require("mousetrap.windowOps").changeWindow(targetWindowNumber)
	else
		print("Mousetrap not started")
		return
	end
end

-- Use tmux next-format command
function M.formatWindows()
	if M.checkRunning() then
		require("mousetrap.windowOps").formatWindows()
	else
		print("Mousetrap not started")
		return
	end
end

-- Use tmux to zoom or unzoom on a pane
function M.focusPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").focusPane()
	else
		print("Mousetrap not started")
		return
	end
end

-- Clear the tmux pane
function M.resetPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").resetPane()
	else
		print("Mousetrap not started")
		return
	end
end

function M.nextPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").nextPane()
	else
		print("Mousetrap not started")
		return
	end
end

return M
