local plr=game.Players.LocalPlayer
local cam=game.Workspace.CurrentCamera
local distort = Instance.new("NumberValue")
distort.Value = 1

local t = game:GetService("TweenService"):Create(distort, TweenInfo.new(20), {Value=0})
t:Play()

game:GetService("RunService").RenderStepped:connect(function(dt) 
	if (distort.Value > 0.001) then
		cam.CoordinateFrame=cam.CoordinateFrame
			*CFrame.new(0,0,0,distort.Value,0,0,0,distort.Value,0,0,0,1)
		--distort.Value = distort.Value - dt
	end
end)

t.Completed:Once(function()
	distort:Destroy()
end)