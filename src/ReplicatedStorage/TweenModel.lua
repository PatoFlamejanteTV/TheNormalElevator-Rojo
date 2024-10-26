local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--TweenService only works on 1 part at a time, so to make this work for models...
--we take 1 part (trackPart), tween that and use model:SetPrimaryPartCFrame to follow that part every render step
--model MUST HAVE a primary part that's the same properties as the trackPart
local function TweenModel(model, endCFrame, modelTweenInfo)
	local primaryPart = model.PrimaryPart
	if (primaryPart==nil) then return end
	if (not primaryPart:IsA("BasePart")) then return end
	
	local trackPart = Instance.new(primaryPart.ClassName)
	trackPart.Anchored=true
	trackPart.Size = primaryPart.Size
	trackPart.CFrame = primaryPart.CFrame
	trackPart.CanCollide = false
	trackPart.CanTouch = false
	trackPart.Transparency = 1
	trackPart.Name = model.Name.."TrackerPart"
	trackPart.Parent = model.Parent
	
	local modelTween = TweenService:Create(trackPart, modelTweenInfo, {CFrame=endCFrame})
	local modelConn = RunService.Stepped:Connect(function()
		model:PivotTo(trackPart.CFrame)
	end)
	
	modelTween:Play()
	modelTween.Completed:Wait()
	modelConn:Disconnect()
	modelConn=nil
	
	model:PivotTo(endCFrame)
	trackPart:Destroy()
end

return TweenModel