local UIS = game:GetService("UserInputService")

local Audio = _G.Local:Load("Audio")
local Lobby = _G.Local:Load("Lobby")
local Elevator = _G.Local:Load("Elevator")
local Storage = game.ReplicatedStorage:WaitForChild("ClientStorage")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Client = {}

Client.Area = "Lobby"
Client.CharacterAdded = false
Client.Juiced = false

Client.onMobile = UIS.TouchEnabled
Client.onController = UIS.GamepadEnabled
Client.onKeyboard = (Client.onMobile == false and Client.onKeyboard == false)


function Client:HideModels(...)
	local models = {...}
	for _, model in pairs(models) do
		if (model) then
			local parent = model.Parent
			if (not model:FindFirstChild("ParentTag")) then
				model.Parent = Storage
				local tag = Instance.new("ObjectValue", model)
				tag.Name = "ParentTag"
				tag.Value = parent
			end
		end
	end
end

function Client:ParentModels(...)
	local models = {...}
	for _, model in pairs(models) do
		if (model) then
			if (typeof(model=="string")) then
				model = Storage:FindFirstChild(model)
			end
			if (model) and (model:FindFirstChild("ParentTag")) then
				model.Parent = model.ParentTag.Value
				model.ParentTag:Destroy()
			end
		end
	end
end

function Client:getPlatform()
	local Result = "Keyboard"
	if (Client.onMobile) then
		Result = "Mobile"
	end
	if (Client.onController) then
		Result = "Console"
	end
	if (Client.onKeyboard) then
		Result = "PC"
	end
	return Result
end

function Client:hideCharacter(Character, Trans)
	local N = Trans~=nil and Trans or 1
	local function hidePart(Part)
		if (Part:IsA("BasePart")) then
			if (Part.Name~="HumanoidRootPart") then
				Part.Transparency = N
				for _, Decal in pairs(Part:GetChildren()) do
					if (Decal:IsA("Decal")) then
						Decal.Transparency = N
					end
				end
			end
		end
	end
	for _, Accessory in pairs(Character:GetChildren()) do
		if (Accessory:IsA("Accessory")) then
			Accessory.Handle.Transparency = N
		end
	end
	for _, Part in pairs(Character:GetChildren()) do
		hidePart(Part)
	end
end

function Client:hideName(Character, Value)
	local Head = Character:FindFirstChild("Head")
	if (Head) and (Head:FindFirstChild("PlayerName")) then
		Head.PlayerName.Enabled = not Value
	end
end

function Client:init()
	if (Client.Area == "Elevator") then
		--Client:ParentModels("Lobby")
	end
--	Client:HideModels(Elevator.Map, Elevator.Background, Elevator.Model, game.Workspace:FindFirstChild("NPCs"))
	
	Client.Area = "Lobby"
	Client.CharacterAdded = true
	
	Audio:playMusic(Audio.Musics.Lobby, true)

	--[[spawn(function()
		while (Lobby.Model.Parent == game.Workspace) do
			print"aaa"
			Lobby:updateLights()
			wait(1)
		end
	end)]]
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = player.Character:WaitForChild("Humanoid")
	cam.FieldOfView=70
	--cam.CameraSubject
end

return Client