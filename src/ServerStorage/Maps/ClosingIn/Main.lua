local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local MOVING_SPEED = 2.5
local Creaking
local Moving = false
local Walls = {["Left"] = {}, ["Right"] = {}}

Floor.Settings = {
	DOORS_OPEN = false,
	INTERACTIVE = false,
	TIME = 28 --seconds
}

local function setVariables(Map)
	Creaking = Floor.Sounds.Creaking
	local function sortWall(Model, ParentSide)
		for _, Part in pairs(Model:GetChildren()) do
			local Side = ParentSide
			if (not ParentSide) then
				if (string.sub(Part.Name, 1, 4) == "Left") then
					Side = "Left"
				elseif (string.sub(Part.Name, 1, 5) == "Right") then
					Side = "Right"
				end
			end
			if (ParentSide) or (Side) then
				if (Part:IsA("BasePart")) then
					table.insert(Walls[Side], #Walls[Side]+1, {["Part"]=Part, originCFrame = Part.CFrame})
				elseif (Part:IsA("Model")) then
					sortWall(Part, Side)
				end
			else
				if (Part:IsA("Model")) then
					sortWall(Part)
				end
			end
		end
	end
	sortWall(Elevator.Model.Walls)
	--sortWall(Elevator.Model.Decoration)
	sortWall(Elevator.Model.Railings)
end

function Floor:initPlayer(Player)

end

local function moveWalls()
	for _, PartTable in pairs(Walls.Left) do
		PartTable.Part.CFrame = PartTable.Part.CFrame + Vector3.new(0,0,0.01*MOVING_SPEED)
	end
	for _, PartTable in pairs(Walls.Right) do
		PartTable.Part.CFrame = PartTable.Part.CFrame - Vector3.new(0,0,0.01*MOVING_SPEED)
	end
end

local function restoreWalls()
	for _, PartTable in pairs(Walls.Left) do
		PartTable.Part.CFrame = PartTable.originCFrame
	end
	for _, PartTable in pairs(Walls.Right) do
		PartTable.Part.CFrame = PartTable.originCFrame
	end
end


function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	wait(5)
	Moving = true
	--start moving Walls
	spawn(function()
		while (Moving) do
			moveWalls()
			wait()
		end
	end)
	wait(1)
	Creaking:Play()
	wait(2.5)
	Creaking.PlaybackSpeed = 1.3
	Creaking:Play()
	wait(4)
	Creaking.PlaybackSpeed = 0.7
	Creaking:Play()
	wait(11)
	for NPC, Script in pairs(Elevator.NPCs) do
		if (NPC.Name == "Bob") or (NPC.Name == "Buffmax") then
			NPC:BreakJoints()
			Script.Humanoid.Health = 0
		end
	end
	Moving = false
end

function Floor.ending()
	Walls = {["Left"] = {}, ["Right"] = {}}
	Elevator:lightsOff()
	restoreWalls()
end

return Floor