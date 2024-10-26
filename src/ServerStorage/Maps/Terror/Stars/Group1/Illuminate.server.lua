for j = 1,0,-0.005 do
local children = script.Parent:GetChildren()
for i = 1, #children do
	if children[i].Name == "Star" then
    children[i].Transparency = j
		end
	end
wait()
end
