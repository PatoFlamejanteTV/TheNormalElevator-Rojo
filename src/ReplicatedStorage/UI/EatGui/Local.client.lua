local Network = _G.Local.Network
local Gui = script.Parent
local Button = Gui:WaitForChild("Eat")

Button.MouseButton1Down:connect(function()
	Network:Send("EatFood")
	Button.Image = "rbxassetid://273168234"
	local thread = coroutine.create(function()
		Button.Image = "rbxassetid://273168259"
		wait(0.05)
		Button.Image = "rbxassetid://273168234"
	end)
	coroutine.resume(thread)
end)