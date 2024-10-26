local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Lights
local Ghosts
local Bolts
local Stars

local fakeStoredCollisions = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	HIDE_NPCS = true,
	TIME = 40 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0}
}

local function setVariables(Map)	
	Lights = Map.Lights
	Ghosts = Map.Ghosts
	Bolts = Map.Bolts
	Stars = Map.Stars
	
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function flash()
	for i = 2,1,-.03 do
		Lights.Light1.PointLight.Brightness = i
		Lights.Light2.PointLight.Brightness = i
		wait()
	end
	for i = 0.6,0.2,-0.008 do
		Lights.Light1.Transparency = i
		Lights.Light2.Transparency = i
		wait()
	end
	for i = 0.2,0.6,0.008 do
		Lights.Light1.Transparency = i
		Lights.Light2.Transparency = i
		wait()
	end
	for i = 0.6,0.2,-0.008 do
		Lights.Light1.Transparency = i
		Lights.Light2.Transparency = i
		wait()
	end
	for i = 0.2,0.9,0.008 do
		Lights.Light1.Transparency = i
		Lights.Light2.Transparency = i
		wait()
	end
end

function GhostIn()
	Ghosts.SurfaceGui.ImageLabel.Visible = true
	for y = 0.2,10,.3 do
		Ghosts.Size = Vector3.new(0.2,y,0.2)
	--	script.Parent.Ghosts.Position = Vector3.new(-3.32, 4.7, -45.7)
		wait()
	end	
	
	for x = 0.2,11,.2 do
		Ghosts.Size = Vector3.new(x,10.2,0.2)
		--script.Parent.Ghosts.Position = Vector3.new(-3.32, 4.7, -45.7)
		wait()
	end
end

function GhostOut()
	for x = 11,0.2,-.6 do
		Ghosts.Size = Vector3.new(x,10.2,0.2)
		--script.Parent.Ghosts.Position = Vector3.new(-3.32, 4.7, -45.7)
		wait()
	end
		
	for y = 10,0.2,-.7 do
		Ghosts.Size = Vector3.new(0.2,y,0.2)
	--	script.Parent.Ghosts.Position = Vector3.new(-3.32, 4.7, -45.7)
		wait()
	end	
	Ghosts.SurfaceGui.ImageLabel.Visible = false
end

function Lightning()
	local lighttime = 0.06
	Bolts.BoltConnect.Script.Disabled = false
	for i = 1,15 do
	Bolts.Bolt1R.SurfaceGui.ImageLabel.Visible = true
	Bolts.Bolt1L.SurfaceGui.ImageLabel.Visible = true
	Lights.Light1.Transparency = 0.3
	Lights.Light2.Transparency = 0.3
	wait(lighttime)
	Lights.Light1.Transparency = 0.6
	Lights.Light2.Transparency = 0.6
	Bolts.Bolt1R.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt1L.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt2R.SurfaceGui.ImageLabel.Visible = true
	Bolts.Bolt2L.SurfaceGui.ImageLabel.Visible = true
	wait(lighttime)
	Bolts.Bolt2R.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt2L.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt3R.SurfaceGui.ImageLabel.Visible = true
	Bolts.Bolt3L.SurfaceGui.ImageLabel.Visible = true
	wait(lighttime)
	Bolts.Bolt3R.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt3L.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt4R.SurfaceGui.ImageLabel.Visible = true
	Bolts.Bolt4L.SurfaceGui.ImageLabel.Visible = true
	wait(lighttime)
	Bolts.Bolt4R.SurfaceGui.ImageLabel.Visible = false
	Bolts.Bolt4L.SurfaceGui.ImageLabel.Visible = false
	end
end


function FadeHall()
	Lights.FadeLamps.Disabled = false
	Stars.Group1.Illuminate.Disabled = false
	for i = 1,0,-.01 do
		Lights.LightRow1.PointLight.Brightness = i
		Lights.PlantLight.PointLight.Brightness = i
		Lights.Light1.PointLight.Brightness = i
		Lights.Light2.PointLight.Brightness = i
		wait()
	end
	Stars.Group2.Illuminate.Disabled = false	
	for i = 1,0,-.008 do
		Lights.LightRow2.PointLight.Brightness = i
		wait()
	end
	Stars.Group3.Illuminate.Disabled = false
		for i = 0.5,0,-.008 do
		Lights.LightRow3B.PointLight.Brightness = i
		wait()
		end
	Stars.Group4.Illuminate.Disabled = false
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
	
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	
	Elevator:changeLightProperties({},{Brightness = 0.25, Range = 12})
	
	Floor.Sounds.Audio:Play()
	flash()
	GhostIn()
	Lightning()
	GhostOut()
	FadeHall()
	
	Map.FakeElevator.DoorL.Script.Disabled = false
	Map.FakeElevator.DoorR.Script.Disabled = false
	wait(2)
	Map.FakeElevator.Drop.Script.Disabled = false
	Map.FakeElevator.Frame.Script.Disabled = false
	wait(1.8)
	Map.CrashSound.Sound:Play()
	local fakeElevator = Elevator:insertFakeElevator(Map, Elevator.Model.EntrancePart)
	fakeElevator.Name = "ReplicaElevator"
	fakeElevator.Parent = game.ServerStorage.WorldModel
	Functions:anchor(fakeElevator, true)
	Functions:weld(fakeElevator, true)
	fakeElevator.Parent = Map
	Elevator:lightsOff()
	Functions:recurseFunctionOnParts(hidePart, Elevator.Model)
	spawn(function()
		for i = 1, 120 do
			Elevator:changeLightProperties({},{Brightness = math.random(1, 10)/10}, fakeElevator)
			wait(0.05)
		end
		Elevator:changeLightProperties({},{Brightness = 0.05}, fakeElevator)
	end)
	wait(0.2)
	Functions:anchor(fakeElevator, false)
end

function Floor.ending()
	Elevator:lightsOff()
	Elevator:restore(true)
	Elevator:teleportPlayers()
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
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
	fakeStoredCollisions = {}
end

return Floor