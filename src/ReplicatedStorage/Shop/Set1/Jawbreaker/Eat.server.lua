local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local ready = true

local popSize = 3

Tool.Activated:Connect(function()
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Head = Character:FindFirstChild("Head")
	if (Character) and (Humanoid) and (Head) then
		if (ready) then
			ready = false
			local fakeHandle = Handle:Clone()
			fakeHandle.Parent = Character
			Handle.Transparency = 1
			local fakeWeld = Instance.new("Weld", fakeHandle)
			fakeWeld.Part0 = Head
			fakeWeld.Part1 = fakeHandle
			--fakeWeld.C0 = CFrame.new(0,Head.Mesh.Offset.Y,-Head.Mesh.Scale.X/2)
			wait(0.8)
			fakeHandle:Destroy()
			if (Head) then
				local Meshes = {}
				for _, charHead in pairs(Character:GetChildren()) do
					if (charHead==Head) or (charHead.Name == "FakeHead") then
						if (charHead.Name=="FakeHead") then
							charHead.Mesh.Scale = charHead.Mesh.Scale+Vector3.new(1.75,1.75,1.75)
						else
							charHead.Size = charHead.Size + Vector3.new(1.75,1.75,1.75)
						end
						
					end
				end
				--Head.Size = Head.Size + Vector3.new(1.75,1.75,1.75)
				--Head.Mesh.Scale = Head.Mesh.Scale + Vector3.new(1.75,1.75,1.75)
				--Head.Transparency = 0
			end
			Tool:Destroy()
		end
	end
	
end)