local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local BiteAnim = Tool:WaitForChild("Bite")
local Track

local Debounce = true


Tool.Activated:connect(function()
	local Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	
	if (Character) and (Humanoid) then
		if (Debounce == true) then
			Debounce = false
			
			Track = Track or Humanoid:LoadAnimation(BiteAnim)
			if (Track) then
				Track:Play()
				wait(0.9)
				local AllBanana = true --check to see if character is already banana'd out
				for _, Part in pairs(Character:GetChildren()) do
					if (Part:IsA("MeshPart")) and (string.sub(Part.Name, 1, 6) ~= "Banana") and (Character:FindFirstChild("Banana"..Part.Name) == nil) then
						AllBanana = false
					end
				end
				
				if (not AllBanana) then
					
					local CharacterPart = (Character:GetChildren()[math.random(1, #Character:GetChildren())])
					repeat
						CharacterPart = (Character:GetChildren()[math.random(1, #Character:GetChildren())])
					until CharacterPart:IsA("MeshPart") and (string.sub(CharacterPart.Name, 1, 6) ~= "Banana") and (Character:FindFirstChild("Banana"..CharacterPart.Name) == nil)
					
					local NewBanana = Handle:Clone()
					NewBanana.Parent = Character
					NewBanana.Name = "Banana"..CharacterPart.Name
					NewBanana.Size = CharacterPart.Size
					
					local NewWeld = Instance.new("Weld", CharacterPart)
					NewWeld.Part0 = CharacterPart
					NewWeld.Part1 = NewBanana
					
					CharacterPart.Transparency = 1
				end
			end
			
			
			Debounce = true
		end
	end
	
	
end)