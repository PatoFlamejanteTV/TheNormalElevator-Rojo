_G.Modules = require(script.Modules.Modules)
_G.Modules:LoadAll()

math.randomseed(tick())

local Lobby = _G.Modules.Lobby
local Elevator = _G.Modules.Elevator
local Functions = _G.Modules.Functions
local Network = _G.Modules.Network
local Data = _G.Modules.Data

local PhysicsService = game:GetService("PhysicsService")
local MPS = game:GetService("MarketplaceService")

local characterGroupName = "Characters"
local characterGroup = PhysicsService:CreateCollisionGroup(characterGroupName)

PhysicsService:CollisionGroupSetCollidable(characterGroupName, characterGroupName, false)

local bodyParts = {"HumanoidRootPart","UpperTorso","LowerTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}

local function addChildrenToGroup(instance, groupName)
	instance.DescendantAdded:Connect(function(Part) addChildrenToGroup(Part, groupName) end)
	for _, v in pairs(instance:GetChildren()) do
		 if v:IsA("BasePart") then
			--print("	-Setting "..v.Name:upper() .. " collision off")
		 	PhysicsService:SetPartCollisionGroup(v, groupName)
		 else
		 	addChildrenToGroup(v, groupName)
		 end
	end
end

local teleportPos = Elevator.Model.TeleportPart.CFrame

function PlayerAdded(Player)
	
	Player.CharacterAdded:Connect(function(Character)
		Player.CharacterAppearanceLoaded:Wait()
		for _, partName in pairs(bodyParts) do
			Character:WaitForChild(partName)
		end
		wait(0.05)
		print("CHARACTER SPAWNED["..Character.Name.."]")
		addChildrenToGroup(Character, characterGroupName)
		Network:Send(Player, "CharacterAdded")
		Network:Send(Player, "SetControl", true)
		local Humanoid = Character:WaitForChild("Humanoid")
		local PlayerName = game.ReplicatedStorage.PlayerName:Clone()
		PlayerName.Parent = Character:FindFirstChild("Head")
		PlayerName.Frame.Title.Text = Humanoid.DisplayName
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		Humanoid.Died:connect(function()
			Elevator:removePlayer(Player)
			Data:addStat(Player, "Deaths", 1)
			Network:Send(Player, "CharacterDied")
		end)
		if (MPS:UserOwnsGamePassAsync(Player.UserId, 1248198)) or (Data.youtubeIds[Player.UserId]) then	--permanent gears 1
			for _, Gear in pairs(game.ReplicatedStorage.Shop.Set1:GetChildren()) do
				Gear:Clone().Parent = Player.Backpack
			end
		end
		if (MPS:UserOwnsGamePassAsync(Player.UserId, 6129872)) or (Data.youtubeIds[Player.UserId]) then
			for _, Gear in pairs(game.ReplicatedStorage.Shop.Set2:GetChildren()) do
				Gear:Clone().Parent = Player.Backpack
			end
		end
		local playerData = Data:getPlayerData(Player)	---<<---- STUCK HERE vvvvv
		if (playerData) then
			if (playerData.Special.Control==true) or ((game.PrivateServerId~="") and (game.PrivateServerOwnerId==Player.UserId)) then
				wait(0.4)
				local ElevatorControl = game.ServerStorage.ElevatorControl:Clone()
				ElevatorControl.Parent = Player.PlayerGui
			end
		end
	end)
	game:GetService("BadgeService"):AwardBadge(Player.UserId, 272350549)
	Data:addPlayer(Player)
end

function PlayerRemoved(Player)
	Data:removePlayer(Player)
	Elevator:removePlayer(Player)
end

for _, Player in pairs(game.Players:GetPlayers()) do
	PlayerAdded(Player)
end

game.Players.PlayerAdded:connect(PlayerAdded)
game.Players.PlayerRemoving:connect(PlayerRemoved)

local isVIPServer = (game.PrivateServerId~="") and (game.PrivateServerOwnerId~=0)

Lobby:loadNPCs()
Elevator:loadMaps(true)
Elevator:loadMusic(true)

local backDB = true

for _, Part in pairs(Elevator.Background:GetChildren()) do
	if (Part:IsA("BasePart")) then
		Part.Touched:Connect(function(Hit)
			local Character = Hit.Parent
			if (Functions:characterIsValid(Character)) then
				local Player = game.Players:GetPlayerFromCharacter(Character)
				Functions:teleportPlayer(Player, Elevator.TeleportPos)
			elseif (Functions:getHumanoid(Character)) and (Functions:getHumanoid(Character).Name == "NPC") then
				if (Elevator.NPCs[Character]) then
					Character:SetPrimaryPartCFrame(Elevator.Model.TeleportPart.CFrame)
				end
			end
		end)
	end
end

local breakChance = 1000

while true do
	
	if (Elevator.bossActivated) then
		print"OK"
		Elevator:initBoss()
		continue
	end
	
	Elevator:playMusic(Elevator:pickMusic())
	
	for _, Player in pairs(Elevator.Players) do
		Network:Send(Player, "ElevatorMusicPlaying")
	end
	for timer = Elevator.INTERMISSION, 1, -1 do
		Elevator:updateTimerParts(Elevator.Model, timer, Elevator.ButtonPad.TimerPart)
		wait(1)
		if (timer == 13) and (math.random(1, breakChance) == 1) and (#Elevator.Players>1) then
			Elevator:crash()
		end
	end
	Elevator:stopMusic()
	local success, err = pcall(function()
		local Floor = nil
		if (#Elevator.Maps > 0) then
			--print"not random"
			Floor = Elevator.Maps[1]
			table.remove(Elevator.Maps, 1)
			Elevator.Maps[#Elevator.Maps+1] = Floor
			--for n, Map in pairs(Elevator.Maps) do
			--	Elevator.Maps[n-1] = Elevator.Maps[n]
			--end
			for _, Player in pairs(game.Players:GetPlayers()) do
				if (Player.PlayerGui:FindFirstChild("ElevatorControl")) then
					Network:Send(Player, "RefreshList")
				end
			end
		else
			--print"random"
			local realMaps = game.ServerStorage.Maps:GetChildren()
			local random = math.random(1, #realMaps)
			Floor = realMaps[random]
		end
		if (Floor) then
			local Map = Elevator:insertMap(Floor)
			local Sounds = Map:FindFirstChild("Sounds")
			local MapScript = Elevator.MapScripts[Map.Name]
			local Settings = MapScript.Settings
			
			local Skybox = game.ReplicatedStorage.Skybox:FindFirstChild(Map.Name)
			if (Skybox) then
				MapScript.Skybox = Skybox:Clone()
				MapScript.Skybox.Parent = game.Lighting
			end
			MapScript.Model = Map
			if (Sounds) then
				for _, Sound in pairs(Sounds:GetChildren()) do
					if (Sound:IsA("Sound")) then
						Sound:Clone().Parent = Elevator.Sounds
					end
				end
			end
			MapScript.Sounds = Elevator.Sounds
			
			Elevator:updateTimerParts(Elevator.Model, Settings.TIME, Elevator.ButtonPad.TimerPart)
			spawn(function() MapScript:init(Map) end)
			Elevator.currentMap = Map
			if (Settings.INTERACTIVE) then Elevator.Model.FakeDoor.CanCollide = false end
			if (Settings.DOORS_OPEN) then Elevator:openDoors(Elevator.Model) end
			if (Settings.HIDE_NPCS) then Elevator:hideNPCs() end
			
			while (Elevator.Time >= 1) do
				wait(1)
				Elevator.Time = Elevator.Time - 1
				Elevator:updateTimerParts(Elevator.Model, Elevator.Time, Elevator.ButtonPad.TimerPart)
			end
			if (MapScript.ending) then MapScript.ending() end
			if (Settings.INTERACTIVE) then Elevator.Model.FakeDoor.CanCollide = true Elevator:teleportPlayers() end
			if (Settings.DOORS_OPEN) then Elevator:closeDoors(Elevator.Model) end
			if (Settings.HIDE_NPCS) then Elevator:showNPCs() end
			for _, Player in pairs(Elevator.Players) do
				local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
				if (PlayerData) then
					PlayerData.Stats.Coins.Value = PlayerData.Stats.Coins.Value + 1
					PlayerData.Stats.Floors.Value = PlayerData.Stats.Floors.Value + 1
				end
			end
		end
	end)
	if (not success) then print(err) end
	Elevator:removeMap()
	Elevator.currentMap = nil
	Elevator:reset()
end