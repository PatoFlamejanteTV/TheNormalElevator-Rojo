local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local Network = _G.Local.Network
local Client = _G.Local.Client

local Player = game:GetService("Players").LocalPlayer
local Event = game:GetService("ReplicatedStorage").ShowMusic

local Gui = script.Parent
local Holder = Gui:WaitForChild("Holder")
local Menu = Holder:WaitForChild("Menu")
local Song = Menu:WaitForChild("Song")
local Left = Menu:WaitForChild("Left")
local Right = Menu:WaitForChild("Right")
local NoteFrame = Gui:WaitForChild("NoteFrame")

local floorSounds={}
local soundConns = {}
local playingSound



local function updateMusicDetails(Music, musicStatus)
	if (musicStatus == "Playing") then
		Song.Status.Text = "Now Playing:"
		Song.Status.TextColor3 = Color3.fromRGB(85, 255, 119)
		--[[if (Client.InElevator==true) then
			Menu:TweenPosition(UDim2.new(), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
		end]]
	elseif (musicStatus == "Stopped") then
		
		Song.Status.Text = "Last Played:"
		Song.Status.TextColor3 = Color3.new(1,1,1)
		--Menu:TweenPosition(UDim2.new(0,0,0,-Holder.Size.Y.Offset), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
	end
	
	local songName = Music:GetAttribute("SongName")

	if (not songName) then
		local soundId = Music.SoundId:gsub("rbxassetid://","") --just need the id numbers
		if (soundId~="") then
			print(soundId)
			songName = MarketplaceService:GetProductInfo(tonumber(soundId), Enum.InfoType.Asset).Name
		end
	end
	Song.SongName.Text = songName or ""
	
	if (Client.Area~="Lobby") then
		Menu.Position=UDim2.new()
	end
	
end

local function getMusicStatus()
	local Music = game.Workspace.Map:FindFirstChild("Music", true)
	if (Music) then
		return Music.IsPlaying==true and "Playing" or "Stopped"
	end
	
	Music = game.Workspace.Elevator:FindFirstChild("Music", true)
	if (Music) then
		return Music.IsPlaying==true and "Playing" or "Stopped"
	end
end

Holder.MouseEnter:Connect(function()
	if (Client.Area=="Lobby") then
		Menu:TweenPosition(UDim2.new(), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
	end
end)

Holder.MouseLeave:Connect(function()
	if (Client.Area=="Lobby") then
		Menu:TweenPosition(UDim2.new(0,0,0,-Holder.Size.Y.Offset), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
	end
end)

if (Client.Area=="Lobby") then
	Menu:TweenPosition(UDim2.new(0,0,0,-Holder.Size.Y.Offset), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
end

local elevatorMusic = game.Workspace.Elevator.ButtonPad.Speaker:WaitForChild("Music")
elevatorMusic:GetPropertyChangedSignal("Playing"):Connect(function()
	updateMusicDetails(elevatorMusic, elevatorMusic.Playing==true and "Playing" or "Stopped")
end)


Event.OnClientEvent:Connect(function(Music, musicStatus)
	Menu:TweenPosition(UDim2.new(), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.2, true)
end)
--[[Network:Bind("PlayerAddedToElevator", function() 
	local Music = game.Workspace.Elevator:FindFirstChild("Music", true)
	local IsPlaying = getMusicStatus(Music)
	updateMusicDetails(IsPlaying, Music)
end)]]

game.Workspace.Map.ChildAdded:Connect(function(item)
	wait(0.8)
	local soundFolder = game.Workspace:FindFirstChild("Sounds")
	if (not soundFolder) then return end
	for _, sound in pairs(soundFolder:GetChildren()) do
		if (sound:IsA("Sound")) and (sound:GetAttribute("SongName")) then
			table.insert(floorSounds, sound)
		end
	end
	
	for _, sound in pairs(floorSounds) do
		sound:GetPropertyChangedSignal("Playing"):Connect(function()
			updateMusicDetails(sound, sound.Playing==true and "Playing" or "Stopped")
		end)
		if (sound.Playing) then
			updateMusicDetails(sound, "Playing")
		end
		
	end
end)

game.Workspace.Map.ChildRemoved:Connect(function(item)
	floorSounds = {}
end)

Right.FAQ.MouseButton1Down:Connect(function()
	NoteFrame.Visible = not NoteFrame.Visible
end)

NoteFrame.Exit.MouseButton1Down:Connect(function()
	NoteFrame.Visible = false
end)

wait(1)
local Music = game.Workspace.Map:FindFirstChild("Music", true) or game.Workspace.Elevator:FindFirstChild("Music", true)
updateMusicDetails(Music, Music.Playing)