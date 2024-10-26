local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Lobby = {}

Lobby.Model = game.Workspace.Lobby
Lobby.Elevator = Lobby.Model.Elevator
--Lobby.RedElevator = Lobby.Model.GavinRoom.RedRoom.RedElevator
--Lobby.Shop = Lobby.Model.Shop

Lobby.ElevatorQueue = {}
Lobby.NPCQueue = {}

local QUEUE_TIME = 3

local elevatorClosing = false
local TriggerDB = true

--local backDoor = Lobby.Model.BackDoor

local function getPlayerInQueue(Player)
	for index, EPlayer in pairs(Lobby.ElevatorQueue) do
		if (EPlayer == Player) then
			return EPlayer, index
		end
	end
	return nil
end

function Lobby:loadNPCs()
	for _, NPC in pairs(Lobby.Model:GetChildren()) do
		if (NPC:FindFirstChild("NPCScript")) then
			require(NPC.NPCScript):init("Lobby")
		end
	end
end

function Lobby:addPlayerToQueue(Player)
	if (not getPlayerInQueue(Player)) and (TriggerDB) then
		TriggerDB = false
		table.insert(Lobby.ElevatorQueue, #Lobby.ElevatorQueue+1, Player)
		Network:Send(Player, "LobbyFakeDoor", true)
		TriggerDB = true
		if (#Lobby.ElevatorQueue+#Lobby.NPCQueue == 1) then
			Lobby:startQueue()
		end
	end
end

function Lobby:addNPCToQueue(NPC)
	local found = false
	for _, AI in pairs(Lobby.NPCQueue) do
		if (AI == NPC) then
			found = true
		end
	end
	if (not found) then
		table.insert(Lobby.NPCQueue, #Lobby.NPCQueue+1, NPC)
		if (#Lobby.ElevatorQueue+#Lobby.NPCQueue == 1) then
			Lobby:startQueue()
		end
	end
end

function Lobby:removePlayerFromQueue(Player)
	local EPlayer, Index = getPlayerInQueue(Player)
	if (EPlayer) then
		table.remove(Lobby.ElevatorQueue, Index)
	end
end

function Lobby:startQueue()
	for int = QUEUE_TIME, 1, -1 do
		Elevator:updateTimerParts(Lobby.Elevator, int, Lobby.Elevator.ButtonPad.TimerPart, Lobby.Elevator.OutsideTimer.TimerPart)
		wait(1)
	end
	elevatorClosing = true
	Lobby.Elevator.FakeDoor.CanCollide = true
	pcall(function()
		Elevator:closeDoors(Lobby.Elevator)
		for _, Player in pairs(Lobby.ElevatorQueue) do
			if (Functions:characterIsValid(Player.Character)) then
				Elevator:addPlayer(Player)
			end
		end
		for _, NPC in pairs(Lobby.NPCQueue) do
			Elevator:addNPC(NPC, true)
		end
		Elevator:updateTimerParts(Lobby.Elevator, QUEUE_TIME, Lobby.Elevator.ButtonPad.TimerPart, Lobby.Elevator.OutsideTimer.TimerPart)
		Elevator:openDoors(Lobby.Elevator)
	end)
	
	Lobby.ElevatorQueue = {}
	Lobby.NPCQueue = {}
	Lobby.Elevator.FakeDoor.CanCollide = false
	elevatorClosing = false
end

function Lobby:initSlideGame()
	local Game = {}
	
	Game.mode = ""
	
	local Cells = {}
	local correctCells = {}
	
	local gamePart = Lobby.Model.SlideGame
	local Gui = gamePart.SlideGame
	local Pictures = gamePart.Pictures
	local cellButton = gamePart.Cell
	
	local CANVAS_SIZE = Gui.CanvasSize.X
	local lastPicID
	
	local function getRandomModeAndPicture()
		local Choices = {"3x3", "4x4", "5x5"}
		local Gamemode = Choices[math.random(1, #Choices)]
		local newPicID
		local pics = Pictures:GetChildren()
		if (lastPicID) then
			repeat newPicID = pics[math.random(1,#pics)].Value until newPicID ~= lastPicID
		else
			newPicID = pics[math.random(1,#pics)].Value
		end
		lastPicID = newPicID
		Game.mode = Gamemode
		return lastPicID
	end
	
	function Game:awardCoins()
		local REWARD
		if (Game.mode == "3x3") then
			REWARD = 3
		elseif (Game.mode == "4x4") then
			REWARD = 5
		elseif (Game.mode == "5x5") then
			REWARD = 10
		end
		for amount = 1, REWARD do
			local Coin = game.ReplicatedStorage.Coin:Clone()
			Coin.Parent = Lobby.Model
			Coin.CFrame = gamePart.CFrame * CFrame.new(2, 0, 0)
			Coin.Velocity = Coin.CFrame.lookVector * 40
			wait(0.1)
		end
	end
	
	function Game:checkWinStatus()
		local won = true
		for num, Cell in pairs(Cells) do
			if (correctCells[Cell.tile].pos[1] ~= Cell.pos[1]) or (correctCells[Cell.tile].pos[2] ~= Cell.pos[2]) then
				won = false
			end
		end
		return won
	end
	
	function Game:new(PictureID)
		Cells = {}
		correctCells = {}
		local CELLS_IN_ROW
		local TOTAL_CELLS
		local EMPTY_CELL
		local endGame = false
		cellButton.Picture.Image = "rbxassetid://"..PictureID
		CELLS_IN_ROW = tonumber(Game.mode:sub(1, 1))
		EMPTY_CELL = {CELLS_IN_ROW, CELLS_IN_ROW}
		TOTAL_CELLS = CELLS_IN_ROW*CELLS_IN_ROW
		
		for num = 0, TOTAL_CELLS-2 do
			
			local Cell = {}
			Cell.tile = num+1
			Cell.pos = {(num%(CELLS_IN_ROW))+1, math.ceil((num+1)/CELLS_IN_ROW)}
			Cell.Instance = cellButton:Clone()
			Cell.Instance.Parent = Gui.Frame
			Cell.Instance.Name = "Cell"..num+1
			Cell.Instance.Size = UDim2.new(0, CANVAS_SIZE/CELLS_IN_ROW, 0, CANVAS_SIZE/CELLS_IN_ROW)
			Cell.Instance.Picture.Size = UDim2.new(0, CANVAS_SIZE, 0, CANVAS_SIZE)
			local posX, posY = (num%CELLS_IN_ROW)*(CANVAS_SIZE/CELLS_IN_ROW), (math.floor(num/CELLS_IN_ROW)*(CANVAS_SIZE/CELLS_IN_ROW))
			Cell.Instance.Position = UDim2.new(0, posX, 0, posY)
			Cell.Instance.Picture.Position = UDim2.new(0, -posX, 0, -posY)
			if (Cell.Instance:FindFirstChild("Number")) then
				Cell.Instance.Number.Text = num+1
			end
			
			Cells[Cell.tile] = Cell
			
			function Cell:move()
				local moveTo = nil
				local movePoses = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
				local foundEmptyCell = false
				for _, Position in pairs(movePoses) do
					if (not foundEmptyCell) then
						local check = {[1] = false, [2] = false}
						local newPos = {Cell.pos[1]+Position[1], Cell.pos[2]+Position[2]}
						--check if newPos is a valid position first (>= 0,0 and <= 3,3)
						if (newPos[1] == EMPTY_CELL[1]) and (newPos[2] == EMPTY_CELL[2]) then
							foundEmptyCell = true
							moveTo = newPos
						end
					end
				end
				if (moveTo) then
					EMPTY_CELL = Cell.pos
					Cell.pos = moveTo
					Cell.Instance:TweenPosition(UDim2.new(0, (moveTo[1]-1)*(CANVAS_SIZE/CELLS_IN_ROW), 0, ((moveTo[2]-1)*(CANVAS_SIZE/CELLS_IN_ROW))), "Out", "Linear", 0.05, true)
				end
			end
			
			Cell.Instance.MouseButton1Down:connect(function()
				if (not endGame) then
					Cell:move()
					if (Game:checkWinStatus() == true) then
						endGame = true
						Game:awardCoins()
						wait(1)
						for _, Cell in pairs(Cells) do
							Cell.Instance:Destroy()
							Cell = nil
						end
						Cells = {}
						correctCells = {}
						wait(1)
						Game:new(getRandomModeAndPicture())
					end
				end
			end)
		end
		
		for num, Cell in pairs(Cells) do
			correctCells[num] = {}
			correctCells[num].tile = Cell.tile
			correctCells[num].pos = Cell.pos
		end
		
		for i = 1, TOTAL_CELLS*(math.random(1,3)) do
			for k = 1, TOTAL_CELLS*(math.random(1,3)) do
				for _, Cell in pairs(Cells) do
					Cell:move()
				end
			end
		end
	end
	
	Game:new(getRandomModeAndPicture())
	
	return Game
end

--Lobby:initSlideGame() not in yet

local oldElevatorQueue = {}

local OLD_INTER = 5

--[[

function startOldQueue()
	local oldElevator = Lobby.Model.OldElevator
	for i = OLD_INTER, 1, -1 do
		oldElevator.FakeDoor.Gui.Label.Text = i
		oldElevator.Timer.Gui.Time.Text = i
		wait(1)
	end
	Elevator:closeDoors(oldElevator)
	pcall(function()
		for _, Player in pairs(oldElevatorQueue) do
			game:GetService("TeleportService"):Teleport(2925696836, Player)
		end
	end)
	wait(1)
	oldElevator.CountBoard.Gui.Label.Text = #oldElevatorQueue .. "/7 players"
	oldElevator.FakeDoor.Gui.Label.Text = OLD_INTER
	oldElevator.Timer.Gui.Time.Text = OLD_INTER
	oldElevatorQueue = {}
	Elevator:openDoors(oldElevator)
end

Lobby.Model.OldElevator.FakeDoor.Touched:Connect(function(Hit)
	if (Functions:characterIsValid(Hit.Parent)) and (Hit.Parent:FindFirstChild("Humanoid")) and (not Functions:GetObjectFromTable(oldElevatorQueue, game.Players:GetPlayerFromCharacter(Hit.Parent))) then
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		table.insert(oldElevatorQueue, #oldElevatorQueue+1, Player)
		Lobby.Model.OldElevator.CountBoard.Gui.Label.Text = #oldElevatorQueue .. "/7 players"
		Functions:teleportPlayer(Player, Lobby.Model.OldElevator.TeleportPart.CFrame)
		if (#oldElevatorQueue==1) then
			startOldQueue()
		end
		
	end
end)]]

Lobby.Elevator.Trigger.Touched:Connect(function(Hit)
	local Character = Hit.Parent
	if (Functions:characterIsValid(Character)) and (not elevatorClosing) then
		Lobby:addPlayerToQueue(game.Players:GetPlayerFromCharacter(Character))
	elseif (Character:FindFirstChild("NPC")) and (Character:FindFirstChild("NPCScript")) then
		Lobby:addNPCToQueue(Character)
	end
end)

local backDoorOpen = false
--[[
backDoor.Trigger.Touched:Connect(function(Hit)
	local Tool = Hit.Parent
	if (Tool:IsA("Tool")) and (Tool.Name == "JOSH") and (not backDoorOpen) then
		backDoorOpen = true
		backDoor.Door:SetPrimaryPartCFrame(backDoor.Door.PrimaryPart.CFrame * CFrame.Angles(0,-math.pi/2, 0))
		wait(3)
		backDoor.Door:SetPrimaryPartCFrame(backDoor.Door.PrimaryPart.CFrame * CFrame.Angles(0,math.pi/2, 0))
		backDoorOpen = false
	end
end)

Lobby.Shop.DarkRoomArea.Touched:Connect(function(Hit)
	local Tool = Hit.Parent
	if (Tool:IsA("Tool")) and (Tool.Name == "JOSH") and (Hit.Name == "Handle") and (not backDoorOpen) then
		Tool.Long.BrickColor = BrickColor.new("Bright yellow")
		Tool.Long.Material = Enum.Material.Neon
		Tool.Thick.BrickColor = BrickColor.new("Bright yellow")
		Tool.Thick.Material = Enum.Material.Neon
	end
end)

Lobby.Model.GoldRoom.Trigger.Touched:Connect(function(Hit)
	local Character = Hit.Parent
	if (Functions:characterIsValid(Character)) and (not Elevator:findNPC("Yaga")) and (not Lobby.Model:FindFirstChild("Yaga")) then
		local Mystery = game.ServerStorage.NPCs:FindFirstChild("Yaga"):Clone()
		Mystery.Parent = Lobby.Model
		Mystery:SetPrimaryPartCFrame(Lobby.Model.GoldRoom.Floor.CFrame * CFrame.new(0,3,0))
		require(Mystery.NPCScript):init("Lobby")
		--[[
		local Mystery = game.ServerStorage.NPCs:FindFirstChild("Raga"):Clone()
		Mystery.Parent = Lobby.Model
		Mystery:SetPrimaryPartCFrame(Lobby.Model.GoldRoom.Floor.CFrame * CFrame.new(0,3,0))
		require(Mystery.NPCScript):init("Lobby")
		local Mystery = game.ServerStorage.NPCs:FindFirstChild("Gaga"):Clone()
		Mystery.Parent = Lobby.Model
		Mystery:SetPrimaryPartCFrame(Lobby.Model.GoldRoom.Floor.CFrame * CFrame.new(0,3,0))
		require(Mystery.NPCScript):init("Lobby")
	end
end)

Lobby.RedElevator.Trigger.Touched:Connect(function(Hit)
	local Character = Hit.Parent
	local Player = game.Players:GetPlayerFromCharacter(Character)
	if (Functions:characterIsValid(Character)) and (Hit.Name == "HumanoidRootPart") then
		wait(6)
		if (Character) then
			game:GetService("TeleportService"):Teleport(3016178476, Player)
		end
	end
end)]]

--[[
	HOLIDAY FUNCTIONS
--]]

return Lobby