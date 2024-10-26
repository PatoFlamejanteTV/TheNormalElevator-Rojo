local PS = game:GetService("PathfindingService")
local TCS = game:GetService("TextChatService")

local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}


----HALLOWEEN VERSION

local VisualLights
local Lights
local Cast
local Table
local Freddie
local Sam
local Colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1)}

local ClickConnection
local bowlLifted = false
local samPath
local freddyPath
local Running = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 20 --seconds
}

Floor.Lighting = {
	Lighting = {OutdoorAmbient=Color3.new(0,0,0), ClockTime=12, Brightness = 0},
}

local function randomLight(Part)
	local Color = Colors[math.random(1,#Colors)]
	Part.Color = Color
	for _, L in pairs(Part:GetChildren()) do	
		if (L:IsA("Light")) then
			L.Enabled = true
			L.Color = Color
		end
		if (L:IsA("Decal")) then
			L.Color3 = Color
		end
	end
end

local function setVariables(Map)
	Floor.Sounds.Music.TimePosition = 28
	VisualLights = Map.VisualLights
	Lights = Map.Lights
	Freddie = Map.Freddie
	Sam = Map.Sam
	Table = Map.Table
	bowlLifted = false
	Running = true
	
	require(Freddie.NPCScript)
	require(Sam.NPCScript)
	
	ClickConnection = Table.Bowl.ProximityPrompt.Triggered:Connect(function(player)
		if (not bowlLifted) then
			bowlLifted = true
			local TP = Floor.Sounds.Music.TimePosition
			Floor.Sounds.Music:Stop()
			Table.Bowl:Destroy()
			Table.Head.Scream:Play()
			Table.Light.PointLight.Enabled = true
			Elevator.Time = Elevator.Time + 10
			wait(3)
			Map.Room.Door:SetPrimaryPartCFrame(Map.Room.Door.PrimaryPart.CFrame * CFrame.Angles(0,math.pi/2,0))
			Sam.Humanoid:MoveTo(Map.DoorPath.Position)
			Sam.Humanoid.MoveToFinished:Connect(function()
				Sam.Humanoid:MoveTo(Map.SamPath.Position)
			end)
			wait(0.6)
			Freddie.Humanoid:MoveTo(Map.DoorPath.Position)
			Freddie.Humanoid.MoveToFinished:Connect(function()
				Freddie.Humanoid:MoveTo(Map.FreddyPath.Position)
			end)
			wait(4)
			TCS:DisplayBubble(Sam.Head, "You got pranked!")
			TCS:DisplayBubble(Freddie.Head, "Got ya! Happy Halloween!")
			Table.Head.face.Texture = "rbxassetid://83022608"
			Floor.Sounds.Music.TimePosition = TP
			Floor.Sounds.Music:Play()
			Floor.Sounds.Music.PlaybackSpeed = 1
			local Parts = {}
			for _, Part in pairs(Lights:GetChildren()) do
				Part.PointLight.Range = 14
				Part.PointLight.Brightness = 4
				Part.PointLight.Enabled = true
				Parts[#Parts+1] = Part
			end
			for _, Part in pairs(VisualLights:GetChildren()) do
				Parts[#Parts+1] = Part
			end
			local Track1 = Sam.Humanoid:LoadAnimation(Map.Dance)
			local Track2 = Freddie.Humanoid:LoadAnimation(Map.Dance)
			Track1:Play()
			Track2:Play()
			for i = 1, 30 do
				if (Running) then
					Functions:recurseFunctionOnParts(randomLight, Parts)
					wait(0.5)
				end
			end
		end
	end)
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
end

function Floor.ending()
	Running = false
	bowlLifted = false
	if (ClickConnection) then
		ClickConnection:Disconnect()
	end
	--if (samPath) then samPath:Destroy() end
	--if (freddyPath) then freddyPath:Destroy() end
end

return Floor