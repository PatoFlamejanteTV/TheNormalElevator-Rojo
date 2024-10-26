
function touch(hit)
	if (hit.Name ~= "HumanoidRootPart") then
		local npc=hit.Parent:FindFirstChild("NPC")
		local human=hit.Parent:FindFirstChild("Humanoid")
		if human then
			human.Health=0
		elseif npc then
			npc.Health=0
		end
	end
end

script.Parent.Touched:connect(touch)