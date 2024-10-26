local phrases =  {
	"Wooooo! The Normal Elevator back in business BABY!!!", 
	"You earn 1 coin for every floor you visit!",
	"Shout out to corona97 and supersesma!! They my cousins",
	"You should totally check out the shop for an enhanced experience",
	"DuffyXx really wants me to make a statue of her",
	"I don't know who Gavin is",
	"Hey, you!! I love you!!",
	"I'm chugging a jug of Arizona Watermelon tea right now prob",
	"follow me on twitter @ericzona_"
}
local lastPhrase

local Elevator = _G.Modules:Load("Elevator")
local Functions = _G.Modules:Load("Functions")

local NPC = {}

NPC.Model = script.Parent
NPC.Name = NPC.Model.Name
NPC.Humanoid = Functions:getHumanoid(NPC.Model)
NPC.Area = "Lobby"
NPC.active = false

local Clone = NPC.Model:Clone()

function NPC:init(Area)
	NPC.active = true
	spawn(function()
		while (NPC.Model) and (NPC.active) do
			NPC:chatLoop()
		end
	end)
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
	wait(3)
	Clone.Parent = NPC.parent
	require(Clone.NPCScript):init()
	NPC.Model.Parent = nil
end)

return NPC