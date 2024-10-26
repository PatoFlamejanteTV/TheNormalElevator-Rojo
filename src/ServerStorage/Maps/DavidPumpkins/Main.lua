local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local David
local newDavid = game.ServerStorage.NPCs:FindFirstChild("David Pumpkins")
local LeftSkeleton
local RightSkeleton
local Light

local midAnim

local running = false
local lightsOn = false

local doorConnected = false
local doorConnection

local Floor = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 20 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {Ambient=Color3.new(0,0,0),OutdoorAmbient=Color3.fromRGB(0,0,0), Brightness = 0},
	--Sky = Floor.Skybox
}

local function setVariables(Map)
	David = Map:FindFirstChild("David Pumpkins")
	LeftSkeleton = Map:FindFirstChild("Left Skelly")
	RightSkeleton = Map:FindFirstChild("Right Skelly")
	Light = Map.Light
	running = true
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function flickerLight()
	if (running) then
		Light.SurfaceLight.Brightness = 0
		Light.Material = Enum.Material.SmoothPlastic
	end
	wait(math.random(1,4)/10)
	if (running) then
		Light.SurfaceLight.Brightness = 6
		Light.Material = Enum.Material.Neon
	end
	wait(math.random(1,4)/10)
	if (running) then
		Light.SurfaceLight.Brightness = 0
		Light.Material = Enum.Material.SmoothPlastic
	end
	wait(math.random(1,4)/10)
	if (running) then
		Light.SurfaceLight.Brightness = 6
		Light.Material = Enum.Material.Neon
	end
end


function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	for NPC, Script in pairs(Elevator.NPCs) do
		if (NPC.Name == "David Pumpkins") then
			David = NPC
		end
	end
	
	if (not David) then
		David = newDavid:Clone()
		David.Parent = Map
		David:SetPrimaryPartCFrame(Map.DavidSpawn.CFrame)
	end
	
	if (David) then
		
		doorConnection = Elevator.Model.FakeDoor.Touched:Connect(function(Hit)
			if (Hit.Parent == David) and (Elevator.NPCs[David]) and (not doorConnected) then
				doorConnected = true
				David:SetPrimaryPartCFrame(Map.DavidSpawn.CFrame)
				Elevator:removeNPC(David)
				David.Parent = Map
			elseif (Hit.Parent == David) and (not Elevator.NPCs[David]) and (not doorConnected) then
				doorConnected = true
				David:SetPrimaryPartCFrame(Elevator.Model.FakeDoor.CFrame * CFrame.new(0,0,-David.PrimaryPart.Size.Z*4))
				Elevator:addNPC(David)
			end
		end)
		
		
		
		
	end
	
	
	
	
	spawn(function()
		while (running) and (Map ~= nil) do
			local r = math.random(1,3)
			if (r == 1) and (lightsOn) then
				spawn(function() flickerLight(Light) end)
			end
			wait(0.2)
		end
	end)
	
	wait(5)
	Floor.Sounds.Music:Play()	--15 BPM           2
	lightsOn = true
	local leftAnim = LeftSkeleton.Humanoid:LoadAnimation(Map.Boogie)
	local rightAnim = RightSkeleton.Humanoid:LoadAnimation(Map.Boogie)
	leftAnim:Play()
	wait(4)
	leftAnim:Stop()
	rightAnim:Play()
	wait(4)
	rightAnim:Stop()
	midAnim = David.NPC:LoadAnimation(Map.DavidDance)
	midAnim:Play()
	wait(3.7)
	midAnim:Stop()
	lightsOn = false
	wait(0.3)
	lightsOn = true
	spawn(function()
		for i = 1, 2 do
			if (not doorConnected) then
				Functions:getHumanoid(David):MoveTo(Elevator.Model.FakeDoor.Position)
			end
			wait(4)
		end
	end)
	leftAnim:Play()
	rightAnim:Play()
	midAnim:Play()
end

function Floor.ending()
	running = false
	lightsOn = false
	
	if (midAnim) then
		midAnim:Stop()
	end
	
	if (doorConnection) then
		doorConnection:Disconnect()
	end
	doorConnected = false
end

return Floor