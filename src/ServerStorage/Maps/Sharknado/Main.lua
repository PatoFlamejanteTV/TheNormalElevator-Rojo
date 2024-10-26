local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Shark = game.ServerStorage.Models.JAWS
local Sharks
local Grass
local Tornados
local RedBuilding

local doorConnection
local doorConnected = false

local TriggerActivated = false
local TriggerConnection

local Running = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 50 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0,Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.new(127/255,127/255,127/255), ClockTime=12,Brightness=1},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Running=true
	Grass = Map.Grass
	Tornados = Map.Tornados:GetChildren()
	RedBuilding = Map.Buildings.RedBuilding
	Sharks = Map.Sharks
end

function Floor:initPlayer(Player)
	local Character = Player.Character
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	if (Functions:characterIsValid(Character)) and (Running) then
		local Humanoid = Character.Humanoid
		Humanoid.WalkSpeed = 24
	end
end

local function moveTornado(tor)
	if (Running) then
		if (tor.CFrame.X > Grass.CFrame.X + Grass.Size.X/2) then
			tor.x.Value = -math.random(1, 3)
		elseif (tor.CFrame.X < Grass.CFrame.X - Grass.Size.X/2) then
			tor.x.Value = math.random(1, 3)
		end
		if (tor.CFrame.Z > Grass.CFrame.Z + Grass.Size.Z/2) then
			tor.z.Value = -math.random(1, 3)
		elseif (tor.CFrame.Z < Grass.CFrame.Z - Grass.Size.Z/2) then
			tor.z.Value = math.random(1, 3)
		end
		tor.CFrame = tor.CFrame + Vector3.new(tor.x.Value, 0, tor.z.Value)
	end
end

local function spawnShark()
	local newShark = Shark:Clone()
	local tornadoSpot = Tornados[math.random(1, #Tornados)]
	newShark.Tornado.Value = tornadoSpot
	newShark:SetPrimaryPartCFrame(tornadoSpot.CFrame)
	newShark.Parent = Sharks
	newShark:MakeJoints()
	return newShark
end

function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Elevator:enableSkybox(Floor.Skybox)
	Floor.Sounds.Music:Play()
	
	Running = true
	
	doorConnection = Elevator.Model.FakeDoor.Touched:Connect(function(Hit)
		if (Hit.Parent.Name == "Raga") and (Hit.Parent:FindFirstChild("NPC")) and (not doorConnected) then
			doorConnected = true
			Elevator:addNPC(Hit.Parent)
		end
	end)
	
	if (Elevator:findNPC("Raga")) then
		TriggerActivated = true
	end
	
	TriggerConnection = RedBuilding.Trigger.Touched:Connect(function(Hit)
		if (Hit.Parent:IsA("Tool")) and (Hit.Parent.Name == "JOSH") and (Hit.Parent:FindFirstChild("Living")) and (not Elevator:findNPC("Raga")) and (not TriggerActivated) then
			TriggerActivated = true
			RedBuilding.Light.SurfaceLight.Enabled = true
			local Mystery = game.ServerStorage.NPCs:FindFirstChild("Raga"):Clone()
			Mystery.Parent = Map
			Mystery:SetPrimaryPartCFrame(RedBuilding.RedSpawn.CFrame)
			require(Mystery.NPCScript):init("Elevator")
		end
	end)
	
	spawn(function()
		while (Running) do
			for _, Tornado in pairs(Tornados) do
				moveTornado(Tornado)
			end
			wait()
		end
	end)
	
	spawn(function()
		while (Running) do
			local newShark = spawnShark()
			wait(3)
			if (newShark) and (newShark:FindFirstChild("Shark")) then
				if (newShark.Shark:FindFirstChild("BodyGyro")) then
					newShark.Shark.BodyGyro:Destroy()
				end
				if (newShark.Shark:FindFirstChild("BodyPosition")) then
					newShark.Shark.BodyPosition:Destroy()
				end
			end
		end
	end)	
	
end

function Floor.ending(Map)
	for _, Shark in pairs(Sharks:GetChildren()) do
		Shark:Destroy()
	end
	for _, Player in pairs(Elevator.Players) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
	Running = false
	Floor.Sounds.Music:Stop()
	TriggerConnection:Disconnect()
	TriggerActivated = false
	doorConnection:Disconnect()
	doorConnected = false
end


return Floor