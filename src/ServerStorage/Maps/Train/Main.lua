local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Trains
local Smoke
local Dude
local Walls

local frontGoing = true
local sideGoing = true
local done = false

local fakeStoredCollisions = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 25 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0.3,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = -1, Enabled = true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.fromRGB(127/255,127/255, 127/255), ClockTime=12, Brightness = 0},
}

local function setVariables(Map)
	Trains = Map.Trains
	Smoke = Map.Smoke
	Walls = Map.ElevatorWalls
	Dude = Map.Dude
	
	done = false
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function moveTrain(Train)
	Train:SetPrimaryPartCFrame(Train.PrimaryPart.CFrame * CFrame.new(0,1,0))
end

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

local function showPart(Part)
	Part.Transparency = 0
	Part.CanCollide = true
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:changeBackgroundColor(Color3.new(1,1,1))

	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	spawn(function()
		while (Map) and (not done) do
			if (frontGoing) then
				moveTrain(Trains.Front)
			end
			if (sideGoing) then
				moveTrain(Trains.Side)
			end
			wait()
		end
	end)
	
	wait(10)
	Floor.Sounds.Voice:Play()
	wait(4)
	Floor.Sounds.Train:Play()
	wait(1.2)
	local Trains = {"Front", "Side"}
	local Side = Trains[math.random(1, #Trains)]
	if (Side == "Front") then
		sideGoing = false
		local wallParts = Elevator:getWallParts("Front")
		Functions:recurseFunctionOnParts(hidePart, wallParts)
		Functions:recurseFunctionOnParts(hidePart, {Elevator.Model.LeftDoor, Elevator.Model.RightDoor})
		Functions:recurseFunctionOnParts(showPart, Walls.Front)
		Smoke.Front.Smoke.Enabled = true
		wait(1)
		Dude.Gui.Enabled = false
		local wallParts = Elevator:getWallParts("Back")
		Functions:recurseFunctionOnParts(hidePart, wallParts)
		Functions:recurseFunctionOnParts(hidePart, {Elevator.Model.Railings:FindFirstChild("Back")})
		Functions:recurseFunctionOnParts(showPart, Walls.Back)
		Smoke.Back.Smoke.Enabled = true
		Smoke.Front.Smoke.Enabled = false
	elseif (Side == "Side") then
		frontGoing = false
		local wallParts = Elevator:getWallParts("Right")
		Functions:recurseFunctionOnParts(hidePart, wallParts)
		Functions:recurseFunctionOnParts(hidePart, {Elevator.Model.Railings:FindFirstChild("Right")})
		Functions:recurseFunctionOnParts(showPart, Walls.Right)
		Smoke.Right.Smoke.Enabled = true
		wait(1)
		Dude.Gui.Enabled = false
		local wallParts = Elevator:getWallParts("Left")
		Functions:recurseFunctionOnParts(hidePart, wallParts)
		Functions:recurseFunctionOnParts(hidePart, {Elevator.Model.Railings:FindFirstChild("Left")})
		Functions:recurseFunctionOnParts(showPart, Walls.Left)
		Smoke.Left.Smoke.Enabled = true
		Smoke.Right.Smoke.Enabled = false
	end
	wait(1)
	for _, Part in pairs(Smoke:GetChildren()) do
		Part.Smoke.Enabled = false
	end
end

function Floor.ending()
	done = true
	frontGoing = true
	sideGoing = true
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
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
	fakeStoredCollisions = {}
end

return Floor