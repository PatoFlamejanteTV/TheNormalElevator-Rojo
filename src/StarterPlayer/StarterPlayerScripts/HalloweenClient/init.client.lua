local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local candyCollected = ReplicatedStorage.Halloween.CandyCollected
local bossEffect = ReplicatedStorage.Halloween.BossEffect
local tweenModel = require(ReplicatedStorage.TweenModel)
local globals = require(ReplicatedStorage.Halloween.HalloweenGlobals)
local CameraShaker = require(script.CameraShaker)

local player = game:GetService("Players").LocalPlayer
local candyGui = player.PlayerGui:WaitForChild("CandyGui")
local bossGui = player.PlayerGui:WaitForChild("BossGui")

local candyColors = globals.candyColors
local candyTI = TweenInfo.new(0.56, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local imgTI = TweenInfo.new(0.56, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)


candyCollected.OnClientEvent:Connect(function(model)
	local sound = script.Collect:Clone()
	sound.Parent=player
	sound.PlayOnRemove=true
	sound:Destroy()
	
	CollectionService:RemoveTag(model, "Candy")
	
	local candyName = model.Name
	local candyImg = candyGui.Candy:Clone()
	local l = candyName:len()
	local c, e = candyName:sub(1, l-5), candyName:sub(l-4, l)
	local matImage = if (e=="Candy") then globals.itemImages[e] else globals.itemImages[candyName]
	local color = if (e=="Candy") then candyColors[c] else Color3.new(1,1,1)
	
	candyImg.Image=matImage
	candyImg.ImageColor3=color
	candyImg.Size=UDim2.fromScale(0.25,0.25)
	candyImg.SizeConstraint=Enum.SizeConstraint.RelativeYY
	candyImg.AnchorPoint=Vector2.new(1,1)
	candyImg.Position=UDim2.new(1,-5,0.5,-5)
	candyImg.Rotation=0
	candyImg.Visible=true
	candyImg.Parent = candyGui
	
	task.spawn(function()
		--[[
		for i = 1, 4 do
			candyImg.Rotation=-candyImg.Rotation
			task.wait(0.08)
		end]]
		
		candyImg.Rotation=0
		local t = TweenService:Create(candyImg, imgTI, {Size=UDim2.fromScale(0.02,0.02), Position=UDim2.fromOffset(candyGui.Pumpkin.AbsolutePosition.X+candyGui.Pumpkin.AbsoluteSize.X/2, candyGui.Pumpkin.AbsolutePosition.Y+candyGui.Pumpkin.AbsoluteSize.Y/2)})
		t:Play()
		t.Completed:Wait()
		candyImg:Destroy()
		candyGui.Pumpkin.Rotation=15
		task.wait(0.09)
		candyGui.Pumpkin.Rotation=-15
		task.wait(0.09)
		candyGui.Pumpkin.Rotation=0
		
	end)
	
	
	
	local scaleV = Instance.new("NumberValue")
	scaleV.Value=1
	
	local ogcf = model:GetPivot()
	local t=0
	
	local scaleConn = RunService.RenderStepped:Connect(function(dt)
		t=math.min(t+dt,candyTI.Time)
		--print(t)
		model:ScaleTo(scaleV.Value)
		model:PivotTo(ogcf:Lerp(player.Character.PrimaryPart.CFrame, t/candyTI.Time))
	end)
	
	TweenService:Create(scaleV, candyTI, {Value=0.05}):Play()
	task.wait(candyTI.Time)
	for _, p in (model:GetChildren()) do
		p.LocalTransparencyModifier=1
	end
	--model.PrimaryPart.LocalTransparencyModifier=1
	model.PrimaryPart.Effects:Destroy()
	scaleConn:Disconnect()
	scaleConn=nil
end)

local function updatePlayersAlive()
	--bossGui.Enabled=true
end

local soulList = {}
local soulIdle = {}
local spinSpeed=360*4
local soulPart

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCFrame
end)

bossEffect.OnClientEvent:Connect(function(...)
	local args = {...}
	if (args[1]=="TrackSoul") then
		local soul = args[2]
		local num = args[3]
		local map = args[4]
		
		local att = soulPart["S"..num]
		
		for i = 1, 62 do
			soul.CFrame = soul.CFrame:Lerp(att.WorldCFrame, i/62)
			task.wait(0.03)
		end
		
		local btm
		soulList[soul] = att
		print"spinfaster"
		--spinSpeed=360*5
		task.wait(1.8)
		soulList[soul] = nil
		soulIdle[soul]=att
		local hideCF = map.Drop.CFrame
		task.spawn(function()
			for i = 1, 200 do
				soul.CFrame = soul.CFrame:Lerp(hideCF, i/200)
				task.wait(0.02)
			end
		end)
		task.wait(3.7)
		hideCF = map.Tunnel.Shadow.CFrame*CFrame.new(0,2,0)
		--task.wait(3)
		--spinSpeed=360
		
		
	elseif(args[1]=="Init") then
		updatePlayersAlive()
		
		local map = args[2]
		soulPart=map.Souls:Clone()
		soulPart.Name="ClientSouls"
		soulPart.Parent = map
		
	elseif (args[1]=="Rumble") then
		print"go"
		local shakeInstance = camShake:ShakeSustain(CameraShaker.Presets.Earthquake)
		task.wait(2)
		shakeInstance:StartFadeOut(1)
		print"stop"
	end
end)

RunService.RenderStepped:Connect(function(dt)
	for _, candy in (CollectionService:GetTagged("Candy")) do
		--candy.PrimaryPart.CFrame*=CFrame.Angles(0,math.rad(2*dt))
		candy:PivotTo(candy:GetPivot()*CFrame.new(0,(math.sin(os.clock()*2)*dt)/2,0)*CFrame.Angles(0,math.rad(50*dt),0))
	end
	
	if (soulPart) then
		soulPart.CFrame*=CFrame.Angles(0,spinSpeed/180*dt,0)
	end
	
	for soul, trackAtt in (soulList) do
		soul.CFrame=trackAtt.WorldCFrame
	end
end)