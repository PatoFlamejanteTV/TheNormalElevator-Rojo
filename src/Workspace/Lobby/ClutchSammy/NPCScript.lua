local phrases =  {
	"harlem actually did an update for his game, wow",
	"I'm the owner of rock bottom again",
	"Peter Piper Pizza sounds so good right now",
	"I'm the reason harlem made his roblox account B)",
	"drowning in homework yo please save me",
	"I've never seen Spongebob catch his bus",
	"shoutout Koneko"
}
local lastPhrase

local Elevator = _G.Modules:Load("Elevator")
local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Data = _G.Modules:Load("Data")

local NPC = {}

NPC.Model = script.Parent
NPC.Name = NPC.Model.Name
NPC.Humanoid = Functions:getHumanoid(NPC.Model)
NPC.Area = "Lobby"
NPC.active = false

NPC.rewardedPlayers = {}
NPC.CANDY_REWARD = {min = 2, max = 4}

local candyReloadTime = 240 --seconds

local Clone = NPC.Model:Clone()
local cloneArea = NPC.Area

local connections = {}

function NPC:cleanup()
	Elevator:removeNPC(NPC.Model)
	NPC.active = false
	for _, conn in pairs(connections) do
		conn:Disconnect()
	end
	if (NPC.Humanoid) then NPC.Humanoid:Destroy() end
	for Player, Reward in pairs(NPC.rewardedPlayers) do
		Network:Send(Player, "ClearNPCReward", NPC.Model)
	end
	table.clear(NPC.rewardedPlayers)
	wait(3)
	Clone.Parent = game.Workspace:FindFirstChild(cloneArea)
	require(Clone.NPCScript):init()
	if (NPC.Model) then NPC.Model:Destroy() end
	NPC = nil
end

function NPC:init(Area)
	NPC.active = true
	return NPC
end

function NPC:chat(phrase)
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
	if (NPC) and (NPC.Model) and (NPC.Model:FindFirstChild("Head")) and (NPC.Model.Parent == game.Workspace.NPCs) then
		game:GetService("Chat"):Chat(NPC.Model.Head, lastPhrase, Enum.ChatColor.Blue)
	end
end

function NPC:chatLoop()
	wait(math.random(15, 45))
	if (not NPC) then return end
	NPC:chat()
end

connections[1] = NPC.Humanoid.Died:Connect(function()
	NPC:cleanup()
end)

connections[2] = NPC.Humanoid.Touched:Connect(function(Hit)

	if (NPC.active) and (Hit.Parent:FindFirstChild("Humanoid")) and (Hit.Parent:FindFirstChild("TreatBag")) then
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
						Network:Send(Player, "RewardedCandy", NPC.Model, candyReloadTime)
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

spawn(function()
	while (NPC) and (NPC.Model) and (NPC.active) do
		NPC:chatLoop()
	end
end)


return NPC