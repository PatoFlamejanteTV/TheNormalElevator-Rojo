local Network = _G.Local.Network
local Gui = script.Parent
local Frame = Gui:WaitForChild("Frame")

local Yes = Frame:WaitForChild("Yes")
local No = Frame:WaitForChild("No")
local Bar = Frame.Question:WaitForChild("Bar")

local Choice = "NO"
No.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
Yes.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

Yes.MouseButton1Down:Connect(function()
	Choice = "YES"
	Yes.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
	No.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

No.MouseButton1Down:Connect(function()
	Choice = "NO"
	Yes.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	No.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
end)

Network.Pass.Event:Connect(function(...)
	local args = {...}
	if (args[1] == "GetAnswer") then
		Bar:TweenSize(UDim2.new(0,0,1,0), "Out", "Linear", args[2])
		wait(args[2])
		Network:Send("Answer", Choice)
		Gui:Destroy()
	end
end)