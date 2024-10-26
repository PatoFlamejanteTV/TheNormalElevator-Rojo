local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Ambient
local Sounds
local Swat
local Sign
local Answer
local AnswerConnection

local Suspect
local SuspectChoice = "NO"
local Questioning = false
local PlayerChoices = {}

local Answers = {["YES"] = 2698860635, ["NO"] = 2698860363}




Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 42 --seconds
}

Floor.Lighting = {
	Bloom = {Intensity = 0,Size = 0, Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.fromRGB(1,1,1),Saturation = 0},
	Rays = {Intensity = 0,Spread = 0},
	Lighting = {ClockTime=12},
	Sky = Floor.Skybox
}

local function setVariables(Map)
	Floor.Model = Map
	Ambient = Floor.Sounds.Ambient
	Sounds = Map.Sound
	Swat = Map.SWAT
	Sign = Map.Sign
	Answer = Map.Answer
	
	AnswerConnection = Answer.Event:Connect(function(Player, playerAnswer)
		--print(Player.Name, Questioning)
		--print(Player.Name.." voted " .. playerAnswer)
		if (Player == Suspect) and (Questioning) then
			SuspectChoice = playerAnswer
			Questioning = false
		elseif (Elevator:getPlayer(Player.Name)) and (Questioning) then
			PlayerChoices[Player] = playerAnswer
		end
	end)
end

local function cloneCharacterToSWAT(Character)
	if (Functions:characterIsValid(Character)) then
		local charClone = Character:Clone()
		charClone.Parent = Floor.Model
		charClone:SetPrimaryPartCFrame(Sign.Middle.CFrame)
	end
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting)
end

local function dragCharacter(Character)
	local myRagdollScript = Character:FindFirstChild("RagdollScript")
	if (not myRagdollScript) then
		myRagdollScript = Floor.Model:FindFirstChild("RagdollScript"):Clone()
		myRagdollScript.Parent = Character
		myRagdollScript.Disabled = false
	end
	myRagdollScript.Activate.Value = true
	for _, Cop in pairs(Swat:GetChildren()) do
		Cop.LowerTorso.Anchored = true
		Cop.PrimaryPart.CFrame = CFrame.new(Cop.PrimaryPart.Position, Floor.Model:FindFirstChild(Cop.Name.."Pos").Position)
	end
	local leftHand = Character:FindFirstChild("LeftHand")
	local rightHand = Character:FindFirstChild("RightHand")
	if (leftHand) and (rightHand) then
		local leftAttach = Instance.new("Attachment")
		local rightAttach = Instance.new("Attachment")
		leftAttach.Parent = leftHand
		rightAttach.Parent = rightHand
		leftAttach.Name = "Rope"
		rightAttach.Name = "Rope"
		leftAttach:Clone().Parent = Swat.Steve.LeftHand
		rightAttach:Clone().Parent = Swat.Jaquan.RightHand
		local jaquanRope = Instance.new("RopeConstraint")
		jaquanRope.Parent = Swat.Jaquan.RightHand.Rope
		local steveRope = Instance.new("RopeConstraint")
		steveRope.Parent = Swat.Steve.LeftHand.Rope
		jaquanRope.Attachment0 = Swat.Jaquan.RightHand.Rope
		jaquanRope.Attachment1 = Character.RightHand.Rope
		jaquanRope.Length = 6
		steveRope.Attachment0 = Swat.Steve.LeftHand.Rope
		steveRope.Attachment1 = Character.LeftHand.Rope
		steveRope.Length = 6
		jaquanRope.Visible = true
		steveRope.Visible = true
		for _, Cop in pairs(Swat:GetChildren()) do
			local Anim = Cop:FindFirstChild("WalkAnim")
			local Track = Cop.Humanoid:LoadAnimation(Anim)
			Track:Play()
			Cop.Humanoid:MoveTo(Floor.Model:FindFirstChild(Cop.Name.."Pos").Position)
		end
	end
	for _, Cop in pairs(Swat:GetChildren()) do
		Cop.LowerTorso.Anchored = false
	end
end

local function answerNo()
	local Voice = Swat.Jaquan.Head.Voice
	Voice.SoundId = "rbxassetid://"..Answers["NO"]
	Voice:Play()
	wait(7)
	Suspect = Elevator:getRandomPlayer({Suspect})
	if (Suspect) then
		Sign.Middle.Gui.Picture.Image = game.Players:GetUserThumbnailAsync(Suspect.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
	end
	wait(2)
	if (Suspect) then
		local Character = Suspect.Character
		if (Functions:characterIsValid(Character)) then
			Functions:teleportPlayer(Suspect, Sign.Middle.CFrame)
			Sign:Destroy()
			Swat.Jaquan.Tool:Destroy()
			Swat.Steve.Tool:Destroy()
			for _, Cop in pairs(Swat:GetChildren()) do
				local Anim = Cop:FindFirstChild("AimAnim")
				local Track = Cop.Humanoid:LoadAnimation(Anim)
				Track:Stop()
			end
			wait(4)
			if (Character) then
				dragCharacter(Character)
				Character.Humanoid.WalkSpeed=0
			end
		end
	end
	
end

local function answerYes()
	for _, Cop in pairs(Swat:GetChildren()) do
		local Anim = Cop:FindFirstChild("AimAnim")
		local Track = Cop.Humanoid:LoadAnimation(Anim)
		Track:Stop()
	end
	local Voice = Swat.Jaquan.Head.Voice
	Voice.MaxDistance = 100
	Voice.SoundId = "rbxassetid://"..Answers["YES"]
	Voice:Play()
	wait(1)
	if (Functions:characterIsValid(Suspect.Character)) then
		Functions:teleportPlayer(Suspect, Sign.Middle.CFrame)
	end
	Sign:Destroy()
	wait(7.5)
	local Character = Suspect.Character
	if (Functions:characterIsValid(Character)) then
		Swat.Jaquan.Tool:Destroy()
		Swat.Steve.Tool:Destroy()
		dragCharacter(Character)
		Character.Humanoid.WalkSpeed=0
	end
end

function Floor:init(Map)
	setVariables(Map)
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Ambient:Play()
	Sounds.Engine:Play()
	Sounds.Siren:Play()
	
	for _, Cop in pairs(Swat:GetChildren()) do
		local Anim = Cop:FindFirstChild("AimAnim")
		local Track = Cop.Humanoid:LoadAnimation(Anim)
		Track:Play()
	end
	
	local Voice = Swat.Jaquan.Head.Voice
	Voice:Play()
	wait(Voice.TimeLength-4)
	Suspect = Elevator:getRandomPlayer()
	if (Suspect) then
		Sign.Middle.Gui.Picture.Image = game.Players:GetUserThumbnailAsync(Suspect.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
		Sign.Particles.ParticleEmitter.Enabled = true
		spawn(function()
			for i = 1, 25 do
				Sign.Middle.Transparency = (10-2/25)/10
				Sign.Middle.Gui.Picture.ImageTransparency = 1 - i/25
				wait()
			end
		end)
		
		local Gui = game.ReplicatedStorage.UI.QuestionGui:Clone()
		Gui.Parent = Suspect.PlayerGui
		Gui.Frame.Question.Text = "The police are looking for you. Do you confess?"
		
		Questioning = true
		Network:Send(Suspect, "GetAnswer", 4)
		local Count = 0
		repeat wait(1) Count = Count+1 until Count==5 or Questioning == false
		Questioning = false
		wait(1)
		Questioning = true
		if (SuspectChoice == "NO") then	--IF SUSPECT DOESNT SHOW HIMSELF
			if (#Elevator.Players > 1) then	--IF THERE ARE OTHER PEOPLE IN ELEVATOR
				for _, Player in pairs(Elevator.Players) do
					if (Player ~= Suspect) then
						local Gui = game.ReplicatedStorage.UI.QuestionGui:Clone()
						Gui.Parent = Player.PlayerGui
						Gui.Frame.Question.Text = "Do you want to snitch this person out?"
						Network:Send(Player, "GetAnswer", 4)
					end
				end
				wait(5)
				Questioning = false
				local YesCount = 0
				local ChoiceCount = 0
				for Player, Answer in pairs(PlayerChoices) do
					ChoiceCount = ChoiceCount+1
					if (Player) and (Answer == "YES") then
						YesCount = YesCount+1
					end
				end
				if (YesCount+YesCount>=ChoiceCount) then
					--THEY SNITCHED HIM OUT
					answerYes()
				else
					--THEY DIDN'T SNITCH HIM OUT
					answerNo()
				end
			else	--IF THERE ARE NO OTHER PLAYERS IN ELEVATOR
				if (#Elevator.NPCs>0) then
					Voice.SoundId = "rbxassetid://"..Answers["NO"]
					Voice:Play()
					wait(7)
					local Character = Elevator:getRandomNPC()
					Character:SetPrimaryPartCFrame(Sign.Middle.CFrame)
					Sign:Destroy()
				else
					answerNo()
				end
			end
			
		elseif (SuspectChoice == "YES") then
			Elevator.Time = Elevator.Time - 10
			answerYes()
		end
	else
		Elevator.Time = 2
	end
	
end

function Floor.ending()
	Questioning = false
	AnswerConnection:Disconnect()
	SuspectChoice = "NO"
	PlayerChoices = {}
	if (Suspect) and (Suspect.Character) and (Suspect.Character:FindFirstChild("RagdollScript")) then
		Suspect.Character.RagdollScript.Activate.Value = false
		Suspect.Character.RagdollScript:Destroy()
	end
	for _, Player in pairs(Elevator.Players) do
		local Character = Player.Character
		if (Functions:characterIsValid(Character)) then
			local Humanoid = Character.Humanoid
			Humanoid.WalkSpeed = 16
		end
	end
	
	Suspect = nil
end

return Floor