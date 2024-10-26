local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Shoes = game.ServerStorage.Models.Shoes
local Kanye
local Pump

local kDances = {"Kick", "Lean", "Spin"}
local pDances = {"Lean", "Kick"}

local lastK = nil
local lastP = nil

local ending = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 30 --seconds
}

local sizeSettings = {
	Depth = 2,
	Width = 2,
	Height = 1.5,
	HeadScale = 0.8
}

local playerSettings = {}

Floor.Lighting = {
	Bloom = {Intensity = 0.1,Size = 16, Threshold = 0.8, Enabled = true},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.fromRGB(255, 226, 221),Saturation = 0, Enabled = true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {ColorShift_Bottom = Color3.fromRGB(255, 250, 194), ColorShift_Top = Color3.fromRGB(124, 103, 103), OutdoorAmbient = Color3.fromRGB(42, 42, 42), Brightness = 1,
				FogColor = Color3.fromRGB(0,0,0), FogEnd = 300, FogStart = 100},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	ending = false
	Kanye = Map.KanyeWest
	Pump = Map.LilPump
	require(Kanye.NPCScript)
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	local Character = Functions:characterIsValid(Player.Character)
	if (Character) and (not ending) then
		local Humanoid = Character.Humanoid
		if (Humanoid.RigType == Enum.HumanoidRigType.R15) then
			local Width = Humanoid:WaitForChild("BodyWidthScale")
			local Height = Humanoid:WaitForChild("BodyHeightScale")
			local Depth = Humanoid:WaitForChild("BodyDepthScale")
			local HeadScale = Humanoid:WaitForChild("HeadScale")
			playerSettings[Player] = {HeadScale = HeadScale.Value, Depth = Depth.Value, Height = Height.Value, Width = Width.Value}
			HeadScale.Value = sizeSettings.HeadScale
			Width.Value = sizeSettings.Width
			Height.Value = sizeSettings.Height
			Depth.Value = sizeSettings.Depth
			
			local leftShoe = Shoes.LeftShoe:Clone()
			leftShoe.Parent = Character
			local leftWeld = Instance.new("ManualWeld", leftShoe)
			leftWeld.Part0 = leftShoe
			leftWeld.Part1 = Character:FindFirstChild("LeftFoot")
			leftWeld.C0 = CFrame.new(0,-0.3,1)
			
			local rightShoe = Shoes.RightShoe:Clone()
			rightShoe.Parent = Character
			local rightWeld
			rightWeld = Instance.new("ManualWeld",rightShoe)
			rightWeld.Part0 = rightShoe
			rightWeld.Part1 = Character:FindFirstChild("RightFoot")
			rightWeld.C0 = CFrame.new(0,-0.3,1)

		end
	end
end

local function updateSpeeds(str)
	if (str == "PumpUp") then
		if (Pump) and (Pump:FindFirstChild("Humanoid")) then
			Pump.Humanoid.WalkSpeed = Pump.Humanoid.WalkSpeed + 2
			Kanye.Humanoid.WalkSpeed = Kanye.Humanoid.WalkSpeed - 2
		end
	elseif (str == "PumpDown") then
		if (Kanye) and (Kanye:FindFirstChild("Humanoid")) then
			Pump.Humanoid.WalkSpeed = Pump.Humanoid.WalkSpeed - 2
			Kanye.Humanoid.WalkSpeed = Kanye.Humanoid.WalkSpeed + 2
		end
	end
end

local function updateSequence()
	while (not ending) do
		updateSpeeds("PumpUp")
		wait(2)
		updateSpeeds("PumpDown")
		wait(2)
		updateSpeeds("PumpDown")
		wait(2)
		updateSpeeds("PumpUp")
		wait(2)
		updateSpeeds("PumpDown")
		wait(2)
		updateSpeeds("PumpUp")
		wait(2)
		updateSpeeds("PumpUp")
		wait(2)
		updateSpeeds("PumpDown")
		wait(2)
	end
end


function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
	
	spawn(function()
		updateSequence()
	end)
	
	while (not ending) do
		
		Kanye.Humanoid:MoveTo(Map.KanyeEnd.Position)
		Pump.Humanoid:MoveTo(Map.PumpEnd.Position)
		
		local kDance = kDances[math.random(1, #kDances)]
		local pDance = pDances[math.random(1, #pDances)]
		
		if (lastK) then
			lastK:Stop()
			lastK:Destroy()
		end
		if (lastP) then
			lastP:Stop()
			lastP:Destroy()
		end
		
		lastK = Kanye.Humanoid:LoadAnimation(Kanye[kDance])
		lastP = Pump.Humanoid:LoadAnimation(Pump[pDance])
		
		lastK:Play()
		lastP:Play()
		wait(math.random(2,4))
	end
end

function Floor.ending(Map)
	ending = true
	for Player, Settings in pairs(playerSettings) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			if (Humanoid.RigType == Enum.HumanoidRigType.R15) then
				local Width = Humanoid:WaitForChild("BodyWidthScale")
				local Height = Humanoid:WaitForChild("BodyHeightScale")
				local Depth = Humanoid:WaitForChild("BodyDepthScale")
				local HeadScale = Humanoid:WaitForChild("HeadScale")
				HeadScale.Value = Settings.HeadScale
				Width.Value = Settings.Width
				Height.Value = Settings.Height
				Depth.Value = Settings.Depth
				if (Character:FindFirstChild("LeftShoe")) then
					Character.LeftShoe:Destroy()
				end
				if (Character:FindFirstChild("RightShoe")) then
					Character.RightShoe:Destroy()
				end
			end
		end
	end
	
	playerSettings = {}
end

return Floor