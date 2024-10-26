--put this script inside the decal you want to change
--to find the decal texture, insert the decal you want on a brick. Look into the brick and click the decal. Scroll Down and it says texture.
--copy the url into the "insert texture here" spot
local Textures = {131395838, 131395847, 131395855, 131395860, 131395868, 131395884, 131395884, 131395891, 131395897, 131395901,
	131395946, 131395957, 131395966, 131395972, 131395979, 131395986, 131395989, 131395993, 131395997, 131396003, 131396007,
	131396012, 131396016, 131396019, 131396024, 131396029, 131396037, 131396042, 131396044, 131396046, 131396054, 131396063,
	131396068, 131396072, 131396078, 131396091, 131396098, 131396102, 131396108, 131396110, 131396113, 131396116, 131396121,
	131396125, 131396133, 131396137, 131396142, 131396146, 131396156, 131396162, 131396164, 131396169, 131396173, 131396176,
	131396181, 131396185, 131396188, 131396192
}

local Colors = {Color3.new(1,0,0), Color3.new(1,1,0), Color3.new(0,1,0)}

local Speed = 0.04
local colorSpeed = 30

spawn(function()
	while true do
		for i = 1, colorSpeed do
			script.Parent.Color3 = Color3.new(i/colorSpeed, 1-i/colorSpeed, 0)
			wait() 
		end
		for i = 1, colorSpeed do
			script.Parent.Color3 = Color3.new(1, i/colorSpeed, 0)
			wait() 
		end
		for i = 1, colorSpeed do
			script.Parent.Color3 = Color3.new(1-i/colorSpeed, 1, 0)
			wait() 
		end
	end
end)

while true do
	for i = 1, #Textures do
		script.Parent.Texture = "rbxassetid://"..Textures[i]
		wait(Speed)
	end
end

