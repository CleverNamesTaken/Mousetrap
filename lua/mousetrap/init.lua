local M = {}

function M.checkRunning()
	local result = os.execute("tmux has-session -t Mousetrap 2>/dev/null")
	if result == 0 then
		return true
	else
		return false
	end
	return
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


function M.timestamp()
	if M.checkRunning() then
		require("mousetrap.bufferOps").timestamp()
	else
		print("Mousetrap not started")
		return
	end
end


function M.newWindow(windowName)
	if M.checkRunning() then
		local paneName = "Admin"
		require("mousetrap.windowOps").newWindow(windowName,paneName)
	else
		print("Mousetrap not started")
		return
	end
end

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

function M.sendSave()
	if M.checkRunning() then
		require("mousetrap.sendKeys").sendSafe(false,false)
	else
		print("Mousetrap not started")
		return
	end
end

function M.sendConsume()
	if M.checkRunning() then
		require("mousetrap.sendKeys").sendSafe(true,false)
	else
		print("Mousetrap not started")
		return
	end
end

function M.safetyToggle()
	if M.checkRunning() then
		require("mousetrap.sendKeys").SafetyToggle()
	else
		print("Mousetrap not started")
		return
	end
end

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


function M.smartPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").smartPane()
	else
		print("Mousetrap not started")
		return
	end
end

function M.changeWindow(targetWindowNumber)
	if M.checkRunning() then
		require("mousetrap.windowOps").changeWindow(targetWindowNumber)
	else
		print("Mousetrap not started")
		return
	end
end

function M.formatWindows()
	if M.checkRunning() then
		require("mousetrap.windowOps").formatWindows()
	else
		print("Mousetrap not started")
		return
	end
end

function M.focusPane()
	if M.checkRunning() then
		require("mousetrap.paneOps").focusPane()
	else
		print("Mousetrap not started")
		return
	end
end

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
