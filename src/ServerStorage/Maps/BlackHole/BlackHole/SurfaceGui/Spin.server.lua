local img=script.Parent.Img
local part=script.Parent.Parent
while true do img.Rotation=img.Rotation+0.5 wait() part.Size = part.Size + Vector3.new(0.1,0.1,0) part.CFrame = part.CFrame * CFrame.new(0,0,-0.145) end