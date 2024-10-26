local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Lights
local AllLights
local Spots
local Triggers
local BackWall
local Slenderman

local SlenderHead = game.ServerStorage.Models:FindFirstChild("SlenderHead")

local triggering = false
local running = true

local activated = {		--for triggers
	[1] = false,
	[2] = false,
	[3] = false
}

local Connections = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 48 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.new(0,0,0), Brightness = 0},
}

local function setVariables(Map)	
	running = true
	Lights = Map.EffectLights
	AllLights = Map.Lights
	Spots = Map.Spots
	Triggers = Map.Triggers
	BackWall = Map.BackWall
	Slenderman = Map.Slenderman
end

local function toggleLight(model, bool)
	model.LightPart.PointLight.Enabled = bool
	for _, Part in pairs(model:GetChildren()) do
		if (Part.Name == "Light") then
			Part.Material = bool and Enum.Material.Neon or Enum.Material.SmoothPlastic
		end
	end
end

local function blinkLight(model)
	if (running) then
		model.LightPart.PointLight.Brightness = 0.5
		if (model.LightPart:FindFirstChild("Sound")) then
			model.LightPart.Sound:Play()
		end
		
		wait(0.2)
		if (model.LightPart:FindFirstChild("Sound")) then
			model.LightPart.Sound.Volume = 1
		end
		model.LightPart.PointLight.Brightness = 2
		wait(0.4)
		if (model.LightPart:FindFirstChild("Sound")) then
			model.LightPart.Sound:Stop()
		end
		toggleLight(model, false)
		wait(0.3)
		toggleLight(model, true)
		model.LightPart.PointLight.Brightness = 0.5
		wait(0.3)
		model.LightPart.PointLight.Brightness = 2
		wait(0.2)
	end
end

local function flickerLight(model)
	if (running) then
		model.LightPart.PointLight.Brightness = 0
		for _, Part in pairs(model:GetChildren()) do
			if (Part.Name == "Light") then
				Part.Material = Enum.Material.SmoothPlastic
			end
		end
	end
	wait(math.random(2,8)/10)
	if (running) then
	model.LightPart.PointLight.Brightness = 2
		for _, Part in pairs(model:GetChildren()) do
			if (Part.Name == "Light") then
				Part.Material = Enum.Material.Neon
			end
		end
	end
	wait(math.random(4,57)/10)
	if (running) then
		model.LightPart.PointLight.Brightness = 0
		for _, Part in pairs(model:GetChildren()) do
			if (Part.Name == "Light") then
				Part.Material = Enum.Material.SmoothPlastic
			end
		end
	end
	wait(math.random(2,8)/10)
	if (running) then
		model.LightPart.PointLight.Brightness = 2
		for _, Part in pairs(model:GetChildren()) do
			if (Part.Name == "Light") then
				Part.Material = Enum.Material.Neon
			end
		end
	end
end


local function moveBackWall(studs)
	for _, Part in pairs(BackWall:GetChildren()) do
		Part.CFrame = Part.CFrame * CFrame.new(0, 0, -studs)
	end
end

function triggerSpot(triggerPart)
	local num = tonumber(triggerPart.Name:sub(8,8))
	if (activated[num] == false) and (not triggering) then
		triggering = true
		activated[num] = true
		local Light = Lights:FindFirstChild("Light"..num)
		blinkLight(Light)
		toggleLight(Light, false)
		wait(0.4)
		
		local Spot = Spots:FindFirstChild("Slenderman"..num)
		Slenderman:SetPrimaryPartCFrame(Spot.PrimaryPart.CFrame)
		for i, v in pairs(Slenderman:GetChildren()) do
			if (v:IsA("BasePart")) and (v.Name~="HumanoidRootPart") then
				v.Transparency = 0
				v.CanCollide = true
			end
		end
		Slenderman.Scare:Play()
		
		toggleLight(Light, true)
		wait(1.5)
		
		toggleLight(Light, false)
		for i, v in pairs(Slenderman:GetChildren()) do
			if (v:IsA("BasePart")) and (v.Name~="HumanoidRootPart") then
				v.Transparency = 1
				v.CanCollide = false
			end
		end
		Slenderman.Scare:Stop()
		wait(0.5)

		toggleLight(Light, true)
		triggering = false
	end
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
	
	Connections[1] = Triggers.Trigger1.Touched:Connect(function(Hit) if (Functions:characterIsValid(Hit.Parent)) then triggerSpot(Triggers.Trigger1) end end)
	Connections[2] = Triggers.Trigger2.Touched:Connect(function(Hit) if (Functions:characterIsValid(Hit.Parent)) then triggerSpot(Triggers.Trigger2) end end)
	Connections[3] = Triggers.Trigger3.Touched:Connect(function(Hit) if (Functions:characterIsValid(Hit.Parent)) then triggerSpot(Triggers.Trigger3) end end)
	
	spawn(function()
		while (running) and (Map ~= nil) do
			local r = math.random(1,3)
			if (r == 1) then
				local Light = AllLights:GetChildren()[math.random(1, #AllLights:GetChildren())]
				spawn(function() flickerLight(Light) end)
				
			end
			wait(0.3)
		end
	end)
	
	wait(Floor.Settings.TIME-12)
	
	Elevator.Model.FakeDoor.CanCollide = true
	Elevator:teleportPlayers()
	
	wait(3)
	for _, Light in pairs(AllLights:GetChildren()) do
		toggleLight(Light, false)
	end
	Floor.Sounds.Thunder:Play()
	Elevator:lightsOff()
	wait(1)
	for _, Light in pairs(AllLights:GetChildren()) do
		if (Light.Name ~= "Light") then
			toggleLight(Light, true)
		end
	end
	Slenderman:SetPrimaryPartCFrame(Spots.Slenderman4.PrimaryPart.CFrame)
	for i, v in pairs(Slenderman:GetChildren()) do
		if (v:IsA("BasePart")) and (v.Name~="HumanoidRootPart") then
			v.Transparency = 0
		end
	end
	wait(2)
	for _, Light in pairs(AllLights:GetChildren()) do
		toggleLight(Light, false)
	end
	wait(0.4)
	for _, Light in pairs(AllLights:GetChildren()) do
		if (Light.Name ~= "Light") then
			toggleLight(Light, true)
		end
	end
	wait(1)
	for _, Light in pairs(AllLights:GetChildren()) do
		toggleLight(Light, false)
	end
	wait(0.3)
	moveBackWall(27)
	for i, v in pairs(Slenderman:GetChildren()) do
		if (v:IsA("BasePart")) and (v.Name~="HumanoidRootPart") then
			v.Transparency = 1
		end
	end
	for _, Light in pairs(AllLights:GetChildren()) do
		if (Light.Name ~= "Light") then
			toggleLight(Light, true)
		end
	end
	wait(1)
	for _, Light in pairs(AllLights:GetChildren()) do
		toggleLight(Light, false)
	end
	wait(1.2)
	toggleLight(AllLights.Light4, true)
	for i, v in pairs(Slenderman:GetChildren()) do
		if (v:IsA("BasePart")) and (v.Name~="HumanoidRootPart") then
			v.Transparency = 0
		end
	end
	wait(0.6)
	moveBackWall(27)
	toggleLight(AllLights.Light5, true)
	Slenderman:SetPrimaryPartCFrame(Spots.Slenderman5.PrimaryPart.CFrame)
	wait(0.6)
	moveBackWall(40)
	toggleLight(AllLights.Light6, true)
	Slenderman:SetPrimaryPartCFrame(Spots.Slenderman6.PrimaryPart.CFrame)
	Slenderman.Scare:Play()
	spawn(function()
		Elevator:resetLights()
		Elevator:flickerLights(2.5)
	end)
	blinkLight(AllLights.Light6)
end

function Floor.ending(Map)
	running = false
	local rPlayer = Elevator:getRandomPlayer()
	if (rPlayer) and (Functions:characterIsValid(rPlayer.Character)) then
		for _, Mesh in pairs(rPlayer.Character.Head:GetChildren()) do
			if (Mesh:IsA("SpecialMesh")) then
				Mesh:Destroy()
			end
		end
		local HeadClone = SlenderHead:Clone()
		HeadClone.Parent = rPlayer.Character.Head
	end
	for i = 1, #activated do
		activated[i] = false
	end
	Functions:disconnectTableEvents(Connections)
	Connections = {}
end

return Floor