local phrases =  {
	"Years later and I'm still stuck here...",
	"Come get your weird artifacts here!" ,
	"Dude I heard these artifacts can shatter reality",
	"I don't like looking at my old code :(",
	"AHHH I FELL OFF THE SIDE AGAIIIIN",
	"Doomsekkar is the best pumpkin hat ever.",
	"I don't like that door under maintenance...",
	"How do I get out of here :(",
	"This snake around my head will attack predators.",
	"I remember when I got turned into a waffle in that elevator...",
	"I'm normally poor, but when I'm not, I BUY TOKENS.",
	"I like driving trains into elevators."
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
	if (NPC.Model) and (NPC.Model:FindFirstChild("Head")) then
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