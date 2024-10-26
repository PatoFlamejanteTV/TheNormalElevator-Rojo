local Network = _G.Local:Load("Network")

local TS = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local Gui = script.Parent
local Frame = Gui:WaitForChild("Frame")
local Light = Gui:WaitForChild("Light")
local Artifacts = Frame:WaitForChild("Outline"):WaitForChild("Artifacts")
local Shadow = Frame:WaitForChild("Shadow")
local Preview = Frame:WaitForChild("Preview")

local selectedArtifact

local function getArtifactModel(modelName)
	local Model
	if (game.ReplicatedStorage.ArtifactModels:FindFirstChild(modelName)) then
		Model = game.ReplicatedStorage.ArtifactModels:FindFirstChild(modelName):Clone()
	end
	return Model
end

local function loadPreview(artifactName)
	Shadow.BackgroundTransparency = 1
	Artifacts.Visible = false
	Preview.Visible = true
	Frame.Sale.Visible = false
	for _, Item in pairs(Preview.Item.View:GetChildren()) do
		Item:Destroy()
	end
	local Model = getArtifactModel(artifactName)
	Model.Parent = Preview.Item.View
	selectedArtifact = artifactName
	if (not Preview.Item.View:FindFirstChild("Port")) then
		local Camera = Instance.new("Camera", Preview.Item.View)
		Camera.Name = "Port"
		local cameraPos = Model.PrimaryPart.CFrame * CFrame.new(2,1,0.5)
		Camera.CFrame = CFrame.new(cameraPos.Position, Model.PrimaryPart.Position)
		Preview.Item.View.CurrentCamera = Camera
	end
	Preview.Title.Text = artifactName
	Preview.Description.Text = Model.Description.Value
	Preview.Coin.Amount.Text = Model.Cost.Value
	
end

for _, Artifact in pairs(Artifacts:GetChildren()) do
	local Model = getArtifactModel(Artifact.Name)
	Model.Parent = Artifact.View
	if (not Artifact.View:FindFirstChild("Port")) then
		local Camera = Instance.new("Camera", Artifact.View)
		Camera.Name = "Port"
		local cameraPos = Model.PrimaryPart.CFrame * CFrame.new(2,1,0.5)
		Camera.CFrame = CFrame.new(cameraPos.Position, Model.PrimaryPart.Position)
		Artifact.View.CurrentCamera = Camera
	end
	
	Artifact.MouseButton1Down:Connect(function()
		loadPreview(Artifact.Name)
	end)
end

Frame.Sale.Text = (#game.ReplicatedStorage.Artifacts:GetChildren()==1 and "1 Artifact for Sale") or (#game.ReplicatedStorage.Artifacts:GetChildren()>1 and #game.ReplicatedStorage.Artifacts:GetChildren().." Artifacts for Sale")

Frame:WaitForChild("Close").MouseButton1Down:Connect(function()
	Gui:Destroy()
end)

Preview.Buy.MouseButton1Down:Connect(function()
	local Result = Network:Get(Player, "PurchaseArtifact", selectedArtifact)
	if (Result==1) then
		Preview.Buy.Label.Text = "BOUGHT"
	elseif (Result==2) then
		Preview.Buy.Label.Text = "CAN'T AFFORD"
	elseif (Result==3) then
		Preview.Buy.Label.Text = "ALREADY HAVE"
	end
	wait(1)
	Preview.Buy.Label.Text = "BUY"
end)

Preview.Cancel.MouseButton1Down:Connect(function()
	Preview.Visible = false
	Shadow.BackgroundTransparency = 0.15
	Frame.Sale.Visible = true
	Artifacts.Visible = true
end)

local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, -1, true)
local tween = TS:Create(Frame.Outline, tweenInfo, {ImageColor3=Color3.fromRGB(90, 55, 40)})
tween:Play()

game:GetService("RunService").RenderStepped:Connect(function()
	Light.Position = UDim2.new(0,Mouse.X-Light.Size.X.Offset/2, 0, Mouse.Y-Light.Size.Y.Offset/2)
end)