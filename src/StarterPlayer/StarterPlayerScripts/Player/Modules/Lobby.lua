local TS = game:GetService("TweenService")

local Player = game.Players.LocalPlayer

local Network = _G.Local:Load("Network")

local Lobby = {}

Lobby.Model = game.Workspace.Lobby
Lobby.Elevator = Lobby.Model.Elevator
--Lobby.SlideGame = Lobby.Model.SlideGame

Lobby.OldDoorOpen = false

local Leaderboard = Lobby.Model:WaitForChild("Leaderboard")

local ShopFrame = Lobby.Model:WaitForChild("ShopFrame")
local Frame = ShopFrame.Shop:WaitForChild("Frame")
local ShopBuy = Frame:WaitForChild("Buy")
local setSelection = 1
local selectedItem = nil

function Lobby:toggleFakeDoor(collide)
	Lobby.Elevator.FakeDoor.CanCollide = collide
end

local function previewItem(Item)
	local Preview = ShopFrame.Shop.Frame.Preview
	Preview.CoinPic.Amount.Text = Item.Cost.Value
	Preview.Item.Image = Item.TextureId
	Preview.Description.Text = Item.Description.Value
	Preview.Gear.Text = Item.Name:upper()
end

function Lobby:loadShop()
	local shopItems = game.ReplicatedStorage.Shop
	for _, Item in pairs(ShopFrame.Shop.Frame.Items:GetChildren()) do
		if (Item.Name ~= "Example") and (Item:IsA("ImageButton")) then
			Item:Destroy()
		end
	end
	selectedItem = nil
	Frame.Last.Visible = false
	Frame.Next.Visible = false
	Frame.Title.Text = "Gear Set " .. setSelection
	if (shopItems:FindFirstChild("Set"..setSelection-1)) then
		Frame.Last.Visible = true
	end
	if (shopItems:FindFirstChild("Set"..setSelection+1)) then
		Frame.Next.Visible = true
	end
	local setFolder = shopItems:FindFirstChild("Set"..setSelection)
	for _, Item in pairs(setFolder:GetChildren()) do
		if (not selectedItem) then
			selectedItem = Item
			previewItem(selectedItem)
		end
		local Button = ShopFrame.Shop.Frame.Items.Example:Clone()
		Button.Parent = ShopFrame.Shop.Frame.Items
		Button.Name = Item.Name
		Button.Item.Image = Item.TextureId
		Button.Amount.Text = Item.Cost.Value
		Button.Visible = true
		
		Button.MouseButton1Down:Connect(function()
			selectedItem = Item
			previewItem(Item)
			Button.Item.ImageColor3 = Color3.new(2/3,2/3,2/3)
		end)
		
		Button.MouseButton1Up:Connect(function()
			Button.Item.ImageColor3 = Color3.new(1,1,1)
		end)
		
		Button.MouseEnter:Connect(function()
			previewItem(Item)
		end)
		
		Button.MouseLeave:Connect(function()
			previewItem(selectedItem)
		end)
	end
end

function Lobby:updateStats()
	local PlayerFrame = Leaderboard.Board.Frame.Player
	PlayerFrame.Portrait.Clip.Person.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&username="..Player.Name
	local PlayerFolder = game.ReplicatedStorage.PlayerData:FindFirstChild(Player.Name)
	if (PlayerFolder) then
		PlayerFrame.Floors.Text = PlayerFolder.Stats.Floors.Value .. " floors"
		PlayerFrame.Visits.Text = PlayerFolder.Stats.Visits.Value .. " visits"
	end
end

function Lobby:init()
	Lobby:loadShop()
	Lobby:updateStats()
end

----------HALLOWEEENNNN


Frame:WaitForChild("Last").MouseButton1Down:Connect(function()
	setSelection = setSelection-1
	Lobby:loadShop()
end)

Frame:WaitForChild("Next").MouseButton1Down:Connect(function()
	setSelection = setSelection+1
	Lobby:loadShop()
end)

ShopBuy.MouseButton1Down:Connect(function()
	ShopFrame.Shop.Frame.Buy.Label.Text = ". . ."
	local Result = Network:Get(Player, "PurchaseItem", setSelection, selectedItem)
	if (Result) then
		ShopFrame.Shop.Frame.Buy.Label.Text = "Purchased " .. selectedItem.Name .. "!"
		wait(1.5)
		ShopFrame.Shop.Frame.Buy.Label.Text = "BUY"
	else
		ShopFrame.Shop.Frame.Buy.Label.Text = "Failed to purchase!"
		wait(1.5)
		ShopFrame.Shop.Frame.Buy.Label.Text = "BUY"
	end
end)

ShopBuy.MouseEnter:Connect(function()
	ShopBuy.ImageColor3 = Color3.new(0,2/3,0)
end)

ShopBuy.MouseLeave:Connect(function()
	ShopBuy.ImageColor3 = Color3.new(0,1,0)
end)

--[[

Lobby.Model.Shop.ShopTrigger.Touched:Connect(function(Hit)
	if (Hit.Name == "HumanoidRootPart") and (Hit.Parent == Player.Character) and (Player.Character.Humanoid.Health > 0) then
		if (Player.PlayerGui:FindFirstChild("ArtifactsGui")==nil) then
			local Gui = game.ReplicatedStorage.ArtifactsGui:Clone()
			Gui.Parent = Player.PlayerGui
		end
	end
end)

Lobby.Model.Shop.ShopTrigger.TouchEnded:Connect(function(Hit)
	if (Hit.Parent == Player.Character) and (Player.Character.Humanoid.Health > 0) then
		if (Player.PlayerGui:FindFirstChild("ArtifactsGui")) then
			Player.PlayerGui.ArtifactsGui:Destroy()
		end
	end
end)


Lobby.Model.OldElevatorDoor.Door.Base.Touched:Connect(function(Hit)
	if (Hit.Parent == Player.Character) and (Player.Character.Humanoid.Health > 0) then
		if (Player.PlayerGui:FindFirstChild("OldElevatorGui")==nil) and (Lobby.OldDoorOpen==false) then
			local Gui = game.ReplicatedStorage.OldElevatorGui:Clone()
			Gui.Parent = Player.PlayerGui
		end
	end
end)
]]
--[[spawn(function()
	local gameStarted = false
	local clickDB = false
	while true do
		gameStarted = #Lobby.SlideGame.SlideGame.Frame:GetChildren() > 0
		if (gameStarted) and (not clickDB) then
			clickDB = true
			--print"oof"
			for _, Cell in pairs(Lobby.SlideGame.SlideGame.Frame:GetChildren()) do
				Cell.MouseButton1Down:connect(function()
					--print"aaa"
				end)
			end
		elseif (not gameStarted) then
			clickDB = false
			--print(gameStarted)
		end
		wait()
	end
end)]]

--[[
	HALLOWEEN FUNCTIONS
--]]

--[[

local Decorations = Lobby.Model.Decorations
local Lights = Decorations.Lights
local LGC = Lights:GetChildren()

local Colors = {
	{170, 0, 170},
	{0,0,0},
	{226, 155, 64}
}

function Lobby:updateLights()
	if (Lobby.Model.Parent == game.Workspace) then
		
		local first = Colors[1]
		for i = 1, #Colors do
			if (i == #Colors) then
				Colors[i] = first
			else
				Colors[i] = Colors[i+1]
			end	
		end
		local Info = TweenInfo.new(0.5)
		for index = 1, #LGC do
			local stack = 0
			local M = index%#Colors
			if (M == 0) then
				stack = 3
			end
			local Light = Lights:FindFirstChild("Light"..index)
			local Bulb = Light.Light
			local colorGoal = {}
			colorGoal.Color = Color3.new(Colors[index%#Colors+stack][1]/255, Colors[index%#Colors+stack][2]/255, Colors[index%#Colors+stack][3]/255)
			local Tween = TS:Create(Bulb, Info, colorGoal)
			Tween:Play()
			Bulb.PointLight.Color = Color3.new(Colors[index%#Colors+stack][1]/255, Colors[index%#Colors+stack][2]/255, Colors[index%#Colors+stack][3]/255)
		end
	end
end

	HOLIDAY FUNCTIONS

local ChristmasLights = Lobby.Model.ChristmasLights
local CLG = ChristmasLights:GetChildren()
local colors = {
	{248, 217, 109},
	{255, 0, 0},
	{180, 128, 255},
	{0, 143, 156}
}]]
--[[Lobby.Model.Whispers.Sound:Play()
local NumPad = Lobby.Model.NumPad
local Last4 = "0000"

for _, Pad in pairs(NumPad:GetChildren()) do
	Pad.Gui.Button.MouseButton1Down:Connect(function()
		Last4 = Last4:sub(2, 4)..Pad.Gui.Button.Text
		if (Last4 == "3792") then
			Lobby.Model.Whispers.Sound.Volume = 0.1
		else
			Lobby.Model.Whispers.Sound.Volume = 0
		end
	end)
end]]

return Lobby

