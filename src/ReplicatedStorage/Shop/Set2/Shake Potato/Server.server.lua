local Character
local Humanoid

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Mouth = Tool:WaitForChild("Mouth")
local ChatBubble = Mouth:WaitForChild("ChatBubble")

local ShakeAnim = Tool:WaitForChild("Shake")
local IdleAnim = Tool:WaitForChild("Idle")	

local Debounce = true

local Shakes = 0

math.randomseed(tick())

local Answers = {"OH YEAH 100%, DEFINITELY", "WHAT? NO! ABSOLUTELY NOT!", "I TOTALLY THINK SO", "According to my calculations, YES 100%",
	"I am the frenchiest fry and I DENY", "WELL DUH, OBVIOUSLY", "HAHAHA ARE YOU SERIOUS, NO!", "I mean I think so, but that's just me",
	"CAN CONFIRM", "CANNOT CONFIRM NOR DENY", "UM, PROBABLY NOT", "YES is what I would say if I was a liar", "Um... I was told to keep this a secret... but yes",
	"Yeaaaaah, no. Definitely no. 100% no.", "YES!!! YES!!! YES!!!"}

local LastAnswer = "Please stop shaking me"


local function UpdateTextBubble(String)
	local INTERVAL = 0.035
	for i = 1, string.len(String) do
		ChatBubble.Bubble.Label.Text = string.sub(String, 1, i)
		wait(INTERVAL)
	end
end

Tool.Activated:connect(function()

	if (Character) and (Humanoid) then
		if (Debounce == true) then
			Debounce = false
			
			Shakes = Shakes + 1
			
			if (Shakes == 10) then
				table.insert(Answers, #Answers+1, "Please stop shaking me")
			end
			
			
			local LoadedShake = Humanoid:LoadAnimation(ShakeAnim)
			
			if (LoadedShake) then
				LoadedShake:Play()
			end
			
			local NewAnswer 
			repeat NewAnswer = Answers[math.random(1, #Answers)] until NewAnswer ~= LastAnswer
			LastAnswer = NewAnswer
			
			wait(2)
			
			ChatBubble.Bubble:TweenSize(UDim2.new(2,0,1,0), "Out", "Elastic", 0.6, false)
			UpdateTextBubble(NewAnswer)
			wait(4)
			ChatBubble.Bubble:TweenSize(UDim2.new(0,0,0,0), "Out", "Linear", 0.1, false)
			wait(0.1)
			ChatBubble.Bubble.Label.Text = ""
			Debounce = true
		end
	end
	
end)

Tool.Equipped:connect(function()
	
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	
	if (Character) and (Humanoid) then
		
		LoadedIdle = Humanoid:LoadAnimation(IdleAnim)
		
		if (LoadedIdle) then
			LoadedIdle:Play()
		end
	end
	
end)

Tool.Unequipped:connect(function()
	
	if (LoadedIdle) then
		LoadedIdle:Stop()
	end
	
end)