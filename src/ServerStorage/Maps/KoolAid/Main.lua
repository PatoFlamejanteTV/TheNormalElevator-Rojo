local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

local KoolAidMan
local YeahSound
local BreakSound
local Smoke, Smoke2
local RunAnim

Floor.Settings = {
	DOORS_OPEN = false,
	INTERACTIVE = false,
	TIME = 13 --seconds
}

local function setVariables(Map)
	KoolAidMan = Map.AnimationMan
	YeahSound = KoolAidMan.Head.Yeah
	BreakSound = KoolAidMan.Head.Break
	Smoke = Map.SmokePart.Smoke
	Smoke2 = Map.SmokePart2.Smoke
	RunAnim = Map.RunAnimation
end

local function showBrokenWall(Side)
	for _, Part in pairs(Floor.Model:FindFirstChild(Side.."Side"):GetChildren()) do
		Part.Transparency = 0
	end
	for _, Part in pairs(Floor.Model:FindFirstChild(Side.."Railing"):GetChildren()) do
		Part.Transparency = 0
		Part.CanCollide = true
	end
end

function Floor:initPlayer(Player) end	--so main script doesn't break

function Floor:init(Map)
	setVariables(Map)
	wait(2)
	YeahSound:Play()
	wait(2)
	YeahSound.Volume = 0.2
	YeahSound:Play()
	wait(2)
	YeahSound.Volume = 0.5
	YeahSound:Play()
	wait(2)
	Smoke.Enabled = true
	local Anim = KoolAidMan.Humanoid:LoadAnimation(RunAnim)
	Anim:Play()
	BreakSound:Play()
	YeahSound.Volume = 1
	YeahSound:Play()
	Elevator:hideWall("Right", true)
	Elevator:hideRailing("Right", true)
	showBrokenWall("Right", true)
	wait(1)
	Smoke.Enabled = false
	wait(1.5)
	Smoke2.Enabled = true
	BreakSound:Play()
	Elevator:hideWall("Left", true)
	Elevator:hideRailing("Left", true)
	showBrokenWall("Left", true)
	wait(1.5)
	Smoke2.Enabled = false
	Elevator:changeLightProperties({Material = Enum.Material.SmoothPlastic, BrickColor = BrickColor.new("Really black")}, {Color = Color3.new(0,0,0)})
	KoolAidMan:Destroy()
	Elevator:hideWall("Right", false)
	Elevator:hideWall("Left", false)
	Elevator:hideRailing("Right", false)
	Elevator:hideRailing("Left", false)
	showBrokenWall("Right", false)
	showBrokenWall("Left", false)
end


return Floor