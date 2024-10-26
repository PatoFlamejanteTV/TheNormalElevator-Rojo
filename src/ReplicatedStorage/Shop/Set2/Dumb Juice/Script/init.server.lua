local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local activated = false

local BAV
local Connection
local drinking = false

Tool.Activated:Connect(function()
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Head = Character:FindFirstChild("Head")
	--local Functions = _G.Modules:Load("Functions")
	
	if (not drinking) and (not activated) and (Character) and (Head) then
		if (Humanoid) then
			if (Connection) then Connection:Disconnect() end
			Connection = Humanoid.Died:Connect(function()
				if (BAV) then
					BAV:Destroy()
				end
				local Ragdoll = Character:FindFirstChild("RagdollScript")
				if (Ragdoll) then
					Ragdoll.Activate.Value = false
				end
			end)
			drinking = true
			local fakeHandle = Handle:Clone()
			fakeHandle.Parent = Character
			Handle.Transparency = 1
			local fakeWeld = Instance.new("Weld", fakeHandle)
			fakeWeld.Part0 = Head
			fakeWeld.Part1 = fakeHandle
			--fakeWeld.C0 = CFrame.new(0,Head.Mesh.Offset.Y-1,-Head.Mesh.Scale.X)*CFrame.Angles(0,-math.pi/2,0)
			Handle.Drink:Play()
			wait(0.8)
			Handle.Drink:Stop()
			fakeHandle:Destroy()
			drinking = false
			activated = true
			Handle.Transparency = 0
			BAV = Instance.new("BodyAngularVelocity", Head)
			local Ragdoll = Character:FindFirstChild("RagdollScript")
			if (not Ragdoll) then
				Ragdoll = script.RagdollScript:Clone()
				Ragdoll.Parent = Character
				Ragdoll.Disabled = false
			end
			Ragdoll.Activate.Value = true
			while (activated) do
				BAV.AngularVelocity = Vector3.new(Humanoid.MoveDirection.Z * 16, 0, Humanoid.MoveDirection.X * -16)
				BAV.MaxTorque = Vector3.new(4000,4000,4000)
				
				if (Humanoid.MoveDirection == Vector3.new(0,0,0)) then
					BAV.MaxTorque = Vector3.new()
				end
				
				wait()
			end
		end
	else
		activated = false
		if (BAV) then
			BAV:Destroy()
		end
		local Ragdoll = Character:FindFirstChild("RagdollScript")
		if (Ragdoll) then
			Ragdoll.Activate.Value = false
		end
		--local Client = _G.Local:Load("Client")
		--Client.Juiced = false
	end
	
end)