local phrases =  {
	"harlem actually did an update for his game, wow",
	"I'm the owner of rock bottom again",
	"Peter Piper Pizza sounds so good right now",
	"I'm the reason harlem made his roblox account B)",
	"drowning in homework yo please save me",
	"I've never seen Spongebob catch his bus"
}
local lastPhrase

local Elevator = _G.Modules:Load("Elevator")
local Functions = _G.Modules:Load("Functions")

local NPC = {}

NPC.Model = script.Parent
NPC.Humanoid = Functions:getHumanoid(NPC.Model)

NPC.active = false
NPC.parent = script.Parent.Parent

local Clone = NPC.Model:Clone()

function NPC:init()
	NPC.active = true
	spawn(function()
		while (NPC.Model) and (NPC.active) do
			NPC:chatLoop()
		end
	end)
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
	if (NPC.Model) and (NPC.Model:FindFirstChild("Head")) and (NPC.Model.Parent == game.Workspace) then
		game:GetService("Chat"):Chat(NPC.Model.Head, lastPhrase, Enum.ChatColor.Blue)
	end
end

function NPC:chatLoop()
	wait(math.random(15, 30))
	NPC:chat()
end

NPC.Humanoid.Died:Connect(function()
	Elevator:removeNPC(NPC.Model)
	NPC.active = false
	wait(3)
	Clone.Parent = NPC.parent
	require(Clone.NPCScript):init()
	NPC.Model.Parent = nil
end)

return NPC