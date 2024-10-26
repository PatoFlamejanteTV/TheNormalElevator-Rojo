local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local halloweenFolder = ReplicatedStorage.Halloween
local halloweenGlobals = require(halloweenFolder.HalloweenGlobals)
local halloweenData = require(ServerScriptService.Halloween.HalloweenData)
local dataFolder = ReplicatedStorage:WaitForChild("HalloweenData")

local function playerCrafted(player, itemName)
	local materials
	local itemType
	
	for itemT, data in (halloweenGlobals.crafting) do
		for name, materialList in (data) do
			if (name==itemName) then
				materials=materialList
				itemType=itemT
				break
			end
		end
	end
	
	if (not materials) then return end
	
	local candyData = dataFolder:FindFirstChild(player.Name)
	if (not candyData) then return end
	
	local canCraft=true
	local items={}
	for material, amount in (materials) do
		if (candyData:FindFirstChild(material)) then
			if (candyData[material].Value<amount) then
				print"missing candy"
				return false
			else
				items[material]={obj=candyData[material], cost=amount}
			end
		else
			local gear = player.Backpack:FindFirstChild(material) or player.Character:FindFirstChild(material)
			if (not gear) then
				print"missing gear"
				return false
			else
				items[material]={obj=gear, cost=amount}
			end
			
		end
	end
	
	if (canCraft) then
		for item, itemData in (items) do
			if (itemData.obj:IsA("IntValue")) then
				itemData.obj.Value-=itemData.cost
			elseif (itemData.obj:IsA("Tool")) then
				itemData.obj:Destroy()
			end
		end
		
		--now reward
		if (itemType=="Candy") then
			halloweenData:AddCandy(player, itemName, 1)
		elseif (itemType=="Gear") then
			halloweenData:AddGear(player, itemName, 1)
		end
	end
	
	return canCraft
end

halloweenFolder.RequestCraft.OnServerInvoke = playerCrafted

local module = {}



return module
