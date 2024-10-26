local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Character

Tool.Equipped:Connect(function()
	Character = Tool.Parent
	local Head = Character:FindFirstChild("Head")
	local Humanoid = Character:FindFirstChild("Humanoid")
	if (Character) and (Head) and (Humanoid) then
		local newHandle = Handle:Clone()
		newHandle.Parent = Character
		local Weld = Instance.new("Weld", newHandle)
		Weld.Part0 = Head
		Weld.Part1 = newHandle
		--Weld.C0 = CFrame.new(0,Head.Mesh.Offset.Y+Head.Mesh.Scale.Y/2,0)
		newHandle.Eat.Disabled = false
		wait()
		Tool:Destroy()
	end
end)