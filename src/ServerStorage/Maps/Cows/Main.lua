local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Cows
local Leaves
local Sheep
local SpecialCow
local CowFaces = {Alive=5618320332,Dead=14673164}
local SheepDB = true
local Running = true

local Connections = {}
local DB = {}
local Clicks = 0

local Running = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 32 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0.1,Size = 1, Threshold = 0.5, Enabled = true},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0.3,Spread = 0.3, Enabled = true},
	Lighting = {OutdoorAmbient=Color3.new(127/255,127/255,127/255), ClockTime=12,Brightness = 1, GeographicLatitude = 70},
	Sky = Floor.Skybox
}

local function anchorPart(Part)
	Part.Anchored = true
end

local function addClick()
	Clicks = Clicks+1
	if (Clicks == #Cows:GetChildren()) then
		local Cow = Cows:GetChildren()[math.random(1, #Cows:GetChildren())]
		Functions:recurseFunctionOnParts(anchorPart, Cow)
		local UFO = game.ServerStorage.Models.UFO:Clone()
		UFO.Parent = Floor.Model
		UFO:SetPrimaryPartCFrame(CFrame.new(Cow.PrimaryPart.Position + Vector3.new(0,15,0)))
		
		wait(3)
		for i = 1, 30 do
			Cow:SetPrimaryPartCFrame(Cow.PrimaryPart.CFrame + Vector3.new(0,0.5,0))
			wait(0.05)
		end
		wait(1)
		UFO.Emitter.ParticleEmitter.Enabled = false
		while (Running) do
			if (UFO) and (Cow) then
				UFO:SetPrimaryPartCFrame(UFO.PrimaryPart.CFrame + Vector3.new(0, 0.5, 0))
				Cow:SetPrimaryPartCFrame(Cow.PrimaryPart.CFrame + Vector3.new(0, 0.5,0))
				wait()
			end
		end
	end
end

local function setVariables(Map)
	Running = true
	
	Cows = Map.Cows
	Leaves = Map.Leaves
	Sheep = Map.Sheep
	SpecialCow = Cows.Amalo
	
	require(Sheep.NPCScript) ---HALLOWEEN CANDY THING
	
	for n, Cow in pairs(Cows:GetChildren()) do
		Connections[n] = Cow.ClickDetector.MouseClick:Connect(function(Player)
			if (not DB[n]) then
				DB[n] = true
				Connections[n]:Disconnect()
				Connections[n]=nil
				Cow.ClickDetector:Destroy()
				Cow.Head.Moo.PlaybackSpeed = math.random(10,12)/10
				Cow.Head.Moo:Play()
				Cow.Head.Mesh.TextureId = "rbxassetid://".. CowFaces.Dead
				local Gyro = Instance.new("BodyGyro", Cow.HumanoidRootPart)
				if (Functions:characterIsValid(Player.Character)) then
					Gyro.CFrame = Cow.HumanoidRootPart.CFrame * CFrame.Angles(0,0,math.pi/2)
				else
					Gyro.CFrame = Cow.HumanoidRootPart.CFrame * CFrame.Angles(0,0,math.pi/2)
				end
				
				Gyro.P = 12500
				Gyro.D = 750
				addClick()
			end
		end)
	end
	
	Connections[#Connections+1] = Sheep.ClickDetector.MouseClick:Connect(function()
		if (SheepDB) then
			SheepDB = false
			Sheep.Torso.Fart:Play()
			local Pellet = Sheep.Pellet:Clone()
			Pellet.Parent = Sheep
			Pellet.Anchored = false
			Pellet.CanCollide = true
			wait(math.random(2,5))
			if (Sheep:FindFirstChild("Head")) then
				Sheep.Head.Sheep:Play()
			end
			SheepDB = true
		end
	end)
	
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	if (Functions:characterIsValid(Player.Character)) and (Running) then
		local Humanoid = Player.Character.Humanoid
		Humanoid.WalkSpeed = 26
	end
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Ambient:Play()
end

function Floor.ending()
	Clicks = 0
	Running = false
	Connections = Functions:disconnectTableEvents(Connections)
	for _, Player in pairs(Elevator.Players) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
	DB = {}
end

return Floor