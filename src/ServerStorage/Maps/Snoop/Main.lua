local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Hitmarkers
local Panel
local BigSnoopPos
local Particles

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 20 --seconds
}

local fakeStoredCollisions = {}

Floor.Lighting = {
	[1] = {
		Bloom = {Intensity = 0,Size = 0, Threshold = 0},
		Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0},
		Rays = {Intensity = 0,Spread = 0},
		Lighting = {OutdoorAmbient=Color3.new(127/255,127/255, 127/255), Brightness = 1,ClockTime=12},
	},
	[2] = {
		Color = {Brightness = 1, Contrast = -1, Saturation = 1, TweenTime = 2,
			Enabled = true},
	},
	[3] = {
		Color = {Brightness = 0, Contrast = 0, Saturation = 0, TweenTime = 2,
			Enabled = true}
	},
	[4] = {
		Color = {Brightness = -0.1, Contrast = 1, Saturation = 1, TintColor = Color3.fromRGB(242, 255, 123), TweenTime = 2, 
			Enabled = true},
		Lighting = {Ambient = Color3.fromRGB(0, 170, 255), Brightness = 1, ColorShift_Bottom = Color3.fromRGB(85,255,127), ColorShift_Top = Color3.fromRGB(255,255,127), OutdoorAmbient = Color3.fromRGB(170,85,255), FogColor = Color3.new(1,1,1), FogEnd = 150, FogStart = 50, ClockTime=12},
		Sky = Floor.Skybox
	},
	[5] = {
		Lighting = {FogEnd = 1600, TweenTime = 8}
	}
}

local Stage = 1 -- for lighting (1 is normal)
local Trippy = false

local function setVariables(Map)
	Hitmarkers = Map.Hitmarkers
	Panel = Map.Panel
	BigSnoopPos = Map.Snoops.BigSnoop.Position
	Particles = Map.Particles
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", Floor.Lighting[Stage])
	if (Trippy) then
		local Cam = Floor.Model:FindFirstChild("WeirdCamera"):Clone()
		Cam.Parent = Player.Backpack
		Cam.Disabled = false
		local Walls = Floor.Model.Walls:Clone()
		Walls.Parent = Player.Backpack
		Walls.Disabled = false
	end
end


function Floor:init(Map)
	setVariables(Map)
	Elevator:changeBackgroundColor(Color3.new(1,1,1))
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	
	Floor.Sounds.Music:Play()
	
	if (game.Workspace.NPCs:FindFirstChild("Raga")) and (game.Workspace.NPCs:FindFirstChild("Yaga")) and (game.Workspace.NPCs:FindFirstChild("Gaga")) then
		for _, Player in pairs(Elevator.Players) do
			game:GetService("BadgeService"):AwardBadge(Player.UserId, 2124445474)
		end
		Elevator.Time = Elevator.Time + 17
		Floor.Sounds.Ringing:Play()
		local NPCs = {}
		NPCs[1] = game.Workspace.NPCs:FindFirstChild("Raga")
		NPCs[2] = game.Workspace.NPCs:FindFirstChild("Gaga")
		NPCs[3] = game.Workspace.NPCs:FindFirstChild("Yaga")
		wait(3)
		for n = 1, #NPCs do
			if (NPCs[n]) then
				local Triangles = game.ServerStorage.Models.Triangles:Clone()
				Triangles.Parent = NPCs[n]:FindFirstChild("HumanoidRootPart")
				Triangles.Color = ColorSequence.new(NPCs[n].Head.Color)
				Triangles.Enabled = true
				spawn(function()
					for i = 1, 25 do
						for _, Part in pairs(NPCs[n]:GetChildren()) do
							if (Part:IsA("BasePart")) and (Part.Name ~= "HumanoidRootPart") then
								Part.Transparency = i/25
							end
						end
						wait(0.08)
					end
				end)
			end
		end

		wait(2)
		
		for _, Player in pairs(Elevator.Players) do
			Network:Send(Player, "LoadLighting", Floor.Lighting[2])
		end
		Stage = 2
		wait(2)
		for n = 1, #NPCs do
			if (NPCs[n]) then
				Elevator.NPCs[NPCs[n]]:remove()
			end
		end
	
		for _, Player in pairs(Elevator.Players) do
			Network:Send(Player, "LoadLighting", Floor.Lighting[3])
		end
		Stage = 3
	
		for _, Thing in pairs(Map:GetChildren()) do
			if (Thing.Name ~= "Particles") and (not Thing:IsA("Folder")) and (not Thing:IsA("Script")) and (Thing.Name ~= "Floor") and (Thing.Name ~= "HotelSign") then
				Thing:Destroy()
			end
		end
		
		wait(2)
		
		Floor.Sounds.Glass:Play()
		Elevator:changeBackgroundColor(Color3.new(0,0,0))
		Particles.Triangles.Enabled = true
		Map.Floor.SurfaceGui:Destroy()
		
		local fakeElevator = Elevator.Model:Clone()
		fakeElevator.Parent = Map
		fakeElevator.Name = "FakeElevator"
		fakeElevator:SetPrimaryPartCFrame(Elevator.Model.PrimaryPart.CFrame)
		
		local function computeDirection(vec)
			local lenSquared = vec.magnitude * vec.magnitude
			local invSqrt = 1 / math.sqrt(lenSquared)
			return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
		end
		
		local function distortPart(Part)
			--Part.Color = Color3.new(0,0,0)
			--Part.Material = Enum.Material.Wood
			Part.Anchored = false
			Part.CanCollide = false
			local floatForce = Instance.new("BodyForce")
			floatForce.Parent = Part
			floatForce.force = Vector3.new(0, Part:GetMass() * 196.2, 0.0)
			local direction = Elevator.Model.TeleportPart.Position - Part.Position
			direction = computeDirection(direction)
			Part.Velocity = direction * -15
			if (Part.Name == "FakeDoor") then
				Part.CanCollide = false
			end
			if (Part:IsA("UnionOperation")) then
				Part.UsePartColor = true
			end
			if (Part.Name == "TimerPart") then
				Part.Gui:Destroy()
			end
			
		end
		
		local function hidePart(Part)
			Part.Transparency = 1
			fakeStoredCollisions[Part] = Part.CanCollide
			Part.CanCollide = false
			for _, Object in pairs(Part:GetChildren()) do
				if (Object:IsA("Decal")) then
					Object.Transparency = 1
				end
				if (Object:IsA("SurfaceGui")) then
					Object.Enabled = false
				end
			end
		end
		
		Functions:recurseFunctionOnParts(distortPart, fakeElevator)
		Functions:recurseFunctionOnParts(hidePart, Elevator.Model)
		
		Floor.Sounds.Music:Stop()
		
		wait(3)
		
		for _, Player in pairs(Elevator.Players) do
			Network:Send(Player, "LoadLighting", Floor.Lighting[2])
		end
		Stage = 2
		
		wait(2)
		fakeElevator:Destroy()
		Elevator:enableSkybox()
		Elevator.Model.FakeDoor.CanCollide = false
		
		for _, Player in pairs(Elevator.Players) do
			Network:Send(Player, "LoadLighting", Floor.Lighting[4])
			local Cam = Floor.Model.WeirdCamera:Clone()
			Cam.Parent = Player.Backpack
			Cam.Disabled = false
			local Walls = Floor.Model.Walls:Clone()
			Walls.Parent = Player.Backpack
			Walls.Disabled = false
		end
		Stage = 4
		Trippy = true
		Particles.Triangles.Enabled = false
		
		local Chorus = Instance.new("ChorusSoundEffect", Floor.Sounds.Music)
		Chorus.Depth = 0.92
		Chorus.Mix = 0.88
		Chorus.Rate = 11.4
		
		Floor.Sounds.Music.PlaybackSpeed = 0.8
		Floor.Sounds.Music:Play()
		Floor.Sounds.Ringing:Stop()
		
		wait(2)
		
		for _, Player in pairs(Elevator.Players) do
			Network:Send(Player, "LoadLighting", Floor.Lighting[5])
		end
		Stage = 5
		
	else
		spawn(function()
			while true do
				wait(math.random(3,10)/100)
				if (Map) and (Map:FindFirstChild("Hitmarker")) then
					local Hit = Floor.Sounds.Hitmarker:Clone()
					Hit.Volume = 0.5
					Hit.Parent = Panel
					Hit:Play()
					spawn(function()
						wait(0.5)
						Hit:Destroy()
					end)
				end
			end
		end)
		
		for i = 1, 4 do
			wait(5)
			local Explosion = Instance.new("Explosion", Map)
			Explosion.Name = "Boom"
			Explosion.Position = Map.Explosion.Position
			Explosion.DestroyJointRadiusPercent = 0
			if (i == 2) then
				local Tween = game:GetService("TweenService"):Create(Map.Snoops.BigSnoop, TweenInfo.new(5), {Position = BigSnoopPos+Vector3.new(0,30,0)})
				Tween:Play()
				Floor.Sounds.ExplodeSound:Play()
			end
		end
		
	end
	
end

function Floor.ending()
	for _, Player in pairs(Elevator.Players) do
		if (Player.Backpack:FindFirstChild("WeirdCamera")) then
			Player.Backpack.WeirdCamera:Destroy()
		end
		if (Player.Backpack:FindFirstChild("Walls")) then
			Player.Backpack.Walls:Destroy()
		end
		Network:Send(Player, "CleanSnoop")
	end
	Stage = 1
	if (Trippy) then
		Trippy = false
		Elevator:teleportPlayers()
		for _, Player in pairs(Elevator.Players) do
			game:GetService("BadgeService"):AwardBadge(Player.UserId, 2124445474)
		end
	end
	local function showElevatorDoors(Part)
		for _, Object in pairs(Part:GetChildren()) do
			if (Object:IsA("Decal")) then
				Object.Transparency = 0
			end
			if (Object:IsA("SurfaceGui")) then
				Object.Enabled = true
			end
		end
	end
	Functions:recurseFunctionOnParts(showElevatorDoors, Elevator.Model)
	for Part, Collide in pairs(fakeStoredCollisions) do
		Part.CanCollide = Collide
	end
	fakeStoredCollisions = {}
	
end

return Floor