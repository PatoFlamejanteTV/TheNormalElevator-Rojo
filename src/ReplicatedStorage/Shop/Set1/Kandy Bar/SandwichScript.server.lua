local Tool = script.Parent;

enabled = true




function onActivated()
	local char = Tool.Parent
	if not enabled  then
		return
	end

	enabled = false
	Tool.GripForward = Vector3.new(-0.976,0,-0.217)
	Tool.GripPos = Vector3.new(.95,-0.76,1.4)
	Tool.GripRight = Vector3.new(0.217,0, 0.976)
	Tool.GripUp = Vector3.new(0,1,0)
	
	Tool.Handle.EatSound:Play()
	
	script.Parent.Bites.Value = script.Parent.Bites.Value + 1
	wait(.8)
	
	if (Tool.Bites.Value == 3) then
		local hat = game.ReplicatedStorage.Hats.Glove:Clone()
		hat.Parent = char
		if (math.random(1,5)==5) then
			hat.Handle.Color = Color3.new(math.random(),math.random(),math.random())
		end
		hat.Handle.SpongeSound:Play()
		Tool:Destroy()
	end

	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripPos = Vector3.new(0,0,0)	
	Tool.GripUp = Vector3.new(1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)


	enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
