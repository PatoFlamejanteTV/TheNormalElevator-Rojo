local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")

local halloweenData = DataStoreService:GetDataStore("Halloween2024")
local halloweenFolder = Instance.new("Folder")
halloweenFolder.Name = "HalloweenData"
halloweenFolder.Parent = game:GetService('ReplicatedStorage')

local Players = game:GetService("Players")

local module = {}
local playerData = {}

function module:AddPlayer(player)
	local data = halloweenData:GetAsync(player.UserId)
	if (not data) then
		data = {
			BlueCandy=-1;
			YellowCandy=-1;
			GreenCandy=-1;
			OrangeCandy=-1;
			PinkCandy=-1;
			
			CandyCorn=-1;
			GummyBear=-1;
			Lollipop=-1;
			Chocolate=-1;
			
			Gear = {
				PhantomCoil=0;
				StarCookie=0;
				Bombkin=0;
			}
		}
	end
	
	local folder = Instance.new("Folder")
	folder.Name=player.Name
	folder.Parent = halloweenFolder
	
	for name, value in (data) do
		
		if (name=="Gear") then
			
		else
			local intValue = Instance.new("IntValue")
			intValue.Name = name
			intValue.Value = value
			intValue.Changed:Connect(function()
				playerData[player][name] = intValue.Value
			end)
			intValue.Parent = folder
		end
		
	end
	
	playerData[player]=data
	
	local function loadCharacter(character)

		while (not player:HasAppearanceLoaded()) do
			task.wait(0.04)
		end
		
		for gear, amount in (data.Gear) do
			for i = 1, amount do
				local newGear = ServerStorage.Halloween.Gear[gear]:Clone()
				newGear.Parent = player.Backpack
			end
		end
	end

	if (player.Character) then
		loadCharacter(player.Character)
	end

	player.CharacterAdded:Connect(loadCharacter)
end

function module:RemovePlayer(player)
	if (not halloweenData:FindFirstChild(player.Name)) then return end
	halloweenData[player.Name]:Destroy()
	halloweenData:SetAsync(player, playerData[player])
	
	playerData[player]=nil
end

function module:AddCandy(player, candyName, amount)
	if (not halloweenFolder:FindFirstChild(player.Name)) then return end
	--print"FOUND"
	local v = halloweenFolder[player.Name][candyName]
	if (v.Value<0) then amount+=1 end
	halloweenFolder[player.Name][candyName].Value+=amount
end

function module:AddGear(player, gearName, amount)
	if (not halloweenFolder:FindFirstChild(player.Name)) then return end
	
	for i = 1, amount do
		local newGear = ServerStorage.Halloween.Gear[gearName]:Clone()
		newGear.Parent = player.Backpack
	end
	playerData[player].Gear[gearName]+=amount
end

for _, v in (Players:GetPlayers()) do
	module:AddPlayer(v)
end

--add new players to data
Players.PlayerAdded:Connect(function(player)
	module:AddPlayer(player)
end)

return module