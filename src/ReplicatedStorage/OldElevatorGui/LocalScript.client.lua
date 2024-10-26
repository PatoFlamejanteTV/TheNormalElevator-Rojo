local Gui = script.Parent
local Frame = Gui:WaitForChild("Frame")
local Go = Frame:WaitForChild("Go")
local Cancel = Frame:WaitForChild("Cancel")

local Lobby = _G.Local:Load("Lobby")

Go.MouseButton1Down:Connect(function()
	Lobby.OldDoorOpen = true
	Lobby.Model.OldElevatorDoor.Door:SetPrimaryPartCFrame(Lobby.Model.OldElevatorDoor.Door.PrimaryPart.CFrame * CFrame.Angles(0,math.pi/2,0))
	Gui:Destroy()
end)

Cancel.MouseButton1Down:Connect(function()
	Gui:Destroy()
end)