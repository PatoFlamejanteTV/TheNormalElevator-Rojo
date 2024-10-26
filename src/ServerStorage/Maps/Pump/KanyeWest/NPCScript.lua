local Elevator = _G.Modules:Load("Elevator")
local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Data = _G.Modules:Load("Data")

local NPC = {}

NPC.Model = script.Parent
NPC.Name = NPC.Model.Name
NPC.Humanoid = Functions:getHumanoid(NPC.Model)
NPC.Area = "Map"
NPC.active = false

NPC.rewardedPlayers = {}
NPC.CANDY_REWARD = {min = 3, max = 6}

local candyReloadTime = 300 --seconds

function NPC:init(Area)
	NPC.active = true
	--[[spawn(function()
		while (NPC.Model) and (NPC.active) do
			NPC:chatLoop()
		end
	end)]]
	return NPC
end

--[[function NPC:chat(phrase)
	if (not phrase) then
		local phrase
		if (lastPhrase) then
			repeat phrase = phrases[math.random(1,#phrases)] until phrase ~= lastPhrase
			lastPhrase = phrase
		else
			lastPhrase = phrases[math.random(1,#phrases)]
		end
	else
		lastPhrase = phrase
	end
	if (NPC.Model) and (NPC.Model:FindFirstChild("Head")) and (NPC.Model.Parent == game.Workspace) then
		game:GetService("Chat"):Chat(NPC.Model.Head, lastPhrase, Enum.ChatColor.Blue)
	end
end

function NPC:chatLoop()
	wait(math.random(15, 45))
	NPC:chat()
end

NPC.Humanoid.Died:Connect(function()
	Elevator:removeNPC(NPC.Model)
	NPC.active = false
	for Player, Reward in pairs(NPC.rewardedPlayers) do
		Network:Send(Player, "ClearNPCReward", NPC.Model)
	end
	wait(3)
	Clone.Parent = NPC.parent
	require(Clone.NPCScript):init()
	NPC.Model.Parent = nil
end)]]

NPC.Humanoid.Touched:Connect(function(Hit)
	
	if (Hit.Parent:FindFirstChild("Humanoid")) and (Hit.Parent:FindFirstChild("TreatBag")) then
		local Character = Hit.Parent
		local Player = game.Players:GetPlayerFromCharacter(Character)
		if (Character) and (not NPC.rewardedPlayers[Player]) then
			local playerFolder = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
			if (playerFolder) and (playerFolder:FindFirstChild("Candy")) then
				if (playerFolder.Candy.Value <= Data.CANDY_MAX) then
					local rewardAmount = math.random(NPC.CANDY_REWARD.min, NPC.CANDY_REWARD.max)
					rewardAmount = (playerFolder.Candy.Value+rewardAmount<=Data.CANDY_MAX) and rewardAmount or Data.CANDY_MAX-playerFolder.Candy.Value
					if (rewardAmount~=0) then
						NPC.rewardedPlayers[Player] = rewardAmount
						playerFolder.Candy.Value = playerFolder.Candy.Value + rewardAmount
						Network:Send(Player, "RewardedCandy", NPC.Model)
						spawn(function()
							wait(candyReloadTime)
							NPC.rewardedPlayers[Player] = nil
						end)
					end
					
				end
				
			end
		end
	end
end)

return NPC