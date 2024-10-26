local model = script.Parent
local grab = model.Grab
local reach = model.Reach
local bp = grab.BodyPosition

local grabbed = false

reach.Touched:connect(function(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent:FindFirstChild("NPC")
	if (not grabbed) and (humanoid) then
		grabbed = true
		grab.Transparency = 0
		reach.Transparency = 1
		humanoid.PlatformStand = true
		local char = hit.Parent
		local torso
		if (char:FindFirstChild("Humanoid")) then
			if (char.Humanoid.RigType == Enum.HumanoidRigType.R6) then
				torso = char.Torso
			else
				torso = char.LowerTorso
			end
		end
		local weld = Instance.new("Weld", grab)
		weld.Name = "PlayerWeld"
		weld.Part0 = grab
		weld.Part1 = torso
		weld.C0 = CFrame.new(0,0,0) * CFrame.Angles(math.pi/2,0, math.pi/2)
		wait(6)
		humanoid.Health = 0
	end
end)