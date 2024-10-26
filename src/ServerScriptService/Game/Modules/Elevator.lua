local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")

local MPS = game:GetService("MarketplaceService")

local Elevator = {}

Elevator.Model = game.Workspace.Elevator
Elevator.ButtonPad = Elevator.Model.ButtonPad
Elevator.Map = game.Workspace.Map
Elevator.Sounds = game.Workspace.Sounds
Elevator.Background = game.Workspace.Background

local Replica = Elevator.Model:Clone()
Replica.Parent = game.ServerStorage
Replica.Name = "ReplicaElevator"

Elevator.currentMap = nil
Elevator.MapIndex = 1
Elevator.Maps = {}
Elevator.originalMaps = {}
Elevator.MapScripts = {}

Elevator.Parts = {} --inside would be {Part = PART, Size = PART.Size, CFrame = Part.CFRAME}
Elevator.Lights = {}

Elevator.TeleportPos = Elevator.Model:FindFirstChild("TeleportPart").CFrame

for _, Model in pairs(Elevator.Model.Lights:GetChildren()) do
	Elevator.Lights[Model] = {Part = Functions:getPropertiesFromPart(Model.Light), Light = Functions:getPropertiesFromLight(Model.Light.SpotLight)}
end

function insertPart(newPart)
	table.insert(Elevator.Parts, #Elevator.Parts+1, {Part=newPart, Size=newPart.Size, CanCollide=newPart.CanCollide, Transparency=newPart.Transparency, CFrame=newPart.CFrame, Velocity = newPart.Velocity, RotVelocity = newPart.RotVelocity, Anchored = true})
end

Functions:recurseFunctionOnParts(insertPart, Elevator.Model)

Elevator.Music = game.ServerStorage.Halloween.Music:GetChildren()
Elevator.userMusic = {}
local LastMusic = 0

Elevator.Players = {}
Elevator.NPCs = {}

Elevator.INTERMISSION = 20
Elevator.Time = Elevator.INTERMISSION

function Elevator:reset()
	--Restore parts size and positions
	Elevator:restore()
	Elevator:toggleGuis(true)
	--Restore FakeDoor to CanCollide true
	Elevator.Model.FakeDoor.CanCollide = true
	--Reset client lighting for players
	for _, Player in pairs(Elevator.Players) do
		Network:Send(Player, "ElevatorLighting")
	end
	--Destroy sounds
	for _, Sound in pairs(Elevator.Sounds:GetChildren()) do
		Sound:Destroy()
	end
	--Reset elevator spot lights
	Elevator:resetLights()
	--Disable skybox
	Elevator:disableSkybox()
	--Change background color
	Elevator:changeBackgroundColor(Color3.new(0,0,0))
	--Clear map storage
	Elevator:clearMapStorage()
end

function Elevator:restore(ignoreDoors)
	Elevator:anchor(true)
	Elevator:weld(false)
	Elevator:resetParts(ignoreDoors)
end

function Elevator:crash()
	local Sound = Elevator.ButtonPad.Speaker.Music
	local TimePos = Sound.TimePosition
	if (Sound.IsPlaying) then
		Sound:Pause()
	end
	Elevator.Model.FakeDoor.PowerDown:Play()
	Elevator:flickerLights(3)
	Elevator:changeLightProperties({},{Brightness = 3})
	wait(3)
	for _, Player in pairs(Elevator.Players) do
		local Freak = game.ReplicatedStorage.Freak:Clone()
		Freak.Parent = Player.Backpack
		Freak.Disabled = false
		game:GetService("BadgeService"):AwardBadge(Player.UserId, 327564237)
	end
	wait(5)
	Sound.TimePosition = TimePos
	Sound:Play()
end

function Elevator:loadMaps(random)
	for i, map in pairs(game.ServerStorage.Maps:GetChildren()) do
		table.insert(Elevator.Maps, i, map)
	end
	if (random) then Functions:RandomizeTable(Elevator.Maps) end
	local newMaps = game.ServerStorage.NewMaps:GetChildren()
	Functions:RandomizeTable(newMaps)
	for _, map in pairs(newMaps) do
		table.insert(Elevator.Maps, 1, map)
	end
	for _, map in pairs(Elevator.Maps) do
		if (not Elevator.MapScripts[map]) then
			local MapScript = map:FindFirstChild("Main")
			local MapModule = require(MapScript)
			Elevator.MapScripts[map.Name] = MapModule
			MapScript:Destroy()
		end
	end
	Elevator.originalMaps = {unpack(Elevator.Maps)}
	
	Elevator.MapScripts["HalloweenBoss"] = require(game.ServerStorage.Halloween.HalloweenBoss.Main)
end

function Elevator:loadMusic(random)
	if (random) then Functions:RandomizeTable(Elevator.Music) end
end

function Elevator:addUserMusic(Player, songId)
	local musicData = {User = Player}
	if (songId) then
		musicData.SoundId = songId
		musicData.Title = game:GetService("MarketplaceService"):GetProductInfo(songId, Enum.InfoType.Asset).Name
		
		table.insert(Elevator.userMusic, musicData)
		
		for _, newPlayer in pairs(game.Players:GetPlayers()) do
			Network:Send(newPlayer, "RefreshSongList", Elevator.userMusic)
		end
	end
	
end

function Elevator:pickMusic()
	local picked = nil
	if (#Elevator.userMusic>0) then
		picked = Elevator.userMusic[1]
	elseif (LastMusic == 0) then
		LastMusic = math.random(1, #Elevator.Music)
		picked = Elevator.Music[LastMusic]
	elseif (LastMusic == #Elevator.Music) then
		LastMusic = 1
		picked = Elevator.Music[LastMusic]
	else
		LastMusic = LastMusic + 1
		picked = Elevator.Music[LastMusic]
	end
	local Properties = Functions:getPropertiesFromSound(picked)
	
	if (type(picked)=="table") then
		--print(picked, picked.User, LastMusic)
		Properties = {SoundId = "rbxassetid://"..picked.SoundId, Volume = 1}
		local Player = picked.User
		local Title = picked.Title
		if (Player) then
			Network:Send(Player, "ShowMessage", [[Your song "]]..Title..[[" is playing in the elevator right now!]])
		end
		
		table.remove(Elevator.userMusic, 1)
		
		for _, newPlayer in pairs(game.Players:GetPlayers()) do
			Network:Send(newPlayer, "RefreshSongList", Elevator.userMusic)
		end
	end
	return Properties
end

function Elevator:insertMap(map)
	map = map:Clone()
	map:SetPrimaryPartCFrame(Elevator.Model:GetPrimaryPartCFrame())
	map.Parent = Elevator.Map
	
	----add more
	return map
end

function Elevator:removeMap()
	for _, m in pairs(Elevator.Map:GetChildren()) do
		m:Destroy()
	end
end

function Elevator:playMusic(props)
	local Sound = Elevator.ButtonPad.Speaker.Music
	for prop, value in pairs(props) do
		if (prop=="SongName") then
			Sound:SetAttribute("SongName", value)
		elseif (Sound[prop]) then
			Sound[prop] = value
		end
		
	end
	Sound:Play()
	local showMusic = game:GetService("ReplicatedStorage").ShowMusic
	showMusic:FireAllClients(Sound, "Playing")
end

function Elevator:stopMusic()
	local Sound = Elevator.ButtonPad.Speaker.Music
	if (Sound.IsPlaying) then
		Sound:Stop()
	end
end

function Elevator:clearMapStorage()
	for _, Item in pairs(game.ServerStorage.MapStorage:GetChildren()) do
		Item:Destroy()
	end
end

function Elevator:enableSkybox()
	for _, part in pairs(Elevator.Background:GetChildren()) do
		if (part:IsA("BasePart")) and (part:FindFirstChild("Screen")) then
			part.Screen.Enabled = false
		end
	end
end

function Elevator:disableSkybox()
	for _, part in pairs(Elevator.Background:GetChildren()) do
		if (part:IsA("BasePart")) and (part:FindFirstChild("Screen")) then
			part.Screen.Enabled = true
		end
	end
	for _, Sky in pairs(game.Lighting:GetChildren()) do
		if (Sky:IsA("Sky")) then
			Sky:Destroy()
		end
	end
	
end

function Elevator:flickerLights(seconds)
	for i = 1, seconds*20 do
		Elevator:changeLightProperties({},{Brightness = math.random(1, 6)/2})
		wait(0.05)
	end
end

function Elevator:insertFakeElevator(Map, entrancePart, doorsClosed)
	local fakeElevator = Replica:Clone()
	fakeElevator.Parent = Map
	fakeElevator.Name = "FakeElevator"
	fakeElevator:SetPrimaryPartCFrame(entrancePart.CFrame)
	local xsize = fakeElevator.LeftDoor.Size.X
	if (not doorsClosed) then
		fakeElevator.LeftDoor.CFrame = fakeElevator.LeftDoor.CFrame*CFrame.new(xsize,0,0)
		fakeElevator.RightDoor.CFrame = fakeElevator.RightDoor.CFrame*CFrame.new(-xsize,0,0)
	end
	return fakeElevator
end

function Elevator:openDoors(Model, Time)
	if (not Model) then Model = Elevator.Model end
	local xsize = Model.LeftDoor.Size.X
	if (Model:FindFirstChild("FakeDoor")) then
		local sound = Model.FakeDoor.Door
		sound:Play()
	end
	if (Time) then
		local Tween = game:GetService("TweenService"):Create(Model.LeftDoor, TweenInfo.new(Time), {CFrame = Model.LeftDoor.CFrame*CFrame.new(xsize,0,0)})
		local Tween2 = game:GetService("TweenService"):Create(Model.RightDoor, TweenInfo.new(Time), {CFrame = Model.RightDoor.CFrame*CFrame.new(-xsize,0,0)})
		Tween:Play() Tween2:Play()
		wait(Time)
	else
		for i = 1, xsize*5 do
			Model.LeftDoor.CFrame = Model.LeftDoor.CFrame * CFrame.new(0.2,0,0)
			Model.RightDoor.CFrame = Model.RightDoor.CFrame * CFrame.new(-0.2,0,0)
			wait()
		end
	end
end

function Elevator:closeDoors(Model, Time)
	if (not Model) then Model = Elevator.Model end
	local xsize = Model.LeftDoor.Size.X
	if (Model:FindFirstChild("FakeDoor")) then
		local sound = Model.FakeDoor.Door
		sound:Play()
	end
	if (Time) then
		local Tween = game:GetService("TweenService"):Create(Model.LeftDoor, TweenInfo.new(Time), {CFrame = Model.LeftDoor.CFrame*CFrame.new(-xsize,0,0)})
		local Tween2 = game:GetService("TweenService"):Create(Model.RightDoor, TweenInfo.new(Time), {CFrame = Model.RightDoor.CFrame*CFrame.new(xsize,0,0)})
		Tween:Play() Tween2:Play()
		wait(Time)
	else
		for i = 1, xsize*5 do
			Model.LeftDoor.CFrame = Model.LeftDoor.CFrame * CFrame.new(-0.2,0,0)
			Model.RightDoor.CFrame = Model.RightDoor.CFrame * CFrame.new(0.2,0,0)
			wait()
		end
	end
end

function Elevator:getWallParts(Side)
	local Parts = {}
	for _, Part in pairs(Elevator.Model.Walls.Top:GetChildren()) do
		if (Side) and (Part.Name:find(Side)) and (Part.Name:sub(1, Side:len()) == Side) then
			table.insert(Parts, #Parts+1, Part)
		elseif (not Side) then
			table.insert(Parts, #Parts+1, Part)
		end
	end
	for _, Part in pairs(Elevator.Model.Walls.Bottom:GetChildren()) do
		if (Side) and (Part.Name:find(Side)) and (Part.Name:sub(1, Side:len()) == Side) then
			table.insert(Parts, #Parts+1, Part)
		elseif (not Side) then
			table.insert(Parts, #Parts+1, Part)
		end
	end
	return Parts
end

function Elevator:hideWall(Side, hide)
	local trans = hide and 1 or not hide and 0
	for _, Part in pairs(Elevator:getWallParts(Side)) do
		Part.Transparency = trans
		Part.CanCollide = not hide
	end
end

function Elevator:hideRailing(Side, hide)
	local trans = hide and 1 or not hide and 0
	for _, Part in pairs(Elevator.Model.Railings:FindFirstChild(Side):GetChildren()) do
		Part.Transparency = trans
		Part.CanCollide = not hide
	end
end

function Elevator:addPlayer(Player)
	local MyPlayer = Functions:GetObjectFromTable(Elevator.Players, Player)
	if (MyPlayer == nil) then
		table.insert(Elevator.Players, 1, Player)
		print("Added " .. Player.Name .. " to elevator")
		print(Elevator.currentMap)
		Functions:teleportPlayer(Player, Elevator.TeleportPos, true, 1)
		if (Elevator.currentMap ~= nil) then
			if (Elevator.currentMap.Name == "Snoop") then
				Network:Send(Player, "LoadElevator", Elevator.MapScripts[Elevator.currentMap.Name].Lighting[1])
			else
				Network:Send(Player, "LoadElevator", Elevator.MapScripts[Elevator.currentMap.Name].Lighting)
			end
			Elevator.MapScripts[Elevator.currentMap.Name]:initPlayer(Player)
		else
			Network:Send(Player, "LoadElevator")
			local showMusic = game:GetService("ReplicatedStorage").ShowMusic
			showMusic:FireClient(Player, Elevator.Model.ButtonPad.Speaker.Music, "Playing")
		end
--[[	else
		Elevator:removePlayer(MyPlayer)
		Elevator:addPlayer(MyPlayer)
		--]]
	end
end

function Elevator:removePlayer(Player)
	local MyPlayer, Index = Functions:GetObjectFromTable(Elevator.Players, Player)
	if (MyPlayer) then
		table.remove(Elevator.Players, Index)
		print("Removed " .. Player.Name .. " from elevator")
	end
end

function Elevator:getPlayer(PlayerName)
	local Result
	for _, Player in pairs(Elevator.Players) do
		if (Player.Name == PlayerName) then
			Result = Player
		end
	end
	return Result
end

function Elevator:addNPC(NPC, teleported)
	local MyNPC = Elevator.NPCs[NPC]
	if (MyNPC  == nil) then
		if (NPC:FindFirstChild("NPCScript")) then
			print("Added [NPC]"..NPC.Name.." to elevator")
			NPC.Parent = game.Workspace.NPCs
			if (not teleported) then
				Elevator.NPCs[NPC] = require(NPC.NPCScript)
				Elevator.NPCs[NPC]:init("Elevator")
				NPC:SetPrimaryPartCFrame(Elevator.Model.FakeDoor.CFrame * CFrame.new(0,0,-NPC.PrimaryPart.Size.Z*4))
				Elevator.NPCs[NPC].Humanoid:MoveTo(Elevator.Model.TeleportPart.Position + Vector3.new(math.random(-8,8), 0, math.random(-8,8)))
				Elevator.NPCs[NPC].Humanoid.MoveToFinished:Connect(function()
					NPC:SetPrimaryPartCFrame(CFrame.new(NPC.PrimaryPart.Position, Elevator.Model.FakeDoor.Position))
				end)
			else
				Elevator.NPCs[NPC] = require(NPC.NPCScript)
				Elevator.NPCs[NPC]:init("Elevator")
				NPC:SetPrimaryPartCFrame(Elevator.Model.TeleportPart.CFrame * CFrame.new(math.random(-8,8), 0, math.random(-8,8)))
			end
		end
	end
end

function Elevator:removeNPC(NPC)
	if (Elevator.NPCs[NPC]) then
		print("Removed [NPC]"..NPC.Name.." from elevator")
		Elevator.NPCs[NPC] = nil
	end
end

function Elevator:hideNPCs()
	for _, NPC in pairs(game.Workspace.NPCs:GetChildren()) do
		if (NPC) and (NPC.PrimaryPart) then
			local Tag = Instance.new("CFrameValue", NPC)
			Tag.Name = "WorldPosition"
			Tag.Value = NPC.PrimaryPart.CFrame
			NPC.Parent = game.ServerStorage.NPCStorage
		end
		
	end
end

function Elevator:showNPCs()
	for _, NPC in pairs(game.ServerStorage.NPCStorage:GetChildren()) do
		if (NPC:FindFirstChild("WorldPosition")) then
			NPC.Parent = game.Workspace.NPCs
			NPC:SetPrimaryPartCFrame(NPC.WorldPosition.Value)
		end
	end
end

function Elevator:findNPC(npcName)
	local Result
	for _, NPC in pairs(game.Workspace.NPCs:GetChildren()) do
		if (NPC.Name == npcName) then
			Result = NPC
		end
	end
	return Result
end

function Elevator:teleportPlayers()
	for _, Player in pairs(Elevator.Players) do
		Functions:teleportPlayer(Player, Elevator.TeleportPos)
	end
end

function Elevator:getAnyPlayer(ignoreList)
	local Players = {}
	for _, Player in pairs(Elevator.Players) do
		local isIgnored = false
		if (ignoreList) then
			for _, ignored in pairs(ignoreList) do
				if (Player == ignored) then
					isIgnored = true
				end
			end
		end
		if (not isIgnored) then
			table.insert(Players, Player)
		end
	end
	if (#Players == 0) then return nil end
	return Players[math.random(1, #Players)]
end

function Elevator:getRandomPlayer(ignoreList)
	local Players = {}
	for _, Player in pairs(Elevator.Players) do
		local isIgnored = false
		if (ignoreList) then
			for _, ignored in pairs(ignoreList) do
				if (Player == ignored) then
					isIgnored = true
				end
			end
		end
		if (not isIgnored) then
			local PlayerData = _G.Modules:Load("Data"):getPlayerData(Player)
			if (PlayerData) and (PlayerData.Settings.CHANCE==true) then	--3x chance
				for i = 1, 3 do
					table.insert(Players, #Players+1, Player)
				end
			else
				table.insert(Players, #Players+1, Player)
			end
			
		end
	end
	if (#Players == 0) then return nil end
	return Players[math.random(1, #Players)]
end

function Elevator:getRandomNPC(ignoreList)
	local NPCs = {}
	for Character, NPC in pairs(Elevator.NPCs) do
		local isIgnored = false
		if (ignoreList) then
			for _, ignored in pairs(ignoreList) do
				if (Character == ignored) then
					isIgnored = true
				end
			end
		end
		if (not isIgnored) then
			table.insert(NPCs, #NPCs+1, Character)
		end
	end
	if (#NPCs == 0) then return nil end
	return NPCs[math.random(1, #NPCs)]
end

function Elevator:updateTimerParts(model, text, ...)
	local parts = {...}
	if (Elevator.Model == model) and (tonumber(text)) then
		Elevator.Time = tonumber(text)
	end
	for _, part in pairs(parts) do
		part.Gui.Label.Text = text
	end
end

function Elevator:changeLightProperties(partProperties, lightProperties, elevatorModel)
	local E = elevatorModel or Elevator.Model
	for _, Model in pairs(E.Lights:GetChildren()) do
		for LightModel, Properties in pairs(Elevator.Lights) do
			if (Model:IsA("Model")) then
				if (partProperties) then
					for prop, value in pairs(partProperties) do
						if (Model.Light[prop]) then
							Model.Light[prop] = value
						end
					end
				end
				if (lightProperties) then
					for prop, value in pairs(lightProperties) do
						if (Model.Light.SpotLight[prop]) then
							Model.Light.SpotLight[prop] = value
						end
					end
				end
			end
		end
	end
end

function Elevator:lightsOff()
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic}, {Color = Color3.new(0,0,0)})
end

function Elevator:resetLights()
	for LightModel, Properties in pairs(Elevator.Lights) do
		for prop, value in pairs(Properties.Part) do
			if (LightModel.Light[prop]) then
				LightModel.Light[prop] = value
			end
		end
		for prop, value in pairs(Properties.Light) do
			if (LightModel.Light.SpotLight[prop]) then
				LightModel.Light.SpotLight[prop] = value
			end
		end
	end
end

function Elevator:changeBackgroundColor(newColor)
	for _, Part in pairs(Elevator.Background:GetChildren()) do
		Part.Screen.Frame.BackgroundColor3 = newColor
	end
end

function Elevator:resetParts(ignoreDoors)
	for _, PartTable in pairs(Elevator.Parts) do
		local Part = PartTable.Part
		for Prop, Value in pairs(PartTable) do
			if (Prop ~= "Part") then
				if (Part[Prop]) then
					if (ignoreDoors) and ((Part.Name~="LeftDoor") and (Part.Name~="RightDoor")) then
						Part[Prop] = Value
					elseif (not ignoreDoors) then
						Part[Prop] = Value
					end
					if (Prop == "CanCollide") then
						Part.CanCollide = Value
					end
				end
			end
		end
	end
end

function Elevator:toggleGuis(on)
	local function toggle(Part)
		for _, Object in pairs(Part:GetChildren()) do
			if (Object:IsA("SurfaceGui")) then
				if (on == nil) then on = not Object.Enabled end
				Object.Enabled = on
			end
		end
	end
	Functions:recurseFunctionOnParts(toggle, Elevator.Model)
end

function Elevator:weld(doWeld)
	Functions:weld(Elevator.Model, doWeld)
end

function Elevator:anchor(doAnchor)
	Functions:anchor(Elevator.Model, doAnchor)
end

function Elevator:hide(doHide)
	local function hidePart(Part)
		Part.Transparency = 1
	end
	Functions:recurseFunctionOnParts(hidePart, Elevator.Model)
end

Elevator.bossActivated=false
Elevator.bossActive=false

function Elevator:toggleTorches(value)		---HALLOW
	
	for _, Torch in pairs(Elevator.Model.Torches:GetChildren()) do
		Torch.Attach.Fire.Enabled = value
	end
	
	task.spawn(function()
		if (value) then
			for i = 1, 30 do
				wait(0.045)
				for _, Torch in pairs(Elevator.Model.Torches:GetChildren()) do
					Torch.Attach.Light.Brightness=(i/30)*3
				end
			end	
		else
			for i = 30,0,-1 do
				wait(0.045)
				for _, Torch in pairs(Elevator.Model.Torches:GetChildren()) do
					Torch.Attach.Light.Brightness=(i/30)*3
				end
			end
		end
	end)
end

function Elevator:initBoss()
	local randomChars = {"%","&","D","@","I","E","%^", "#&", "*@"}
	
	local dark = false

	Elevator.hauntStage = 1
	Elevator:hideNPCs()

	local scaryMusic = Instance.new("Sound")
	scaryMusic.SoundId = "rbxassetid://5819068775"
	scaryMusic.Volume = 1
	scaryMusic.Name = "Strings"
	scaryMusic.Looped = true
	scaryMusic.Parent = game.Workspace
	
	--[[
	local scaryWind = Instance.new("Sound")
	scaryWind.SoundId = "rbxassetid://4794769432"
	scaryWind.Volume = 0.5
	scaryWind.Name = "Wind"
	scaryWind.Parent = game.Workspace]]

	for timer = Elevator.INTERMISSION, 1, -1 do
		Elevator:updateTimerParts(Elevator.Model, timer, Elevator.ButtonPad.TimerPart)
		if (timer==Elevator.INTERMISSION-3) then
			scaryMusic:Play()
		elseif (timer == Elevator.INTERMISSION-4) then

			local partColor = Color3.fromRGB(123, 47, 123)
			local lightColor = Color3.fromRGB(77, 49, 135)
			task.spawn(function()
				for i = 1, 55 do
					wait(0.045)
					Elevator:changeLightProperties({Color = partColor:lerp(Color3.fromRGB(22, 14, 84), i/55)}, {Color = lightColor:lerp(Color3.fromRGB(22, 14, 84), i/55)})
				end
				wait(3)
				Elevator:flickerLights(5)
				Elevator:lightsOff()
			end)

		elseif (timer == Elevator.INTERMISSION-10) then
			task.spawn(function()
				while (not dark) do
					Elevator:updateTimerParts(Elevator.Model, randomChars[math.random(1,#randomChars)], Elevator.ButtonPad.TimerPart)
					wait(0.075)
				end
			end)
		elseif (timer==3) then
			Elevator:toggleTorches(false)
			scaryMusic:Stop()
			scaryMusic:Destroy()
		end
		wait(1)
	end

	--[[
	if (scaryWind.Playing) then
		scaryWind:Stop()
	end
	scaryWind:Destroy()]]
	
	Elevator.bossActive=true
	local Map = Elevator:insertMap(game.ServerStorage.Halloween.HalloweenBoss)
	local Sounds = Map:FindFirstChild("Sounds")
	local MapScript = require(Map.Main)
	local Settings = MapScript.Settings

	MapScript.Model = Map
	if (Sounds) then
		for _, Sound in pairs(Sounds:GetChildren()) do
			if (Sound:IsA("Sound")) then
				Sound:Clone().Parent = Elevator.Sounds
			end
		end
	end
	MapScript.Sounds = Elevator.Sounds
	
	local breakSound = Instance.new("Sound")
	breakSound.SoundId = "rbxassetid://158712406"
	breakSound.Volume = 1
	breakSound.Parent = Elevator.Model.Floor
	breakSound.PlayOnRemove=true

	Elevator:updateTimerParts(Elevator.Model, "", Elevator.ButtonPad.TimerPart)
	task.spawn(function() MapScript:init(Map) end)
	Elevator.currentMap = Map
	Elevator.Model.Floor.CanCollide=false
	Elevator.Model.Floor.Transparency=1
	breakSound:Destroy()
	
	

	while (Elevator.bossActive) do
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

return Elevator