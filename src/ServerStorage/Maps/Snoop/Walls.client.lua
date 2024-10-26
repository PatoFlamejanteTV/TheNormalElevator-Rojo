local FRAME_SIZE = Vector2.new(200,200)
local PIXEL_SIZE = 10
local SCALE = 64
local SPEED = 1
local UPDATE_RATE = 0.1

local peens = {}
 
function HSVtoRGB(h, s, v)
	h = (h % 1) * 6
	local f = h % 1
	local p = v * (1 - s)
	local q = v * (1 - s * f)
	local t = v * (1 - s * (1 - f))
	if h < 1 then
		return v, t, p
	elseif h < 2 then
		return q, v, p
	elseif h < 3 then
		return p, v, t
	elseif h < 4 then
		return p, q, v
	elseif h < 5 then
		return t, p, v
	else
		return v, p, q
	end
end
 
function CreateRaster(frame_size, pixel_size)
	assert(pixel_size % 1 == 0, "pixel size must be an integer")
	assert(frame_size.X % pixel_size == 0 and frame_size.Y % pixel_size == 0, "frame size must be a multiple of pixel size")
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, frame_size.X, 0, frame_size.Y)
	frame.BackgroundTransparency = 1
	local pixels = {}
	local pixel_index = 1
	for x = 0, frame_size.X - 1, pixel_size do
		for y = 0, frame_size.Y - 1, pixel_size do
			local pixel_frame = Instance.new("Frame", frame)
			pixel_frame.BorderSizePixel = 0
			pixel_frame.Position = UDim2.new(0, x, 0, y)
			pixel_frame.Size = UDim2.new(0, pixel_size, 0, pixel_size)
			pixel_frame.BackgroundTransparency = 0.5
			pixels[pixel_index], pixel_index = pixel_frame, pixel_index + 1
		end
	end
	return frame, pixels
end
 
function UpdateNoiseRaster(pixels, frame_size, pixel_size, scale, seed_offset, depth)
	local pixel_index, pixel_frame = 1
	for x = 0, frame_size.X - 1, pixel_size do
		for y = 0, frame_size.Y - 1, pixel_size do
			pixel_frame, pixel_index = pixels[pixel_index], pixel_index + 1
			-- This is where the noise value is computed.
			-- The division by scale is to stretch the pattern out.
			-- The addition of 0.5 * pixel_size is not really necessary since seed_offset randomises it anyway, but puts the coordinate in the middle of the pixel.
			-- The addition of seed_offset is to make it display a random section of the simplex noise plane.
			-- depth is the time factor that causes it to be animated.
			local value = math.noise(x / scale + 0.5 * pixel_size + seed_offset.X, y / scale + 0.5 * pixel_size + seed_offset.Y, depth)
			pixel_frame.BackgroundColor3 = Color3.new(HSVtoRGB(0.5 + value, 1, 1))
		end
	end
end
 
local seed_offset = Vector2.new(65536 * (math.random() - 0.5), 65536 * (math.random() - 0.5))
local depth = 0
local raster, pixels = script.Parent:FindFirstChild("NoiseRaster")
if raster then
	raster:Destroy()
end
for _, part in pairs(game.Workspace.Background:GetChildren()) do
	raster, pixels = CreateRaster(FRAME_SIZE, PIXEL_SIZE)
	peens[#peens+1] = pixels
	raster.BorderColor3 = Color3.new(0, 0, 0)
	raster.BorderSizePixel = 0
	raster.Name = "NoiseRaster"
	raster.Position = UDim2.new(0.5, -0.5 * FRAME_SIZE.X, 0.5, -0.5 * FRAME_SIZE.Y) -- place in center
	local Gui = part.Screen:Clone()
	Gui.Parent = part
	Gui.Name = "Fake"
	Gui.Frame:Destroy()
	Gui.Enabled = true
	raster.Parent = Gui
end

while true do
	for _, peen in pairs(peens) do
		UpdateNoiseRaster(peen, FRAME_SIZE, PIXEL_SIZE, SCALE, seed_offset, depth)
	end
	depth = depth + SPEED * Wait(UPDATE_RATE)
end