local ReplicatedStorage = game:GetService("ReplicatedStorage")

local random = Random.new()
local candyCollected = ReplicatedStorage.Halloween.CandyCollected
local halloweenData = ReplicatedStorage:WaitForChild("HalloweenData")
local candyColors = require(ReplicatedStorage.Halloween.HalloweenGlobals).candyColors

local pHoverImg = "rbxassetid://99386206077272"
local pDefImg = "rbxassetid://98941253790591"

local candyImgs = {
	candy="rbxassetid://86343935474416";
	candyCorn="rbxassetid://132604135806537";
	lollipop="rbxassetid://110083267306176";
	gummyBear="rbxassetid://86686643572830";
	chocolate="rbxassetid://131913285284275"
}

local zoomImgs = {
	In="rbxassetid://125503476098031";
	Out="rbxassetid://120463998735496"
}

local player = game:GetService("Players").LocalPlayer
local candyData = halloweenData:WaitForChild(player.Name)

local gui = script.Parent
local basket = gui:WaitForChild("Basket")
local pumpkin = gui:WaitForChild("Pumpkin")
local detailB = basket:WaitForChild("Detail")
local candyTemp = gui:WaitForChild("Candy")

local function updateCandyList()
	local listF = basket:WaitForChild("ListFrame")
	
	local function upd(candyListF)
		for _, candyF in (candyListF:GetChildren()) do
			local candyV = candyData:FindFirstChild(candyF.Name)
			local colorN = candyF.Name:gsub("%Candy", "")

			local color = if (candyListF.Name=="CandyFrame") then candyColors[colorN] else Color3.new(1,1,1)

			if (candyV)  then

				if (candyV.Value>0) then
					candyF.Label.Text = "x"..candyV.Value
					candyF.Label.TextColor3=Color3.new(1,1,1)
					candyF.Icon.ImageColor3=color
					candyF.Icon.ImageTransparency=0
				elseif (candyV.Value==0) then
					candyF.Icon.ImageColor3=color
					candyF.Icon.ImageTransparency=0
					candyF.Label.Text = "x0"
					candyF.Label.TextColor3=Color3.new(1,1,1)
				elseif (candyV.Value<0) then
					candyF.Icon.ImageColor3=Color3.new(0,0,0)
					candyF.Icon.ImageTransparency=0.5
					candyF.Label.Text = "???"
					candyF.Label.TextColor3=Color3.new(0,0,0)
				end

			end
		
		end
	end
	
	for _, candyListF in (listF:GetChildren()) do
		upd(candyListF)
	end
	
	basket.BasketFrame.Empty.Visible=#basket.BasketFrame:GetChildren()==1
end

local function candyRemoved(candyName)
	
end

candyCollected.OnClientEvent:Connect(function(model)
	
	local max=1000
	
	local newCandy = candyTemp:Clone()
	newCandy.Image=candyImgs[model.Name]
	newCandy.Name = model.Name
	newCandy.Position = UDim2.new()
	newCandy.Visible=true
	
	if (model.Name=="candy") then
		newCandy.ImageColor3 = model.PrimaryPart.Color
		newCandy.Size=UDim2.new(0.3,0,0.3,0)
	elseif (model.Name=="candyCorn") then
		newCandy.Size=UDim2.new(0.25,0,0.25,0)
	elseif (model.Name=="lollipop") then
		newCandy.Size=UDim2.new(0.35,0,0.35,0)
	elseif (model.Name=="gummyBear") then
		newCandy.Size=UDim2.new(0.275,0,0.275,0)
	end

	max-=(newCandy.Size.X.Scale*1000)
	local posX = random:NextInteger(1, max)
	local posY = random:NextInteger(1, max)
	newCandy.Position = UDim2.fromScale(posX/1000,posY/1000)
	newCandy.Rotation = random:NextInteger(0, 360)
	newCandy.Parent = basket.BasketFrame
	
	updateCandyList()
end)

pumpkin.MouseButton1Click:Connect(function()
	basket.ListFrame.Visible=false
	basket.BasketFrame.Visible=true
	basket.Visible=not basket.Visible
end)

pumpkin.MouseEnter:Connect(function()
	pumpkin.Image=pHoverImg
	pumpkin.Glow.Visible=true
end)

pumpkin.MouseLeave:Connect(function()
	pumpkin.Image=pDefImg
	pumpkin.Glow.Visible=false
end)

detailB.MouseButton1Down:Connect(function()
	updateCandyList()
	
	basket.ListFrame.Visible= not basket.ListFrame.Visible
	basket.BasketFrame.Visible= not basket.ListFrame.Visible
	
	detailB.Image=if (basket.ListFrame.Visible) then zoomImgs.Out else zoomImgs.In
end)

updateCandyList()