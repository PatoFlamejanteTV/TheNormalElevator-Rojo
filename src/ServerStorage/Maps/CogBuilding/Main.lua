local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

Floor.Model = nil

local Cog = game.ServerStorage.NPCs:FindFirstChild("Bloodsucker")
local CogElevator

local doorConnection
local doorConnected = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 20 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Floor.Model = Map
	CogElevator = Map.CogElevator
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	Network:Send(Player, "ElevatorFakeDoor", true)
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	Elevator.Model.FakeDoor.CanCollide = false
	
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	local newCog = Cog:Clone()
	newCog.Parent = Map
	newCog:SetPrimaryPartCFrame(Map.CogSpawn.CFrame)
	
	doorConnection = Elevator.Model.FakeDoor.Touched:Connect(function(Hit)
		if (Hit.Parent == newCog) and (not doorConnected) then
			doorConnected = true
			Elevator:addNPC(newCog)
		end
	end)
	
	Floor.Sounds.Music:Play()
	Elevator:openDoors(CogElevator)
	
	wait(1)
	
	for i = 1, 2 do
		if (not doorConnected) then
			Functions:getHumanoid(newCog):MoveTo(Elevator.Model.TeleportPart.Position)
		end
		wait(4)
	end
	
end

function Floor.ending(Map)
	Elevator.Model.FakeDoor.CanCollide = true
	doorConnection:Disconnect()
	doorConnected = false
end

return Floor