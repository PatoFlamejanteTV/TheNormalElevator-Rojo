local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local fakeStoredCollisions = {}
local fakeElevator

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	HIDE_NPCS = true,
	TIME = 30 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0.1,Size = 1, Threshold = 0.5},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0.3,Spread = 0.3},
	Lighting = {OutdoorAmbient=Color3.new(127/255,127/255,127/255), Brightness = 1, ClockTime=14},
	Sky = Floor.Skybox
}

local function hidePart(Part)
	Part.Transparency = 1
	fakeStoredCollisions[Part] = Part.CanCollide
	Part.CanCollide = false
	for _, Object in pairs(Part:GetChildren()) do
		if (Object:IsA("Decal")) then
			Object.Transparency = 1
		end
		if (Object:IsA("SurfaceGui")) then
			Object.Enabled = false
		end
	end
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

function Floor:init(Map)
	fakeElevator = Elevator:insertFakeElevator(Map, Map:FindFirstChild("EntrancePart"))
	fakeElevator.Name = "FakeElevator"
	Functions:recurseFunctionOnParts(hidePart, Elevator.Model)
	fakeElevator.Parent = game.ServerStorage.WorldModel
	Functions:anchor(fakeElevator,true)
	Functions:weld(fakeElevator, true)
	fakeElevator.Parent = Map
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	wait(2)
	Floor.Sounds.Music:Play()
	local BodyPosition = Map.BodyMovers.BodyPosition
	BodyPosition.Parent = fakeElevator.TeleportPart
	local BodyAV = Map.BodyMovers.BodyAngularVelocity
	BodyAV.Parent = fakeElevator.TeleportPart
	BodyPosition.Position = fakeElevator.TeleportPart.Position
	
	Functions:anchor(fakeElevator, false)
	for num = 1, 14 do
		local x = math.random(-4, 4)
		local y = math.random(-4, 4)
		local z = math.random(-4, 4)
		BodyAV.angularvelocity = Vector3.new(x,y,z)
		wait(2)
	end
	
end

function Floor.ending()
	if (fakeElevator) then
		fakeElevator:Destroy()
	end
	Elevator:lightsOff()
	Elevator:restore(true)
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
	Elevator:teleportPlayers()
	Floor.Sounds.Music:Stop()
	local function showElevatorDoors(Part)
		for _, Object in pairs(Part:GetChildren()) do
			if (Object:IsA("Decal")) then
				Object.Transparency = 0
			end
			if (Object:IsA("SurfaceGui")) then
				Object.Enabled = false
			end
		end
	end
	Functions:recurseFunctionOnParts(showElevatorDoors, Elevator.Model)
end

return Floor