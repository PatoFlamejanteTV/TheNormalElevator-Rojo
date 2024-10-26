local MPS = game:GetService("MarketplaceService")

local costumePassId = 1048898

local Network = {}

local sendEvent = game.ReplicatedStorage.Send
local getFunction = game.ReplicatedStorage.Get

function Network:Send(Player, ...)
	sendEvent:FireClient(Player, ...)
end

function Network:Get(Player, ...)
	return getFunction:InvokeClient(Player, ...)
end


sendEvent.OnServerEvent:Connect(function(Player, ...)
	local args = {...}
	local Elevator = _G.Modules:Load("Elevator")
	if (args[1] == "PlaySound") then
		local Parent = args[2]
		local Properties = args[3]
		local Sound = Instance.new("Sound", Parent)
		Sound.Name = "Effect"
		Sound.Volume = 1
		if (Properties) then
			for Prop, Value in pairs(Properties) do
				if (Sound[Prop]) then
					Sound[Prop] = Value
				end
			end
		end
		Sound:Play()
		wait(Sound.TimeLength)
		Sound:Destroy()
	end
	if (Elevator) then
		if (args[1] == "ClearMaps") then
			local Data = _G.Modules:Load("Data"):getPlayerData(Player)
			if ((Data) and (Data.Special.Control==true)) or ((game.PrivateServerId~="") and (game.PrivateServerOwnerId==Player.UserId)) then
				Elevator.Maps = {}
				for _, Player in pairs(game.Players:GetPlayers()) do
					if (Player.PlayerGui:FindFirstChild("ElevatorControl")) then
						Network:Send(Player, "RefreshList")
					end
				end
			end
		elseif (args[1] == "FixMaps") then
			local Data = _G.Modules:Load("Data"):getPlayerData(Player)
			local Functions = _G.Modules:Load("Functions")
			if ((Data) and (Data.Special.Control==true)) or ((game.PrivateServerId~="") and (game.PrivateServerOwnerId==Player.UserId)) then
				Elevator.Maps = {unpack(Elevator.originalMaps)}
				Functions:RandomizeTable(Elevator.Maps)
				for _, Player in pairs(game.Players:GetPlayers()) do
					if (Player.PlayerGui:FindFirstChild("ElevatorControl")) then
						Network:Send(Player, "RefreshList")
					end
				end
			end
		elseif (args[1] == "RemoveMaps") then
			local removeList = args[2]
			local Data = _G.Modules:Load("Data"):getPlayerData(Player)
			local Functions = _G.Modules:Load("Functions")
			if ((Data) and (Data.Special.Control==true)) or ((game.PrivateServerId~="") and (game.PrivateServerOwnerId==Player.UserId)) then
				for _, mapName in pairs(removeList) do
					local realMap = game.ServerStorage.Maps:FindFirstChild(mapName) or game.ServerStorage.NewMaps:FindFirstChild(mapName)
					local Map, Index = Functions:GetObjectFromTable(Elevator.Maps, realMap)
					if (Map) then
						table.remove(Elevator.Maps, Index)
					end
				end
				for _, Player in pairs(game.Players:GetPlayers()) do
					if (Player.PlayerGui:FindFirstChild("ElevatorControl")) then
						Network:Send(Player, "RefreshList")
					end
				end
			end
		elseif (Elevator.currentMap) then
			if (Elevator.currentMap.Name == "EatingContest") then
				if (args[1] == "EatFood") then
					Elevator.currentMap.Eat:Fire(Player)
				end
			elseif (Elevator.currentMap.Name == "Cops") then
				if (args[1] == "Answer") then
					Elevator.currentMap.Answer:Fire(Player, args[2])
				end
			elseif (Elevator.currentMap.Name == "Pokemon") then
				if (args[1] == "Attack") then
					Elevator.currentMap.Attack:Fire(Player, args[2])
				end
			end
		end
	end
	
end)

local function insertCostume(Costume, Character)
	local Functions = _G.Modules:Load("Functions")
	if (Costume.Title.Value=="Gavin") then
		Functions:hideCharacter(Character, 0)
		if (Character:FindFirstChild("Head")) then
			Character.Head.Transparency = 0
			for _, Decal in pairs(Character.Head:GetChildren()) do
				if (Decal:IsA("Decal")) then
					Decal.Transparency = 0
				end
			end
		end
		if (Character:FindFirstChild("Body Colors")) then
			Character:FindFirstChild("Body Colors"):Destroy()
			local Colors = Costume:FindFirstChild("Body Colors"):Clone()
			Colors.Parent = Character
		end
		if (Character:FindFirstChild("Shirt")) then
			Character.Shirt.ShirtTemplate = Costume.Shirt.ShirtTemplate
		end
		if (Character:FindFirstChild("Pants")) then
			Character.Pants.PantsTemplate = Costume.Pants.PantsTemplate
		end
		for _, Accessory in pairs(Character:GetChildren()) do
			if (Accessory:IsA("Accessory")) then
				Accessory.Handle.Transparency = 1
			end
		end
		for _, Part in pairs(Costume:GetChildren()) do
			if (Part:IsA("Accessory")) then
				Part = Part:Clone()
				Part.Parent = Character
				Part.Name = "CostumeHat"
			end
			if (Character:FindFirstChild(Part.Name)) and (Character:FindFirstChild(Part.Name):IsA("BasePart")) then
				Character:FindFirstChild(Part.Name).Size = Part.Size
			end
		end
	else
		Functions:hideCharacter(Character)
		local Storage = Instance.new("Folder", Character)
		Storage.Name = "Costume"
		local Value = Instance.new("StringValue", Storage)
		Value.Name = "Title"
		Value.Value = Costume.Name
		for _, Part in pairs(Costume:GetChildren()) do
			if (Part:IsA("BasePart")) then
				local realPart = Character:FindFirstChild(Part.Name)
				if (realPart) then
					Part = Part:Clone()
					Part.Parent = Storage
					realPart.Size = Part.Size
					local newWeld = Instance.new("Weld", Part)
					newWeld.Part0 = Part
					newWeld.Part1 = realPart
				end
			elseif (Part:IsA("Accessory")) then
				Part = Part:Clone()
				Part.Parent = Character
				Part.Name = "CostumeHat"
			end
		end
		if (Costume.Title.Value=="Santa") then
			if (Character:FindFirstChild("Head")) then
				Character.Head.Transparency = 0
				for _, Decal in pairs(Character.Head:GetChildren()) do
					if (Decal:IsA("Decal")) then
						Decal.Transparency = 0
					end
				end
			end
		end
	end
	
end



function getFunction:OnServerInvoke(Player, ...)
	local args = {...}
	if (args[1] == "MusicIsPlaying") then

		local Elevator = _G.Modules.Elevator
		if (Elevator.currentMap ~= nil) then

			local Floor = Elevator.MapScripts[Elevator.currentMap.Name]
			local Music = Floor.Music
			if (Music) then
				return Music.IsPlaying, Music.TimePosition
			end
		end
		
	elseif (args[1] == "PurchaseItem") then
		local Result = false
		local Selection = args[2]
		local Item = args[3]
		local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
		if (PlayerData) then
			local Coins = PlayerData.Stats.Coins
			if (game.ReplicatedStorage:FindFirstChild("Shop")) and (game.ReplicatedStorage.Shop:FindFirstChild("Set"..Selection)) then
				local Item = game.ReplicatedStorage.Shop:FindFirstChild("Set"..Selection):FindFirstChild(Item.Name)
				if (Item) then
					if (Coins.Value >= Item.Cost.Value) then
						local newItem = Item:Clone()
						newItem.Parent = Player.StarterGear
						newItem:Clone().Parent = Player.Backpack
						Coins.Value = Coins.Value - Item.Cost.Value
						Result = true
					end
				end
			end
		end
		return Result
		
	elseif (args[1] == "PurchaseArtifact") then
		local Result = 0	--0 = nothing, 1 = complete, 2 = not enough, 3 = already have
		local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
		if (PlayerData) then
			local Coins = PlayerData.Stats.Coins
			local Item = game.ReplicatedStorage.ArtifactModels:FindFirstChild(args[2])
			local Functions = _G.Modules:Load("Functions")
			if (Item) and (not Functions:getToolFromPlayer(Player, Item.Name)) then
				if (Coins.Value >= Item.Cost.Value) then
					local newItem = game.ReplicatedStorage.Artifacts:FindFirstChild(args[2]):Clone()
					newItem.Parent = Player.StarterGear
					newItem:Clone().Parent = Player.Backpack
					Coins.Value = Coins.Value - Item.Cost.Value
					Result = 1
				else
					Result = 2
				end
			elseif (Functions:getToolFromPlayer(Player, Item.Name)) then
				Result = 3
			end
			return Result
		end
	elseif (args[1] == "IsYoutuber") then
		local Data = _G.Modules:Load("Data")
		return (Data.youtubeIds[Player.UserId])
		
	elseif (args[1] == "LoadCostume") then
		local Costume = args[2]
		local Success = false
		if (MPS:UserOwnsGamePassAsync(Player.UserId, costumePassId)) then
			local Functions = _G.Modules:Load("Functions")
			if (Functions:characterIsValid(Player.Character)) then
				if (Player.Character:FindFirstChild("Costume")) then
					Player.Character.Costume:Destroy()
				end
				insertCostume(Costume, Player.Character)
			end
			Success = true
		end
		return Success
		
	elseif (args[1] == "UnloadCostume") then
		local Success = false
		local Character = Player.Character
		local Functions = _G.Modules:Load("Functions")
		local partProperties = args[2]
		local bodyColors = args[3]
		local clothes = args[4]
		if (Functions:characterIsValid(Character)) then
			if (Character:FindFirstChild("Costume")) then
				Character.Costume:Destroy()
			end
			Functions:hideCharacter(Character, 0)
			for _, Part in pairs(Character:GetChildren()) do
				if (Part:IsA("BasePart")) and (partProperties[Part.Name])then
					Part.Size = partProperties[Part.Name].Size
					Part.Transparency = partProperties[Part.Name].Transparency
				end
			end
			for _, Accessory in pairs(Character:GetChildren()) do
				if (Accessory:IsA("Accessory")) and (Accessory.Name == "CostumeHat") then
					Accessory:Destroy()
				end
			end
			if (Character:FindFirstChild("Shirt")) then
				Character.Shirt.ShirtTemplate = clothes.Shirt
			end
			if (Character:FindFirstChild("Pants")) then
				Character.Pants.PantsTemplate = clothes.Pants
			end
			if (Character:FindFirstChild("Body Colors")) then
				for Prop, Value in pairs(bodyColors) do
					Character:FindFirstChild("Body Colors")[Prop] = Value
				end
			end
			Success = true
		end
		return Success
		
	elseif (args[1] == "UpdateSetting") then
		local Result = false
		local Data = _G.Modules:Load("Data")
		local Settings=args[2]
		local Value=args[3]
		if (Settings=="CHANCE") then
			if (MPS:UserOwnsGamePassAsync(Player.UserId, 452845)) or (Data.youtubeIds(Player.UserId)) then
				Data:changeSetting(Player, Settings, Value)
				Result = true
			end
		end
		return Result
	elseif (args[1] == "GetElevatorVolume") then
		return _G.Modules.Elevator.Model.ButtonPad.Speaker.Music.Volume
	elseif (args[1] == "GetSoundVolume") then
		local Sound = args[2]
		if (Sound) then
			return Sound.Volume
		end
	elseif (args[1] == "FloorList") then
		local List = {}
		local Elevator = _G.Modules:Load("Elevator")
		for i, Floor in pairs(Elevator.originalMaps) do
			List[i] = Floor.Name
		end
		return List
	elseif (args[1] == "AddFloor") then
		local floorName = args[2]
		local Data = _G.Modules:Load("Data"):getPlayerData(Player)
		local Elevator = _G.Modules:Load("Elevator")
		local Success = false
		if ((Data) and (Data.Special.Control==true)) or ((game.PrivateServerId~="") and (game.PrivateServerOwnerId==Player.UserId)) then
			local Floor = game.ServerStorage.Maps:FindFirstChild(floorName) or game.ServerStorage.NewMaps:FindFirstChild(floorName)
			if (Floor) then
				table.insert(Elevator.Maps, 1, Floor)
				Success = true
			end
			for _, Player in pairs(game.Players:GetPlayers()) do
				if (Player.PlayerGui:FindFirstChild("ElevatorControl")) then
					Network:Send(Player, "RefreshList")
				end
			end
		end
		
		return Success
	elseif (args[1] == "NextFloorsList") then
		local List = nil
		local Elevator = _G.Modules:Load("Elevator")
		if (#Elevator.Maps > 0) then
			List = {}
			for i, Floor in pairs(Elevator.Maps) do
				List[i] = Floor.Name
			end
			return List
		end
		
	elseif (args[1] == "GetUserSongList") then
		local Elevator = _G.Modules:Load("Elevator")
		local List = Elevator.userMusic
		return List
	end
end

return Network