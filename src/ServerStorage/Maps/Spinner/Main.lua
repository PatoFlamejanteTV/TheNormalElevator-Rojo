local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local FakeRoom
local Elevators
local Pushers
local Spinner

local fakeStoredCollisions = {}

local Connections = {}

local Running = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	HIDE_NPCS = true,
	TIME = 40 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.fromRGB(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.fromRGB(127/255,127/255, 127/255), Brightness = 1,ClockTime=14}
}

local function setVariables(Map)
	FakeRoom = Map.FakeRoom
	FakeRoom.Parent = game.ServerStorage.WorldModel
	Functions:anchor(FakeRoom, true)
	Functions:weld(FakeRoom, true)
	FakeRoom.Parent = Map
	Elevators = Map.Elevators
	Pushers = Map.Pushers
	Spinner = Map.Spinner
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function activatePusher(Base)
	Functions:anchor(Base.Pusher, false)
	Base.Pusher.Base.BodyPosition.Position = (Base.Pusher.Base.CFrame*CFrame.new(50,0,0)).p
end

local function updateSpinner()
	for _, Blade in pairs(Spinner:GetChildren()) do
		Blade.CFrame = Blade.CFrame * CFrame.Angles(0,math.rad(10),0)
	end
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


function Floor:init(Map)
	setVariables(Map)
	Elevator:changeBackgroundColor(Color3.fromRGB(106, 166, 255))
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Connections[1] = Map.Break.Touched:Connect(function(Hit)
		if (Functions:characterIsValid(Hit.Parent)) or (Hit.Parent:IsDescendantOf(Elevators)) or (Hit.Parent:IsDescendantOf(FakeRoom)) then
			Hit.Parent:BreakJoints()
		end
	end)
	
	for _, Base in pairs(Pushers:GetChildren()) do
		local BP = Base.Pusher.Base.BodyPosition
		local BG = Base.Pusher.Base.BodyGyro
		BP.Position = Base.Pusher.Base.Position
		BP.MaxForce = Vector3.new(5000000,5000000,5000000)
		BP.D = 1000
		BP.P = 5000000
		
		BG.CFrame = Base.Pusher.Base.CFrame
		BG.P = 100000
		BG.MaxTorque = Vector3.new(40000,40000,40000)
	end
	
	Running = true
	spawn(function()
		while (Running) do
			updateSpinner()
			wait()
		end
	end)
	
	wait(0.5)
	Floor.Sounds.Calm:Play()
	
	for _, Pusher in pairs(Pushers:GetChildren()) do
		Pusher.Parent = game.ServerStorage.WorldModel
		Functions:anchor(Pusher.Pusher, true)
		Functions:weld(Pusher.Pusher, true)
		Pusher.Parent = Pushers
	end

	wait(15)
	
	for _, entrancePart in pairs(Elevators:GetChildren()) do
		local fakeElevator = Elevator:insertFakeElevator(Elevators, entrancePart)
		fakeElevator.Name = entrancePart.Name
		entrancePart:Destroy()
		fakeElevator.Parent = game.ServerStorage.WorldModel
		Functions:anchor(fakeElevator,true)
		Functions:weld(fakeElevator,true)
		fakeElevator.Parent = Elevators
	end
	
	---hide real elevator
	Functions:recurseFunctionOnParts(hidePart, Elevator.Model)
	
	--if (Elevators:FindFirstChild("Top")) then
	--	Functions:weld(Elevators.Top, true)
	--end
	--if (Elevators:FindFirstChild("Middle")) then
	--	Functions:weld(Elevators.Middle, true)
	--end
	--if (Elevators:FindFirstChild("Bottom")) then
	--	Functions:weld(Elevators.Bottom, true)
	--end
	
	Floor.Sounds.Calm:Stop()
	FakeRoom.Sun.Star.face.Transparency = 0
	wait(1)
	
	Functions:anchor(FakeRoom, false)
	wait(3)
	
	Floor.Sounds.Crazy:Play()
	Functions:anchor(Elevators.Top, false)
	wait(3)
	activatePusher(Pushers.Top)
	
	wait(5)
	Functions:anchor(Elevators.Middle, false)
	activatePusher(Pushers.Middle)
	Elevators.Bottom.Walls.Top.Back:Destroy()
	
	wait(5)
	Functions:anchor(Elevators.Bottom, false)
	activatePusher(Pushers.Bottom)
end

function Floor.ending()
	Running = false
	Elevator:lightsOff()
	Elevator:restore(true)
	Elevator:teleportPlayers()
	Connections = {}
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
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
	fakeStoredCollisions = {}
end

return Floor