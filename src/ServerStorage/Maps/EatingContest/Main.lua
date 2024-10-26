local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local TCS = game:GetService("TextChatService")

local Floor = {}

local Contestants = {}
local Judge
local Leaderboard
local EatEvent
local EatConnection
local Noob = game.ServerStorage.NPCs.Noob

local inContest = false

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 35 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0,Threshold = 0, Enabled = false},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0, Enabled = false},
	Rays = {Intensity = 0,Spread = 0, Enabled = false},
	Lighting = {Ambient=Color3.fromRGB(109,77,67), Brightness = 0,ClockTime=18,FogColor=Color3.fromRGB(50,31,31),FogEnd=150},
	Sky = Floor.Skybox
}

local function sortLeaderboard()
	for num, Contestant in pairs(Contestants) do
		local topScore = 0
		local Frame = Leaderboard:FindFirstChild("Player"..num)
		if (Contestant.Score >= topScore) then
			Frame.Score.TextColor3 = Color3.new(0,1,0)
			topScore = Contestant.Score
		else
			Frame.Score.TextColor3 = Color3.new(1,0,0)
		end
	end
end

local function updateContestantBoard(Index, Contestant)
	local Frame = Leaderboard:FindFirstChild("Player"..Index)
	Frame.Score.Text = Contestant.Score
	Frame.Title.Text = Contestant.Player.Name
	sortLeaderboard()
	if (not Contestant.Player:IsA("Player")) then
		Frame.Clip.Picture.Image = "rbxassetid://990119136"
	else
		Frame.Clip.Picture.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&username="..Contestant.Player.Name
	end
end

local function setVariables(Map)
	Judge = Map:FindFirstChild("Shedletsky")
	Leaderboard = Map.Scoreboard.Board.Leaderboard
	EatEvent = Map.Eat
	
	EatConnection = EatEvent.Event:Connect(function(Player)
		for num, Contestant in pairs(Contestants) do
			if (Player == Contestant.Player) and (inContest) then
				Contestant.Score = Contestant.Score + 1
				updateContestantBoard(num, Contestant)
				spawn(function()
					Map["Food"..num].Pie.Emitter.Enabled = true
					wait(0.15)
					Map["Food"..num].Pie.Emitter.Enabled = false
				end)
			end
		end
	end)
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end



local function addBotScore(num, Contestant)
	Contestant.Score = Contestant.Score + 1
	updateContestantBoard(num, Contestant)
	wait(math.random(1, 25)/math.random(45, 60))
	spawn(function()
		Floor.Model["Food"..num].Pie.Emitter.Enabled = true
		wait(0.15)
		Floor.Model["Food"..num].Pie.Emitter.Enabled = false
	end)
end

local function getWinner()
	table.sort(Contestants, function(a, b) return a.Score > b.Score end)
	if (Contestants[1].Score == Contestants[2].Score) then	--Tie
		return nil
	end
	return Contestants[1].Player
end

function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Elevator:enableSkybox(Floor.Skybox)
	Floor.Sounds.Music:Play()
	
	wait(2)
	TCS:DisplayBubble(Judge.Head, "Welcome to my annual pie eating contest!")
	wait(3)
	TCS:DisplayBubble(Judge.Head, "Here will be our 3 contestants!")
	wait(1)
	--Gather total possible amount of players
	local ignoreList = {}
	for num = 1, 3 do
		local rPlayer = Elevator:getRandomPlayer(ignoreList)
		if (rPlayer) then 
			Contestants[num] = {Player = rPlayer, Score = 0}
			ignoreList[num] = Contestants[num].Player
		end
	end
	--If not enough players then add NPCs
	if (#Contestants < 3) then
		for num = #Contestants+1, 3 do
			local newNoob = Noob:Clone()
			newNoob:MakeJoints()
			newNoob.Parent = Map
			Contestants[num] = {Player = newNoob, Score = 0}
		end
	end
	--Teleport players
	for num, Contestant in pairs(Contestants) do
		local Character
		if (Contestant.Player:IsA("Player")) then
			Network:Send(Contestant.Player, "SetControl", false)
			Character = Contestant.Player.Character
		else
			Character = Contestant.Player
		end
		updateContestantBoard(num, Contestant)
		if (Character) then
			Character:SetPrimaryPartCFrame(Map:FindFirstChild("Food"..num).Spawn.CFrame)
		end
	end
	--Countdown
	wait(3)
	TCS:DisplayBubble(Judge.Head, "Ready?")
	wait(1)
	TCS:DisplayBubble(Judge.Head, "Set.")
	--Give players eating ui
	for num, Contestant in pairs(Contestants) do
		if (Contestant.Player:IsA("Player")) then
			game.ReplicatedStorage.UI.EatGui:Clone().Parent = Contestant.Player.PlayerGui
		end
	end
	wait(1)
	TCS:DisplayBubble(Judge.Head, "EAT!")
	inContest = true
	spawn(function()
		for i = 15, 1, -1 do
			Map.Timer.Time.Gui.Label.Text = i
			wait(1)
		end
	end)
	for num, Contestant in pairs(Contestants) do
		if (not Contestant.Player:IsA("Player")) then
			spawn(function()
				while (inContest) do
					addBotScore(num, Contestant)
				end
			end)
		end
	end
	wait(15)
	inContest = false
	TCS:DisplayBubble(Judge.Head, "Time!")
	Map.Timer.Time.Gui.Label.Text = ""
	for num, Contestant in pairs(Contestants) do
		local Player = Contestant.Player
		if (Player:IsA("Player")) and (Player.PlayerGui:FindFirstChild("EatGui")) then
			Player.PlayerGui.EatGui:Destroy()
		end
	end
	wait(1)
	local Winner = getWinner()
	if (Winner) then
		TCS:DisplayBubble(Judge.Head, "The winner is " .. Winner.Name .. "!")
		pcall(function()
			if (Winner:IsA("Player")) then
				game:GetService("BadgeService"):AwardBadge(Winner.UserId, 273622985)
			end
		end)
	else
		TCS:DisplayBubble(Judge.Head, "It's a tie! You're all losers!")
	end
	Floor.Sounds.Music:Stop()
	wait(3)
	TCS:DisplayBubble(Judge.Head, "See you next time! I'll get to making more food...")
	for _, Contestant in pairs(Contestants) do
		if (Contestant.Player:IsA("Player")) then
			Network:Send(Contestant.Player, "SetControl", true)
			Functions:teleportPlayer(Contestant.Player, Elevator.TeleportPos, false)
		end
	end
	Contestants = {}
end

function Floor.ending()
	EatConnection:Disconnect()
end

return Floor