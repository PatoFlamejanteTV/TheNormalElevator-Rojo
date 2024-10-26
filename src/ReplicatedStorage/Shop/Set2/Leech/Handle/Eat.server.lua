local Character = script.Parent.Parent
local Humanoid = Character:WaitForChild("Humanoid")

script.Parent.Drink:Play()

if (Humanoid.RigType == Enum.HumanoidRigType.R15) then
	local Width = Humanoid:FindFirstChild("BodyWidthScale")
	local Depth = Humanoid:WaitForChild("BodyDepthScale")
	for i = Width.Value, 0.1, -0.1 do
		Width.Value = i
		Depth.Value = i
		wait(0.3)
	end
end

script.Parent:Destroy()