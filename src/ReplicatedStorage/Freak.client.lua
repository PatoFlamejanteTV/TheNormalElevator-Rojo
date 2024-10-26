local Client = _G.Local:Load("Client")
local UI = _G.Local:Load("UI")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local bodyParts = {"HumanoidRootPart","UpperTorso","LowerTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
local freakSound = script:WaitForChild("FreakSound")


function recurse(root,callback,i)
	i= i or 0
	for _,v in pairs(root:GetChildren()) do
		i = i + 1
		callback(i,v)
		
		if #v:GetChildren() > 0 then
			i = recurse(v,callback,i)
		end
	end
	
	return i
end

local function ragdollCharacter(pCharacter)
	pCharacter.Archivable = true
	Client:hideName(pCharacter, true)
	local fakeCharacter = pCharacter:Clone()
	pCharacter.Archivable = false
	fakeCharacter.Parent = pCharacter.Parent
	fakeCharacter:SetPrimaryPartCFrame(fakeCharacter.PrimaryPart.CFrame)
	fakeCharacter.Name = "Ragdoll"
	Client:hideCharacter(pCharacter)
	
	
	--Helps to fix constraint spasms
	local function ragdollJoint(part0, part1, attachmentName, className, properties)
		attachmentName = attachmentName.."RigAttachment"
		local constraint = Instance.new(className.."Constraint")
		constraint.Attachment0 = part0:FindFirstChild(attachmentName)
		constraint.Attachment1 = part1:FindFirstChild(attachmentName)
		constraint.Name = "RagdollConstraint"..part1.Name
		
		for _,propertyData in next,properties or {} do
			constraint[propertyData[1]] = propertyData[2]
		end
		
		constraint.Parent = fakeCharacter
	end

	local function getAttachment0(attachmentName)
		for _,child in next,fakeCharacter:GetChildren() do
			local attachment = child:FindFirstChild(attachmentName)
			if attachment then
				return attachment
			end
		end
	end
	recurse(fakeCharacter, function(_,v)
		if v:IsA("Attachment") then
			v.Axis = Vector3.new(0, 1, 0)
			v.SecondaryAxis = Vector3.new(0, 0, 1)
			v.Rotation = Vector3.new(0, 0, 0)
		end
	end)
	
	--Re-attach hats
	for _,child in next,fakeCharacter:GetChildren() do
		if child:IsA("Accoutrement") then
			--Loop through all parts instead of only checking for one to be forwards-compatible in the event
			--ROBLOX implements multi-part accessories
			for _,part in next,child:GetChildren() do
				if part:IsA("BasePart") then
					local attachment1 = part:FindFirstChildOfClass("Attachment")
					local attachment0 = getAttachment0(attachment1.Name)
					if attachment0 and attachment1 then
						--Shouldn't use constraints for this, but have to because of a ROBLOX idiosyncrasy where
						--joints connecting a character are perpetually deleted while the character is dead
						local constraint = Instance.new("HingeConstraint")
						constraint.Attachment0 = attachment0
						constraint.Attachment1 = attachment1
						constraint.LimitsEnabled = true
						constraint.UpperAngle = 0 --Simulate weld by making it difficult for constraint to move
						constraint.LowerAngle = 0
						constraint.Parent = fakeCharacter
					end
				end
			end
		end
	end
	
	ragdollJoint(fakeCharacter.LowerTorso, fakeCharacter.UpperTorso, "Waist", "BallSocket", {
		{"LimitsEnabled",true};
		{"UpperAngle",5};
	})
	ragdollJoint(fakeCharacter.UpperTorso, fakeCharacter.Head, "Neck", "BallSocket", {
		{"LimitsEnabled",true};
		{"UpperAngle",15};
	})
	
	local handProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle",0};
		{"LowerAngle",0};
	}
	ragdollJoint(fakeCharacter.LeftLowerArm, fakeCharacter.LeftHand, "LeftWrist", "Hinge", handProperties)
	ragdollJoint(fakeCharacter.RightLowerArm, fakeCharacter.RightHand, "RightWrist", "Hinge", handProperties)
	
	local shinProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle", 0};
		{"LowerAngle", -75};
	}
	ragdollJoint(fakeCharacter.LeftUpperLeg, fakeCharacter.LeftLowerLeg, "LeftKnee", "Hinge", shinProperties)
	ragdollJoint(fakeCharacter.RightUpperLeg, fakeCharacter.RightLowerLeg, "RightKnee", "Hinge", shinProperties)
	
	local footProperties = {
		{"LimitsEnabled", true};
		{"UpperAngle", 15};
		{"LowerAngle", -45};
	}
	ragdollJoint(fakeCharacter.LeftLowerLeg, fakeCharacter.LeftFoot, "LeftAnkle", "Hinge", footProperties)
	ragdollJoint(fakeCharacter.RightLowerLeg, fakeCharacter.RightFoot, "RightAnkle", "Hinge", footProperties)
	
	--TODO fix ability for socket to turn backwards whenn ConeConstraints are shipped
	ragdollJoint(fakeCharacter.UpperTorso, fakeCharacter.LeftUpperArm, "LeftShoulder", "BallSocket")
	ragdollJoint(fakeCharacter.LeftUpperArm, fakeCharacter.LeftLowerArm, "LeftElbow", "BallSocket")
	ragdollJoint(fakeCharacter.UpperTorso, fakeCharacter.RightUpperArm, "RightShoulder", "BallSocket")
	ragdollJoint(fakeCharacter.RightUpperArm, fakeCharacter.RightLowerArm, "RightElbow", "BallSocket")
	ragdollJoint(fakeCharacter.LowerTorso, fakeCharacter.LeftUpperLeg, "LeftHip", "BallSocket")
	ragdollJoint(fakeCharacter.LowerTorso, fakeCharacter.RightUpperLeg, "RightHip", "BallSocket")
	
	local BT = Instance.new("BodyThrust", fakeCharacter.UpperTorso)
	BT.Location = fakeCharacter.PrimaryPart.Position
	BT.Force = Vector3.new(10,0,10)
	
	for _, Part in pairs(fakeCharacter:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.CanCollide = true
		end
	end
	
	return fakeCharacter
end

local chars = {}
local fakechars = {}

freakSound:Play()
game.StarterGui:SetCoreGuiEnabled("Chat", false)
for _, pCharacter in pairs(game.Workspace:GetChildren()) do
	if (game.Players:GetPlayerFromCharacter(pCharacter)) and (pCharacter~=Character)  then
		chars[#chars+1] = pCharacter
		fakechars[#fakechars+1] = ragdollCharacter(pCharacter)
		wait()
		fakechars[#fakechars]:BreakJoints()
	end
end
wait(5)
game.StarterGui:SetCoreGuiEnabled("Chat", true)
freakSound:Stop()
for _, pCharacter in pairs(chars) do
	if (pCharacter) then
		if (UI.SETTINGS.HIDE_PLAYERS==false) then
			Client:hideCharacter(pCharacter, 0)
		end
		if (UI.SETTINGS.HIDE_NAMETAGS==false) then
			Client:hideName(pCharacter, false)
		end
		
	end
end
for _, Fake in pairs(fakechars) do
	Fake:Destroy()
end
