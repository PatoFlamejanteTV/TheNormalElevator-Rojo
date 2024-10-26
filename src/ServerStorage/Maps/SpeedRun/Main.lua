local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local BadgeService = game:GetService("BadgeService")

local Floor = {}

local Running = true
local deathParts
local winnerDB = true
local loserDB = true
local deathDB = {}
local secretDB = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = true,
	TIME = 60 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0.1,Contrast = 0.2,TintColor = Color3.fromRGB(170,85,255),Saturation = 0.6, Enabled = true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {Ambient=Color3.fromRGB(77,157,89),OutdoorAmbient=Color3.fromRGB(171,97,53), ClockTime=12,Brightness = 0},
}

local function setVariables(Map)
	deathParts = Map.DeathParts:GetChildren()
	for _, Part in pairs(deathParts) do
		deathDB[Part] = true
	end
	Running = true
end

local function setConnections()
	for _, Part in pairs(deathParts) do
		Part.Touched:connect(function(Hit)
			local Character = Hit.Parent
			if (Functions:characterIsValid(Character)) and (deathDB[Part]) then
				deathDB[Part] = false
				local Player = game.Players:GetPlayerFromCharacter(Character)
				Functions:teleportPlayer(Player, Elevator.TeleportPos)
				wait()
				deathDB[Part] = true
			end
		end)
	end
	Floor.Model.WinnerTeleportation.Touched:connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) and (winnerDB) then
			winnerDB = false
			local Player = game.Players:GetPlayerFromCharacter(Character)
			Functions:teleportPlayer(Player, Floor.Model.WinnerTeleport.CFrame)
			local Cookie = game.ServerStorage.Gear.Cookie:Clone()
			Cookie.Parent = Character
			BadgeService:AwardBadge(Player.UserId, 272350605)
			wait(0.5)
			winnerDB = true
		end
	end)
	Floor.Model.LoserTeleportation.Touched:connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) and (loserDB) then
			loserDB = false
			local Player = game.Players:GetPlayerFromCharacter(Character)
			Functions:teleportPlayer(Player, Floor.Model.LoserTeleport.CFrame)
			wait()
			loserDB = true
		end
	end)
	Floor.Model.HigherSound.Touched:connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) then
			local Player = game.Players:GetPlayerFromCharacter(Character)
			if (secretDB[Player] == false) then
				secretDB[Player] = true
				Network:Send(Player, "ChangeMusicProperties", {{Music = Floor.Sounds.Music, Properties = Floor.MusicProperties, Tween = TweenInfo.new(1)}})
			end
		end
	end)
	Floor.Model.LowerSound.Touched:connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) then
			local Player = game.Players:GetPlayerFromCharacter(Character)
			if (secretDB[Player] == true) then
				secretDB[Player] = false
				Network:Send(Player, "ChangeMusicProperties", {{Music = Floor.Sounds.Music, Properties = {Volume = 0}, Tween = TweenInfo.new(1)}})
			end
		end
	end)
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
	local Character = Player.Character
	if (Functions:characterIsValid(Character)) and (Running) then
		local Humanoid = Character.Humanoid
		Humanoid.WalkSpeed = 50
	end
	secretDB[Player] = true
end


function Floor:init(Map)
	setVariables(Map)
	setConnections()
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
end

function Floor.ending()
	Running = false
	Floor.Sounds.Music:Stop()
	for _, Player in pairs(Elevator.Players) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
end

return Floor