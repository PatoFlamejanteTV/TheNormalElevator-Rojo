local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local CandySpawner = require(game.ServerScriptService.Halloween.CandySpawner)

local Floor = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 33 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0,Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.new(91/255,91/255,91/255), FogColor=Color3.new(0,0,0), ClockTime=12,FogEnd=250},
	Sky = Floor.Skybox
}

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end


function Floor:init(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Floor.Sounds.FenceSound:Play()
	Floor.Sounds.Ambient:Play()
	wait(4)
	for i = 1, 25 do
		Map.BlackPart.Transparency = 0.04*i
		wait()
	end
	wait(4)
	Map.BlackPart.Transparency = 0
	Floor.Sounds.FenceSound:Play()
	Floor.Sounds.SparkSound:Play()
	wait(0.5)
	for _, Part in pairs (Map.WallFixed:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.Transparency=1
		end
	end
	for _, Part in pairs (Map.WallBroken1:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.Transparency=0
		end
	end
	wait(2)
	for i = 1, 25, 2 do
		Map.BlackPart.Transparency = 0.08*i
		wait()
	end
	wait(0.6)
	Map.SparkP1.Sparkes.Enabled=true
	Floor.Sounds.SparkSound:Play()
	wait(0.2)
	Map.SparkP1.Sparkes.Enabled=false
	wait(0.5)
	Map.SparkP3.Sparkes.Enabled=true
	Floor.Sounds.SparkSound:Play()
	wait(0.2)
	Map.SparkP3.Sparkes.Enabled=false
	wait(2.5)
	Map.SparkP2.Sparkes.Enabled=true
	Floor.Sounds.SparkSound:Play()
	wait(0.2)
	Map.SparkP2.Sparkes.Enabled=false
	wait(1)
	Floor.Sounds.DinosaurSound:Play()
	wait(1)
	Floor.Sounds.StompSound:Play()
	wait(4)
	Floor.Sounds.DinosaurSound.Volume = 1
	wait(2)
	Map.SmokePart.Smoke1.Enabled=true
	Map.SmokePart.Smoke2.Enabled=true
	wait(1)
	for _, Part in pairs (Map.Dinosaur:GetChildren()) do
		if (Part:IsA("BasePart")) and (Part.Name ~= "Ray") and (Part.Name ~= "HumanoidRootPart") then
			Part.Transparency=0
		end
	end
	wait(1)
	Floor.Sounds.BreakWallSound:Play()
	for _, Part in pairs (Map.WallBroken1:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.Transparency=1
		end
	end
	for _, Part in pairs (Map.WallBroken2:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.Transparency=0
		end
	end
	pcall(function()
		CandySpawner:spawn(Map.Candies.CandySpawner)
	end)
	Map.Dinosaur.Humanoid:LoadAnimation(Map.RunTest):Play()
	wait()
	Map.SmokePart.Smoke1.Enabled=false
	Map.SmokePart.Smoke2.Enabled=false
	Floor.Sounds.StompSound:Stop()
	wait(2)
	Floor.Sounds.DinosaurSound:Play()
end

return Floor