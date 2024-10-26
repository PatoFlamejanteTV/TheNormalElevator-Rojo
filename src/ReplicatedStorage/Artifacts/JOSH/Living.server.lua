local Elevator = _G.Modules:Load("Elevator")
local Network = _G.Modules:Load("Network")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Long = Tool:WaitForChild("Long")
local Thick = Tool:WaitForChild("Thick")

local yesSound = Handle:WaitForChild("RGY")
local noSound = Handle:WaitForChild("JOSH")

local currentMap

local activated = false
local equipped = false

local db = true

local words = {[true] = {"RAGA", "GAGA", "YAGA"}, [false] = {"JOOGI", "OOGI", "SOOGI", "HOOGI"}}

local function on(mapName)
	activated = true
	Long.Material = Enum.Material.Neon
	Thick.Material = Enum.Material.Neon
	if (mapName == "RockBottom") then
		Long.BrickColor = BrickColor.new("Bright green")
		Thick.BrickColor = BrickColor.new("Bright green")
	elseif (mapName == "Sharknado") then
		Long.BrickColor = BrickColor.new("Bright red")
		Thick.BrickColor = BrickColor.new("Bright red")
	elseif (mapName == "DarkRoomArea") then
		Long.BrickColor = BrickColor.new("Bright yellow")
		Thick.BrickColor = BrickColor.new("Bright yellow")
	elseif (mapName == "Snoop") then
		Long.BrickColor = BrickColor.new("Institutional white")
		Thick.BrickColor = BrickColor.new("Institutional white")
	end
end

local function off()
	activated = false
	Long.Material = Enum.Material.Wood
	Thick.Material = Enum.Material.Wood
	Long.BrickColor = BrickColor.new("Pastel brown")
	Thick.BrickColor = BrickColor.new("Pastel brown")
end

Tool.Activated:Connect(function()
	
	if (db) then
		db = false
		local status = activated
		local Sound = (status and yesSound) or noSound
		Handle.Talk.Enabled = true
		Sound:Play()
		for i = 1, #words[status] do
			Handle.Talk.Label.Text = words[status][i]
			if (words[status][i]=="RAGA") then
				Handle.Talk.Label.TextStrokeColor3 = Color3.new(1,0,0)
			elseif (words[status][i]=="GAGA") then
				Handle.Talk.Label.TextStrokeColor3 = Color3.new(0,1,0)
			elseif (words[status][i]=="YAGA") then
				Handle.Talk.Label.TextStrokeColor3 = Color3.new(1,1,0)
			else
				Handle.Talk.Label.TextStrokeColor3 = Color3.new(1,1,1)
			end
			wait(Sound.TimeLength/#words[status])
		end
		Handle.Talk.Enabled = false
		db = true
	end
	
end)

Tool.Equipped:Connect(function()
	
	equipped = true
	yesSound.Volume = 0.5
	noSound.Volume = 0.5
	
	
	if (Elevator.currentMap) and ((Elevator.currentMap.Name == "RockBottom") or (Elevator.currentMap.Name == "Sharknado") or (Elevator.currentMap.Name == "SnoopDogg")) then
		on(Elevator.currentMap.Name)
	elseif (Elevator.currentMap == nil) or ((Elevator.currentMap.Name ~= "RockBottom") and (Elevator.currentMap.Name ~= "Sharknado") and (Elevator.currentMap.Name ~= "SnoopDogg")) then
		off()
	end
	
end)

Tool.Unequipped:Connect(function() 
	equipped = false
	if (yesSound.IsPlaying) then
		yesSound.Volume = 0
	end
	if (noSound.IsPlaying) then
		noSound.Volume = 0
	end
end)

Handle.Touched:Connect(function(Hit)
	if (Hit.Name == "DarkRoomArea") then
		on(Hit.Name)
	end
end)

Handle.TouchEnded:Connect(function(Hit)
	if (Hit.Name == "DarkRoomArea") then
		off()
	end
end)

Elevator.Map.ChildAdded:Connect(function(Map)
	if (Map.Name == "RockBottom") or (Map.Name == "Sharknado") or (Map.Name == "Snoop") then
		if (equipped) then
			on(Map.Name)
		end
	end
end)

Elevator.Map.ChildRemoved:Connect(function(Map)
	if (Map.Name == "RockBottom") or (Map.Name == "Sharknado") or (Map.Name == "Snoop") then
		if (equipped) then
			off()
		end
	end
end)