local TS = game:GetService("TweenService")

local Lighting = {}

Lighting.Lobby = {
	Bloom = {Enabled = 0, Intensity = 0,Size = 0,Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0, Enabled = false},
	Rays = {Intensity = 0,Spread = 0, Enabled = false},
	Blur = {Size = 0, Enabled = false},
	Lighting = {Ambient = Color3.new(0,0,0), OutdoorAmbient=Color3.new(0,0,0), ColorShift_Bottom=Color3.new(0,0,0), ColorShift_Top=Color3.new(0,0,0), Brightness=0, ClockTime=0, 
		FogColor=Color3.fromRGB(187, 172, 255), FogEnd=1000000000, FogStart= 0, GeographicLatitude=41.733, EnvironmentDiffuseScale = 0, EnvironmentSpecularScale = 0},
	Sky = nil
}

Lighting.Elevator = {
	Bloom = {Enabled = 0, Intensity = 0,Size = 0,Threshold = 0},
	Color = {Brightness = 0,Contrast = 0,TintColor = Color3.new(1,1,1),Saturation = 0,  Enabled = false},
	Rays = {Intensity = 0,Spread = 0, Enabled = false},
	Blur = {Size = 0, Enabled = false},
	Lighting = {Ambient = Color3.new(0,0,0), OutdoorAmbient=Color3.new(0,0,0), ColorShift_Bottom=Color3.new(0,0,0), ColorShift_Top=Color3.new(0,0,0), Brightness=0, ClockTime=0, 
		FogColor=Color3.new(0,0,0), FogStart= 0, FogEnd=1000000000, GeographicLatitude=41.733, EnvironmentDiffuseScale = 0, EnvironmentSpecularScale = 0},
	Sky = nil
}

Lighting.Instance = game.Lighting
Lighting.Bloom = game.Lighting.Bloom
Lighting.Blur = game.Lighting.Blur
Lighting.Color = game.Lighting.Color
Lighting.Rays = game.Lighting.Rays

local function removeSky()
	for _, skybox in pairs(Lighting.Instance:GetChildren()) do
		if (skybox:IsA("Sky")) then
			skybox:Destroy()
		end
	end
end

local function insertSky(sky)
	removeSky()
	local Sky = sky:Clone()
	Sky.Parent = Lighting.Instance
end

function Lighting:update(settings)
	if (settings == nil) then return end
	for ins, props in pairs(settings) do
		if (ins == "Sky") and (props) then
			insertSky(props)
		elseif (ins == "Sky") and (props == nil) then
			removeSky()
		else
			if (props) and (props.Enabled ~= nil) then
				Lighting[ins]["Enabled"] = props.Enabled
			end
			if (props) and (props["TweenTime"]) then
				local Goal = {}
				for i, v in pairs(props) do
					if (i ~= "Enabled") and (i~="TweenTime") then
						Goal[i] = v
					end
				end
				--if (Goal.Enabled) then Goal.Enabled = nil end
				--if (Goal.Tween) then Goal.Tween = nil end
				if (ins == "Lighting") then ins = "Instance" end
				local Tween = TS:Create(Lighting[ins], TweenInfo.new(props["TweenTime"]), Goal)
				Tween:Play()
			elseif (props) and (not props["TweenTime"]) then
				--print("no tween", ins)
				for prop, value in pairs(props) do
					if (prop ~= "TweenTime") then
						if (ins == "Lighting") then ins = "Instance" end
						if (prop == "Enabled") then
							Lighting[ins][prop] = value
						end
						if (Lighting[ins][prop]) then
							Lighting[ins][prop] = value
						end
					end
				end
			end
		end
	end	
end

function Lighting:init()
	Lighting:update(Lighting.Lobby)
end

return Lighting