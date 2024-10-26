local Player = game.Players.LocalPlayer
local Tool = script.Parent
local Gui = Tool:WaitForChild("PotatoGui")


Tool.Equipped:connect(function()
	
	if (Player.PlayerGui:FindFirstChild(Gui.Name) == nil) then
		local NewGui = Gui:Clone()
		NewGui.Parent = Player.PlayerGui
	end	
	
end)

Tool.Unequipped:connect(function()
	
	if (Player.PlayerGui:FindFirstChild(Gui.Name)) then
		Player.PlayerGui:FindFirstChild(Gui.Name):Destroy()
	end	
	
end)