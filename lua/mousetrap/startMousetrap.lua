local M = {}


function M.stop ()
	os.execute("tmux kill-session -t Mousetrap")
end





function M.start ()
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
			" -n '" .. windowName .. "' -s Mousetrap '" .. scriptCommand .. "'")
        require("mousetrap.paneOps").namePane(terminalName)
	print("Starting Mousetrap...")
	vim.g.commandIndex = 0
end


return M


