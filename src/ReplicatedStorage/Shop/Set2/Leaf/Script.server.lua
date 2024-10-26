local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Debounce = true

local MAX_CLICK = 5
local INC_SIZE = 0.5

local Clicks = 0


Tool.Equipped:connect(function()
	local Character = Tool.Parent
	if (Character:FindFirstChild("GiraffeHead") == nil) then
		Clicks = 0
	end
end)

Tool.Activated:connect(function()
	local Character = Tool.Parent
	local Head = Character:FindFirstChild("Head")
	local fakeHead
	local giraffeHead
	
	if (Character) and (Character:FindFirstChild("Humanoid")) and (Head) then
		if (Debounce == true) then
			Debounce = false
			
			Clicks = Clicks + 1
			
			local fakeLeaf = Handle:Clone()
			fakeLeaf.Parent = Character 
			Handle.Transparency = 1
			local leafWeld = Instance.new("Weld", fakeLeaf)
			leafWeld.Part0 = Head
			leafWeld.Part1 = fakeLeaf
			--leafWeld.C0 = CFrame.new(0,Head.Mesh.Offset.Y,-Head.Mesh.Scale.X/2) * CFrame.Angles(math.pi/2,0,0)
			
			if (Clicks == 1) and (Character:FindFirstChild("GiraffeHead") == nil) then
				fakeHead = Instance.new("Part")
				fakeHead.Name = "FakeHead"
				fakeHead.CanCollide = false
				fakeHead.Size = Head.Size
				fakeHead.Color = Head.Color
				fakeHead.Anchored=false
				fakeHead.Parent = Character
				
				local Weld = Instance.new("Weld", Head)
				Weld.Part0=Head
				Weld.Part1=fakeHead
				
				for _, decal in pairs(Head:GetChildren()) do
					if (decal:IsA("Decal")) then
						decal:Clone().Parent = fakeHead
						decal.Transparency = 1
					end
				end
				
				giraffeHead = Instance.new("Part")
				giraffeHead.Name = "GiraffeHead"
				giraffeHead.CanCollide = false
				giraffeHead.Size = Head.Size
				giraffeHead.Color = Head.Color
				giraffeHead.Anchored=false
				giraffeHead.Parent = Character
				
				local giraffeMesh = Instance.new("SpecialMesh", giraffeHead)
				giraffeMesh.MeshType = Enum.MeshType.FileMesh
				giraffeMesh.MeshId = Head.MeshId
				giraffeMesh.TextureId = Head.TextureID
				giraffeMesh.Name = "Mesh"
				giraffeMesh.Scale = Vector3.new(0.9,1,0.9)
				
				
				local fakeMesh = Instance.new("SpecialMesh", fakeHead)
				fakeMesh.MeshType = Enum.MeshType.FileMesh
				fakeMesh.MeshId = Head.MeshId
				fakeMesh.TextureId = Head.TextureID
				fakeMesh.Name = "Mesh"
				fakeMesh.Scale = Vector3.new(0.9,1,0.9)
				
				--FakeHead = Head:Clone()
				--FakeHead.Name = "GiraffeHead"
				--FakeHead.Parent = Character
				--FakeHead.CanCollide = false
				Head.Transparency = 1
				local Weld = Instance.new("Weld", Head)
				Weld.Part0 = Head
				Weld.Part1 = giraffeHead
				
				
				
			elseif (Character:FindFirstChild("GiraffeHead")) then
				giraffeHead = Character.GiraffeHead
				fakeHead = Character.FakeHead
			end
			wait(0.4)
			fakeLeaf:Destroy()
			if (Clicks <= 5) then
				for i = 1, INC_SIZE*10, INC_SIZE do
					
					
					--Head.Mesh.Scale = Head.Mesh.Scale + Vector3.new(0, INC_SIZE/10, 0)
					if (Clicks < 5) then
						if (not Head) then return end
						
						--fakeHead.Mesh.Scale = fakeHead.Mesh.Scale + Vector3.new(0, INC_SIZE/10, 0)
						fakeHead.Mesh.Offset = fakeHead.Mesh.Offset + Vector3.new(0, (INC_SIZE/10), 0)
						
						giraffeHead.Mesh.Scale = giraffeHead.Mesh.Scale + Vector3.new(0, INC_SIZE/10, 0)
						giraffeHead.Mesh.Offset = giraffeHead.Mesh.Offset + Vector3.new(0, (INC_SIZE/10)/2, 0)
						for _, Hat in pairs(Character:GetChildren()) do
							if (Hat:IsA("Accessory")) and (Hat:FindFirstChild("Handle")) then
								if (Hat.AccessoryType == Enum.AccessoryType.Hat) or (Hat.AccessoryType==Enum.AccessoryType.Face) or (Hat.AccessoryType==Enum.AccessoryType.Hair) or (Hat.AccessoryType==Enum.AccessoryType.Neck) then
									for _, Weld in pairs(Hat.Handle:GetChildren()) do
										if (Weld:IsA("Weld")) or (Weld:IsA("WeldConstriant")) then
											Weld.C0 = Weld.C0 * CFrame.new(0, -INC_SIZE/10, 0)
										end
									end
								end
							end
						end
					elseif (Clicks >= 5) then
						if (not Head) then return end

						--fakeHead.Mesh.Scale = fakeHead.Mesh.Scale + Vector3.new(0, INC_SIZE/4, 0)
						fakeHead.Mesh.Offset = fakeHead.Mesh.Offset + Vector3.new(0, (INC_SIZE/4), 0)
						
						giraffeHead.Mesh.Scale = giraffeHead.Mesh.Scale + Vector3.new(0, INC_SIZE/4, 0)
						giraffeHead.Mesh.Offset = giraffeHead.Mesh.Offset + Vector3.new(0, (INC_SIZE/4)/2, 0)
						for _, Hat in pairs(Character:GetChildren()) do
							if (Hat:IsA("Accessory")) and (Hat:FindFirstChild("Handle")) then
								if (Hat.AccessoryType == Enum.AccessoryType.Hat) or (Hat.AccessoryType==Enum.AccessoryType.Face) or (Hat.AccessoryType==Enum.AccessoryType.Hair) or (Hat.AccessoryType==Enum.AccessoryType.Neck) then
									for _, Weld in pairs(Hat.Handle:GetChildren()) do
										if (Weld:IsA("Weld")) or (Weld:IsA("WeldConstriant")) then
											Weld.C0 = Weld.C0 * CFrame.new(0, -INC_SIZE/4, 0)
										end
									end
								end
							end
						end
					end
					wait(0.05)
				end
				if (Clicks == 5) then
					Tool:Destroy()
				end
			end
			Handle.Transparency = 0
			Debounce = true
		end
	end
	
	
	
end)