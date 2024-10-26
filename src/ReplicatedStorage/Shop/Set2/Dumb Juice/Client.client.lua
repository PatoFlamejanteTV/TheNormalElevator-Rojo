local Player = game.Players.LocalPlayer
local Tool = script.Parent
local Gui = Tool:WaitForChild("DrinkGui")

local dontClone = false

Tool.Equipped:connect(function()
	
	if (Player.PlayerGui:FindFirstChild(Gui.Name) == nil) and (dontClone==false) then
		local NewGui = Gui:Clone()
		NewGui.Parent = Player.PlayerGui
		
		NewGui.Hint.MouseEnter:Connect(function()
			NewGui.Hint.BackgroundColor3 = Color3.new(1,0,0)
		end)
		
		NewGui.Hint.MouseLeave:Connect(function()
			NewGui.Hint.BackgroundColor3 = Color3.new(0,0,0)
		end)
		
		NewGui.Hint.MouseButton1Down:Connect(function()
			NewGui:Destroy()
			dontClone = true
		end)
	end	
	
end)

Tool.Unequipped:connect(function()
	
	if (Player.PlayerGui:FindFirstChild(Gui.Name)) then
		Player.PlayerGui:FindFirstChild(Gui.Name):Destroy()
	end	
	
end)