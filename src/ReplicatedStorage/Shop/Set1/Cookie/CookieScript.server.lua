local Tool = script.Parent
local character

local Meshes={}

enabled = true

function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	local Char = Tool.Parent
	local Torso = Char:FindFirstChild("Torso") or Char:FindFirstChild("UpperTorso")
	Tool.GripForward = Vector3.new(0.439, 0.878, 0.189)
	Tool.GripPos = Vector3.new(-0.3, 1.2, -1.3)
	Tool.GripRight = Vector3.new(0.0844, 0.169, -0.982)
	Tool.GripUp = Vector3.new(0.894, -0.347, 0)


	Tool.Handle.EatSound:Play()

	script.Parent.Bites.Value = script.Parent.Bites.Value + 1
	wait(.8)
	
	if (script.Parent.Bites.Value == 3) then
		local popSize = 2
		local doPop = false
		local Parts = {Char:FindFirstChild("UpperTorso")}
		for _, Part in pairs(Parts) do
			
			if (not Char:FindFirstChild("Fat"..Part.Name)) then
				local newPart = Instance.new("Part")
				newPart.Parent = Char
				newPart.CanCollide = false
				newPart.Anchored = false
				newPart.Name = "Fat"..Part.Name
				newPart.Size = Part.Size
				newPart.CFrame = Part.CFrame
				newPart.Color = Part.Color
				newPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
				newPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
				
				local newMesh = Instance.new("SpecialMesh")
				newMesh.Parent = newPart
				newMesh.MeshType = Enum.MeshType.Sphere
				
				local newWeld = Instance.new("Weld")
				newWeld.Parent = Part
				newWeld.Part0 = Part
				newWeld.Part1 = newPart
				
				Meshes[newPart] = newMesh
				
			else
				Meshes[Char["Fat"..Part.Name]] = Char["Fat"..Part.Name].Mesh
				for i = 1, 5 do
					for _, Mesh in pairs(Meshes) do
						Mesh.Scale = Mesh.Scale + Vector3.new(0.1,0.1,0.1)
						if (Mesh.Scale.X > popSize) then
							doPop = true
						end
					end
					wait(0.05)
				end
			end
			
			
		end
		if (doPop) then
			for i = 1, 2 do
				for _, Mesh in pairs(Meshes) do
					Mesh.Scale = Mesh.Scale + Vector3.new(0.1,0.1,0.1)
				end
				wait(0.05)
			end
			for _, Part in pairs(Parts) do
				Part:Destroy()
			end
			for Part, Mesh in pairs(Meshes) do
				Part:Destroy()
			end
			if (character.PrimaryPart) and (character.PrimaryPart:FindFirstChild("PopSound")) and (character.PrimaryPart.PopSound:IsA("Sound")) then
				character.PrimaryPart.PopSound:Play()
			elseif (character.PrimaryPart) then
				local Sound = Tool.PopSound:Clone()
				Sound.Parent = character.PrimaryPart
				Sound:Play()
			end
		else
			for i = 1, 10 do
				for _, Mesh in pairs(Meshes) do
					Mesh.Scale = Mesh.Scale + Vector3.new(0.1,0.1,0.1)
					--[[if (Mesh.Scale.X > popSize) then
						Mesh.Scale = Vector3.new(popSize,popSize,popSize*2)
					end]]
				end
				wait(0.05)
			end
		end
		Tool:Destroy()
	end


	Tool.GripForward = Vector3.new(-1, 1, -0)
	Tool.GripPos = Vector3.new(0.1, -0.3, 0)
	Tool.GripRight = Vector3.new(0,0, -1)
	Tool.GripUp = Vector3.new(1,0,0)


	enabled = true

end

Tool.Equipped:Connect(function()
	character = Tool.Parent
end)

script.Parent.Activated:connect(onActivated)