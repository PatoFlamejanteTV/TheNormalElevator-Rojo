function touch(hit)
	if (hit.Parent) then
		local human=hit.Parent:FindFirstChild("Humanoid")
		if human then
			human.Health=0
		end
	end
end

script.Parent.Touched:connect(touch)