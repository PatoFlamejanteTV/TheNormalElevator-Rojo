local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Spongebob
local BobPositions
local Bus
local BusPositions
local Bathroom
local Bench
local Vending
local Kandy

local TriggerActivated = false
local TriggerConnection

local doorConnection
local doorConnected = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 25 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0.4,Contrast = 0.8,TintColor = Color3.fromRGB(70, 135, 255),Saturation = 1, Enabled = true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.fromRGB(50,50,50), Brightness = 0, FogColor = Color3.fromRGB(0,0,0), FogEnd = 250},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Running=true
	Spongebob = Map.Spongebob
	BobPositions = Map.BobPositions
	Bus = Map.Bus
	BusPositions = Map.BusPositions
	Bathroom = Map.Bathroom
	Bench = Map.Bench
	Vending = Map.Vending
	Kandy = Map.KandyBar
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	if (Functions:characterIsValid(Player.Character)) and (Running) then
		local Humanoid = Player.Character.Humanoid
		Humanoid.WalkSpeed = 18
	end
end

local function busPullUp(scene)
	if (scene == 1) then
		for num = 1, 52 do
			Bus:SetPrimaryPartCFrame(Bus.PrimaryPart.CFrame:Lerp(BusPositions.Stop1.CFrame, num/52))
			wait()
		end
	elseif (scene == 2) then
		for num = 1, 26 do
			Bus:SetPrimaryPartCFrame(Bus.PrimaryPart.CFrame:Lerp(BusPositions.Stop2.CFrame, num/26))
			wait()
		end
	elseif (scene == 3) then
		Bus:SetPrimaryPartCFrame(BusPositions.Stop3.CFrame)
	elseif (scene == 4) then
		for num = 1, 12 do
			Bus:SetPrimaryPartCFrame(Bus.PrimaryPart.CFrame:Lerp(BusPositions.Stop4.CFrame, num/12))
			wait()
		end
	elseif (scene == 5) then
		Bus:SetPrimaryPartCFrame(BusPositions.Stop5.CFrame)
	end
end
	
local function modelTransparency(model, num)
	for _, Part in pairs(model:GetChildren()) do
		if (Part:IsA("BasePart")) then
			Part.Transparency = num
		end
	end
end


function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
	
	Kandy.Parent = game.ServerStorage.MapStorage
	
	doorConnection = Elevator.Model.FakeDoor.Touched:Connect(function(Hit)
		if (Hit.Parent.Name == "Gaga") and (Hit.Parent:FindFirstChild("NPC")) and (not doorConnected) then
			doorConnected = true
			Elevator:addNPC(Hit.Parent)
		end
	end)
	
	if (Elevator:findNPC("Gaga")) then
		TriggerActivated = true
		Bathroom.Light.SurfaceLight.Enabled = true
		local baseCframe = Bathroom.RightDoor.Main.PrimaryPart.CFrame
		Bathroom.RightDoor.Main:SetPrimaryPartCFrame(baseCframe * CFrame.Angles(0, -math.pi/2, 0))
	end
	
	TriggerConnection = Bathroom.Trigger.Touched:Connect(function(Hit)
		if (Hit.Parent:IsA("Tool")) and (Hit.Parent.Name == "JOSH") and (Hit.Parent:FindFirstChild("Living")) and (not Elevator:findNPC("Gaga")) and (not TriggerActivated) then
			TriggerActivated = true
			Bathroom.Light.SurfaceLight.Enabled = true
			local Mystery = game.ServerStorage.NPCs:FindFirstChild("Gaga"):Clone()
			Mystery.Parent = Map
			Mystery:SetPrimaryPartCFrame(Bathroom.RightDoor.Main.Base.CFrame * CFrame.new(0,0,-1))
			require(Mystery.NPCScript):init("Elevator")
			local baseCframe = Bathroom.RightDoor.Main.PrimaryPart.CFrame
			for i = 1, 15 do
				Bathroom.RightDoor.Main:SetPrimaryPartCFrame(baseCframe * CFrame.Angles(0, math.rad(-6*i), 0))
				wait()
			end
		end
	end)
	
	spawn(function()
		wait(5)
		Bus.Engine.Going:Play()
		busPullUp(1)
		wait(1)
		busPullUp(2)
		busPullUp(3)
		busPullUp(4)
		busPullUp(5)
	end)
	math.randomseed(tick())
	local benchChance = math.random(1,3)
	if (benchChance == 1) then
		Kandy.Parent = Map
		Kandy.Handle.Anchored = false
		Spongebob.Parent = game.ServerStorage.MapStorage
		wait(7)
		Bench:Destroy()
		Spongebob.Parent = Map
		Spongebob:SetPrimaryPartCFrame(BobPositions.Bench.CFrame)
	else
		Bench.Parent = game.ServerStorage
		wait(3)
		modelTransparency(Spongebob.RightHand, 1)
		modelTransparency(Spongebob.RightHand2, 0)
		wait(0.1)
		Spongebob.RightHand2.Hand.Beep:Play()
		wait(0.6)
		modelTransparency(Spongebob.RightHand2, 1)
		modelTransparency(Spongebob.RightHand, 0)
		wait(1)
		Spongebob:SetPrimaryPartCFrame(Spongebob.PrimaryPart.CFrame*CFrame.Angles(0, math.pi/2, 0))
		Spongebob:SetPrimaryPartCFrame(Spongebob.PrimaryPart.CFrame * CFrame.new(0.5,0,0))
		wait(1)
		Kandy.Parent = Map
		Kandy.Handle.Anchored = false
	end
	
end

function Floor.ending(Map)
	TriggerConnection:Disconnect()
	TriggerActivated = false
	doorConnection:Disconnect()
	doorConnected = false
	for _, Player in pairs(Elevator.Players) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
end

return Floor