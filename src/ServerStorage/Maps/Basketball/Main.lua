local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 40 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.fromRGB(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {FogColor=Color3.fromRGB(67,51,72),FogEnd=250,OutdoorAmbient=Color3.new(0,0,0), Ambient=Color3.new(0,0,0), Brightness = 0.3, ClockTime=12},
	Sky = Floor.Skybox
}

local Balling = true
local Hoop
local boardGui

local trackTime = 0.4

local Scores = {}
local firstDetections = {}
local Connections = {}

local function sortLeaderboard()
	for num, Player in pairs(Scores) do
		local topScore = 0
		
	end
end

local function setVariables(Map)
	Balling = true
	Hoop = Map:FindFirstChild("Hoop")
	Hoop:MakeJoints()
	boardGui = Map.Scoreboard.Gui
	
	Connections[1] = Hoop.Goal.TopDetect.Touched:Connect(function(Hit)
		if (Hit.Name == "FakeBall") and (Hit:FindFirstChild("Shooter")) then
			firstDetections[Hit.Parent] = tick()
			spawn(function()
				wait(trackTime)
				if (firstDetections[Hit.Parent]) then
					firstDetections[Hit.Parent] = nil
				end
				
			end)
		end
	end)
	
	Connections[2] = Hoop.Goal.NetDetect.Touched:Connect(function(Hit)
		if (Hit.Name == "FakeBall") and (Hit:FindFirstChild("Shooter")) then
			if (firstDetections[Hit.Parent]) then
				if (game.Players:FindFirstChild(Hit.Shooter.Value)) then
					for _, Player in pairs(Scores) do
						if (Player.Player == game.Players:FindFirstChild(Hit.Shooter.Value)) then
							Player.Score = Player.Score+1
							--sortLeaderboard()
						end
					end
				end
				Hoop.Goal.NetDetect.Sound.PitchEffect.Octave = math.random(100, 120)/100
				Hoop.Goal.NetDetect.Sound:Play()
				if (firstDetections[Hit.Parent]) then
					firstDetections[Hit.Parent] = nil
				end
			end
		end
	end)
end

local function addPlayerToBoard(newPlayer)
	local num = #Scores+1
	Scores[num] = {Player=newPlayer,Score=0}
	local Frame = boardGui.Frame.Example:Clone()
	Frame.Parent = boardGui.Frame
	Frame.Score.Text = Scores[num].Score
	sortLeaderboard()
end

function Floor:initPlayer(Player)
	local Character = Player.Character
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	if (Functions:characterIsValid(Character)) and (Balling) then
		local Ball = game.ServerStorage.Halloween.Gear.PumpkinBall:Clone()
		Ball.Parent = Character
	end
	if (Balling) then
		--addPlayerToBoard(Player)
	end
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
end

function Floor.ending()
	Balling = false
	Connections = Functions:disconnectTableEvents(Connections)
	Floor.Sounds.Music:Stop()
	for _, Player in pairs(Elevator.Players) do
		local Ball = Player.Backpack:FindFirstChild("PumpkinBall")
		if (Ball) then
			--Ball.Parent = game.ServerStorage.MapStorage
			Ball.Event:FireClient(Player, "RemoveGui")
			Ball:Destroy()
		else
			local Character = Player.Character
			if (Character) then
				local Ball = Character:FindFirstChild("PumpkinBall")
				if (Ball) then
					--Ball.Parent = game.ServerStorage.MapStorage
					Ball.Event:FireClient(Player, "RemoveGui")
					Ball:Destroy()
				end
			end
		end
	end
	for _, Ball in pairs(Floor.Model:GetChildren()) do
		if (Ball:IsA("Tool")) and (Ball.Name == "PumpkinBall") then
			Ball:Destroy()
		end
	end
end

return Floor