local rs = game:GetService("ReplicatedStorage")
local ss = game:GetService("ServerStorage")
local cs = game:GetService("CollectionService")

local random = Random.new()

local chances = {}
chances.candy = 93
chances.candyCorn = 2
chances.gummyBear = 2
chances.lollipop = 2
chances.chocolate = 1

local halloweenData = require(script.Parent.HalloweenData)

local globals = require(rs.Halloween.HalloweenGlobals)
local folder = ss.Halloween.Candies


local Candy = {}

local colorList = {}
for color, _ in (globals.candyColors) do
	table.insert(colorList, color)
end

function Candy:spawn(spawner)
	local rng = random:NextInteger(1,1000)
	local weight = 0
	
	local candyName
	for name, rarity in (chances) do
		weight+=rarity
		if (rng<=weight*10) then
			candyName=name
			break
		end
	end
	
	local class = {
		name="";
		obj=nil;
		touchedBy={}
	}
	
	
	local randomColor = colorList[random:NextInteger(1, #colorList)]
	class.obj = folder[candyName]:Clone()
	class.obj:PivotTo(spawner.CFrame)
	--print(class.obj.Name)
	class.name = class.obj.Name:gsub("^%l", string.upper)
	class.obj.Name = class.name
	--print(class.name)
	
	if (candyName=="candy") then
		local candyColor = globals.candyColors[randomColor]
		class.obj.PrimaryPart.Color = candyColor
		class.obj.PrimaryPart.Effects.Glow.Color = ColorSequence.new(candyColor)
		class.obj.PrimaryPart.Effects.Rays.Color = ColorSequence.new(candyColor)
		class.name = randomColor.."Candy"
		class.obj.Name=class.name
	elseif (candyName=="lollipop") then
		class.name = "Lollipop"
	end
	
	class.obj.PrimaryPart.Touched:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if (player) and (not class.touchedBy[player.UserId]) then
			class.touchedBy[player.UserId] = true
			halloweenData:AddCandy(player, class.name, 1)
			rs.Halloween.CandyCollected:FireClient(player, class.obj)

		end
	end)
	
	class.obj.Destroying:Connect(function()
		--cs:RemoveTag(class.obj, "Candy")
		class=nil
	end)

	class.obj.Parent = spawner.Parent
	cs:AddTag(class.obj, "Candy")
	return class.obj
end

local elevatorCandies={}

workspace.Map.ChildAdded:Connect(function(map)
	if (map:FindFirstChild("Candies")) then
		for _, spawner in (map.Candies:GetChildren()) do
			Candy:spawn(spawner)
			spawner.Transparency=1
		end
	end
end)

workspace.Map.ChildRemoved:Connect(function()
	for _, model in (workspace.Elevator.CandySpawners:GetChildren()) do
		if (model:IsA("Model")) then
			model:Destroy()
		end
	end
	for _, spawner in (workspace.Elevator.CandySpawners:GetChildren()) do
		Candy:spawn(spawner)
		spawner.Transparency=1
	end
end)

for _, spawner in (workspace.Elevator.CandySpawners:GetChildren()) do
	Candy:spawn(spawner)
	spawner.Transparency=1
end

local lobbyCandies={}
--[[
task.spawn(function()
	while true do
		for _, oldCandy in (lobbyCandies) do
			oldCandy:Destroy()
		end
		lobbyCandies={}
		for _, spawner in (workspace.Lobby.Candies:GetChildren()) do
			local model = Candy:spawn(spawner)
			spawner.Transparency=1
			table.insert(lobbyCandies, model)
		end
		task.wait(240)
	end
end)]]

for _, spawner in (workspace.Lobby.Candies:GetChildren()) do
	local model = Candy:spawn(spawner)
	spawner.Transparency=1
	table.insert(lobbyCandies, model)
end



return Candy