local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local CandySpawner = require(game.ServerScriptService.Halloween.CandySpawner)

local Floor = {}

local Jason
local Machette
local Girl
local Fireplace

local hitParts = {}
local hitConnection
local runConnection


Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 35 --seconds
}

Floor.Lighting = {
	Lighting = {FogColor = Color3.fromRGB(20, 20, 29), FogEnd = 250},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Jason = Map.Jason
	Machette = Jason.Machette.Handle
	Girl = Map:FindFirstChild("JoyfulDolphin916")
	Fireplace = Map.Fireplace
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Floor.Sounds.Ambience:Play()
	wait(8)
	Floor.Sounds.Music:Play()
	Jason.Humanoid:MoveTo(Map.Stop1.Position)
	wait(4.5)
	local throwTrack = Jason.Humanoid:LoadAnimation(Jason.Throw)
	throwTrack:Play()
	Girl.Head.Scream:Play()
	wait(1)
	Girl.Head.Scream:Stop()
	Fireplace.LightPart.Fire.Size = NumberSequence.new(0)
	Fireplace.LightPart.Fire.Enabled = false
	Fireplace.LightPart.PointLight.Enabled  = false
	Floor.Sounds.Wind:Play()
	wait(2)
	local Tween = game:GetService("TweenService"):Create(Floor.Sounds.Wind, TweenInfo.new(1), {Volume = 0})
	Tween:Play()
	wait(5)
	Jason.Humanoid:MoveTo(Map.Stop2.Position)
	pcall(function()
		CandySpawner:spawn(Map.Candies.CandySpawner)
	end)
	wait(3)
	throwTrack:Play()
	wait(1.2)
	
	Machette.Parent = Map
	Machette.Anchored = true
	hitConnection = Machette.Touched:Connect(function(Hit)
		if (Hit.Name ~= "HumanoidRootPart") then
			local Character = Hit.Parent
			if (Functions:characterIsValid(Character)) then
				local hitClone = Hit:Clone()
				Hit:Destroy()
				
				hitClone.Anchored = true
				for _, p in pairs(hitClone:GetChildren()) do
					if (not p:IsA("SpecialMesh")) or (not p:IsA("Decal")) then
						p:Destroy()
					end
				end
				--hitClone.Anchored = false
				hitClone.Parent = Map
				--[[
				local Weld = Instance.new("ManualWeld", hitClone)
				Weld.Part0 = hitClone
				Weld.Part1 = Machette
				Weld.C0 = hitClone.CFrame:inverse() * Machette.CFrame]]
				table.insert(hitParts, #hitParts, {Part = hitClone, Orientation = hitClone.CFrame})
			end
		end
	end)
	Machette.Air:Play()
	local partTween = game:GetService("TweenService"):Create(Machette, TweenInfo.new(0.7), {Rotation = Map.FakeMachette.Rotation, CFrame = Map.FakeMachette.CFrame})
	partTween:Play()
	wait(0.7)
	hitConnection:Disconnect()
	Machette.Hit:Play()
end

function Floor.ending()
	runConnection = nil
end

runConnection = game:GetService("RunService").Stepped:Connect(function()
	for _, hitPart in pairs(hitParts) do
		hitPart.Part.CFrame = Machette.CFrame * CFrame.Angles(hitPart.Orientation.X, hitPart.Orientation.Y, hitPart.Orientation.Z)
	end
end)

return Floor