--------------------------------------------------------
---------- Version 2.0 ---------------------------------
---------- Released 8/17/2017 --------------------------
---------- Written by orange451 ------------------------
--------------------------------------------------------
wait();

local DEBUG = false;

function waitFor( directory, name ) 
	while ( directory == nil or (name ~= nil and directory:FindFirstChild(name) == nil) ) do
		wait(0.1);
	end
	if ( name == nil ) then
		return directory;
	else
		return directory:FindFirstChild(name);
	end
end

function getCharacter()
	return script.Parent;
end

function getPlayer()
	return game.Players:GetPlayerFromCharacter(getCharacter());
end

function getHumanoid()
	return waitFor( getCharacter(), "Humanoid" );
end

function getNearestPlayer( position )
	local Players = game.Players:GetChildren();
	local dist = math.huge;
	local ret = nil;
	for i=1,#Players do
		local Player = Players[i];
		local Character = Player.Character;
		if ( Character ~= nil ) then
			local Root = Character:FindFirstChild("HumanoidRootPart");
			if ( Root ~= nil ) then
				local t = (position - Root.Position).magnitude;
				if ( t < dist ) then
					dist = t;
					ret = Player;
				end
			end
		end
	end
	
	return ret;
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

local RootPart = nil;
local MotorList = {};
local GlueList = {};
local ColliderList = {};
local DestroyList = {};

function deactivate()
	if ( RootPart == nil ) then
		return;
	end
	
	-- Move to Players Location
	local UpperTorso = getCharacter():FindFirstChild("UpperTorso");
	if ( UpperTorso ~= nil ) then
		UpperTorso:SetNetworkOwner(nil);
		RootPart.CFrame = UpperTorso.CFrame;
	end
	
	-- Replace Motors
	for i=1,#MotorList do
		local MotorData = MotorList[i];
		local PartTo = MotorData[1];
		local Motor = MotorData[2];
		Motor.Parent = PartTo;
	end
	
	-- Remove Glues
	for i=1,#GlueList do
		GlueList[i]:Destroy();
	end
	
	-- Remove Colliders
	for i=1,#ColliderList do
		ColliderList[i]:Destroy();
	end
	
	for i =1, #DestroyList do
		DestroyList[i]:Destroy();
	end
	
	-- Replace Humanoid Stuff
	getHumanoid().PlatformStand = false;
	RootPart.Parent = getCharacter();
	getCharacter().PrimaryPart = RootPart
	
	-- Restart
	MotorList = {};
	GlueList = {};
	DestroyList = {};
	RootPart = nil;
end

function activate()
	local Character = getCharacter();
	local Humanoid = getHumanoid();
	local HumanoidRoot = script.Parent:FindFirstChild("HumanoidRootPart");
	if ( HumanoidRoot == nil ) then
		return;
	end
	local Position = script.Parent.HumanoidRootPart.Position;
	Humanoid.PlatformStand = true;
	
	-- Handle death specific ragdoll. Will Clone you, then destroy you.
	local RagDollModel = Character;
	--[[if ( (Humanoid.Health <= 0) and script.ActivateOnDeath.CloneAndDestroy.Value ) then
		Character:FindFirstChild("HumanoidRootPart"):Destroy();
		Character.Archivable = true;
		RagDollModel = Character:Clone();
		RagDollModel.Name = "RagDoll";
			
		local t = RagDollModel:GetChildren();
		for i=1,#t do
			local t2 = t[i];
			if ( t2:IsA("Script") or t2:IsA("LocalScript") ) then
				t2:Destroy();
			end
		end
		
		spawn(function()
			wait();
			RagDollModel.Humanoid.PlatformStand = true;
			game.Debris:AddItem(RagDollModel, script.ActivateOnDeath.CloneAndDestroy.Delay.Value);
		end)
		
		RagDollModel.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
		RagDollModel.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff;
		RagDollModel.Humanoid.Health = 0;
		RagDollModel.Parent = game.Workspace;
		
		local RagDollPointer = Instance.new("ObjectValue");
		RagDollPointer.Value = RagDollModel;
		RagDollPointer.Name = "RagDoll";
		RagDollPointer.Parent = Character;
	end]]
	
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
				DestroyList[#DestroyList+1] = W
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
	Character.PrimaryPart = Character:FindFirstChild("Head")
	
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
	
	-- Give player physics
	if ( script.GivePlayerPhysics.Value ) then
		local PlayerPhysics = getPlayer();
		if ( script.GivePlayerPhysics.ForceNearestPlayer.Value ) then
			PlayerPhysics = getNearestPlayer( Position );
		end
		
		local Children = RagDollModel:GetChildren();
		for i=1,#Children do
			local Child = Children[i];
			if ( Child:IsA("BasePart") ) then
				Child:SetNetworkOwner(PlayerPhysics);
			end
		end
	end
	
	-- Copy plugins into ragdoll
	local Plugins = script.Plugins:GetChildren();
	for i=1,#Plugins do
		local Plugin = Plugins[i];
		local Copy = Plugin:Clone();
		if ( Copy:IsA("Script") ) then
			Copy.Disabled = false;
		end
		Copy.Parent = RagDollModel;
	end
end

-- Wait for torso (assume everything else will load at the same time)
waitFor( getCharacter(), "UpperTorso" );

-- Activate when we die.
getHumanoid().Died:Connect(function()
	if ( script.ActivateOnDeath.Value ) then
		script.Activate.Value = true;
	end
end);

-- Activate when setting is checked.
script.Activate.Changed:Connect(function(value)
	if ( value ) then
		activate();
	else
		deactivate();
	end
end);

-- Activate it on start.
if ( script.Activate.Value ) then
	activate();
end