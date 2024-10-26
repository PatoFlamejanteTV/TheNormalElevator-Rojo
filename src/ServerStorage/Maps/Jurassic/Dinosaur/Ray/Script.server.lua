local Dino = script.Parent
local doEat = true

function Eat(Character)
	if (Character) and (doEat) then
		doEat = false
		local Humanoid = Character:FindFirstChild("Humanoid") or (Character:FindFirstChild("NPC"))
		local Head = Character:FindFirstChild("Head")
		local HRP = Character:FindFirstChild("HumanoidRootPart")
		
		local Tongue = Dino.Parent:FindFirstChild("Tongue")
		
		if (Humanoid) and (Head) and (HRP) and (Humanoid.Health > 0) and (Tongue) then
			local Weld = Instance.new("Weld", Dino)
			Weld.Part0 = Head
			Weld.Part1 = Tongue
			Weld.C1 = Weld.C1*CFrame.new(0,1,0)*CFrame.fromAxisAngle(Vector3.new(1,0,0),math.rad(90))
			for i = 1, 10 do
				wait(0.5)
				local Blood = Instance.new("Part", Dino)
				Blood.Name = "Blood"
				Blood.Size = Vector3.new(0.6,0.2,0.6)
				Blood.Anchored = false
				Blood.CanCollide = true
				Blood.Color = Color3.new(1,0,0)
				if (Head) then
					Blood.CFrame = CFrame.new(Vector3.new(Head.Position.x+math.random(-10,10),Head.Position.y+10,Head.Position.z+math.random(-10,10)))
				end
			end
		end
		
		if (Humanoid) then
			Humanoid.Health = 0
		end
		
		wait(5)
		doEat = true
	end
end


function onTouched(Part)
	if (Part.Parent) then
		local Humanoid = Part.Parent:FindFirstChild("Humanoid") or (Part.Parent:FindFirstChild("NPC"))
		if (Humanoid) then
			if (Part.Parent:FindFirstChild("Head")) then
				Part.Parent.Head.Anchored = false
				Eat(Part.Parent)
			end
		end
	end
end

Dino.Touched:connect(onTouched)