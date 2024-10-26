local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local MPS = game:GetService("MarketplaceService")

local Network = _G.Local:Load("Network")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local Menu = Main:WaitForChild("Menu")

local PlayerData = game.ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(Player.Name)
local Coins = PlayerData:WaitForChild("Stats"):WaitForChild("Coins")
local CoinsValue = Coins.Value

local menuOpen = true
local shopLoaded = false
local animsLoaded = false
local costumesLoaded = false
local settingsLoaded = false

local UI = {}

local Anims = {
	Basic = {
		Pack = 1,
		[1] = {Name="Sit",Id=2871896480},
		[2] = {Name="Flex",Id=2872513421},
		[3] = {Name="Think",Id=2883660341},
		[4] = {Name="Fall",Id=2883696456},
		[5] = {Name="High Five",Id=2883587127}
	},
	Silly = {
		Pack = 2,
		[1] = {Name="Backflip",Id=566738258},
		[2] = {Name="Frontflip",Id=566737340},
		[3] = {Name="Freeze Frame",Id=566736394},
		[4] = {Name="Tip Head",Id=566735642},
		[5] = {Name="Snow Angel",Id=566735109}
	},
	Dance = {
		Pack = 3,
		[1] = {Name="Russian Dance",Id=566732796},
		[2] = {Name="MJ Spin", Id=566734179},
		[3] = {Name="Sidewalk Dance",Id=566732116},
		[4] = {Name="Worm Dance",Id=566731378},
		[5] = {Name="Hip Twister",Id=566730550}
	},
	Spicy = {
		Pack = 4,
		[1] = {Name = "E Girl", Id=2807155067},
		[2] = {Name = "Salsa", Id=751730382},
		[3] = {Name = "Helicopter", Id=2987647367},
		[4] = {Name = "Superman", Id=2987698769},
		[5] = {Name = "Pendulum", Id=3013570122}
	},
	Haunted = {
		Pack = 5,
		[1] = {Name = "Spider", Id=5765303449},
		[2] = {Name = "Spook", Id=5765475299},
		[3] = {Name = "Possessed", Id=5766072914},
		[4] = {Name = "Death", Id=5766205345},
		[5] = {Name = "Boogie", Id=5766217713}
	}
}

local Gamepasses = {
	["The Chosen One"] = 452845,
	["Animation Pack - Silly"] = 763806,
	["Animation Pack - Dance"] = 774123,
	["Animation Pack - Spicy"] = 6130139,
	["Animation Pack - Haunted"] = 12026246,
	["Gear Set 1 - Permanent"] = 1248198,
	["Gear Set 2 - Permanent"] = 6129872,
	["Costumes"] = 1048898
}

local Products = {
	["25 Coins"] = 39160805,
	["50 Coins"] = 24325647,
	["100 Coins"] = 24325656,
	["250 Coins"] = 39160866
}

local addSongId = 32478838

UI.SETTINGS = {
	HIDE_PLAYERS = false,
	HIDE_NAMETAGS = false,
	MUTE_MUSIC = false,
	MUTE_ELEVATOR = false,
	CHANCE = false
}

local animPassIds = {Silly=763806,Dance=774123,Spicy=6130139,Haunted=12026246}
local costumePassId = 1048898
local costumeSelection = "None"
local packSelection = "None"
local lastAnim = "None"
local animSelection = 0
local animTrack = nil

local characterParts={}
local characterClothes={}
local characterBodyColors={}

local function closeBlockingFrames(buttonName)
	if (buttonName == "Shop") then
		Main.Costumes.Visible = false
		Menu.Costumes.BackgroundTransparency = 1
		Main.Settings.Visible = false
		Menu.Settings.BackgroundTransparency = 1
	elseif (buttonName == "Settings") then
		Main.Animations.Visible = false
		Menu.Animations.BackgroundTransparency = 1
		Main.Shop.Visible = false
		Menu.Shop.BackgroundTransparency = 1
	elseif (buttonName == "Animations") then
		Main.Costumes.Visible = false
		Menu.Costumes.BackgroundTransparency = 1
		Main.Settings.Visible = false
		Menu.Settings.BackgroundTransparency = 1
	elseif (buttonName == "Costumes") then
		Main.Animations.Visible = false
		Menu.Animations.BackgroundTransparency = 1
		Main.Shop.Visible = false
		Menu.Shop.BackgroundTransparency = 1
		Main.Settings.Visible = false
		Menu.Settings.BackgroundTransparency = 1
	end
end

local function menuButtonClicked(buttonName)
	local Button = Menu:FindFirstChild(buttonName)
	Button.BackgroundTransparency = Main:FindFirstChild(buttonName).Visible == true and 1 or 0
	if (Main:FindFirstChild(buttonName).Visible == false) then
		closeBlockingFrames(buttonName)
	end
	if (buttonName == "Shop") then
		Main.Shop.Visible = not Main.Shop.Visible
		if (Main.Shop.Visible) then
			if (Main.Shop.Items.Visible==true) then
				UI:loadShop()
			end
		end
	elseif (buttonName == "Settings") then
		Main.Settings.Visible = not Main.Settings.Visible
		UI:loadSettings()
	elseif (buttonName == "Animations") then
		Main.Animations.Visible = not Main.Animations.Visible
		UI:loadAnimations()
	elseif (buttonName == "Costumes") then
		if (MPS:UserOwnsGamePassAsync(Player.UserId, 1048898)) then
			Main.Costumes.Visible = not Main.Costumes.Visible
			UI:loadCostumes()
		else
			Button.BackgroundTransparency = 1
			UI:previewShopSelection("Passes", "Costumes")
		end
	end
end

local function menuButtonEnter(buttonName)
	if (Main:FindFirstChild(buttonName)) then
		Menu.Desc.Text = buttonName
	end
	Menu.Desc.Visible = true
end

local function loadPack(packName)
	local Frame = Main:FindFirstChild("Animations")
	local Index = Frame.Top:FindFirstChild(packName)
	local lastPass = Frame.Top:FindFirstChild(packSelection)
	packSelection = packName
	if (lastPass==nil) or (lastPass~=nil and lastPass.Name ~= packSelection) then
		if (lastPass) then
			lastPass.BackgroundColor3 = Color3.new(0,1,0)
		end
		Index.BackgroundColor3 = Color3.new(1,1,1)
		Frame.Selection.Text = packName .. " Pack"
		for i = 1, 5 do
			local Button = Frame:FindFirstChild("Anim"..i)
			if (Anims[packName][i]) then
				Button.Visible = true
				Button.Label.Text = Anims[packName][i].Name
				Button.ImageColor3 = Color3.new(1,1,1)
			else
				Button.Visible = false
			end
		end
	end
end

local function getPackName(Number)
	local returnName
	for packName, packData in pairs(Anims) do
		if (packData.Pack==Number) then
			returnName = packName
		end
	end
	return returnName
end


function UI:init()
	Menu.Count.Amount.Text = PlayerData.Stats.Coins.Value
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	Main.Enabled = true
end

function UI:toggleSongName(sound, soundName)
	local function updateMusicDetails(musicStatus, Music)
		if (musicStatus == "Playing") then
			Song.Status.Text = "Now Playing:"
			Song.Status.TextColor3 = Color3.fromRGB(85, 255, 119)
			if (Client.InElevator==true) then
				Menu:TweenPosition(UDim2.new(), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
			end
		elseif (musicStatus == "Stopped") then
			Song.Status.Text = "Last Played:"
			Song.Status.TextColor3 = Color3.new(1,1,1)
			Menu:TweenPosition(UDim2.new(0,0,0,-Holder.Size.Y.Offset), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
		end

		local songName = Music:GetAttribute("SongName")

		if (not songName) then
			local soundId = Music.SoundId:gsub("rbxassetid://","") --just need the id numbers
			songName = MarketplaceService:GetProductInfo(tonumber(soundId), Enum.InfoType.Asset).Name
		end
		Song.SongName.Text = songName
	end
end

function UI:loadAnimations()
	local Frame = Main:FindFirstChild("Animations")
	if (not animsLoaded) then
		animsLoaded = true
		--first, load passes
		for _, Pass in pairs(Frame.Top:GetChildren()) do
			if (Pass:IsA("TextButton")) then
				if (animPassIds[Pass.Name]) and ((MPS:UserOwnsGamePassAsync(Player.UserId, animPassIds[Pass.Name])) or Network:Get(Player, "IsYoutuber")) then
					Pass.BackgroundColor3 = Color3.new(0,1,0)
					Pass.Text = Anims[Pass.Name].Pack
					Pass.Lock.Visible = false
				end
				Pass.MouseButton1Down:Connect(function()
					if (animPassIds[Pass.Name]) then
						if (MPS:UserOwnsGamePassAsync(Player.UserId, animPassIds[Pass.Name])) or (Network:Get(Player, "IsYoutuber")) then
							loadPack(Pass.Name)
						else
							UI:previewShopSelection("Passes", "Animation Pack - "..Pass.Name)
							
						end
					else
						loadPack(Pass.Name)
					end
				end)
			end
		end
		--load anim buttons
		for i = 1, 5 do
			local Button = Frame:FindFirstChild("Anim"..i)
			Button.MouseButton1Down:Connect(function()
				if (Player.Character) and (Player.Character:FindFirstChild("Humanoid")) and (Player.Character.Humanoid.Health > 0) then
					if (Frame:FindFirstChild("Anim"..animSelection)) then
						Frame:FindFirstChild("Anim"..animSelection).ImageColor3 = Color3.new(1,1,1)
					end
					if (animSelection == i) and (animTrack) and (lastAnim==Anims[packSelection][i].Name)then
						if (animTrack.Looped) then
							animSelection = 0
							animTrack:Stop()
							animTrack:Destroy()
						else
							animTrack:Play()
						end
						
					elseif (animSelection~=i) or (lastAnim~=Anims[packSelection][i].Name) then
						animSelection = i
						if (Player.Character:FindFirstChild("PackAnimation")) then
							Player.Character.PackAnimation:Destroy()
						end
						local newAnimation = Instance.new("Animation", Player.Character)
						newAnimation.Name = "PackAnimation"
						newAnimation.AnimationId = "rbxassetid://"..Anims[packSelection][i].Id
						if (animTrack) then animTrack:Stop() animTrack:Destroy() end
						animTrack = Player.Character.Humanoid:LoadAnimation(newAnimation)
						animTrack:Play()
						lastAnim = Anims[packSelection][i].Name
						if (animTrack) and (animTrack.Looped) then
							Button.ImageColor3 = Color3.fromRGB(255, 249, 75)
						end
					end
					
				end
				
			end)
		end
		loadPack("Basic")
	end
end

function UI:loadCostumes()
	local Frame = Main:FindFirstChild("Costumes")
	if (not costumesLoaded) then
		costumesLoaded = true
		
		local Character = Player.Character or Player.CharacterAdded:Wait()
		for _, Part in pairs(Character:GetChildren()) do
			if (Part:IsA("BasePart")) then
				characterParts[Part.Name] = {Size = Part.Size, Transparency = Part.Transparency}
			end
			if (Part:IsA("BodyColors")) then
				characterBodyColors = {HeadColor3=Part.HeadColor3, LeftArmColor3=Part.LeftArmColor3, LeftLegColor3=Part.LeftLegColor3, RightArmColor3=Part.RightArmColor3, RightLegColor3=Part.RightLegColor3, TorsoColor3=Part.TorsoColor3}
			end
			if (Part:IsA("Shirt")) then
				characterClothes.Shirt = Part.ShirtTemplate
			end
			if (Part:IsA("Pants")) then
				characterClothes.Pants = Part.PantsTemplate
			end
		end
		
		Frame.Reset.MouseButton1Down:Connect(function()
			if (costumeSelection~="None") then
				local Success = Network:Get(Player, "UnloadCostume", characterParts, characterBodyColors, characterClothes)
				if (Success) then
					costumeSelection = "None"
					Frame.Reset.Visible = false
					for _, Button in pairs(Frame.Panel.Shade:GetChildren()) do
						if (Button:IsA("ImageButton")) and (Button.Visible) then
							Button.ImageColor3 = Color3.new(0,0,0)
						end
					end
				end
			end
		end)
		
		for i, Costume in pairs(game.ReplicatedStorage.Costumes:GetChildren()) do
			if (Costume:IsA("Folder")) then
				local Button = Frame.Panel.Shade.Example:Clone()
				Button.Parent = Frame.Panel.Shade
				Button.Name = Costume.Name
				Button.Label.Text = Costume.Name
				Button.Visible = true
				Button.LayoutOrder = i
				Button.MouseButton1Down:Connect(function()
					if (MPS:UserOwnsGamePassAsync(Player.UserId, costumePassId)) then
						local Success = Network:Get(Player, "LoadCostume", Costume)
						if (Success) then
							Frame.Reset.Visible = true
							costumeSelection = Costume.Name
							Button.ImageColor3 = Color3.new(1/2,1/2,1/2)
						end
					end
				end)
				Button.MouseEnter:Connect(function()
					Button.ImageColor3 = Color3.new(1/2,1/2,1/2)
					if (Costume:FindFirstChild("Display")) then
						Frame.Display.Image = Costume.Display.Value
					end
				end)
				Button.MouseLeave:Connect(function()
					if (costumeSelection~=Button.Name) then
						Button.ImageColor3 = Color3.new(0,0,0)
					end
					if (costumeSelection~="None") then
						local Costume = game.ReplicatedStorage.Costumes:FindFirstChild(costumeSelection)
						if (Costume) and (Costume:FindFirstChild("Display")) then
							Frame.Display.Image = Costume.Display.Value
						end
					elseif (costumeSelection=="None") then
						Frame.Display.Image = ""
					end
				end)
			end
		end
	end
end

local shopSelection = "Gears"
local itemSelection = ""
local setSelection = 1

local validSongPurchase = false
UI.addSongId = 0

local function checkSongDetails()
	local shopFrame = Main:FindFirstChild("Shop")
	local Details = shopFrame.Song.Details
	if (MPS:GetProductInfo(tonumber(Details.Frame.ID.Text)).AssetTypeId==3) then
		local dataSound = Instance.new("Sound", Player)
		dataSound.SoundId = "rbxassetid://"..Details.Frame.ID.Text
		wait(0.8)
		if (dataSound.TimeLength >= 25) then
			validSongPurchase = true
			UI.addSongId = tonumber(Details.Frame.ID.Text)
			Details.Song.Text = MPS:GetProductInfo(tonumber(Details.Frame.ID.Text), Enum.InfoType.Asset).Name
			Details.Song.TextColor3 = Color3.new(1,1,1/2)
		else
			validSongPurchase = false
			UI.addSongId = 0
			Details.Song.Text = "ERROR: Song needs to be longer than 25 seconds"
			Details.Song.TextColor3 = Color3.new(1,0,0)
		end
	else
		validSongPurchase = false
		UI.addSongId = 0
		Details.Song.Text = "ERROR: Not a song ID"
		Details.Song.TextColor3 = Color3.new(1,0,0)
	end
end

function UI:refreshSongSelection(songData)
	local shopFrame = Main:FindFirstChild("Shop")
	local List = shopFrame.Song.Waiting.List
	for _, Frame in pairs(List:GetChildren()) do
		if (Frame.Name~="Example") and (Frame:IsA("Frame")) then
			Frame:Destroy()
		end
	end
	for num, Data in pairs(songData) do
		local Frame = List.Example:Clone()
		Frame.Parent = List
		Frame.Name = "Song"..num
		Frame.Number.Text = "#"..num
		Frame.Song.Text = Data.Title
		if (Data.User ~= Player) then
			Frame.Song.TextColor3 = Color3.new(1,1,1)
			Frame.Song.Font = Enum.Font.SourceSansItalic
		end
		Frame.Visible = true
	end
end

function UI:previewSongSelection()
	local shopFrame = Main:FindFirstChild("Shop")
	shopFrame.Preview.Visible = false
	shopFrame.Items.Visible = false
	local songFrame = shopFrame:FindFirstChild("Song")
	local Details = songFrame.Details
	songFrame.Visible = true
	shopFrame.Wood.Title.Text = "Add Song"
	local productInfo = MPS:GetProductInfo(addSongId, Enum.InfoType.Product)
	Details.Buy.Label.Text = "ADD SONG (R$"..productInfo.PriceInRobux..")"
	UI:refreshSongSelection(Network:Get(Player, "GetUserSongList"))
end

function UI:previewShopSelection(Category, Item)
	if (shopLoaded==false) then
		UI:loadShop()
	end
	shopSelection = Category
	itemSelection = Item
	closeBlockingFrames("Shop")
	local shopFrame = Main:FindFirstChild("Shop")
	local Preview = shopFrame:FindFirstChild("Preview")
	shopFrame.Visible = true
	shopFrame.Items.Visible = false
	shopFrame.Song.Visible = false
	Preview.Visible = true
	if (Category == "Passes") then
		local passId = Gamepasses[Item]
		if (passId) then
			local passInfo = MPS:GetProductInfo(passId, Enum.InfoType.GamePass)
			if (passInfo) then
				Preview.Item.Gear.Image = "rbxassetid://" .. passInfo.IconImageAssetId
				Preview.Item.Cost.Text = "R$"..passInfo.PriceInRobux
				Preview.Item.Cost.TextColor3 = Color3.new(0,1,0)
				Preview.Item.Title.Text = Item
				Preview.Description.Text = passInfo.Description
			end
		end
	elseif (Category == "Gears") then
		Preview.Item.Gear.Image = Item.TextureId
		Preview.Item.Cost.Text = Item.Cost.Value
		Preview.Item.Cost.TextColor3 = Color3.new(1,1,0)
		Preview.Item.Title.Text = Item.Name
		Preview.Description.Text = Item.Description.Value
	elseif (Category == "Coins") then
		local productId = Products[Item]
		if (productId) then
			local pInfo = MPS:GetProductInfo(productId, Enum.InfoType.Product)
			if (pInfo) then
				Preview.Item.Title.Text = Item
				Preview.Item.Gear.Image = "rbxassetid://" .. pInfo.IconImageAssetId
				Preview.Item.Cost.Text = "R$"..pInfo.PriceInRobux
				Preview.Item.Cost.TextColor3 = Color3.new(0,1,0)
				Preview.Description.Text = pInfo.Description
			end
		end
	end
end

function UI:loadShopCategory()
	local shopFrame = Main:FindFirstChild("Shop")
	local shopItems = game.ReplicatedStorage.Shop
	local Preview = shopFrame:FindFirstChild("Preview")
	shopFrame.Visible = true
	shopFrame.Items.Visible = true
	shopFrame.Song.Visible = false
	Preview.Visible = false
	for _, Item in pairs(shopFrame.Items:GetChildren()) do
		if (Item.Name ~= "Example") and (Item:IsA("ImageButton")) then
			Item:Destroy()
		end
	end
	shopFrame.Wood.Title.Text = shopSelection
	if (shopSelection == "Gears") then
		shopFrame.Wood.Title.Text = "Gear Set " .. setSelection
	end
	local Name
	local Image
	local Text
	local TextColor
	local function createItemButton(Item)
		local Button = shopFrame.Items.Example:Clone()
		Button.Parent = shopFrame.Items
		Button.Name = Name
		Button.Item.Image = Image
		Button.Title.Text = Name
		Button.Amount.Text = Text
		Button.Amount.TextColor3 = TextColor
		Button.Visible = true
		
		Button.MouseButton1Down:Connect(function()
			UI:previewShopSelection(shopSelection, Item)
		end)
		
		Button.MouseEnter:Connect(function()
			Button.Item.ImageColor3 = Color3.fromRGB(255, 224, 151)
		end)
		
		Button.MouseLeave:Connect(function()
			Button.Item.ImageColor3 = Color3.new(1,1,1)
		end)
		
		return Button
	end
	shopFrame.Wood.Title.Next.Visible = false
	shopFrame.Wood.Title.Last.Visible = false
	if (shopSelection == "Gears") then
		if (shopItems:FindFirstChild("Set"..setSelection-1)) then
			shopFrame.Wood.Title.Last.Visible = true
		end
		if (shopItems:FindFirstChild("Set"..setSelection+1)) then
			shopFrame.Wood.Title.Next.Visible = true
		end
		
		local SetFolder = shopItems:FindFirstChild("Set"..setSelection)
		for _, Item in pairs(SetFolder:GetChildren()) do
			--print("loaD", Item.Name)
			Name = Item.Name
			Image = Item.TextureId
			Text = Item.Cost.Value
			TextColor = Color3.new(1,1,0)
			createItemButton(Item)
		end
	elseif (shopSelection == "Passes") then
		for passName, passId in pairs(Gamepasses) do
			Name = passName
			TextColor = Color3.new(0,1,0)
			local passInfo = MPS:GetProductInfo(passId, Enum.InfoType.GamePass)
			Image = "rbxassetid://" .. passInfo.IconImageAssetId
			if (passInfo) and (not MPS:UserOwnsGamePassAsync(Player.UserId, passId)) then
				Text = "R$"..passInfo.PriceInRobux
			elseif (passInfo) and (MPS:UserOwnsGamePassAsync(Player.UserId, passId)) then
				Text = "OWNED"
			else
				Text = "R$?"
			end
			createItemButton(passName)
		end
	elseif (shopSelection == "Coins") then
		for productName, productId in pairs(Products) do
			Name = productName
			TextColor = Color3.new(0,1,0)
			local productInfo = MPS:GetProductInfo(productId, Enum.InfoType.Product)
			if (productInfo) then
				Image = "rbxassetid://" .. productInfo.IconImageAssetId
				Text = "R$"..productInfo.PriceInRobux
			end
			createItemButton(productName)
		end
	end
end

function UI:loadShop()
	if (not shopLoaded) then
		shopLoaded = true
		local shopFrame = Main.Shop
		local brickFrame = shopFrame.Brick
		UI:loadShopCategory()
		
		brickFrame.Passes.MouseButton1Down:Connect(function()
			if (shopSelection ~= "Passes") then
				shopSelection = "Passes"
				UI:loadShopCategory()
			end
		end)
		brickFrame.Gears.MouseButton1Down:Connect(function()
			if (shopSelection ~= "Gears") then
				shopSelection = "Gears"
				UI:loadShopCategory()
			end
		end)
		brickFrame.Coins.MouseButton1Down:Connect(function()
			if (shopSelection ~= "Coins") then
				shopSelection = "Coins"
				UI:loadShopCategory()
			end
		end)
		brickFrame.Song.MouseButton1Down:Connect(function()
			shopSelection = ""
			UI:previewSongSelection()
		end)
		brickFrame.Close.MouseButton1Down:Connect(function()
			local Button = Menu:FindFirstChild("Shop")
			Button.BackgroundTransparency = Main:FindFirstChild("Shop").Visible == true and 1 or 0
			Main.Shop.Visible = false
		end)
		shopFrame.Preview.Cancel.MouseButton1Down:Connect(function()
			UI:loadShopCategory()
		end)
		shopFrame.Preview.Buy.MouseButton1Down:Connect(function()
			if (shopFrame.Preview.Buy.Label.Text == "BUY") then
				if (shopSelection == "Coins") then
					MPS:PromptProductPurchase(Player, Products[itemSelection])
				elseif (shopSelection == "Passes") then
					MPS:PromptGamePassPurchase(Player, Gamepasses[itemSelection])
				elseif (shopSelection == "Gears") then
					local Result = Network:Get(Player, "PurchaseItem", setSelection, itemSelection)
					if (Result) then
						shopFrame.Preview.Buy.Label.Text = "PURCHASED"
						wait(1)
						shopFrame.Preview.Buy.Label.Text = "BUY"
					else
						shopFrame.Preview.Buy.Label.Text = "FAILED TO PURCHASE"
						wait(1)
						shopFrame.Preview.Buy.Label.Text = "BUY"
					end
				end
			end
		end)
		shopFrame.Wood.Title.Last.MouseButton1Down:Connect(function()
			setSelection = setSelection-1
			UI:loadShopCategory()
		end)
		shopFrame.Wood.Title.Next.MouseButton1Down:Connect(function()
			setSelection = setSelection+1
			UI:loadShopCategory()
		end)
		shopFrame.Song.Details.Buy.MouseButton1Down:Connect(function()
			if (validSongPurchase) then
				MPS:PromptProductPurchase(Player, addSongId)
			end
		end)
		shopFrame.Song.Details.Frame.ID.FocusLost:Connect(function()
			checkSongDetails()
		end)
	end
end

local settingSelection = "General"

local function updateSetting(Option, Setting, Value)
	local doSwitch = true
	--print("set", Setting, Value)
	if (Setting == "HIDE_PLAYERS") then
		for _, Character in pairs(game.Workspace:GetChildren()) do
			if (game.Players:GetPlayerFromCharacter(Character)) and (Character~=Player.Character) then
				local Client = _G.Local:Load("Client")
				if (Value == true) then
					Client:hideCharacter(Character)
				else
					Client:hideCharacter(Character, 0)
				end
			end
		end
	elseif (Setting == "HIDE_NAMETAGS") then
		for _, Character in pairs(game.Workspace:GetChildren()) do
			if (game.Players:GetPlayerFromCharacter(Character)) then
				local Client = _G.Local:Load("Client")
				Client:hideName(Character, Value)
			end
		end
	elseif (Setting == "MUTE_ELEVATOR") then
		local Audio = _G.Local:Load("Audio")
		Audio:muteElevator(Value)
	elseif (Setting == "MUTE_MUSIC") then
		local Audio = _G.Local:Load("Audio")
		Audio:muteMusic(Value)
	elseif (Setting == "CHANCE") then
		local Success = Network:Get(Player, "UpdateSetting", Setting, Value)
		doSwitch = Success
	end
	if (doSwitch) then
		UI.SETTINGS[Setting] = Value
		if (Value==true) then
			Option.Switch.Bar:TweenPosition(UDim2.new(0.5,0,0,0), "Out", "Linear", 0.05)
			Option.Switch.ImageColor3 = Color3.new(0,1,0)
			Option.Switch.ImageTransparency = 0
		else
			Option.Switch.Bar:TweenPosition(UDim2.new(0,0,0,0), "Out", "Linear", 0.05)
			Option.Switch.ImageColor3 = Color3.new(0,0,0)
			Option.Switch.ImageTransparency = 0.5
		end
	end
end

function UI:loadSettings()
	if (not settingsLoaded) then
		settingsLoaded = true
		
		local Frame = Main.Settings.Menu
		for _, Option in pairs(Frame:GetChildren()) do
			--for _, Option in pairs(Tab:GetChildren()) do
				if (Option:FindFirstChild("Switch")) then
					Option.Switch.MouseButton1Down:Connect(function()
						if (UI.SETTINGS[Option.Name]==false) then
							updateSetting(Option, Option.Name, true)
						else
							updateSetting(Option, Option.Name, false)
						end
					end)
					if (Option.Name == "CHANCE") then
						if (MPS:UserOwnsGamePassAsync(Player.UserId, 452845)) then
							Option.Visible = true
							updateSetting(Option, Option.Name, true)
						end
					end
				end
			--end
			
		end
	end
end

function UI:addCoins()
	local PlayerData = game.ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(Player.Name)
	local Amount = Menu.Count.Amount
	Amount.Text = PlayerData.Stats.Coins.Value
	local Effect = Amount:Clone()
	Effect.Parent = Amount.Parent
	Effect.Name = "CoinEffect"
	local R, G
	if (Coins.Value > CoinsValue) then
		Effect.Text = "+" .. Coins.Value - CoinsValue
		G = 1
	elseif (Coins.Value < CoinsValue) then
		Effect.Text = Coins.Value - CoinsValue
		R = 1
	end
	CoinsValue = Coins.Value
	Effect.TextColor3 = Color3.new(R~=nil and R or 0, G~=nil and G or 0,0)
	Effect.TextStrokeColor3 = Color3.new(R~=nil and R-0.2 or 0, G~=nil and G-0.2 or 0,0)
	--Effect.ImageColor3 = Color3.new(R~=nil and R or 0, G~=nil and G or 0,0)
	Effect:TweenPosition(UDim2.new(Effect.Position.X, UDim.new(-3, Effect.Position.Y.Offset)), "Out", "Sine", 1)
	for T = 1, 10 do
		Effect.TextTransparency = T/10
		Effect.TextStrokeTransparency = T/10
		--Effect.ImageTransparency = T/10
		wait(0.1)
	end
	Effect:Destroy()
end

function UI:fadeBlackScreen(trans, length, fadeBack, delayTime, textTable)
	local blackScreen = PlayerGui:FindFirstChild("Misc").Black
	blackScreen.Visible = true
	local oldTrans = blackScreen.Transparency
	local Info = TweenInfo.new(length)
	local transGoal = {Transparency = trans}
	local Tween = TS:Create(blackScreen, Info, transGoal)
	Tween:Play()
	if (fadeBack) then
		Tween.Completed:Wait()
		if (textTable) then
			blackScreen.Label.Visible = true
			for key, value in pairs(textTable) do
				if (blackScreen.Label[key]) then
					blackScreen.Label[key] = value
				end
			end
		end
		wait(delayTime)
		blackScreen.Label.Visible = false
		transGoal = {Transparency = oldTrans}
		Tween = TS:Create(blackScreen, Info, transGoal)
		Tween:Play()
	end
	Tween.Completed:Wait()
	PlayerGui:FindFirstChild("Misc").Black.Visible = false
end

function UI:showMessage(Text, showTime, Type)
	local Gui = PlayerGui.Misc
	local Frame = Gui:FindFirstChild("Message")
	if (Frame.Visible == false) then
		Frame.Visible = true
		Frame:TweenPosition(UDim2.new(0.15,0,0.05,0), "Out", "Back", 0.6)
		if (Type) then
			for i = 1, Text:len() do
				Frame.Label.Text = Text:sub(i, Text:len())
				wait()
			end
		else
			Frame.Label.Text = Text
		end
		wait(showTime)
		Frame:TweenPosition(UDim2.new(0.15,0,-0.5,0), "In", "Back", 0.6)
		wait(0.6)
		Frame.Visible = false
	end
end

for _, Button in pairs(Menu:GetChildren()) do
	if (Button:IsA("ImageButton")) and (Main:FindFirstChild(Button.Name)) then
		Button.MouseButton1Down:Connect(function()
			menuButtonClicked(Button.Name)
		end)
		Button.MouseEnter:Connect(function()
			menuButtonEnter(Button.Name)
		end)
		Button.MouseLeave:Connect(function()
			Menu.Desc.Text = ":)"
			Menu.Desc.Visible = false
		end)
	end
end

Menu.Toggle.MouseButton1Down:Connect(function()
	if (menuOpen) then
		menuOpen = false
		Menu.Toggle.Text = ">"
		Menu:TweenPosition(UDim2.new(0,-Menu.AbsoluteSize.X,1,0), "Out", "Sine", 0.2, true)
	else
		menuOpen = true
		Menu.Toggle.Text = "<"
		Menu:TweenPosition(UDim2.new(0,0,1,0), "Out", "Sine", 0.2, true)
	end
end)

local Client = _G.Local:Load("Client")
if (Client.onMobile) then
	Menu.Size = UDim2.new(0.65,0,0.07,0)
	Main:WaitForChild("Shop").Items.UIGridLayout.CellSize = UDim2.new(0,60,0,60)
end

Coins.Changed:connect(function()
	UI:addCoins()
end)

return UI