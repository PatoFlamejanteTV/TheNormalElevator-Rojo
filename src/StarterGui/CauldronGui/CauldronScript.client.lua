local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Client = _G.Local:Load("Client")

local CollectionService = game:GetService("CollectionService")

local prompts = {}

for _, cauldron in (CollectionService:GetTagged("PromptCauldron")) do
	table.insert(prompts, cauldron.PromptPart.ProximityPrompt)
end

local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local gui = script.Parent

local menu = gui:WaitForChild("Menu")
local craftF = gui:WaitForChild("CraftFrame")

local halloweenData = ReplicatedStorage:WaitForChild("HalloweenData")
local candyData = halloweenData:WaitForChild(player.Name)
local globals = require(ReplicatedStorage.Halloween.HalloweenGlobals)

local requestCraft = ReplicatedStorage.Halloween.RequestCraft

local selectedItem
local selectedType
local selectedCauldron

local cSpeed=1

local function loadCraftMenu(itemName, itemType)
	--first the grid
	--we gotta put all the needed materials
	local materials = globals.crafting[itemType][itemName]
	
	local index=0
	for material, amount in (materials) do
		index+=1
		
		local l = material:len()
		local c, e = material:sub(1, l-5), material:sub(l-4, l)
		local matImage = if (e=="Candy") then globals.itemImages[e] else globals.itemImages[material]
		
		local frame = craftF.Grid["Frame"..index]
		frame.Item.Image = matImage
		frame.Amount.Text = math.max(0, candyData[material].Value).."/"..amount
		frame.Visible = true
		
		if (e=="Candy") then
			frame.Item.ImageColor3 = globals.candyColors[c]
		else
			frame.Item.ImageColor3=Color3.new(1,1,1)
		end
		
		if (candyData:FindFirstChild(material).Value>=amount) then
			frame.BackgroundColor3=Color3.fromRGB(29, 23, 33)
			frame.UIStroke.Color=Color3.fromRGB(29, 23, 33)
			frame.Amount.TextColor3=Color3.new(1,1,1)
		else
			frame.BackgroundColor3=Color3.fromRGB(86, 9, 10)
			frame.UIStroke.Color=Color3.fromRGB(86, 9, 10)
			frame.Amount.TextColor3=Color3.fromRGB(255, 0, 0)
		end
	end
	
	index+=1
	for i = index, 4 do
		craftF.Grid["Frame"..i].Visible=false
	end
	
	craftF.SelectedItem.Image=globals.itemImages[itemName]
	selectedItem=itemName
	selectedType=itemType
	
	--now we make the frames visible
	craftF.Visible=true
	menu.Visible=false
end

menu:WaitForChild("Exit").MouseButton1Click:Connect(function()
	gui.Enabled=false
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = player.Character.Humanoid
	--camera.CFrame = workspace.CauldronCam.CFrame
	camera.FieldOfView=70
	player.PlayerGui.CandyGui.Enabled=true
	player.PlayerGui.MusicGui.Enabled=true
	player.PlayerGui.Main.Enabled=true
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	
	for _, prompt in (prompts) do
		prompt.Enabled=true
	end
end)

for _, option in (menu.Options:GetChildren()) do
	if (option:IsA("Frame")) then
		for _, item in (option:GetChildren()) do
			if (item:IsA("ImageButton")) then
				item.MouseButton1Click:Connect(function()
					loadCraftMenu(item.Name, option.Name)
				end)
			end
		end
	end
end

craftF.Cancel.MouseButton1Down:Connect(function()
	craftF.Visible=false
	menu.Visible=true
end)



local rotTI = TweenInfo.new(0.37, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local shakeTI = TweenInfo.new(0.11, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true)
local camTI = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local itemTI = TweenInfo.new(0.95, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local fadeTI = TweenInfo.new(0.33, Enum.EasingStyle.Linear)




craftF.Craft.MouseButton1Click:Connect(function()
	local success = requestCraft:InvokeServer(selectedItem)
	
	if (success) then
		local materials = globals.crafting[selectedType][selectedItem]
		local basketPart = selectedCauldron.BasketPart
		local basketCF=basketPart.CFrame
		local basketGui = basketPart.Gui
		
		local rotTween = TweenService:Create(basketPart.Gui.Icon, rotTI, {Rotation=180})
		local shakeTween = TweenService:Create(basketPart, shakeTI, {CFrame=basketCF*CFrame.new(0,1.6,0)})
		local pFadeInTween = TweenService:Create(basketGui.Icon, fadeTI, {ImageTransparency=0})
		local pFadeOutTween = TweenService:Create(basketGui.Icon, fadeTI, {ImageTransparency=1})
		
		gui.Enabled=false
		local fov = selectedCauldron.CauldronCam:GetAttribute("FOV").Min
		local camTween = TweenService:Create(workspace.CurrentCamera, camTI, {FieldOfView=fov})
		
		camTween:Play()
		
		task.wait(0.375)
		
		basketGui.Icon.Rotation=0
		--basketGui.Icon.ImageTransparency=0
		basketGui.Enabled=true
		
		pFadeInTween:Play()
		
		rotTween:Play()
		rotTween.Completed:Wait()
		
		task.wait(0.15)
		
		local i=1
		
		
		
		for material, amount in (materials) do
			local frame = craftF.Grid["Frame"..i]
			local emitter = basketPart["Candy"..i]
			emitter.Texture=frame.Item.Image
			emitter.Color=ColorSequence.new(frame.Item.ImageColor3)
			task.spawn(function()
				for c = 1, amount do
					emitter:Emit(1)
					task.wait(0.05)
				end
			end)
			
			shakeTween:Play()
			shakeTween.Completed:Wait()
			i+=1
			
			if (i==2) then
				task.delay(0.12, function()
					selectedCauldron.Water.Bubbles.Enabled=true
					gui.Boil:Play()
					cSpeed=8
				end)
			end
		end
		
		pFadeOutTween:Play()
		task.wait(0.88)
		basketGui.Enabled=false
		gui.Boil:Stop()
		selectedCauldron.Water.Bubbles.Enabled=false
		task.wait(0.85)
		
		cSpeed=1
		
		local newItem = selectedCauldron.ItemPart:Clone()
		newItem.Gui.Icon.Image = craftF.SelectedItem.Image
		newItem.Gui.Icon.ImageColor3 = craftF.SelectedItem.ImageColor3
		newItem.Gui.Enabled=true
		newItem.CFrame = selectedCauldron.ItemPart.CFrame
		newItem.Parent = workspace
		
		local itemTween = TweenService:Create(newItem, itemTI, {CFrame=selectedCauldron.ItemPart.CFrame*CFrame.new(0,4.75,0)})
		itemTween:Play()
		
		task.wait(1.7)
		
		itemTween:Destroy()
		newItem:Destroy()
		
		loadCraftMenu(selectedItem, selectedType)
		gui.Enabled=true
		camera.FieldOfView=selectedCauldron.CauldronCam:GetAttribute("FOV").Max
	end
end)

for _, prompt in (prompts) do
	prompt.Triggered:Connect(function()
		selectedCauldron=prompt.Parent.Parent
		gui.Enabled=true
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = selectedCauldron.CauldronCam.CFrame
		
		--if (selectedCauldron.Parent.Name=="Elevator") then 55 else 45
		camera.FieldOfView=selectedCauldron.CauldronCam:GetAttribute("FOV").Max

		player.PlayerGui.CandyGui.Enabled=false
		player.PlayerGui.MusicGui.Enabled=false
		player.PlayerGui.Main.Enabled=false
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

		craftF.Visible=false
		menu.Visible=true
		
		for _, prompt in (prompts) do
			prompt.Enabled=false
		end
	end)
end


RunService.RenderStepped:Connect(function(dt)
	for _, cauldron in (CollectionService:GetTagged("Cauldron")) do
		cauldron.Water.CFrame*=CFrame.Angles(math.rad(90)*dt*cSpeed,0,0)
	end
end)