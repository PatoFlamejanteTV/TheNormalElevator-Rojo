local Elevator = {}

Elevator.Model = game.Workspace:FindFirstChild("Elevator")
Elevator.Map = game.Workspace:FindFirstChild("Map")
Elevator.Background = game.Workspace:FindFirstChild("Background")

function Elevator:toggleFakeDoor(collide)
	if (Elevator.Model) then
		Elevator.Model.FakeDoor.CanCollide = collide
	end
end

return Elevator