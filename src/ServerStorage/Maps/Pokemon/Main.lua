local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local TCS = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local BadgeService = game:GetService("BadgeService")

local Floor = {}

local Ash
local Brock
local Pokeball = game.ServerStorage.Gear.Pokeball
local attackEvent

local Attacks = {
	"Thunderbolt",
	"Flamethrower",
	"Tornado",
	"Rock Slide"
}

local NEEDED_PLAYERS = 2
local Battlers = {}
local Noob = game.ServerStorage.NPCs.Noob
local playerAttack
local attackConnection

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 40 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0.2,Contrast = 0.5,TintColor = Color3.fromRGB(199,99,90),Saturation = -0.3,Enabled=true},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {OutdoorAmbient=Color3.fromRGB(30,26,84), Ambient=Color3.new(0,0,0),GeographicLatitude=24,Brightness=0, EnvironmentDiffuseScale=0.108,ClockTime=20,FogColor=Color3.new(0,0,0),FogEnd=355},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Ash = Map.Ash
	Brock = Map.Brock
	attackEvent = Map.Attack
	attackConnection = attackEvent.Event:Connect(function(Player, attackName)
		if (Battlers[1] == Player) or (Battlers[2] == Player) and (Functions:GetObjectFromTable(Attacks, attackName)) then
			playerAttack = attackName
		end
	end)
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function choosePokemon(num)
	local Character
	local newBall = Pokeball:Clone()
	if (not Battlers[num]) then
		Character = Noob:Clone()
		Battlers[num] = Character
	end
	if (num == 1) then	--Brock
		newBall.Parent = Brock
		TCS:DisplayBubble(Brock.Head, "Go, " .. Battlers[num].Name .. "!")
	elseif (num == 2) then
		newBall.Parent = Ash
		TCS:DisplayBubble(Ash.Head, "I choose you, " .. Battlers[num].Name .. "!")
	end
	wait(0.2)
	newBall.Handle.Release:Play()
	if (Battlers[num]:IsA("Player")) and (Functions:characterIsValid(Battlers[num].Character)) then
		Network:Send(Battlers[num], "SetControl", false)
		Functions:teleportPlayer(Battlers[num], Floor.Model:FindFirstChild("Pokemon"..num).CFrame*CFrame.new(0,4,0), false)
	elseif (Battlers[num]:IsA("Player")) and (not Functions:characterIsValid(Battlers[num].Character)) then
		Character = Noob:Clone()
		Battlers[num] = Character
		Character.Parent = Floor.Model
		Character:SetPrimaryPartCFrame(Floor.Model:FindFirstChild("Pokemon"..num).CFrame*CFrame.new(0,4,0))
	elseif (not Battlers[num]:IsA("Player")) then
		Character.Parent = Floor.Model
		Character:SetPrimaryPartCFrame(Floor.Model:FindFirstChild("Pokemon"..num).CFrame*CFrame.new(0,4,0))
	end
end

local function generateThunderBolt(point1, point2)
	local Segments = 4
	local nextPoint = point1
	local lastPoint
	local Model = Instance.new("Model", Floor.Model)
	Model.Name = "Bolt"
	for i = 1, Segments do
		lastPoint = nextPoint
		nextPoint = (CFrame.new(lastPoint, point2) * CFrame.new(math.random(-3, 3),math.random(-3, 3),-math.random(4,5))).p
		if (i == Segments) then
			nextPoint = point2
		end
		local dist = (lastPoint - nextPoint).magnitude
		local Cylinder = game.ServerStorage.Models.Cylinder:Clone()
		Cylinder.Name = "Segment"..i
		Cylinder.Parent = Model
		Cylinder.Size = Vector3.new(0.3,dist,0.3)
		Cylinder.Color = Color3.new(1,1,0)
		Cylinder.Material = Enum.Material.Neon
		Cylinder.Transparency = 0.3
		Cylinder.CanCollide = false
		Cylinder.CFrame = CFrame.new(lastPoint, nextPoint) * CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,-dist/2,0)
		wait(0.05)
	end
	return Model
end

local function pokemonAttack(num)
	local Attack = playerAttack or Attacks[math.random(1, #Attacks)]
	playerAttack = nil
	local OppositeNum = (num%NEEDED_PLAYERS)+1
	local OppositeSpawn = Floor.Model:FindFirstChild("Pokemon"..OppositeNum)
	local Enemy
	local Battler
	if (Battlers[num]:IsA("Player")) and (Functions:characterIsValid(Battlers[num].Character)) then
		Battler = Battlers[num].Character
	elseif (not Battlers[num]:IsA("Player")) then
		Battler = Battlers[num]
	end
	if (num == 1) then
		TCS:DisplayBubble(Brock.Head, Battlers[num].Name .. ", use " .. Attack .. "!")
		Enemy = Battlers[2]
		if (Battlers[2]:IsA("Player")) and (Functions:characterIsValid(Battlers[2].Character)) then
			Enemy = Battlers[2].Character
		elseif (not Battlers[2]:IsA("Player")) then
			Enemy = Battlers[2]
		end
	elseif (num == 2) then
		TCS:DisplayBubble(Ash.Head, Battlers[num].Name .. ", use " .. Attack .. "!")
		Enemy = Battlers[1]
		if (Battlers[1]:IsA("Player")) and (Functions:characterIsValid(Battlers[1].Character)) then
			Enemy = Battlers[1].Character
		elseif (not Battlers[1]:IsA("Player")) then
			Enemy = Battlers[1]
		end
	end
	if (Attack == "Thunderbolt") then
		--local Thunder = game.ServerStorage.Models.Thunder:Clone()
		--Thunder.Parent = Floor.Model
		--Thunder:SetPrimaryPartCFrame(OppositeSpawn.CFrame)
		local Bubble = game.ServerStorage.Models.Bubble:Clone()
		Bubble.Parent = Battler:FindFirstChild("HumanoidRootPart")
		wait(0.2)
		--Thunder.Bolt.Transparency = 0
		--Thunder.Bolt.Thunder:Play()
		local Bolts = game.ServerStorage.Models.Bolts:Clone()
		Bolts.Parent = Enemy:FindFirstChild("HumanoidRootPart")
		local Thunder = generateThunderBolt(Bubble.Parent.Position, Bolts.Parent.Position)
		Floor.Model:FindFirstChild("Pokemon"..num).Thunder:Play()
		local meshTextures = {}
		local partColors = {}
		local changeColor = Color3.new(1,1,0)
		local function color(Part)
			if (not partColors[Part]) then
				partColors[Part] = Part.Color
			end
			Part.Color = changeColor
			if (Part.Name == "Handle") then
				for _, Mesh in pairs(Part:GetChildren()) do
					if (Mesh:IsA("SpecialMesh")) then
						if (not meshTextures[Mesh]) then
							meshTextures[Mesh] = Mesh.TextureId
						end
						Mesh.TextureId = ""			
					end
				end
			end
		end
		for i = 1, 10 do
			changeColor = Color3.new(1,1,0)
			Functions:recurseFunctionOnParts(color, Enemy)
			wait(0.1)
			changeColor = Color3.new(0,0,0)
			Functions:recurseFunctionOnParts(color, Enemy)
			wait(0.1)
		end
		for Part, Color in pairs(partColors) do
			Part.Color = Color
		end
		for Mesh, Texture in pairs(meshTextures) do
			Mesh.TextureId = Texture
		end
		Thunder:Destroy()
		Bubble:Destroy()
		Bolts:Destroy()
	elseif (Attack == "Flamethrower") then
		local FirePart = Floor.Model:FindFirstChild("Fire"..num)
		FirePart.Fire.Enabled = true
		FirePart.Sound:Play()
		
		local meshTextures = {}
		local partColors = {}
		local changeColor = Color3.new(0,0,0)
		local function color(Part)
			if (not partColors[Part]) then
				partColors[Part] = Part.Color
			end
			Part.Color = changeColor
			if (Part.Name == "Handle") then
				for _, Mesh in pairs(Part:GetChildren()) do
					if (Mesh:IsA("SpecialMesh")) then
						if (not meshTextures[Mesh]) then
							meshTextures[Mesh] = Mesh.TextureId
						end
						Mesh.TextureId = ""			
					end
				end
			end
		end
		wait(1)
		Functions:recurseFunctionOnParts(color, Enemy)
		wait(1)
		FirePart.Fire.Enabled = false
		FirePart.Sound:Stop()
		wait(1)
		for Part, Color in pairs(partColors) do
			Part.Color = Color
		end
		for Mesh, Texture in pairs(meshTextures) do
			Mesh.TextureId = Texture
		end
	elseif (Attack == "Tornado") then
		local Tornado = Floor.Model:FindFirstChild("Tornado"..num)
		local TornadoCFrame = Tornado.CFrame
		Tornado.Smoke.Enabled = true
		Tornado.Sound:Play()
		wait(1)
		local TornadoInfo = TweenInfo.new(0.8)
		local TornadoGoal = {CFrame = CFrame.new(OppositeSpawn.CFrame.X, Tornado.CFrame.Y, OppositeSpawn.CFrame.Z)}
		local Tween = TweenService:Create(Tornado, TornadoInfo, TornadoGoal)
		Tween:Play()
		wait(0.8)
		local bodyAV = Instance.new("BodyAngularVelocity")
		if (not Battlers[OppositeNum]:IsA("Player")) then
			bodyAV.Parent = Battlers[OppositeNum].PrimaryPart or Battlers[OppositeNum]:FindFirstChild("HumanoidRootPart")
		else
			bodyAV.Parent = Battlers[OppositeNum].Character.PrimaryPart or Battlers[OppositeNum].Character:FindFirstChild("HumanoidRootPart")
		end
		bodyAV.MaxTorque = Vector3.new(9000000, 9000000, 9000000)
		bodyAV.P = 500
		for i = 1, 15 do
			bodyAV.AngularVelocity = Vector3.new(0,i,0)
			wait()
		end
		Tornado.Smoke.Enabled = false
		for i = 1, 15 do
			Tornado.Sound.Volume = 1 - i/15
			bodyAV.AngularVelocity = Vector3.new(0,15-i,0)
			wait(0.1)
		end
		bodyAV:Destroy()
		Enemy:SetPrimaryPartCFrame(CFrame.new(Enemy.PrimaryPart.Position, Battler.PrimaryPart.Position))
		Tornado.CFrame = TornadoCFrame
	elseif (Attack == "Rock Slide") then
		local RockStorage = Instance.new("Folder", Floor.Model)
		RockStorage.Name = "Rocks"
		local Sound = Instance.new("Sound", OppositeSpawn)
		Sound.Name = "Rocks"
		Sound.SoundId = "rbxassetid://253269033"
		Sound.Volume = 1
		Sound:Play()
		local Smoke = game.ServerStorage.Models.Smoke:Clone()
		Smoke.Parent = OppositeSpawn
		wait(0.5)
		for i = 1, 20 do
			wait(0.1)
			local Rock = game.ServerStorage.Models.Rock:Clone()
			Rock.Parent = RockStorage
			Rock.CFrame = CFrame.new(Enemy.Head.Position + Vector3.new(0,10,0))
			Rock.Anchored = false
		end
		wait(0.5)
		Smoke:Destroy()
		Sound:Destroy()
		RockStorage:Destroy()
	end
end

function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
	
	local ignoreList = {}
	wait(3)
	--Get two battlers
	for num = 1, NEEDED_PLAYERS do
		local Player = Elevator:getRandomPlayer(ignoreList)
		if (Player) then
			Battlers[num] = Player
			ignoreList[num] = Player
		end
	end
	--[[Get NPCs if needed
	if (#Battlers < NEEDED_PLAYERS) then
		for num = #Battlers+1, NEEDED_PLAYERS do
			local newNoob = Noob:Clone()
			newNoob:MakeJoints()
			Battlers[num] = newNoob
		end
	end]]
	--Choose pokemon
	choosePokemon(1)
	wait(4)
	choosePokemon(2)
	wait(1)
	if (Battlers[2]:IsA("Player")) then
		local Gui = game.ReplicatedStorage.UI.PokemonGui:Clone()
		Gui.Parent = Battlers[2].PlayerGui
		Network:Send(Battlers[2], "GetAttack", 3)
	end
	wait(3.2)
	--Start attacks
	pokemonAttack(2)
	if (Battlers[1]:IsA("Player")) then
		local Gui = game.ReplicatedStorage.UI.PokemonGui:Clone()
		Gui.Parent = Battlers[1].PlayerGui
		Network:Send(Battlers[1], "GetAttack", 3)
	end
	wait(3.2)
	pokemonAttack(1)
	if (Battlers[2]:IsA("Player")) then
		local Gui = game.ReplicatedStorage.UI.PokemonGui:Clone()
		Gui.Parent = Battlers[2].PlayerGui
		Network:Send(Battlers[2], "GetAttack", 3)
	end
	wait(3.2)
	pokemonAttack(2)
	local Winner
	if (math.random(1, 2) == 1) then
		Winner = Battlers[1]
		if (Battlers[1]:IsA("Player")) then
			local Gui = game.ReplicatedStorage.UI.PokemonGui:Clone()
			Gui.Parent = Battlers[1].PlayerGui
			Network:Send(Battlers[1], "GetAttack", 3)
		end
		wait(3.2)
		pokemonAttack(1)
		wait(3)
		Map.Center.Red.CanCollide = false
		Map.Center.Red.Anchored = false
		TCS:DisplayBubble(Ash.Head, "Nooo! My pokemon!")
		wait(1)
		TCS:DisplayBubble(Brock.Head, "Great job " .. Winner.Name .. "!")
	else
		wait(3.2)
		Elevator.Time = Elevator.Time - 5
		Winner = Battlers[2]
		Map.Center.White.CanCollide = false
		Map.Center.White.Anchored = false
		TCS:DisplayBubble(Brock.Head, "Agh! Not again!")
		wait(1)
		TCS:DisplayBubble(Ash.Head, "Yeah! You did it " .. Winner.Name .. "!")
	end
	if (Winner:IsA("Player")) then
		BadgeService:AwardBadge(Winner.UserId, 272350681)
	end
	wait(2)
	for num, Battler in pairs(Battlers) do
		if (Battler:IsA("Player")) then
			Functions:teleportPlayer(Battler, Elevator.TeleportPos)
			Network:Send(Battler, "SetControl", true)
		end
	end
end

function Floor.ending()
	attackConnection:Disconnect()
	attackConnection = nil
	Battlers = {}
	playerAttack = nil
end

return Floor