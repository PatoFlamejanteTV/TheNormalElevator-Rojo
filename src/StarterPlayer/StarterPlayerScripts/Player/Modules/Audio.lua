local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer

local Network = _G.Local:Load("Network")

local Audio = {}

Audio.Folder = nil
Audio.SoundFolder = nil
Audio.MusicFolder = nil

local Sounds = game.Workspace:FindFirstChild("Sounds")

Audio.Musics = {
	Lobby = {
		SoundId = "rbxassetid://5493936730",
		Name = "Lobby",
		Looped = true,
		Volume = 0.5
	}
}

local function fadeInSound(Sound, NewV, Time) --Time is seconds
	local UI = _G.Local:Load("UI")
	for v1 = 0, NewV, NewV/10 do
		if (UI.SETTINGS.MUTE_MUSIC == false) then
			Sound.Volume = v1
		end
		wait(Time/10)
	end
	if (UI.SETTINGS.MUTE_MUSIC == false) then Sound.Volume = NewV end
end

local function fadeOutSound(Sound, Time) --Time is seconds
	local UI = _G.Local:Load("UI")
	local V = Sound.Volume
	for v1 = V, V*10, V do
		if (UI.SETTINGS.MUTE_MUSIC == false) then
			Sound.Volume = V - v1/10
		end
		wait(Time/10)
	end
	Sound.Volume = 0
end

function Audio:init()
	Audio.Folder = Instance.new("Folder", Player)
	Audio.Folder.Name = "Audio"
	
	Audio.SoundFolder = Instance.new("Folder", Player)
	Audio.SoundFolder.Name = "Sounds"
	
	Audio.MusicFolder = Instance.new("Folder", Player)
	Audio.MusicFolder.Name = "Music"
end

function Audio:playMusic(properties, fadeIn)
	Audio:stopMusic(true)
	local Music
	if (type(properties) == "table") then
		Music = Instance.new("Sound", Audio.MusicFolder)
		for key, value in pairs(properties) do
			Music[key] = value
		end
	elseif (type(properties) == "userdata") and (properties:IsA("Sound")) then
		Music = properties
	end
	Music:Play()
	local UI = _G.Local:Load("UI")
	if (UI.SETTINGS.MUTE_MUSIC==false) then
		if (fadeIn) then
			spawn(function()
				fadeInSound(Music, Music.Volume, 3)
			end)
		end
	else
		Music.Volume = 0
	end
	
end

function Audio:muteElevator(Value)
	local Volume = (Value==nil and 0) or (Value==true and 0) or (Value==false and Network:Get(Player, "GetElevatorVolume"))
	if (game.Workspace:FindFirstChild("Elevator")) then
		local Elevator = game.Workspace.Elevator
		Elevator.ButtonPad.Speaker.Music.Volume = Volume
	end
end

function Audio:muteMusic(Value)
	local Client = _G.Local.Client
	local Volumes = {}
	for _, Sound in pairs(Sounds:GetChildren()) do
		if (Sound:IsA("Sound")) then
			local Volume = (Value==nil and 0) or (Value==true and 0) or (Value==false and Network:Get(Player, "GetSoundVolume", Sound))
			Volumes[Sound] = Volume
		end
	end
	for Sound, Volume in pairs(Volumes) do
		if (Client.Area == "Elevator") then
			Sound.Volume = Volume
		else
			Sound.Volume = 0
		end
	end
	for _, Music in pairs(Audio.MusicFolder:GetChildren()) do
		if (Music:IsA("Sound")) then
			local Volume = (Value==nil and 0) or (Value==true and 0) or (Value==false and Audio.Musics[Music.Name].Volume)
			Music.Volume = Volume
		end
	end
end

function Audio:stopMusic(fadeOut)
	for _, Music in pairs(Audio.MusicFolder:GetChildren()) do
		if (Music:IsA("Sound")) and (Music.IsPlaying) then
			if (fadeOut) then
				spawn(function()
					fadeOutSound(Music, 1)
					Music:Stop()
					Music:Destroy()
				end)
			else
				Music:Stop()
				Music:Destroy()
			end
		end
	end
end

function Audio:stopMapMusic()
	for _, Music in pairs(Sounds:GetChildren()) do
		Music.Volume = 0
	end
end

-----CHANGE ALL FLOORS CODE
function Audio:changeMusicProperties(Musics)
	for _, MusicTable in pairs(Musics) do
		local Music = MusicTable.Music
		local Properties = MusicTable.Properties
		local Info = MusicTable.Tween
		if (Info) then
			local Tween = TweenService:Create(Music, Info, Properties)
			Tween:Play()
		else
			for Prop, Value in pairs(Properties) do
				if (Music[Prop]) then
					Music[Prop] = Value
				end
			end
			if (not Music.IsPlaying) then
				--Do a server check to see if it's playing
				local Network = _G.Local.Network
				local isPlaying, TimePosition = Network:Get(Player, "MusicIsPlaying", Music)
				Music.Playing = isPlaying
				Music.TimePosition = TimePosition
			end
		end
	end
end


Sounds.ChildAdded:Connect(function(Sound)
	local Client = _G.Local.Client
	if (Sound:IsA("Sound")) then
		if (Client.Area == "Lobby") then
			Sound.Volume = 0
		elseif (Client.Area == "Elevator") then
			local UI = _G.Local.UI
			if (UI.SETTINGS.MUTE_MUSIC == true) then
				Sound.Volume = 0
			end
		end
	end
end)

return Audio