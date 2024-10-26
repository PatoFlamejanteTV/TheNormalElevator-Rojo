local ReplicatedStorage = game:GetService("ReplicatedStorage")

local random = Random.new()
local candyCollected = ReplicatedStorage.Halloween.CandyCollected
local halloweenData = ReplicatedStorage:WaitForChild("HalloweenData")
local candyColors = require(ReplicatedStorage.Halloween.HalloweenGlobals).candyColors

local pHoverImg = "rbxassetid://99386206077272"
local pDefImg = "rbxassetid://98941253790591"

local candyImgs = {
	Candy="rbxassetid://86343935474416";
	CandyCorn="rbxassetid://132604135806537";
	Lollipop="rbxassetid://110083267306176";
	GummyBear="rbxassetid://86686643572830";
	Chocolate="rbxassetid://131913285284275"
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

local function addCandy(candyName, candyAmount)
	
	
	
	local candyFolder = basket.BasketFrame:FindFirstChild(candyName)
	if (not candyFolder) and (candyAmount>0) then
		candyFolder = Instance.new("Folder")
		candyFolder.Name=candyName
		candyFolder.Parent = basket.BasketFrame
	elseif (candyFolder) and (candyAmount<=0) then
		candyFolder:Destroy()
	end
	
	if (not candyFolder) then return end
	
	local candyGC = candyFolder:GetChildren()
	local numCandies = #candyGC
	if (numCandies>candyAmount) then --we lost candies
		
		for i = 1, candyAmount do
			candyGC[#candyGC]:Destroy()
		end
	elseif (numCandies<candyAmount) then --we got candies
		local diff = candyAmount-numCandies
		local l = candyName:len()
		local c, e = candyName:sub(1, l-5), candyName:sub(l-4, l)
		
		for i = 1, diff do
			local max=1000

			local newCandy = candyTemp:Clone()
			newCandy.Name = candyName
			newCandy.Position = UDim2.new()
			newCandy.Visible=true

			if (e=="Candy") then
				newCandy.ImageColor3 = candyColors[c]
				newCandy.Size=UDim2.new(0.3,0,0.3,0)
				candyName=e
			elseif (candyName=="CandyCorn") then
				newCandy.Size=UDim2.new(0.25,0,0.25,0)
			elseif (candyName=="Lollipop") then
				newCandy.Size=UDim2.new(0.35,0,0.35,0)
			elseif (candyName=="GummyBear") then
				newCandy.Size=UDim2.new(0.275,0,0.275,0)
			end

			newCandy.Image=candyImgs[candyName]

			max-=(newCandy.Size.X.Scale*1000)
			local posX = random:NextInteger(1, max)
			local posY = random:NextInteger(1, max)
			newCandy.Position = UDim2.fromScale(posX/1000,posY/1000)
			newCandy.Rotation = random:NextInteger(0, 360)
			newCandy.Parent = candyFolder
		end
	end
	
	updateCandyList()
end

for _, candyV in (candyData:GetChildren()) do
	addCandy(candyV.Name, candyV.Value)
	candyV.Changed:Connect(function(a)
		addCandy(candyV.Name, a)
	end)
end

updateCandyList()