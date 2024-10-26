local RS = game:GetService("RunService")

local Client = _G.Local:Load("Client")

local Player = game.Players.LocalPlayer
local Gui = script.Parent
local Pumpkin = Gui:WaitForChild("Pumpkin")
local Count = Pumpkin:WaitForChild("Count")
local candyImg = Gui:WaitForChild("Candy")

local Data = game.ReplicatedStorage.PlayerData:WaitForChild(Player.Name)
local Candy = Data:WaitForChild("Candy")

local lastValue = Candy.Value
Count.Text = lastValue

local tweening = false
local candyToAdd = 0
local candiesRaining = {}

local CANDY_MAX = 50 --make sure to change if i do change the max

local toggleSpeed = 1
local toggleMaxCountTick = tick()
local showingMaxOrNumber = "number"

local function addCandies()
	while (candyToAdd > 0) do
		local candySize = 20 --pixel size
		local candyPic = candyImg:Clone()
		candyPic.Name = "FakeCandy"
		candyPic.Parent = Gui
		candyPic.Position = UDim2.new(1, math.random(Pumpkin.Position.X.Offset+20, Pumpkin.Position.X.Offset+Pumpkin.Size.X.Offset-20), 1, Pumpkin.Position.Y.Offset-80)
		candyPic.Rotation = math.random(-180, 180)
		candyPic.Visible = true
		candyPic:TweenPosition(UDim2.new(1,Pumpkin.Position.X.Offset+Pumpkin.Size.X.Offset/2,1,Pumpkin.Position.Y.Offset+Pumpkin.Size.Y.Offset/2), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 1, false)
		spawn(function()
			table.insert(candiesRaining, #candiesRaining+1, candyPic)
			local pos = #candiesRaining
			for i = 1, 10 do
				candyPic.ImageTransparency = 1 - i/10
				wait(0.05)
			end
			wait(0.6)
			table.remove(candiesRaining, pos)
			candyPic:Destroy()
		end)
		wait(0.4)
		if (tonumber(Count.Text)) then
			Count.Text = tonumber(Count.Text)+1
		end
		Count.Text = tonumber(Count.Text)+1
		candyToAdd = candyToAdd-1
	end
end

Candy.Changed:Connect(function()
	local valueDiff = Candy.Value - lastValue
	lastValue = Candy.Value
	if (valueDiff > 0) then
		Gui.Jingle:Play()
		candyToAdd = candyToAdd + valueDiff
		Pumpkin.Amount.Text = "+" .. valueDiff
		Pumpkin.Amount.Visible = true
		if (not tweening) then
			if (not Client.onMobile) then
				tweening = true
				Pumpkin:TweenSizeAndPosition(UDim2.new(0,150,0,150), UDim2.new(1,-155,1,-155), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.6, false)
				wait(1)
				addCandies()
				wait(1)
				Pumpkin:TweenSizeAndPosition(UDim2.new(0,80,0,80), UDim2.new(1,-85,1,-85), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.6, false)
				wait(0.4)
				tweening = false
			else
				addCandies()
			end
			wait(1)
			Pumpkin.Amount.Visible = false
			Count.Text = Candy.Value
		end
	end
end)


RS.RenderStepped:Connect(function()
	if (showingMaxOrNumber == "number") and (tonumber(Count.Text) >= CANDY_MAX) then
		if (tick() - toggleMaxCountTick >= toggleSpeed) then
			showingMaxOrNumber = "max"
			toggleMaxCountTick = tick()
			Count.Text = "MAX"
			Count.TextColor3 = Color3.new(1,0,0)
		end
	elseif (showingMaxOrNumber == "max") and (tick() - toggleMaxCountTick >= toggleSpeed) then
		showingMaxOrNumber = "number"
		toggleMaxCountTick = tick()
		Count.Text = Candy.Value
		Count.TextColor3 = Color3.new(1,1,1)
		
	end
	
	if (lastValue < CANDY_MAX) then
		Count.Text = Candy.Value
		showingMaxOrNumber = "number"
		Count.TextColor3 = Color3.new(1,1,1)
	end
	
	
	for _, candy in pairs(candiesRaining) do
		candy.Rotation = candy.Rotation + 0.25
	end
end)
