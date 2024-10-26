local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Noob
local Running = false

local doorConnection
local doorConnected = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 25 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0.2,Contrast = 0.4,TintColor = Color3.new(1,1,1),Saturation = -0.3, Enabled=true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.fromRGB(128,128,128), Ambient=Color3.new(0,0,0), Brightness = 2, FogColor = Color3.fromRGB(19,4,21), FogEnd = 400, FogStart = 75, ClockTime = 18},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Noob = game.ServerStorage.NPCs:FindFirstChild("Buffmax"):Clone()		--CHANGE THIS BACK TO BOB
	Noob.Parent = Map
	Noob:SetPrimaryPartCFrame(Map.NoobSpawn.CFrame)
	Running = true
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
	Floor.Sounds.Music:Play()
	
	doorConnection = Elevator.Model.FakeDoor.Touched:Connect(function(Hit)
		if (Hit.Parent == Noob) and (not doorConnected) then
			doorConnected = true
			Elevator:addNPC(Noob)
		end
	end)
	
	wait(11)
	local Humanoid = Noob:FindFirstChildOfClass("Humanoid")
	local Track = Humanoid:LoadAnimation(Noob.Walking)
	Track:Play()
	while (Running) and (not doorConnected) do
		Humanoid:MoveTo(Elevator.Model.FakeDoor.Position)
		wait(2)
	end
	Track:Stop()
	Track:Destroy()
end

function Floor.ending()
	Running = false
	doorConnection:Disconnect()
	doorConnected = false
end

return Floor