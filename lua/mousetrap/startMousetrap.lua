local M = {}


function M.stop ()
	os.execute("tmux kill-session -t Mousetrap")
	print("Mousetrap killed")
end





function M.start ()

	if require("mousetrap.init").checkRunning() then
		print("Mousetrap is already running")
		return
	end
	local workDir = require("mousetrap.config").options.workDir
        local scriptDir = workDir .. "/scripts"

        -- create scriptDir
        os.execute("mkdir -p " .. scriptDir )

        local windowName = "LOCAL"
        -- window names all caps
        local paneName = "Admin"
        -- pane names sane letters
        local terminalName = windowName .. "~" .. paneName
        local scriptName = terminalName .. ".script"
        local scriptCommand = "script -af '" .. scriptDir .. "/" .. scriptName .."'"

	-- before I do this, check if it already exists
        os.execute("tmux new-session -d -c " .. workDir ..
			" -n '" .. windowName .. "' -s Mousetrap '" .. scriptCommand .. "'" ..
			"&& tmux set -g pane-border-status top " ..
			"&& tmux set -g allow-rename off" ..
			"&& tmux set -g automatic-rename off")
        require("mousetrap.paneOps").namePane(terminalName)
	print("Starting Mousetrap...")
	vim.g.commandIndex = 0
end


return M


