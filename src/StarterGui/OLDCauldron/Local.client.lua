local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Client = _G.Local:Load("Client")
local Network = _G.Local:Load("Network")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Gui = script.Parent
local Cauldron = Gui:WaitForChild("Cauldron")
local Pumpkin = Gui:WaitForChild("Pumpkin")
local FakeCauldron = Gui:WaitForChild("FakeCauldron")
local previewFrame = Cauldron:WaitForChild("PreviewFrame")
local fakePreviewFrame = FakeCauldron:WaitForChild("Preview")

local Tricks = game.ReplicatedStorage.Tricks


local TRICK_ENUMS = {
	Trick1 = "Suta Cookie",
	Trick2 = "Phantom Potion",
	Trick3 = "Haunt Box"
}

local selectedTrick

local function updatePumpkin()
	--Pumpkin.Amount.Visible = true
	Pumpkin.Count.Visible = true
	Pumpkin.Rotation = 0
	local PlayerData = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
	if (PlayerData) and (PlayerData:FindFirstChild("Candy")) then
		Pumpkin.Count.Text = PlayerData.Candy.Value
	end
end


local function loadPreviewFrame(trickName)
	previewFrame.Visible = true
	local trickTool = Tricks:FindFirstChild(trickName)
	previewFrame.Price.Text = trickTool.Cost.Value
	
	for _, trickButton in pairs(Cauldron:GetChildren()) do
		if (trickButton:IsA("ImageButton")) and (trickButton.Name:sub(1,5) == "Trick") then
			trickButton.Visible = false
		end
	end
end

local function loadTrickButtons()
	updatePumpkin()
	for _, trickButton in pairs(Cauldron:GetChildren()) do
		if (trickButton:IsA("ImageButton")) and (trickButton.Name:sub(1,5) == "Trick") then
			local trickTool = Tricks:FindFirstChild(TRICK_ENUMS[trickButton.Name])
			if (trickTool) then
				
				if (Client.unlockedTricks[trickButton.Name] == true) then --if the trick is already unlocked then 
					trickButton.Price.Visible = false
					trickButton.Lock.Visible = false
					trickButton.Image = trickTool.TextureId
					trickButton.ImageTransparency = 0
					
				end
				trickButton.Price.Text = trickTool.Cost.Value
			end
		end
	end
end

local function figureEight()
	local lock = FakeCauldron.Lock
	local rx, ry = lock.Position.X.Scale, lock.Position.Y.Scale
	local ang = tick() * 0.15
	local xo = math.cos(ang*math.pi*2)*0.02
	local yo = math.sin(4*ang*math.pi)*0.02
	local xx = UDim.new(rx+xo, lock.Position.X.Offset)
	local yy = UDim.new(ry+yo, lock.Position.Y.Offset)
	lock.Position = UDim2.new(xx,yy)
end

local function updatecircle()
	local lock = FakeCauldron.Lock
	FakeCauldron.Lock.Position = UDim2.new(0.5,0,0.5,0)
	local rx, ry = lock.Position.X.Scale, lock.Position.Y.Scale
	local ang = tick()*2
	local radius = 0.2
	local x, y = UDim.new(rx+math.cos(ang)*radius, lock.Position.X.Offset), UDim.new(ry+math.sin(ang)*radius,lock.Position.Y.Offset)
	lock.Position = UDim2.new(x, y)
	figureEight()
end


for _, trickButton in pairs(Cauldron:GetChildren()) do
	
	if (trickButton:IsA("ImageButton")) and (trickButton.Name:sub(1,5) == "Trick") then
		local trickTool = Tricks:FindFirstChild(TRICK_ENUMS[trickButton.Name])
		if (trickTool) then
			
			if (Client.unlockedTricks[trickButton.Name] == true) then --if the trick is already unlocked then 
				trickButton.Price.Visible = false
				trickButton.Lock.Visible = false
				trickButton.Image = trickTool.TextureId
				trickButton.ImageTransparency = 0
				
			end
			trickButton.Price.Text = trickTool.Cost.Value
			
			trickButton.MouseButton1Down:Connect(function()
				
				selectedTrick = trickButton.Name
				if (Client.unlockedTricks[trickButton.Name] == false) then
					loadPreviewFrame(TRICK_ENUMS[trickButton.Name])
				else
					if (not Character:FindFirstChild(TRICK_ENUMS[trickButton.Name])) and (not Player.Backpack:FindFirstChild(TRICK_ENUMS[trickButton.Name]))then
						Network:Send("EquipTrick", TRICK_ENUMS[trickButton.Name])
					end
				end
			end)
			
			trickButton.MouseEnter:Connect(function()
				trickButton.Circle.ImageColor3 = Color3.new(0.15,0.15,0.15)
			end)
			
			trickButton.MouseLeave:Connect(function()
				trickButton.Circle.ImageColor3 = Color3.new()
			end)
			
		end
		

	end
end

updatePumpkin()
local pumpkinFlip = TS:Create(Pumpkin, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180})

previewFrame:WaitForChild("Buy").MouseButton1Down:Connect(function()
	if (selectedTrick) then
		local Success = Network:Get(Player, "PurchaseTrick", TRICK_ENUMS[selectedTrick]) --1 is complete, 2 is not enough, 3 is already has (shouldnt be possible)
		if (Success == 1) then
			Client.unlockedTricks[selectedTrick] = true
			Cauldron.Visible = false
			previewFrame.Visible = false
			for _, trickButton in pairs(Cauldron:GetChildren()) do
				if (trickButton:IsA("ImageButton")) and (trickButton.Name:sub(1,5) == "Trick") then
					trickButton.Visible = true
				end
			end
			----hide the shop cauldron
			FakeCauldron.Lock.TextTransparency = 1
			FakeCauldron.Visible = true
			FakeCauldron.Close.Visible = false
			
			--drop candy in cauldron
			Pumpkin.Amount.Visible = false
			Pumpkin.Count.Visible = false
			local cost = Tricks:FindFirstChild(TRICK_ENUMS[selectedTrick]).Cost.Value
			pumpkinFlip:Play()
			wait(1)
			local candies = {}
			for i = 1, cost do
				local candy = Gui.Candy:Clone()
				candy.Name = "FakeCandy"
				candy.Parent = Gui
				--print(Pumpkin.Position.X.Scale-Pumpkin.Size.X.Scale/2, Pumpkin.Position.X.Scale+Pumpkin.Size.X.Scale/2)
				candy.Position = UDim2.new(Pumpkin.Position.X.Scale, math.random(-candy.Size.X.Offset, candy.Size.X.Offset), Pumpkin.Position.Y.Scale, math.random(-candy.Size.Y.Offset, candy.Size.Y.Offset))
				local cx = candy.Position.X
				--print(candy.Position)
				candy.Visible = true
				candy:TweenPosition(UDim2.new(cx.Scale, cx.Offset, FakeCauldron.Position.Y.Scale, FakeCauldron.Position.Y.Offset), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.8, false)
				candies[i] = candy
			end
			wait(1)
			for _, candy in pairs(candies) do
				candy:Destroy()
			end
			
			
			Pumpkin.Visible = false
			Gui.Boil:Play()
			RS:BindToRenderStep("LoadTrick", Enum.RenderPriority.Camera.Value-1, updatecircle)
			for i = 1, 10 do
				FakeCauldron.Lock.TextTransparency = 1- i/10
				FakeCauldron.Lock.TextStrokeTransparency = 1- i/10
				wait(0.05)
			end
			wait(1)
			FakeCauldron.Black.Visible = true
			for i = 1, 20 do
				FakeCauldron.Black.ImageTransparency = 1-i/20
				wait(0.035)
			end
			wait(3)
			for i = 1, 10 do
				FakeCauldron.Lock.TextTransparency = i/10
				FakeCauldron.Lock.TextStrokeTransparency = i/10
				wait(0.05)
			end
			Gui.Boil:Stop()
			RS:UnbindFromRenderStep("LoadTrick")
			----LOAD TOOL DATA
			fakePreviewFrame.Visible = true
			fakePreviewFrame.Title.TextTransparency = 1
			fakePreviewFrame.Title.Glow.Size = UDim2.new(0,0,0,0)
			local trickData = game.ReplicatedStorage.Tricks:FindFirstChild(TRICK_ENUMS[selectedTrick])
			if (trickData) then
				fakePreviewFrame.Title.Text = trickData.Name
				fakePreviewFrame.Trick.Image = trickData.TextureId
			end
			
			wait(1)
			Gui.Wind:Play()
			for i = 1, 20 do
				FakeCauldron.Black.ImageTransparency = i/20
				wait(0.035)
			end
			FakeCauldron.Black.Visible = false
			fakePreviewFrame.Title.Glow:TweenSize(UDim2.new(1.3,0,1.3,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 2)
			wait(1)
			for i = 1, 20 do
				FakeCauldron.Preview.Title.TextTransparency = 1 - i/20
				wait(0.05)
			end
			wait(1)
			fakePreviewFrame.Back.Visible = true
			fakePreviewFrame.Equip.Visible = true
			FakeCauldron.Close.Visible = true
		end
	end
end)

previewFrame:WaitForChild("Cancel").MouseButton1Down:Connect(function()
	previewFrame.Visible = false
	for _, trickButton in pairs(Cauldron:GetChildren()) do
		if (trickButton:IsA("ImageButton")) and (trickButton.Name:sub(1,5) == "Trick") then
			trickButton.Visible = true
		end
	end
end)


fakePreviewFrame:WaitForChild("Equip").MouseButton1Down:Connect(function()
	Network:Send("EquipTrick", TRICK_ENUMS[selectedTrick])
	Gui:Destroy()
end)

fakePreviewFrame:WaitForChild("Back").MouseButton1Down:Connect(function()
	FakeCauldron.Visible = false
	FakeCauldron.Close.Visible = false
	fakePreviewFrame.Back.Visible = false
	fakePreviewFrame.Equip.Visible = false
	fakePreviewFrame.Visible = false
	previewFrame.Visible = false
	Cauldron.Visible = true
	Pumpkin.Visible = true
	updatePumpkin()
	loadTrickButtons()
end)

Cauldron:WaitForChild("Close").MouseButton1Down:Connect(function()
	Gui:Destroy()
end)

FakeCauldron:WaitForChild("Close").MouseButton1Down:Connect(function()
	Gui:Destroy()
end)