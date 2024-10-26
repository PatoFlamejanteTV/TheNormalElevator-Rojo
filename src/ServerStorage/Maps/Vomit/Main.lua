local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local Noob
local Face
local Vomit

local Faces = {"rbxassetid://113475009", "rbxassetid://155218074", "rbxassetid://179665577"}

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 20 --seconds
}
local function setVariables(Map)
	Noob = Map.Noob
	Face = Noob.Head.face
	Vomit = Map.Vomit
end

function Floor:initPlayer(Player)
	Network:Send(Player, "LoadLighting", {Sky = Floor.Skybox})
end

function Floor:init(Map)
	setVariables(Map)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Elevator:enableSkybox()
	Floor.Sounds.Ambience:Play()
	
	wait(5)
	Noob.Humanoid:LoadAnimation(Noob.Vomit):Play()
	wait(0.1)
	Noob.Head.Sound:Play()
	Face.Texture = Faces[2]
	wait(1)
	Face.Texture = Faces[3]
	for i = 1, 50 do
		local newVomit = Vomit:Clone()
		local touched = false
		newVomit.Parent = Map
		newVomit.Transparency = 0
		newVomit.Anchored = false
		newVomit.CFrame = Noob.Head.CFrame * CFrame.Angles(math.pi/2, 0,0)
		newVomit.Mesh.Scale = Vector3.new(1,0.5,1) * math.random(1, 3)
		newVomit.Velocity = (Noob.Head.CFrame * CFrame.Angles(math.pi/4,0,0)).lookVector * math.random(40, 90)
		newVomit.Touched:connect(function(hit)
			if (hit.Name ~= "FakeDoor") and (hit.Parent ~= Noob) and (hit.Name ~= "Vomit") and (hit.CanCollide == true) and (not newVomit:FindFirstChild("VomitWeld")) then
				touched = true
				local weld = Instance.new("Weld", newVomit)
				weld.Name = "VomitWeld"
				weld.Part0 = newVomit
				weld.Part1 = hit
				weld.C0 = newVomit.CFrame:inverse() * newVomit.CFrame
				weld.C1 = hit.CFrame:inverse() * newVomit.CFrame
			end
		end)
		wait(0.1)
	end
	Face.Texture = Faces[1]
end


return Floor