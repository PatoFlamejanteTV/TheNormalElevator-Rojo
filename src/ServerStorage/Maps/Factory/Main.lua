local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Dance
local Scene
local Bars
local Dancers
local Lights
local Conveyer
local Sign

local Running = false

Floor.MusicProperties = {Volume = 2}

local Colors = {["Orange"]=Color3.new(1,0.5,0), ["Purple"]=Color3.new(0.7,0,0.7), ["Green"]=Color3.new(0,1,0), ["Black"]=Color3.new(0.1,0.1,0.1)}
local BarColors = {{255,0}, {245, 27}, {213,51}, {180,68}, {141,66}, {111,66}, {56,38}, {24,21}}
local currentColors = {Left="Orange",Middle="Black",Right="Orange"}
local lightColorList = {"Orange", "Black"} --for elevator lights
local lightIndex = 1
local playerIndex = 1
local Kawaii = {}
local Storage = {}
local waitingList = {}
local NPCs={}

local Connections = {}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 30 --seconds
}

local function setVariables(Map)
	Dance = Map.Dance
	Scene = Map.Scene
	Bars = Scene.Bars
	Dancers = Scene.Dancers
	Lights = Scene.Lights
	Conveyer = Scene.Conveyer
	Sign = Map.Sign
end

function Floor:initPlayer(Player)
	
end

local function kawaiiCharacter(Character, Color)
	local shirtId = (Color == "Orange" and 1081193434) or (Color == "Purple" and 1142696327) or (Color == "Green" and 1142753463) or (Color == "Black" and 0)
	local pantsId = (Color ~= "Black" and 1284269182) or 2408267030
	if (Character) then
		if (not Character.Head:FindFirstChild("hearts")) then
			local Hearts = Dancers.Middle.Head.hearts:Clone()
			Hearts.Parent = Character.Head
		end
		if (Character:FindFirstChild("Honey Hair")) then
			Character["Honey Hair"]:Destroy()
		end
		local Hair = game.ServerStorage.Models:FindFirstChild("Honey Hair"):Clone()
		Hair.Parent = Character
		Hair.Handle.Color = Colors[Color]
		if (game.Players:GetPlayerFromCharacter(Character)) then
			if (not Storage[Character]) then
				Storage[Character] = {}
			end
			if (Character:FindFirstChild("Shirt")) and (not Storage[Character].Shirt) then
				Storage[Character].Shirt = Character.Shirt.ShirtTemplate
				Character.Shirt:Destroy()
			end
			if (Character:FindFirstChild("Pants")) and (not Storage[Character].Pants) then
				Storage[Character].Pants = Character.Pants.PantsTemplate
				Character.Pants:Destroy()
			end
			local Humanoid = Functions:getHumanoid(Character)
			if (Humanoid) and (Humanoid.RigType == Enum.HumanoidRigType.R15) then
				Storage[Character].Animation = Humanoid:LoadAnimation(Dance)
				Storage[Character].Animation:Play()
			end
			table.insert(Kawaii, #Kawaii+1, Character)
		else
			if (Character:FindFirstChild("Shirt")) then
				Character.Shirt:Destroy()
			end
			if (Character:FindFirstChild("Pants")) then
				Character.Pants:Destroy()
			end
			local Humanoid = Functions:getHumanoid(Character)
			local Track = Humanoid:LoadAnimation(Dance)
			Track:Play()
		end
		local Shirt = Instance.new("Shirt", Character)
		Shirt.ShirtTemplate = "rbxassetid://"..shirtId
		Shirt.Name = "Shirt"
		local Pants = Instance.new("Pants", Character)
		Pants.PantsTemplate = "rbxassetid://"..pantsId
		Pants.Name = "Pants"
	end
end

local function lightUpBars()
	local barParts = Bars.Middle:GetChildren()
	for i = #barParts, 1, -1 do
		for _, Model in pairs(Bars:GetChildren()) do
			if (Model:IsA("Model")) then
				local Color = currentColors[Model.Name]
				for _, Part in pairs(Model:GetChildren()) do
					Part.Material = Enum.Material.SmoothPlastic
				end
				local Bar = Model:FindFirstChild("Bar"..i)
				if (Bar) then
					Bar.Material = Enum.Material.Neon
					Bar.Color = Color3.new(0,0,0):lerp(Colors[Color], 1 - i/#barParts)
					--[[
					if (Color == "Orange") then
						Bar.Color = Color3.new(0,0,0):lerp(Colors[Color], i)
					elseif (Color == "Black") then
						Bar.Color = Color3.new(0,0,0)
					elseif (Color == "Green") then
						Bar.Color = Color3.fromRGB(BarColors[i][2], BarColors[i][1], BarColors[i][2])
					elseif (Color == "Purple") then
						Bar.Color = Color3.fromRGB(BarColors[i][1], BarColors[i][2], BarColors[i][1])
					end]]
				end
			end
		end
		wait(0.58/#barParts)
	end
end

function Floor:init(Map)
	setVariables(Map)
	Elevator:hideWall("Right", true)
	Elevator:hideRailing("Right", true)
	Elevator:lightsOff()
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
	
	Connections[1] = Map.ElevatorTunnel.Shadows.Back.Touched:Connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) and (not Functions:GetObjectFromTable(waitingList, Character)) then
			table.insert(waitingList, #waitingList+1, Character)
			Character:SetPrimaryPartCFrame(Scene.SpawnPosition.CFrame)
			Character.HumanoidRootPart.Anchored = true
			Character.Humanoid.WalkSpeed = 0
		end
	end)
	
	Connections[2] = Map.Scene.ExitTunnel.Shadows.Back.Touched:Connect(function(Hit)
		local Character = Hit.Parent
		if (Functions:characterIsValid(Character)) then
			if (game.Players:GetPlayerFromCharacter(Character)) then
				Character:SetPrimaryPartCFrame(Elevator.Model.TeleportPart.CFrame)
				Character.Humanoid.WalkSpeed = 16
			else
				Character:Destroy()
			end
		elseif (Character) and (Character.Name == "Noob") then
			Character:Destroy()
		end
	end)
	
	wait(9) --here we go
	Sign.Gui.Label.Text = "Factory"
	Running = true
	for _, Dancer in pairs(Dancers:GetChildren()) do
		Dancer.Humanoid:LoadAnimation(Dance):Play()
	end
	spawn(function()
		while (Running) do
			lightUpBars()
			for _, Layer in pairs(Lights:GetChildren()) do
				for _, Part in pairs(Layer:GetChildren()) do
					Part.SpotLight.Color = Colors[currentColors[Part.Name]]
				end
			end
			if (lightIndex+1>#lightColorList) then
				lightIndex = 1
			else
				lightIndex=lightIndex+1
			end
			Elevator:changeLightProperties({Color = Colors[lightColorList[lightIndex]]},{Color = Colors[lightColorList[lightIndex]]})
		end
	end)
	spawn(function()
		while (Running) do
			if (#NPCs > 6) then
				NPCs[#NPCs]:Destroy()
			end
			if (playerIndex+1>#lightColorList) then
				playerIndex = 1
			else
				playerIndex=playerIndex+1
			end
			if (#waitingList>0) then
				local Character = Functions:characterIsValid(waitingList[1])
				if (Character) then
					waitingList[1].HumanoidRootPart.Anchored = false
					kawaiiCharacter(Character, lightColorList[playerIndex])
				end
				table.remove(waitingList, 1)
			else
				local Character = game.ServerStorage.NPCs.Noob:Clone()
				Character.Parent = Map
				Character:SetPrimaryPartCFrame(Scene.SpawnPosition.CFrame)
				--Functions:addWeight(Character, 5)
				table.insert(NPCs, 1, Character)
				kawaiiCharacter(Character, lightColorList[playerIndex])
			end
			Conveyer.Velocity = Conveyer.CFrame.rightVector * 16
			wait(0.58)
			Conveyer.Velocity = Vector3.new(0,0,0)
			wait(0.58)
		end
	end)
	wait(9.4)
	lightIndex = 1
	playerIndex = 1
	lightColorList = {"Purple", "Green"}
	currentColors["Middle"] = "Green"
	currentColors["Left"] = "Purple"
	currentColors["Right"] = "Purple"
	for _, Dancer in pairs(Dancers:GetChildren()) do
		kawaiiCharacter(Dancer, currentColors[Dancer.Name])
	end
end

function Floor.ending()
	Running = false
	Elevator:hideWall("Right", false)
	Elevator:hideRailing("Right", false)
	for _, Character in pairs(Kawaii) do
		if (Functions:characterIsValid(Character)) then
			Character.Humanoid.WalkSpeed = 16
			Character.HumanoidRootPart.Anchored = false
			if (Character:FindFirstChild("Honey Hair")) then
				--Character["Honey Hair"]:Destroy()
			end
			if (Storage[Character]) then
				if (Storage[Character].Shirt) and (Character:FindFirstChild("Shirt")) then
					Character.Shirt.ShirtTemplate = Storage[Character].Shirt
				end
				if (Storage[Character].Pants) and (Character:FindFirstChild("Pants")) then
					Character.Pants.PantsTemplate = Storage[Character].Pants
				end
				if (Storage[Character].Animation) then
					Storage[Character].Animation:Stop()
				end
			end
		end
		if (Character:FindFirstChild("Head")) and (Character.Head:FindFirstChild("hearts")) then
			--Character.Head.hearts:Destroy()
		end
	end
	Kawaii={}
	Storage={}
	waitingList={}
	NPCs = {}
	currentColors = {Left="Orange",Middle="Black",Right="Orange"}
	lightColorList = {"Orange", "Black"}
	lightIndex = 1
	playerIndex = 1
	Functions:disconnectTableEvents(Connections)
	Connections={}
end

return Floor