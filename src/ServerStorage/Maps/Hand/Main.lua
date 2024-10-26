local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local soundEffects
local Hands
local bodyPos

Floor.Settings = {
	DOORS_OPEN = false,
	INTERACTIVE = false,
	TIME = 40 --seconds
}

local function setVariables(Map)
	soundEffects = Map.SoundEffects
	Hands = Map.Hands
	bodyPos = Hands.Grab.BodyPosition
	bodyPos.Position = Map.Destinations.Start.Position
end

function Floor:initPlayer(Player)

end

function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Silence:Play()
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic},{Color = Color3.new(27/255, 34/255, 39/255)})
	local effectAudio = Instance.new("Sound", Elevator.ButtonPad.Speaker)
	effectAudio.Name = "Shutdown"
	effectAudio.SoundId = "rbxassetid://276848267"
	effectAudio.Volume = 1
	effectAudio:Play()
	
	wait(5)
	
	local breakAudio = Instance.new("Sound", Elevator.ButtonPad.Speaker)
	breakAudio.Name = "Break"
	breakAudio.SoundId = "rbxassetid://528728818"
	breakAudio.Volume = 5
	breakAudio:Play()

	wait(15)
	
	soundEffects.Footsteps:Play()
	wait(3)
	soundEffects.Laugh:Play()
	wait(5)
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic},{Color = Color3.new(0,0,0)})
	effectAudio:Play()
	wait(0.5)
	soundEffects.Wood:Play()
	Elevator.Model.Walls.Top.Back.CanCollide = false
	Elevator.Model.Walls.Top.Back.Transparency = 1
	--[[for _, part in pairs(Elevator.Model.Decoration.Wreath:GetChildren()) do
		part.Transparency = 1
	end]]
	Map.Wall.Transparency = 0
	
	wait(2)
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic},{Color = Color3.new(27/255, 34/255, 39/255)})
	bodyPos.Position = Map.Destinations.End.Position
	wait(5)
	bodyPos.Position = Map.Destinations.Start.Position
	wait(3)
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic},{Color = Color3.new(0,0,0)})
	Elevator.Model.Walls.Top.Back.CanCollide = true
	Elevator.Model.Walls.Top.Back.Transparency = 0
	Map.Wall.Transparency = 1
	--[[for _, part in pairs(Elevator.Model.Decoration.Wreath:GetChildren()) do
		part.Transparency = 0
	end]]
	effectAudio:Destroy()
	breakAudio:Destroy()
end


return Floor