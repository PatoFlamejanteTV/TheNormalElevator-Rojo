local Network = _G.Modules:Load("Network")

local Functions = {}

function Functions:RandomizeTable(Table)
	for i = 1, #Table - 1 do
        local r = math.random(i, #Table)
        Table[i], Table[r] = Table[r] ,Table[i]
	end
end

function Functions:GetObjectFromTable(Table, MyObject)
	local ThisObject = nil
	local ThisIndex = nil
	for Index, Object in pairs(Table) do
		if (Object == MyObject) then
			ThisObject = Object
			ThisIndex = Index
		end
	end
	return ThisObject, ThisIndex
end

function Functions:recurseFunctionOnParts(func, Model)
	if (type(Model)~="table") and (Model:IsA("Model")) then
		for _, Part in pairs(Model:GetChildren()) do
			if (Part:IsA("BasePart")) or (Part:IsA("UnionOperation")) then
				func(Part)
			else
				Functions:recurseFunctionOnParts(func, Part)
			end
		end
	elseif (type(Model) == "table") then
		for _, Part in pairs(Model) do
			if (Part:IsA("BasePart")) or (Part:IsA("UnionOperation")) then
				func(Part)
			else
				Functions:recurseFunctionOnParts(func, Part)
			end
		end
	end
end

function Functions:addWeight(Model, Size)
	if (Model.PrimaryPart) then
		local Weight = game.ReplicatedStorage:FindFirstChild("Weight"):Clone()
		Weight.Parent = Model
		Weight.CFrame = Model.PrimaryPart.CFrame
		if (Size) then
			Weight.Size = Vector3.new(Size, Size, Size)
		else
			Weight.Size = Vector3.new(12,12,12)
		end
		local Motor = Instance.new("Motor6D", Weight)
		Motor.Part0 = Weight
		Motor.Part1 = Model.PrimaryPart
	end
end

function Functions:getPropertiesFromSound(Sound)
	local Properties = {PlaybackSpeed = Sound.PlaybackSpeed, RollOffMode = Sound.RollOffMode, SoundId = Sound.SoundId, TimePosition = Sound.TimePosition, Volume = Sound.Volume, SongName = Sound:GetAttribute("SongName")}
	return Properties
end

function Functions:getPropertiesFromLight(Light)
	local Properties = {Angle = Light.Angle, Brightness = Light.Brightness, Color = Light.Color, Range = Light.Range, Shadows = Light.Shadows, Enabled = Light.Enabled}
	return Properties
end

function Functions:getPropertiesFromPart(Part, ignoreList)
	local Properties = {Color = Part.Color, Material = Part.Material, Reflectance = Part.Reflectance, Transparency = Part.Transparency, Size = Part.Size, CFrame = Part.CFrame, RotVelocity = Part.RotVelocity, Velocity = Part.Velocity, Anchored = Part.Anchored, CanCollide = Part.CanCollide}
	if (ignoreList) then
		for _, Prop in pairs(ignoreList) do
			if (Properties[Prop]) then Properties[Prop] = nil end
		end
	end
	return Properties
end

function Functions:hideCharacter(Character, Trans)
	local N = Trans~=nil and Trans or 1
	local function hidePart(Part)
		if (Part.Name~="HumanoidRootPart") then
			Part.Transparency = N
			for _, Decal in pairs(Part:GetChildren()) do
				if (Decal:IsA("Decal")) then
					Decal.Transparency = N
				end
			end
		end
	end
	for _, Accessory in pairs(Character:GetChildren()) do
		if (Accessory:IsA("Accessory")) then
			Accessory.Handle.Transparency = N
		end
	end
	Functions:recurseFunctionOnParts(hidePart, Character)
end

function Functions:characterIsValid(Character)
	local valid = false
	if (Character) then
		local Humanoid = Functions:getHumanoid(Character)
		local Player = game.Players:GetPlayerFromCharacter(Character)
		local HRP = Character:FindFirstChild("HumanoidRootPart")
		if (Humanoid) and (HRP) and (Player) and (Humanoid.Health > 0) then
			valid = Character
		end
	end
	return valid
end

function Functions:getHumanoid(Object)
	local humanoid = nil
	for _, Human in pairs(Object:GetChildren()) do
		if (Human:IsA("Humanoid")) then
			humanoid = Human
		end
	end
	return humanoid
end

function Functions:getToolFromPlayer(Player, toolName)
	local Backpack = Player.Backpack
	local Character = Player.Character
	local tool = nil
	for _, T in pairs(Backpack:GetChildren()) do
		if (T:IsA("Tool")) and (T.Name == toolName) then
			tool = T
		end
	end
	if (Character) then
		for _, T in pairs(Character:GetChildren()) do
			if (T:IsA("Tool")) and (T.Name == toolName) then
				tool = T
			end
		end
		
	end
	return tool
end

function Functions:disconnectTableEvents(Table)
	for _, Event in pairs(Table) do
		Event:Disconnect()
	end
	return {}
end

function Functions:weld(Model, doWeld)
	local PrimaryPart = Model.PrimaryPart
	if (not PrimaryPart) then
		local found = false
		for _, P in pairs(Model:GetChildren()) do
			if (P:IsA("BasePart")) and (not found) then
				found = true
				PrimaryPart = P
			end
		end
	end
	local function weldPart(Part)
		if (Part ~= PrimaryPart) then
			local Weld = Instance.new("Weld", PrimaryPart)
			Weld.Part0 = PrimaryPart
			Weld.Part1 = Part
			Weld.C0 = PrimaryPart.CFrame:inverse()
			Weld.C1 = Part.CFrame:inverse()
		end
	end
	local function destroyWelds()
		for _, Weld in pairs(PrimaryPart:GetChildren()) do
			if (Weld:IsA("Weld")) then
				Weld:Destroy()
			end
		end
	end
	if (doWeld) then 
		Functions:recurseFunctionOnParts(weldPart, Model)
	else
		destroyWelds()
	end
	
end

function Functions:anchor(Model, doAnchor)
	local function anchorPart(Part)
		Part.Anchored = doAnchor
	end
	Functions:recurseFunctionOnParts(anchorPart, Model)
end

function Functions:setPartsCollision(Model, Collide)
	local function collidePart(Part)
		Part.CanCollide = Collide
	end
	if (Collide) then
		Functions:recurseFunctionOnParts(collidePart, Model)
	end
end

function Functions:teleportPlayer(Player, Destination, Transition, Delay)
	local Character = Player.Character
	if (Functions:characterIsValid(Character)) then
		if (Transition) then
			Network:Send(Player, "FadeBlack", 0, 1, true, Delay)
			wait(Delay)
		end
		if (Character.PrimaryPart) then
			Character:SetPrimaryPartCFrame(Destination)
		end
	elseif (Character) and (Character.PrimaryPart) and (not Character:FindFirstChild("HumanoidRootPart")) then
		Character:SetPrimaryPartCFrame(Destination)
	end
end

local RootLimbData = {
	{
		["WeldTo"]			= "LowerTorso",
		["WeldRoot"]		= "HumanoidRootPart",
		["AttachmentName"]	= "Root",
		["NeedsCollider"]	= false,
		["UpperAngle"]		= 10
	},
	{
		["WeldTo"]			= "UpperTorso",
		["WeldRoot"]		= "LowerTorso",
		["AttachmentName"]	= "Waist",
		["ColliderOffset"]	= CFrame.new(0, 0.5, 0),
		["UpperAngle"]		= 0
	},
	{
		["WeldTo"]			= "Head",
		["WeldRoot"]		= "UpperTorso",
		["AttachmentName"]	= "Neck",
		["ColliderOffset"]	= CFrame.new(),
		["UpperAngle"]		= 20
	},
	{
		["WeldTo"]			= "LeftUpperLeg",
		["WeldRoot"]		= "LowerTorso",
		["AttachmentName"]	= "LeftHip",
		["ColliderOffset"]	= CFrame.new(0, -0.5, 0)
	},
	{
		["WeldTo"]			= "RightUpperLeg",
		["WeldRoot"]		= "LowerTorso",
		["AttachmentName"]	= "RightHip",
		["ColliderOffset"]	= CFrame.new(0, -0.5, 0)
	},
	{
		["WeldTo"]			= "RightLowerLeg",
		["WeldRoot"]		= "RightUpperLeg",
		["AttachmentName"]	= "RightKnee",
		["ColliderOffset"]	= CFrame.new(0, -0.5, 0)
	},
	{
		["WeldTo"]			= "LeftLowerLeg",
		["WeldRoot"]		= "LeftUpperLeg",
		["AttachmentName"]	= "LeftKnee",
		["ColliderOffset"]	= CFrame.new(-0.05, -0.5, 0)
	},
	{
		["WeldTo"]			= "RightUpperArm",
		["WeldRoot"]		= "UpperTorso",
		["AttachmentName"]	= "RightShoulder",
		["ColliderOffset"]	= CFrame.new(0.05, 0.45, 0.15),
	},
	{
		["WeldTo"]			= "LeftUpperArm",
		["WeldRoot"]		= "UpperTorso",
		["AttachmentName"]	= "LeftShoulder",
		["ColliderOffset"]	= CFrame.new(0, 0.45, 0.15),
	},
	{
		["WeldTo"]			= "LeftLowerArm",
		["WeldRoot"]		= "LeftUpperArm",
		["AttachmentName"]	= "LeftElbow",
		["ColliderOffset"]	= CFrame.new(0, 0.125, 0),
		["UpperAngle"]		= 10
	},
	{
		["WeldTo"]			= "RightLowerArm",
		["WeldRoot"]		= "RightUpperArm",
		["AttachmentName"]	= "RightElbow",
		["ColliderOffset"]	= CFrame.new(0, 0.125, 0),
		["UpperAngle"]		= 10
	},
	{
		["WeldTo"]			= "RightHand",
		["WeldRoot"]		= "RightLowerArm",
		["AttachmentName"]	= "RightWrist",
		["ColliderOffset"]	= CFrame.new(0, 0.125, 0),
		["UpperAngle"]		= 0
	},
	{
		["WeldTo"]			= "LeftHand",
		["WeldRoot"]		= "LeftLowerArm",
		["AttachmentName"]	= "LeftWrist",
		["ColliderOffset"]	= CFrame.new(0, 0.125, 0),
		["UpperAngle"]		= 0
	},
	{
		["WeldTo"]			= "LeftFoot",
		["WeldRoot"]		= "LeftLowerLeg",
		["AttachmentName"]	= "LeftAnkle",
		["NeedsCollider"]	= false,
		["UpperAngle"]		= 0
	},
	{
		["WeldTo"]			= "RightFoot",
		["WeldRoot"]		= "RightLowerLeg",
		["AttachmentName"]	= "RightAnkle",
		["NeedsCollider"]	= false,
		["UpperAngle"]		= 0
	},
}

local RootPart = nil
local MotorList = {}
local GlueList = {}
local ColliderList = {}

function Functions:ragdollCharacter(char)
	if (Functions:characterIsValid(char)) then
		print"pls"
		pcall(function()
			local Character = char
			local Humanoid = char:FindFirstChildOfClass("Humanoid")
			local HumanoidRoot = char:FindFirstChild("HumanoidRootPart")
			if ( HumanoidRoot == nil ) then
				return
			end
			print"okay"
			local Position = char.HumanoidRootPart.Position
			Humanoid.PlatformStand = true
			
			-- Handle death specific ragdoll. Will Clone you, then destroy you.
			local RagDollModel = Character
			
			-- Reglue The Character
			for i=1,#RootLimbData do
				local limbData = RootLimbData[i];
				local partName = limbData["WeldTo"];
				local weldName = limbData["WeldRoot"];
				local PartTo = RagDollModel:FindFirstChild(partName);
				local WeldTo = RagDollModel:FindFirstChild(weldName);
				
				if ( PartTo ~= nil and WeldTo ~= nil ) then
					if ( RagDollModel ~= nil ) then
						if ( script.ApplyRandomVelocity.Value ) then
							local scale = script.ApplyRandomVelocity.Force.Value;
							local vecX = (math.random()-math.random())*scale;
							local vecY = (math.random()-math.random())*scale;
							local vecZ = (math.random()-math.random())*scale;
							PartTo.Velocity = PartTo.Velocity + Vector3.new(vecX, vecY, vecZ);
						end
						PartTo.Parent = RagDollModel;
					end
					-- Create New Constraint
					local UpperAngle = limbData["UpperAngle"];
					local Joint = Instance.new("BallSocketConstraint");
					if ( (UpperAngle ~= nil and UpperAngle == 0) or (script.WeldHead.Value and partName == "Head") ) then
						Joint = Instance.new("HingeConstraint");
						Joint.UpperAngle = 0;
						Joint.LowerAngle = 0;
					end
					Joint.Name = limbData["AttachmentName"];
					Joint.LimitsEnabled = true;
					Joint.Attachment0 = PartTo:FindFirstChild(Joint.Name .. "RigAttachment");
					Joint.Attachment1 = WeldTo:FindFirstChild(Joint.Name .. "RigAttachment");
					Joint.Parent = PartTo;
					GlueList[#GlueList+1] = Joint;
					if ( UpperAngle ~= nil ) then
						Joint.UpperAngle = UpperAngle;
					end
					
					-- Destroy the motor attaching it
					local Motor = PartTo:FindFirstChildOfClass("Motor6D");
					if ( Motor ~= nil ) then
						if ( Humanoid.Health <= 0 ) then
							Motor:Destroy();
						else
							MotorList[#MotorList+1] = { PartTo, Motor };
							Motor.Parent = nil;
						end
					end
					
					-- Create Collider
					local needsCollider = limbData["NeedsCollider"];
					if ( needsCollider == nil ) then
						needsCollider = true;
					end
					if ( needsCollider ) then
						local B = Instance.new("Part");
						B.CanCollide = true;
						B.TopSurface = 0;
						B.BottomSurface = 0;
						B.formFactor = "Symmetric";
						B.Size = Vector3.new(0.7, 0.7, 0.7);
						B.Transparency = 1;
						B.BrickColor = BrickColor.Red();
						B.Parent = RagDollModel;
						local W = Instance.new("Weld");
						W.Part0 = PartTo;
						W.Part1 = B;
						W.C0 = limbData["ColliderOffset"];
						W.Parent = PartTo;
						ColliderList[#ColliderList+1] = B;
					end
				end
			end
			
			-- Destroy Root Part
			local root = Character:FindFirstChild("HumanoidRootPart");
			if ( root ~= nil ) then
				RootPart = root;
				if ( Humanoid.Health <= 0 ) then
					RootPart:Destroy();
				else
					RootPart.Parent = nil;
				end
			end	
			
			-- Delete all my parts if we made a new ragdoll
			if ( RagDollModel ~= Character ) then
				print("Deleting character");
				local children = Character:GetChildren();
				for i=1,#children do
					local child = children[i];
					if ( child:IsA("BasePart") or child:IsA("Accessory") ) then
						child:Destroy();
					end
				end
			end
			
		end)
	end
	
end

function Functions:fireFunctionForMultiplePlayers(func, Params, Players)
	for _, Player in pairs(Players) do
		func(unpack(Params))
	end
end

return Functions