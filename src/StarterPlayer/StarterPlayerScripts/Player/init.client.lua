_G.Local = require(script.Modules.Modules)
_G.Local:LoadAll()
local UI = _G.Local.UI
local Audio = _G.Local.Audio
local Lighting = _G.Local.Lighting
local Client = _G.Local.Client
local Lobby = _G.Local.Lobby
local Elevator = _G.Local.Elevator
local Network = _G.Local.Network

--hi people who arent ME looking at MY code, hope ur happy >:(


Network.Pass = script:WaitForChild("Pass") --bindable event
Network.Fetch = script:WaitForChild("Fetch") --bindable function

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local Control = Player.PlayerScripts:WaitForChild("PlayerModule")
local MasterControl = require(Control:WaitForChild("ControlModule"))

--[[
local ReplicatedStorage = game.ReplicatedStorage
local PlayerData = ReplicatedStorage:WaitForChild("PlayerData")
local MyData = PlayerData:WaitForChild(Player.Name)
]]

Audio:init()
--Client:init()
--Lighting:init()
--UI:init()

Network.Pass.Event:Connect(function(...)

	local args = {...}
	
	
	if (args[1] == "LobbyFakeDoor") then
		Lobby:toggleFakeDoor(args[2])
	elseif (args[1] == "ElevatorFakeDoor") then
		Elevator:toggleFakeDoor(args[2])
		
	elseif (args[1] == "SetControl") then
		if (args[2] == false) then MasterControl:Disable() else MasterControl:Enable() end
		
	elseif (args[1] == "CharacterAdded") then
		Client:init()
		Lighting:init()
		UI:init()
		Lobby:init()
		Audio:stopMapMusic()
		
	elseif (args[1] == "CharacterDied") then
		Client.CharacterAdded = false
		
	elseif (args[1] == "ToggleNames") then
		for _, otherPlayer in pairs(args[2]) do
			if (otherPlayer.Character) then
				Client:hideName(otherPlayer.Character, not args[3])
			end
		end
	elseif (args[1] == "ResetSettingsUI") then
		for _, otherPlayer in pairs(game.Players:GetPlayers()) do
			if (Player~=otherPlayer) and (otherPlayer.Character) then
				local Char = otherPlayer.Character
				if (UI.SETTINGS.HIDE_PLAYERS==false) then
					Client:hideCharacter(Char, 0)
				else
					Client:hideCharacter(Char, 1)
				end
				if (UI.SETTINGS.HIDE_NAMETAGS==false) then
					Client:hideName(Char, false)
				else
					Client:hideNAme(Char, true)
				end
			end
		end
		
		
	elseif (args[1] == "LoadElevator") then
		Client.Area = "Elevator"
		--Client:ParentModels("Elevator", "Background", "Map", "NPCs")
	--	Client:HideModels(Lobby.Model)
		Audio:stopMusic(true)
		Lighting:update(args[2])
		
		if (UI.SETTINGS.MUTE_ELEVATOR==true) then
			Audio:muteElevator()
		end
		if (UI.SETTINGS.MUTE_MUSIC==false) then
			Audio:muteMusic(false)
		end
		
	elseif (args[1] == "FadeBlack") then
		UI:fadeBlackScreen(args[2], args[3], args[4], args[5])
	elseif (args[1] == "BlackScreenText") then
		UI:fadeBlackScreen(args[2], args[3], args[4], args[5], args[6])
		
	elseif (args[1] == "LoadLighting") then
		print(args[2])
		Lighting:update(args[2])
		
	elseif (args[1] == "ElevatorLighting") then
		Lighting:update(Lighting.Elevator)
		
	elseif (args[1] == "PlayMusic") then
		Audio:playMusic(args[2])
		
	--elseif (args[1]=="ShowMusicPlaying") then
		
		
	elseif (args[1] == "ChangeMusicProperties") then
		Audio:changeMusicProperties(args[2])
		
	elseif (args[1] == "CleanSnoop") then
		if (game.Workspace:FindFirstChild("Background")) then
			for _, Part in pairs(game.Workspace.Background:GetChildren()) do
				if (Part:FindFirstChild("Fake")) then
					Part.Fake:Destroy()
				end
			end
		end
	elseif (args[1] == "ShowMessage") then
		local num = args[3] or 7
		UI:showMessage(args[2], num)
		
	elseif (args[1] == "ElevatorMusicPlaying") then
		if (UI.SETTINGS.MUTE_ELEVATOR==true) then
			Audio:muteElevator()
		else
			Audio:muteElevator(false)
		end
	elseif (args[1] == "RefreshSongList") then
		UI:refreshSongSelection(args[2])
		
	elseif (args[1] == "CountdownBar") then
		local Bar = args[2]
		
	elseif (args[1] == "RewardedCandy") then
		Client.collectedCandyFrom[args[2]] = args[3] --args[3] is reload time
		if (Client.candyTimers[args[2]]) then
			Client.candyTimers[args[2]]:Destroy()
			Client.candyTimers[args[2]] = nil
		end
		if (args[3]) and (Client.candyTimers[args[2]] == nil) then
			local timerGui = Instance.new("BillboardGui")
			timerGui.Enabled = false
			Client.candyTimers[args[2]] = timerGui
			timerGui.Name = "TimerGui"
			timerGui.Parent = args[2].PrimaryPart
			timerGui.AlwaysOnTop = true
			timerGui.LightInfluence = 0
			timerGui.Size = UDim2.new(1.5,0,1.5,0)
			timerGui.MaxDistance = 30
			timerGui.Adornee = args[2].PrimaryPart
			
			local timeLabel = Instance.new("TextLabel")
			timeLabel.Name = "Label"
			timeLabel.Parent = timerGui
			timeLabel.BackgroundTransparency = 1
			timeLabel.Size = UDim2.new(1,0,1,0)
			timeLabel.Font = Enum.Font.GothamBlack
			timeLabel.Text = args[3]
			timeLabel.TextScaled = true
			timeLabel.TextColor3 = Color3.new(1,1,1)
			timeLabel.TextStrokeColor3 = Color3.new()
			timeLabel.TextStrokeTransparency = 0
			
			for i = args[3], 1, -1 do
				Client.collectedCandyFrom[args[2]] = i
				timeLabel.Text = i
				wait(1)
			end
			if (Client.candyTimers[args[2]]) and (Client.candyTimers[args[2]] == timerGui) then
				Client.candyTimers[args[2]]:Destroy()
				Client.candyTimers[args[2]] = nil
			end
			
			
			Client.collectedCandyFrom[args[2]] = nil
			
		elseif (not args[3]) then
			Client.collectedCandyFrom[args[2]] = -1
		end
		
	elseif (args[1] == "ClearNPCReward") then
		Client.collectedCandyFrom[args[2]] = nil
		
	elseif (args[1] == "ToggleUI") then
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, args[2])
		--game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, args[2])
		
		--[[
		for _, Gui in pairs(Player.PlayerGui:GetChildren()) do
			if (Gui.Name == "Main")  then
				Gui.Enabled = args[2]
			elseif (Gui.Name == "CandyGui") and args[2]==false then
				Gui.Enabled = args[2]
			end
		end]]
	elseif (args[1] == "RemoveTrickData") then
		Client.unlockedTricks["Trick"..args[2]] = false
		
	elseif (args[1] == "LoadDeathScene") then
		local playerList = args[2]
		local loadTime = args[3]
		local deathScene = game.ReplicatedStorage.DeathScene:Clone()
		deathScene.Parent = game.Workspace
		
		local fakeChars={}
		local chars = {}
		
		pcall(function()
			if (#playerList>1) then
				for _, elevatorPlayer in pairs(playerList) do
					local pChar = elevatorPlayer.Character
					if (pChar) and (Character~=pChar) and (pChar:FindFirstChild("Humanoid")) and (pChar.Humanoid.Health > 0) then
						table.insert(chars, pChar)
						pChar.Archivable = true
						Client:hideName(pChar, true)
						local fakeChar = pChar:Clone()
						pChar.Archivable = false
						Client:hideCharacter(pChar, 1)
						fakeChar.Parent = pChar.Parent
						fakeChars[#fakeChars+1] = fakeChar
						fakeChar.Name = "DeadPose"
						
						local deathPoses = deathScene.Poses:GetChildren()
						local myDeathPose = deathPoses[math.random(1, #deathPoses)]
						--fakeChar:SetPrimaryPartCFrame(myDeathPose.PrimaryPart.CFrame)
						for _, bodyPart in pairs(fakeChar:GetChildren()) do
							if (bodyPart:IsA("BasePart")) and (myDeathPose:FindFirstChild(bodyPart.Name)) and (myDeathPose[bodyPart.Name]:IsA("BasePart"))then
								fakeChar[bodyPart.Name].Anchored = true
								fakeChar[bodyPart.Name].CFrame = myDeathPose[bodyPart.Name].CFrame
								
							end
						end
						if (myDeathPose:FindFirstChild("Weapons")) then
							for _, weapon in pairs(myDeathPose.Weapons:GetChildren()) do
								weapon.Transparency = 0
							end
						end
					end
				end
			else
				local pChar = Character
				if (pChar) and (pChar:FindFirstChild("Humanoid")) and (pChar.Humanoid.Health > 0) then
					pChar.Archivable = true
					Client:hideName(pChar, true)
					local fakeChar = pChar:Clone()
					pChar.Archivable = false
					fakeChar.Parent = pChar.Parent
					fakeChars[#fakeChars+1] = fakeChar
					fakeChar.Name = "DeadPose"
					
					local deathPoses = deathScene.Poses:GetChildren()
					local myDeathPose = deathPoses[math.random(1, #deathPoses)]
					--fakeChar:SetPrimaryPartCFrame(myDeathPose.PrimaryPart.CFrame)
					for _, bodyPart in pairs(fakeChar:GetChildren()) do
						if (bodyPart:IsA("BasePart")) and (myDeathPose[bodyPart.Name]) and (myDeathPose[bodyPart.Name]:IsA("BasePart"))then
							fakeChar[bodyPart.Name].Anchored = true
							fakeChar[bodyPart.Name].CFrame = myDeathPose[bodyPart.Name].CFrame
							
						end
					end
					if (myDeathPose:FindFirstChild("Weapons")) then
						for _, weapon in pairs(myDeathPose.Weapons:GetChildren()) do
							weapon.Transparency = 0
						end
					end
				end
			end
		end)
		
		
		
		
		wait(loadTime)
		deathScene:Destroy()
		for _,  deathS in pairs(game.Workspace:GetChildren()) do
			if (deathS.Name == "DeathScene") then
				deathS:Destroy()
			end
		end
		for _, fakeChar in pairs(fakeChars) do
			fakeChar:Destroy()
		end

		for _, Char in pairs(chars) do
			if (Char) then
				--if (UI.SETTINGS.HIDE_PLAYERS==false) then
					Client:hideCharacter(Char, 0)
				--end
				--if (UI.SETTINGS.HIDE_NAMETAGS==false) then
				--	Client:hideName(Char, false)
				--end
			end
		end
	end
end)
	
Network.Fetch.OnInvoke = function(...)
	
	local args = {...}
	local Result
	
	if (args[1] == "ClientArea") then
		Result = Client.Area
		
	elseif (args[1] == "UserSongId") then
		Result = UI.addSongId
	end
	
	return Result
end

game.Players.PlayerAdded:Connect(function(newPlayer)
	newPlayer.CharacterAdded:Connect(function(newCharacter)
		
		if (UI.SETTINGS.HIDE_PLAYERS==true) and (Character~=newCharacter) then
			Client:hideCharacter(Character)
		end
		
	end)
end)