local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Cat
local catCFrame
local catPoses
local catEmitter
local Sparkle
local fakeStoredCollisions = {}

local dancePos = 0
local hop = 0

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 30 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.new(127/255,127/255, 127/255), Brightness = 1, ClockTime=14},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Cat = Map.Cat
	catCFrame = Cat.CFrame
	catPoses = Map.CatPositions
	catEmitter = Map.Emitter.CatEmitter
	Sparkle = Map.Sparkle.Emit
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

function dance()
	if (dancePos == 0) then
		dancePos = 1
		Cat.CFrame = catCFrame * CFrame.Angles(-math.pi/2, 0, math.pi/4)
	else
		dancePos = 0
		Cat.CFrame = catCFrame * CFrame.Angles(-math.pi/2, 0, -math.pi/4)
	end
	wait(0.2)
end

function dunceduncedunce()
	if (hop == 0) then
		hop = 1
		Cat.CFrame = catPoses:FindFirstChild("Pose1").CFrame
		for i = 2, #catPoses:GetChildren() do
			Cat.CFrame = Cat.CFrame:lerp(catPoses["Pose"..i].CFrame, i/#catPoses:GetChildren())
			wait(0.1)	
		end
	else
		Cat.CFrame = catPoses:FindFirstChild("Pose7").CFrame
		local ind = 2
		for i = #catPoses:GetChildren()-1, 1, -1 do
			Cat.CFrame = Cat.CFrame:lerp(catPoses["Pose"..i].CFrame, ind/7)
			ind = ind + 1
			wait(0.1)	
		end
		hop = 0
	end
end

function andI()
	wait(0.35)
end

function catImAKittyCat()
	Cat.CFrame = catCFrame
	wait(0.2)
	Sparkle.Enabled = true
	wait(0.8)
	Sparkle.Enabled = false
	wait(0.4)
end

function purrovocativepooooosiiing()
	Cat.CFrame = catCFrame
	for i = 1, 7 do
		Cat.CFrame = Cat.CFrame * CFrame.Angles(math.rad(math.random(60, 180)),math.rad(math.random(60, 180)),math.rad(math.random(60, 180)))
		wait(0.5)
	end
end

local function fadeElevator()
	local fadeNum = 0
	local function fadePart(Part)
		if (Part.Transparency < fadeNum) then
			Part.Transparency = fadeNum
		end
		for _, Object in pairs(Part:GetChildren()) do
			if (Object:IsA("Decal")) then
				Object.Transparency = fadeNum
			end
			if (Object:IsA("SurfaceGui")) then
				Object.Enabled = false
			end
		end
	end
	local function collidePart(Part)
		fakeStoredCollisions[Part] = Part.CanCollide
		Part.CanCollide = false
	end
	Functions:recurseFunctionOnParts(collidePart, Elevator.Model)
	for i = 1, 10 do
		fadeNum = i/10
		Functions:recurseFunctionOnParts(fadePart, Elevator.Model)
		wait(0.05)
	end
end

function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	wait(3)
	Floor.Sounds.Music:Play()
	catImAKittyCat()
	andI() dance() dance() dance() andI() dance() dance() dance()
	catImAKittyCat()
	andI() dance() dance() dance() andI() dance() dance() dance()
	catEmitter.Enabled = true
	spawn(function()
		fadeElevator()
	end)
	catImAKittyCat()
	andI() dance() dance() dance() andI() dance() dance() dance()
	catImAKittyCat()
	andI() dance() dance() dance() andI() dance() dance() dance()
	catImAKittyCat()
	andI() dance() dance() dance() andI() dance() dance() dance()
	catImAKittyCat()
	andI() dunceduncedunce() andI() dunceduncedunce()
	purrovocativepooooosiiing() purrovocativepooooosiiing()
	catImAKittyCat()
	andI() dance() dance() dance()
end

function Floor.ending()
	local function showElevatorDoors(Part)
		for _, Object in pairs(Part:GetChildren()) do
			if (Object:IsA("Decal")) then
				Object.Transparency = 0
			end
			if (Object:IsA("SurfaceGui")) then
				Object.Enabled = true
			end
		end
	end
	Functions:recurseFunctionOnParts(showElevatorDoors, Elevator.Model)
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
	fakeStoredCollisions = {}
	Elevator:teleportPlayers()
end

return Floor