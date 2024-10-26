local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

--HALLOWEEN VERSION

local Shiba
local Stations
local Noob = game.ServerStorage.NPCs.Noob

local danceTime = 20
local bonusTime = 1 --how much time to react to hit the next color for a bonus score
local scoreBonus = 100

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 65 --seconds
}

Floor.Lighting = {
	Color = {Brightness = 0.2, Contrast = 0.4, Saturation = 0.5, TintColor = Color3.fromRGB(225,247,255), Enabled = true},
	Lighting = {Brightness = 0, ClockTime = 0}
}

local Colors = {{Name = "Orange", Color = Color3.fromRGB(213, 115, 61)},
				{Name = "Purple", Color = Color3.new(0.7,0,0.7)},
				{Name = "Green", Color = Color3.new(0,1,0)},
				{Name = "White", Color = Color3.new(1,1,1)}
}
local Dancers = {}

local trackingSteps = false
local Connections = {}

math.randomseed(tick())

local function setVariables(Map)
	Shiba = Map.Shiba
	Stations = Map.Stations
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	for _, Player in pairs(Elevator.Players) do
		game.ReplicatedStorage.UI.DanceChatGui:Clone().Parent = Player.PlayerGui
		game.ReplicatedStorage.UI.DanceScoreGui:Clone().Parent = Player.PlayerGui
	end
end

local function typewriter(text)
	for _, Player in pairs(Elevator.Players) do
		local chatGui = Player.PlayerGui:FindFirstChild("DanceChatGui")
		if (chatGui) and (chatGui["Event"]) then
			chatGui.Event:FireClient(Player, "Chat", text)
		end
	end
	Shiba.Head.Bark:Play()
	local waitTime = text:len()
	wait(waitTime*0.04)
	--[[Banner.Dialog.Text = ""
	for i = 1, text:len() do
		Banner.Dialog.Text = text:sub(1, i)
		wait(0.035)
	end]]
	Shiba.Head.Bark:Stop()
end
--[[
local function sortLeaderboard()
	table.sort(Dancers, function(a, b) return a.Score > b.Score end)
	for i = 1, #Dancers do
		local frame = PlayerFrame:FindFirstChild("Player"..Dancers[i].Pos)
		frame.Rank.Text = (i==1 and "1st") or (i==2 and "2nd") or (i==3 and "3rd")
		frame.Score.Text = Dancers[i].Score
		local Station = Stations:FindFirstChild("Station"..Dancers[i].Pos)
		Station.ColorPanel.Board.Gui.Frame.Score.Label.Text = Dancers[i].Score
	end
end

local function updateLeaderboard(Index, Player)
	local playerFrame = PlayerFrame:FindFirstChild("Player"..Index)
	if (Player:IsA("Player")) then
		playerFrame.Clip.Picture.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&username="..Player.Name
	else
		playerFrame.Clip.Picture.Image = "rbxassetid://990119136"
	end
	playerFrame.Player.Text = Player.Name
	--playerFrame.Score.Label.Text = Dancers[Index].Score
end]]


local function getWinner()
	table.sort(Dancers, function(a, b) return a.Score > b.Score end)
	if (Dancers[1].Score == Dancers[2].Score) then	--Tie
		return nil
	end
	return Dancers[1]
end

local function getDancerFromPos(num)
	for i = 1, #Dancers do
		if (Dancers[i].Pos == num) then
			return Dancers[i]
		end
	end
end

local function setRandomColor(lastColor, Pos)
	local newColor
	repeat newColor = Colors[math.random(1, #Colors)] until newColor.Name ~= lastColor.Name
	local Station = Stations:FindFirstChild("Station"..Pos)
	local DanceFloor = Station.DanceFloor
	
	for _, glowPart in pairs(DanceFloor.Glow:GetChildren()) do
		glowPart.Color = newColor.Color
	end
	
	for _, Part in pairs(DanceFloor:GetChildren()) do
		if (Part:FindFirstChild("Emitter")) then
			Part.Emitter:Destroy()
		end
	end
	
	local colorPart = DanceFloor:FindFirstChild(newColor.Name)
	
	DanceFloor.Area.Light.Color = newColor.Color
	colorPart.Material = Enum.Material.Neon
	colorPart.Color = newColor.Color
	local GhostEmitter = Floor.Model.Emitter:Clone()
	GhostEmitter.Parent = colorPart
	GhostEmitter.Enabled = true
	
	return newColor.Name
end

local function colorTouched(colorPart, Hit, Pos)
	local Character = Hit.Parent
	local Player = game.Players:GetPlayerFromCharacter(Character)
	if (trackingSteps) and (Character) and (Character:FindFirstChild("Humanoid")) then
		for _, Part in pairs(colorPart.Parent:GetChildren()) do
			if (Part:IsA("BasePart")) then
				--Part.Material = Enum.Material.SmoothPlastic
			end
		end
		colorPart.Material = Enum.Material.Slate
		colorPart.Color = Color3.fromRGB(91, 93, 105)
		--colorPart.Material = Enum.Material.Neon
		local Dancer = getDancerFromPos(Pos)
		if (Dancer.Player.Name == Character.Name) then
			if (Dancer.nextColor == colorPart.Name) then
				Dancer.nextColor = setRandomColor(colorPart, Pos)
				local Station = Stations:FindFirstChild("Station"..Pos)
				local ScoreGui = Station.ColorPanel.Board.Score:Clone()
				ScoreGui.Parent = Station.ColorPanel.Board
				ScoreGui.Enabled = true
				ScoreGui.Frame.Score.Text = "+"..scoreBonus
				
				Dancer.Score = Dancer.Score + scoreBonus
				if (tick() - Dancer.lastTouched <= bonusTime) then
					Dancer.Score = Dancer.Score + scoreBonus/2
					ScoreGui.Frame.Bonus.Visible = true
				end
				Dancer.lastTouched = tick()
				spawn(function()
					for i = 1, 30 do
						ScoreGui.StudsOffset = ScoreGui.StudsOffset:Lerp(Vector3.new(0,6,0), i/30)
						wait()
					end
					ScoreGui:Destroy()
				end)
				
				Station.ColorPanel.Board.Gui.Frame.Score.Label.Text = Dancer.Score
			elseif (Dancer.nextColor ~= colorPart.Name) and (Dancer.lastPart ~= colorPart) then
				local Station = Stations:FindFirstChild("Station"..Pos)
				local ScoreGui = Station.ColorPanel.Board.Score:Clone()
				ScoreGui.Parent = Station.ColorPanel.Board
				ScoreGui.Enabled = true
				ScoreGui.Frame.Score.Text = "-"..scoreBonus*0.75
				ScoreGui.Frame.Score.TextColor3 = Color3.new(1,0,0)
				Dancer.Score = Dancer.Score - scoreBonus*0.75
				spawn(function()
					for i = 1, 30 do
						ScoreGui.StudsOffset = ScoreGui.StudsOffset:Lerp(Vector3.new(0,6,0), i/30)
						wait()
					end
					ScoreGui:Destroy()
				end)
				Station.ColorPanel.Board.Gui.Frame.Score.Label.Text = Dancer.Score
			end
			Dancer.lastPart = colorPart
		end
	end
end

local function initDanceFloors()
	trackingSteps = true
	for n, Dancer in pairs(Dancers) do
		Connections[n] = {}
		local Station = Stations:FindFirstChild("Station"..Dancer.Pos)
		local DanceFloor = Station:FindFirstChild("DanceFloor")
		Connections[n][1] = DanceFloor.Purple.Touched:Connect(function(Hit) colorTouched(DanceFloor.Purple, Hit, Dancer.Pos) end)
		Connections[n][2] = DanceFloor.Orange.Touched:Connect(function(Hit) colorTouched(DanceFloor.Orange, Hit, Dancer.Pos) end)
		Connections[n][3] = DanceFloor.Green.Touched:Connect(function(Hit) colorTouched(DanceFloor.Green, Hit, Dancer.Pos) end)
		Connections[n][4] = DanceFloor.White.Touched:Connect(function(Hit) colorTouched(DanceFloor.White, Hit, Dancer.Pos) end)
		Dancer.nextColor = setRandomColor({Name = "Black"}, Dancer.Pos)
		--updateLeaderboard(Dancer.Pos, Dancer.Player)
	end
end


function Floor:init(Map)
	--Elevator:changeLightProperties({Color = Color3.fromRGB(16, 42, 220)},{Color = Color3.new(0,0,1)})
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	wait(2.5)
	Floor.Sounds.Music.TimePosition = 20
	Floor.Sounds.Music:Play()
	Map.RoomLight.Light.Enabled = true
	Map.RoomLight.Switch:Play()
	for _, lightPart in pairs(Map.Chandelier.Lights:GetChildren()) do
		lightPart.Material = Enum.Material.Neon
	end
	--Shiba.Material = Enum.Material.ForceField
	wait(1)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = true
		end
	end
	typewriter("WELCOME MORTALS TO JOJO'S GHOST SHOW!")
	wait(1.5)
	typewriter("I AM YOUR DAZZLING GHOST, JOJO!")
	wait(1)
	typewriter("TONIGHT, WE WILL FORCE 3 BEINGS TO DANCE ON GRAVES!")
	wait(2)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = false
		end
	end
	
	local ignoreList = {}
	for num = 1, 3 do
		local rPlayer = Elevator:getRandomPlayer(ignoreList)
		if (rPlayer) then 
			Dancers[num] = {Player = rPlayer, Score = 0, Pos = num, nextColor = "Black", lastTouched = tick(), lastPart = nil}
			ignoreList[num] = rPlayer
		end
	end
	
	if (#Dancers < 3) then
		for num = #Dancers+1, 3 do
			local newNoob = Noob:Clone()
			newNoob:MakeJoints()
			newNoob.Parent = Map
			Dancers[num] = {Player = newNoob, Score = 0, Pos = num, nextColor = "Black", lastTouched = tick(), lastPart = nil}
		end
	end
	
	for num, Dancer in pairs(Dancers) do
		local Station = Stations:FindFirstChild("Station"..num)
		local Middle = Station.DanceFloor.Area
		local Character
		if (Dancer.Player:IsA("Player")) then
			Network:Send(Dancer.Player, "SetControl", false)
			Character = Dancer.Player.Character
		else
			Character = Dancer.Player
		end
		if (Character) then
			Character:MoveTo((Middle.CFrame*CFrame.new(0,2,0)).Position)
			if (Character:FindFirstChild("Humanoid")) then
				Character.Humanoid.WalkSpeed = 25
			end
		end
	end
	
	wait(1)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = true
		end
	end
	
	typewriter("OKAY SOULS, THIS IS HOW TO DO YOUR JOB")
	wait(2)
	typewriter("STEP ON THE GRAVE THAT LIGHTS UP TO CLOSE THE GHOST REALM")
	wait(2)
	typewriter("THE GHOSTS WILL KEEP TRYING TO ARISE, SO KEEP STEPPING")
	wait(1)
	initDanceFloors()
	wait(1)
	typewriter("READY?")
	wait(1)
	typewriter("SET.")
	wait(1)
	typewriter("BATTLE!")
	spawn(function()
		for t = danceTime, 1, -1 do
			for _, Station in pairs(Stations:GetChildren()) do
				Station.ColorPanel.Board.Gui.Frame.Time.Label.Text = t
			end
			wait(1)
		end
		trackingSteps = false
	end)
	
	for num, Dancer in pairs(Dancers) do
		if (Dancer.Player:IsA("Player")) then
			Network:Send(Dancer.Player, "SetControl", true)
		else
			local DanceFloor = Stations:FindFirstChild("Station"..Dancer.Pos).DanceFloor
			spawn(function()
				while trackingSteps do
					local nextColorPart = DanceFloor:FindFirstChild(Dancer.nextColor)
					local delayTime = math.random(10, 120)/100
					wait(delayTime)
					Dancer.Player.Humanoid:MoveTo(nextColorPart.Position)
					repeat wait(0.6) Dancer.Player.Humanoid.Jump = true until Dancer.nextColor ~= nextColorPart.Name or not trackingSteps
				end
			end)
		end
	end
	
	wait(1)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = false
		end
	end
	
	repeat wait() until trackingSteps == false
	wait(1)
	for _, Station in pairs(Stations:GetChildren()) do
		for _, Part in pairs(Station.DanceFloor:GetChildren()) do
			if (Part:FindFirstChild("Emitter")) then
				Part.Emitter:Destroy()
			end
		end
	end
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = true
		end
	end
	for _, Dancer in pairs(Dancers) do
		if (Dancer.Player:IsA("Player")) then
			Functions:teleportPlayer(Dancer.Player, Elevator.TeleportPos, false)
		end
	end
	typewriter("WOW. GOOD JOB DEFILING THOSE GRAVES.")
	wait(2)
	typewriter("BUT THE BEST DEFILER IS...")
	wait(2)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = false
		end
	end
	table.sort(Dancers, function(a, b) return a.Score > b.Score end)
	for _, Player in pairs(Elevator.Players) do
		local scoreGui = Player.PlayerGui:FindFirstChild("DanceScoreGui")
		if (scoreGui) then
			scoreGui.Enabled = true
			for i = 1, #Dancers do
				local frame = scoreGui.Frame:FindFirstChild("Player"..i)
				if (Dancers[i].Player:IsA("Player")) then
					frame.Clip.Picture.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&username="..Dancers[i].Player.Name
				else
					frame.Clip.Picture.Image = "rbxassetid://990119136"
				end
				frame.Player.Text = Dancers[i].Player.Name
				frame.Rank.Text = (i==1 and "1st") or (i==2 and "2nd") or (i==3 and "3rd")
				frame.Score.Text = Dancers[i].Score
			end
		end
	end
	local Winner = getWinner()
	if (Winner) then
		if (Winner.Player:IsA("Player")) then
			game:GetService("BadgeService"):AwardBadge(Winner.Player.UserId, 2124456073)
		end
		--PlayerFrame:FindFirstChild("Player"..Winner.Pos).BackgroundColor3 = Color3.fromRGB(255, 215, 71)
	end
	wait(3)
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceScoreGui")) then
			Player.PlayerGui.DanceScoreGui.Enabled = false
		end
	end
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui.Enabled = true
		end
	end
	if (Winner) then
		typewriter(Winner.Player.Name:upper() .. " IS NOW GUARANTEED TO BE HAUNTED! BRAVO!")
	else
		typewriter("A TIE? LOOKS LIKE YOU'RE ALL GETTING HAUNTED.")
	end
	
end

function Floor.ending()
	for n, Connection in pairs(Connections) do
		for i = 1, #Connection do
			Connection[i]:Disconnect()
		end
	end
	Connections={}
	Dancers = {}
	for _, Player in pairs(Elevator.Players) do
		if (Player.PlayerGui:FindFirstChild("DanceChatGui")) then
			Player.PlayerGui.DanceChatGui:Destroy()
		end
		if (Player.PlayerGui:FindFirstChild("DanceScoreGui")) then
			Player.PlayerGui.DanceScoreGui:Destroy()
		end
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
end

return Floor