local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local TV
local Screen

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 25 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0,Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {Brightness = 1, FogColor=Color3.fromRGB(73, 160, 184), FogStart = 40, FogEnd=120, ClockTime=14}
}

local function setVariables(Map)
	TV = Map.TV.Screen
	Screen = TV.SurfaceGui.Static
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function tvOn()
	TV.Transparency = 0.9
	TV.Static:Stop()
	Screen.ImageTransparency = 0.7
	Screen.BackgroundTransparency = 1
end

local function tvOff()
	for i = 1, 5 do
		TV.Transparency = 0.9 - i/5
		wait()
	end
	TV.Static:Play()
	Screen.ImageTransparency = 0
	Screen.BackgroundTransparency = 0
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:lightsOff()
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Floor.Sounds.Ambience:Play()
	
	wait(5)
	tvOff()
	
	wait(0.5)
	local Ring = game.ServerStorage.NPCs.Ring:Clone()
	Ring.Parent = Map
	Ring:SetPrimaryPartCFrame(Map.RingPosition.CFrame)
	local rHumanoid = Ring:FindFirstChild("Humanoid")
	local crawlTrack = rHumanoid:LoadAnimation(Ring.Crawl)
	
	wait(0.5)
	tvOn()
	crawlTrack:Play()
	
	wait(crawlTrack.Length)
	crawlTrack:Stop()
	tvOff()
	
	wait(0.5)
	Ring:SetPrimaryPartCFrame(Map.RingPosition2.CFrame)
	local walkTrack = rHumanoid:LoadAnimation(Ring.Walk)
	walkTrack:Play()
	rHumanoid:MoveTo(TV.Position)
	wait(0.5)
	tvOn()
	
	wait(3)
	tvOff()
	
	wait(0.4)
	Ring:SetPrimaryPartCFrame(Map.RingPosition3.CFrame)
	rHumanoid:MoveTo(TV.Position)
	wait(0.4)
	tvOn()
	
	wait(2)
	tvOff()
	
	wait(0.2)
	Ring:SetPrimaryPartCFrame(Map.RingPosition4.CFrame)
	rHumanoid:MoveTo(TV.Position)
	wait(0.2)
	tvOn()
	
	wait(1)
	tvOff()
	
	wait(0.1)
	Ring:SetPrimaryPartCFrame(Map.RingPosition5.CFrame)
	rHumanoid:MoveTo(TV.Position)
	wait(0.1)
	tvOn()
	
	wait(1)
	Screen.ImageTransparency = 1
	Screen.BackgroundTransparency = 0
	TV.SurfaceLight.Enabled = false
	Floor.Sounds.Ambience:Stop()
	Elevator.Model.FakeDoor.CanCollide = true
	
	for _, Player in pairs(Elevator.Players) do
		Network:Send(Player, "LoadLighting", {Lighting = {Brightness = 0}})
	end
	
	wait(3)
	Ring:SetPrimaryPartCFrame(Map.RingAttackPos.CFrame)
	Screen.ImageTransparency = 0
	TV.Static:Play()
	TV.SurfaceLight.Enabled = true
	rHumanoid.WalkSpeed = 10
	Ring.Track.Disabled = false
	Ring.Head.Scream:Play()
	TV.CanCollide = false
	
end

function Floor.ending()
	local Ring = Floor.Model:FindFirstChild("Ring")
	if (Ring) and (Ring.Head.Scream.IsPlaying) then
		Ring.Head.Scream:Stop()
	end
end

return Floor