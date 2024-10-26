local Testing = false

local Elevator = _G.Modules:Load("Elevator")

local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetDataStore("Data2232019")
local OrderedData = DSS:GetOrderedDataStore("Floors1")
if (not DataStore) then
	Testing = true
	print("Testing mode")
end
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local PurchaseHistory = DSS:GetDataStore("PurchaseHistory")

local PlayerData = {}
local newPlayerData = {
	Stats = {Floors = 0, Coins = 0, Deaths = 0, Visits = 1},
	Settings = {CHANCE=false},
	Special = {Control=false},
	Banned = false,
	Bans = {},
}

local DataFolder = game.ReplicatedStorage:WaitForChild("PlayerData")
local Data = {}

local Banlist = {}

local SpecialList = {119883404, 36070193}

Data.youtubeIds = {[303005185] = "Gloom"}

local UPDATE_TIME = 60 --save all players' stats this many seconds
local ORDERED_UPDATE_TIME = 60

local Leaderboard = game.Workspace.Lobby.Leaderboard

local function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function Data:getPlayerData(Player)
	return PlayerData[Player]
end

function Data:addStat(Player, Stat, Value)
	local PlayerFolder = DataFolder:FindFirstChild(Player.Name)
	if (PlayerFolder) then
		local StatFolder = PlayerFolder:FindFirstChild("Stats")
		if (StatFolder) then
			PlayerData[Player]["Stats"][Stat] = PlayerData[Player]["Stats"][Stat] + Value
			StatFolder[Stat].Value = StatFolder[Stat].Value + Value
		end
	end
end

function Data:getDataFromId(UserId)
	if (UserId) then
		local userData = DataStore:GetAsync(UserId)
		if (userData) then
			return HttpService:JSONDecode(userData)
		end
	end
end

function Data:setDataFromId(UserId, userData)
	if (userData) and (type(userData)=="table") then
		DataStore:SetAsync(UserId, HttpService:JSONEncode(userData))
	elseif (userData == nil) then
		DataStore:RemoveAsync(UserId)
	end
end

function Data:addPlayer(Player)

	local myPlayerData = DataStore:GetAsync(Player.UserId)
		--Check if they had old data store
	local oldStore = game:GetService("DataStoreService"):GetDataStore("Stats"..Player.UserId)
	local oldStats
	if (oldStore) then
		oldStats = oldStore:GetAsync("PlayerStats")
	end
	
	if (myPlayerData) then
		myPlayerData = HttpService:JSONDecode(myPlayerData)
		myPlayerData.Stats.Visits = myPlayerData.Stats.Visits+1
	end
	
	if (oldStore) and (oldStats) then
		if (myPlayerData==nil) then
			myPlayerData = deepCopy(newPlayerData)
			myPlayerData.Stats.Floors = oldStats["Floors"]
			myPlayerData.Stats.Coins = oldStats["Coins"]
			myPlayerData.Stats.Deaths = oldStats["Deaths"]
			DataStore:SetAsync(Player.UserId, HttpService:JSONEncode(myPlayerData))
		else
			myPlayerData.Stats.Floors = (oldStats["Floors"]>myPlayerData.Stats.Floors and oldStats["Floors"]) or myPlayerData.Stats.Floors
		end
	else
		if (myPlayerData==nil) then
			myPlayerData = deepCopy(newPlayerData)
			DataStore:SetAsync(Player.UserId, HttpService:JSONEncode(myPlayerData))
		else
			for Key, Value in pairs(newPlayerData) do
				if (not myPlayerData[Key]) then
					myPlayerData[Key] = Value
				end
			end
			for Key, Value in pairs(newPlayerData.Stats) do
				if (not myPlayerData.Stats[Key]) then
					myPlayerData.Stats[Key] = Value
				end
			end
		end
	end
	
	if (Player.UserId==game.CreatorId) then 
		myPlayerData.Special.Control=true 
	end
	for _, Id in pairs(SpecialList) do
		if (Player.UserId==Id) then
			myPlayerData.Special.Control=true
		end
	end
	PlayerData[Player] = myPlayerData or newPlayerData
	
	--Add player's data folder
	local PlayerFolder = Instance.new("Folder", DataFolder)
	PlayerFolder.Name = Player.Name
	
	if (PlayerData[Player].Banned == true) then
		Player:Kick(PlayerData[Player].Bans[#PlayerData[Player].Bans].Reason)
		print("KICKED: "..Player.Name)
	else
		for Key, Table in pairs(newPlayerData) do
			local DataFolder = Instance.new("Folder", PlayerFolder)
			DataFolder.Name = Key
			if (type(Table)=="table") then
				for Stat, Value in pairs(Table) do
					local valueType
					if (type(Value) == "number") then
						valueType = "IntValue"
					elseif (type(Value) == "string") then
						valueType = "StringValue"
					elseif (type(Value) == "boolean") then
						valueType = "BoolValue"
					end
					local dataValue = Instance.new(valueType, DataFolder)
					dataValue.Name = Stat
					dataValue.Value = Value
					if (myPlayerData) then
						dataValue.Value = myPlayerData[Key][Stat]
					end
					
					dataValue.Changed:connect(function()
						PlayerData[Player][Key][Stat] = dataValue.Value
					end)
				end
			end
		end		
				--Get every key and put the stats and value in folder blaublaueg	
		if (not myPlayerData) then
			myPlayerData = HttpService:JSONEncode(PlayerData[Player])
			DataStore:SetAsync(Player.UserId, myPlayerData)
		end	
		
		if (DSS:GetDataStore("Data"):GetAsync(Player.UserId)) and (myPlayerData.Stats.Visits==1) then
			Data:addStat(Player, "Coins",150)
		end
	end
end

function Data:removePlayer(Player)
	print("Saved for " .. Player.Name)
	local PlayerFolder = DataFolder:FindFirstChild(Player.Name)
	if (PlayerData[Player]) then
		local myPlayerData = HttpService:JSONEncode(PlayerData[Player])
		if (PlayerFolder) and (PlayerData[Player]) then
			DataStore:SetAsync(Player.UserId, myPlayerData)
		end
		PlayerData[Player] = nil
		if (PlayerFolder) then PlayerFolder:Destroy() end
	end
end

function Data:Get(UserId)
	local myPlayerData = DataStore:GetAsync(UserId)
	if (myPlayerData) then
		return HttpService:JSONDecode(DataStore:GetAsync(UserId))
	end
end

function Data:changeSetting(Player, Setting, Value)
	if (PlayerData[Player]) then
		PlayerData[Player].Settings[Setting]=Value
	end
end

function Data:Ban(UserID, Time, Reason)
	local Player = game.Players:GetPlayerByUserId(UserID)
	local myPlayerData = DataStore:GetAsync(UserID)
	if (myPlayerData) then
		myPlayerData = HttpService:JSONDecode(myPlayerData)
		myPlayerData.Banned = true
		local banData = {["Time"] = Time, ["Reason"] = Reason}
		table.insert(myPlayerData.Bans, #myPlayerData.Bans+1, banData)
		myPlayerData = HttpService:JSONEncode(myPlayerData)
		DataStore:UpdateAsync(UserID, function(oldValue)
			return myPlayerData or oldValue
		end)
		print("BANNED: "..Player.Name)
	end
	if (game.Players:FindFirstChild(Player.Name)) then
		if (Reason) then
			Player:Kick(Reason)
		else
			Player:Kick()
		end
		print("KICKED: "..Player.Name)
	end
end

function Data:Unban(UserID)
	local myPlayerData = DataStore:GetAsync(UserID)
	if (myPlayerData) then
		myPlayerData = HttpService:JSONDecode(myPlayerData)
		myPlayerData.Banned = false
		myPlayerData = HttpService:JSONEncode(myPlayerData)
		DataStore:SetAsync(UserID, myPlayerData)
		print("UNBANNED: "..UserID)
	end
end

local productIds = {Coins25 = 39160805, Coins50 = 24325647,Coins100 = 24325656, Coins250 = 39160866, addSong = 32478838}

MarketplaceService.ProcessReceipt = function(receiptInfo) 
    local playerProductKey = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
    if PurchaseHistory:GetAsync(playerProductKey) then
        return Enum.ProductPurchaseDecision.PurchaseGranted --We already granted it.
    end
    -- find the player based on the PlayerId in receiptInfo
    for i, player in ipairs(game.Players:GetPlayers()) do
        if player.userId == receiptInfo.PlayerId then
            -- check which product was purchased (required, otherwise you'll award the wrong items if you're using more than one developer product)

			if (receiptInfo.ProductId == productIds["Coins25"]) then
				DataFolder:FindFirstChild(player.Name).Stats.Coins.Value = DataFolder:FindFirstChild(player.Name).Stats.Coins.Value + 25
			elseif(receiptInfo.ProductId == productIds["Coins50"]) then
				DataFolder:FindFirstChild(player.Name).Stats.Coins.Value = DataFolder:FindFirstChild(player.Name).Stats.Coins.Value + 50
			elseif(receiptInfo.ProductId == productIds["Coins100"]) then
				DataFolder:FindFirstChild(player.Name).Stats.Coins.Value = DataFolder:FindFirstChild(player.Name).Stats.Coins.Value + 100
			elseif(receiptInfo.ProductId == productIds["Coins250"]) then
				DataFolder:FindFirstChild(player.Name).Stats.Coins.Value = DataFolder:FindFirstChild(player.Name).Stats.Coins.Value + 250
			elseif(receiptInfo.ProductId == productIds["addSong"]) then
				local Network = _G.Modules:Load("Network")
				local songId = Network:Get(player, "UserSongId")
				
				
				if (songId) then
					Elevator:addUserMusic(player, songId)
				end
			end
			
        end	
    end
    -- record the transaction in a Data Store
    PurchaseHistory:SetAsync(playerProductKey, true)	
    -- tell ROBLOX that we have successfully handled the transaction (required)
    return Enum.ProductPurchaseDecision.PurchaseGranted		
end

function updateLeaderboard(RANK_DATA)

	for _, Player in pairs(game.Players:GetPlayers()) do
		local Data = PlayerData[Player]
		if (Data) then
			OrderedData:SetAsync(Player.UserId, Data.Stats.Floors)
		end
	end
	
	local Board = Leaderboard.Board.Frame.Leaderboard
	for _, PlayerFrame in pairs(Board:GetChildren()) do
		if (PlayerFrame:IsA("Frame")) and (PlayerFrame.Name~="Example") then
			PlayerFrame:Destroy()
		end
	end
	
	local Top = {}
	for Pos, Value in pairs(RANK_DATA) do
		Top[Pos] = Value.key
		local playerFrame = Board.Example:Clone()
		playerFrame.Parent = Board
		playerFrame.Name = "Player"..Pos
		playerFrame.Player.Text = game.Players:GetNameFromUserIdAsync(tonumber(Value.key))
		playerFrame.Score.Text = Value.value
		local ps = {[1] = "st", [2] = "nd", [3] = "rd"}
		playerFrame.Rank.Text = (ps[Pos]~=nil and Pos..ps[Pos]) or Pos.."th"
		playerFrame.Position = UDim2.new(0,0,(Pos-1)*0.1,0)
		playerFrame.BackgroundTransparency = (Pos%2~=0 and 1) or 0.9
		playerFrame.Visible = true
	end
	
end

spawn(function()
	while true do
		local success, message = pcall(function()
			local pages = OrderedData:GetSortedAsync(false, 10)
			local data = pages:GetCurrentPage()
			updateLeaderboard(data)
		end)
		if (not success) then
			print(message)
		end
		for T = ORDERED_UPDATE_TIME, 1, -1 do
			local seconds = (T~=1 and "seconds") or (T==1 and "second")
			Leaderboard.Board.Frame.Top.Time.Text = "(updating in " ..T.." "..seconds..")"
			wait(1)
		end
	end
end)

spawn(function()
	while true do
		wait(UPDATE_TIME)
		for Player, Data in pairs(PlayerData) do
			local PlayerFolder = DataFolder:FindFirstChild(Player.Name)
			if (PlayerFolder) then
				local myPlayerData = HttpService:JSONEncode(Data)
				DataStore:SetAsync(Player.UserId, myPlayerData)
			end
		end
	end
end)

return Data