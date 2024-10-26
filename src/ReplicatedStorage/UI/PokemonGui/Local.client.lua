local Network = _G.Local.Network
local Gui = script.Parent
local Frame = Gui:WaitForChild("Frame")
local Time = Frame:WaitForChild("Time")
local Bar = Time:WaitForChild("Bar")
local Choice

for _, attackButton in pairs(Frame:GetChildren()) do
	if (attackButton:IsA("TextButton")) then
		attackButton.MouseButton1Down:Connect(function()
			Choice = attackButton.Text
		end)
	end
end

Network.Pass.Event:Connect(function(...)
	local args = {...}
	if (args[1] == "GetAttack") then
		Bar:TweenSize(UDim2.new(0,0,1,0), "Out", "Linear", args[2])
		wait(args[2])
		Network:Send("Attack", Choice)
		Gui:Destroy()
	end
end)