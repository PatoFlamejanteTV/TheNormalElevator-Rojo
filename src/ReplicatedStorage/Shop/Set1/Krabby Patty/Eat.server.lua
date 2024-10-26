local Tool = script.Parent
local Char


enabled = true

function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	local Char = Tool.Parent
	local Humanoid = Char:FindFirstChild("Humanoid")
	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(-0.5, -0.8, -1.5)
	Tool.GripRight = Vector3.new(0,0, -1)
	Tool.GripUp = Vector3.new(0, 1, 0)


	Tool.Handle.EatSound:Play()

	script.Parent.Bites.Value = script.Parent.Bites.Value + 1
	wait(.8)
	
	if (script.Parent.Bites.Value == 3) then
		local popSize = 3
		local doPop = false
		local Meshes={}
		local Parts = {Char:FindFirstChild("LeftLowerLeg"),Char:FindFirstChild("LeftUpperLeg"),Char:FindFirstChild("LeftFoot"),Char:FindFirstChild("RightLowerLeg"),Char:FindFirstChild("RightUpperLeg"),Char:FindFirstChild("RightFoot")}
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
			end
			if (Meshes[Char["Fat"..Part.Name]].Scale.X >= popSize) then
				doPop = true
			end
		end
		if (doPop) then
			for i = 1, 2 do
				for Part, Mesh in pairs(Meshes) do
					Mesh.Scale = Mesh.Scale + Vector3.new(0.15,0.15,0.15)
				end
				wait(0.1)
			end
			for _, Part in pairs(Parts) do
				Part:Destroy()
			end
			for Part, Mesh in pairs(Meshes) do
				Part:Destroy()
			end
			Humanoid.HipHeight = 0.01
			if (Char.PrimaryPart) and (Char.PrimaryPart:FindFirstChild("PopSound")) and (Char.PrimaryPart.PopSound:IsA("Sound")) then
				Char.PrimaryPart.PopSound:Play()
			elseif (Char.PrimaryPart) then
				local Sound = Tool.PopSound:Clone()
				Sound.Parent = Char.PrimaryPart
				Sound:Play()
			end
		else
			for i = 1, 5 do
				for Part, Mesh in pairs(Meshes) do
					Mesh.Scale = Mesh.Scale + Vector3.new(0.15,0.15,0.15)
					if (Mesh.Scale.X > popSize) then
						Mesh.Scale = Vector3.new(popSize,popSize,popSize)
					end
				end
				wait(0.1)
			end
		end
	
		Tool:Destroy()
	end


	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripPos = Vector3.new(0.1, -0.6, -0.1)
	Tool.GripRight = Vector3.new(0,0, -1)
	Tool.GripUp = Vector3.new(0, 1, 0)


	enabled = true

end

Tool.Equipped:Connect(function()
	Char = Tool.Parent
end)

script.Parent.Activated:connect(onActivated)