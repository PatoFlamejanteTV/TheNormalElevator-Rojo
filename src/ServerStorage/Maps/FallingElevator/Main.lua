local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Room
local Noises
local BrokenFloor

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 33 --seconds
}

local function setVariables(Map)
	Room = Map.Room
	Noises = Map.Noises
	BrokenFloor = Map.BrokenFloor
end

function Floor:initPlayer(Player)
	
end

local function shiftElevator(Part)
	Part.CFrame = Part.CFrame - Vector3.new(0,1,0)
end

local function openFakeDoors()
	local xsize = Room.LeftDoor.Size.X
	for i = 1, xsize*5 do
		Room.LeftDoor.CFrame = Room.LeftDoor.CFrame * CFrame.new(0.2,0,0)
		Room.RightDoor.CFrame = Room.RightDoor.CFrame * CFrame.new(-0.2,0,0)
		wait()
	end
end

local function breakElevator()
	Noises.Break:Play()
	BrokenFloor.Transparency = 0
	Elevator.Model.Floor.Transparency = 1
	Elevator.Model.Floor.CanCollide = false
end


function Floor:init(Map)
	setVariables(Map)
	local fakeElevator = Elevator:insertFakeElevator(Map, Map.FakeEntrancePart, true)
	Functions:setPartsCollision(fakeElevator.Lights, false)
	fakeElevator.Roof.CanCollide = false
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	wait(3)
	Noises.Creak:Play()
	wait(7)
	Noises.Shift:Play()
	Functions:recurseFunctionOnParts(shiftElevator, Elevator.Model)
	wait(5)
	Noises.Creak2:Play()
	wait(5)
	Noises.Creak2.Volume = 0.1
	Noises.Creak2:Play()
	wait(5)
	breakElevator()
	wait(3)
	Elevator.Model.FakeDoor.CanCollide = false
	spawn(function()openFakeDoors() end)
	wait(5)
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic, BrickColor = BrickColor.new("Really black")}, {Color = Color3.new(0,0,0)})
	Elevator.Model.Floor.Transparency = 0
	Elevator.Model.Floor.CanCollide = true
	Elevator.Model.FakeDoor.CanCollide = true
	BrokenFloor.Transparency = 1
	Elevator:teleportPlayers()
end

return Floor