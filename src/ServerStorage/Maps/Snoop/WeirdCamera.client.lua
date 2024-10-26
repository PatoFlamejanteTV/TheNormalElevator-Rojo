local plr=game.Players.LocalPlayer
local cam=game.Workspace.CurrentCamera
local distort=1

local randomDes1 = math.random(1,1000)
local randomDes2 = math.random(1,1000)

local r1 = math.random(1,1000)
local r2 = math.random(1,1000)

local add = 1

local t1, t2 = false, false

game:GetService("RunService").RenderStepped:connect(function()
	
	if (not t1) then
		t1 = true
		randomDes1 = math.random(1,1000)
		--print(1, randomDes1)
	end
	
	if (not t2) then
		t2 = true
		randomDes2 = math.random(1,1000)
		--print(2, randomDes2)
	end
	
	if (r1 < randomDes1) then
		r1 = r1+add
	elseif (r1 > randomDes1) then
		r1 = r1-add
	elseif (r1 == randomDes1) then
		t1 = false
	end
	
	if (r2 < randomDes2) then
		r2 = r2+add
	elseif (r2 > randomDes2) then
		r2 = r2-add
	elseif (r2 == randomDes2) then
		t2 = false
	end
	
	--print("first:", r1, "goal:", randomDes1)
	--print(r1 == randomDes1)
	--print("second:", r2, "goal:", randomDes2)
	
	
		cam.CoordinateFrame=cam.CoordinateFrame
		*CFrame.new(0,0,0,r1/1000,0,0,0,r2/1000,0,0,0,1)

end)
