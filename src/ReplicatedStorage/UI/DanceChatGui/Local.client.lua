local Gui = script.Parent
local Event = Gui.Event
local Dialog = Gui.Banner.Dialog

Event.OnClientEvent:Connect(function(...)
	local args={...}
	if (args[1] == "Chat") then
		Gui.Banner.Visible = true
		Dialog.Text = ""
		for i = 1, args[2]:len() do
			Dialog.Text = args[2]:sub(1, i)
			wait(0.035)
		end
	end
end)