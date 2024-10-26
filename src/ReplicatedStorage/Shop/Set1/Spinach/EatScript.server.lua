local Tool = script.Parent

local TIME_BETWEEN_USES = 32
local BEFORE_SOUND_TIME = 0.5
local AFTER_SOUND_TIME = 1.5

local LeftArmMesh = nil
local RightArmMesh = nil

local Anims = {}

local CLOSED_C1 = CFrame.new(-0.6,0,0)

local function Attach(part0, part1, name)
	local motor = Instance.new("Motor6D")
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = CFrame.new()
	motor.C1 = CLOSED_C1
	if name then
		motor.Name = name
	end
	motor.Parent = part0
	return motor
end

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		local character = Tool.Parent
		if character  then
			local humanoid = character:FindFirstChild("Humanoid")
			Tool.Lid.Transparency = 1
			Tool.Lid2.Transparency = 0
			wait(BEFORE_SOUND_TIME)
			if character == Tool.Parent then	-- Check that character is still drinking
			
				local drinkSound = Tool:FindFirstChild('DrinkSound')
				if drinkSound then drinkSound:Play() end
				wait(AFTER_SOUND_TIME)
				local popSize = 3
				local doPop = false
				local Meshes={}
				local Parts = {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand"),character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")}
				for _, Part in pairs(Parts) do
					
					if (not character:FindFirstChild("Fat"..Part.Name)) then
						local newPart = Instance.new("Part")
						newPart.Parent = character
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
						Meshes[character["Fat"..Part.Name]] = character["Fat"..Part.Name].Mesh
					end
					if (Meshes[character["Fat"..Part.Name]].Scale.X >= popSize) then
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
					Tool.Lid.Transparency = 0
					Tool.Lid2.Transparency = 1
					Stop('EquipAnim')
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
					Tool:Destroy()
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
					
					Tool.Lid.Transparency = 0
					Tool.Lid2.Transparency = 1
					Stop('EquipAnim')
					Tool:Destroy()
				end
				
			
			else
				Tool.Enabled = true
			end

		end
	end
end

function OnEquipped()
	--Attach(Tool.Handle, Tool.Lid)
	Stop('EatAnim')
	Play('EquipAnim')
end

function OnUnequipped()
	Stop('EatAnim')
	Stop('EquipAnim')
end
	

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)

