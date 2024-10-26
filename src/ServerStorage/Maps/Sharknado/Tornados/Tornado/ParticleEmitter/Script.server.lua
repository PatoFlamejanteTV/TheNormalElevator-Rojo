local speed = 2

while true do
	script.Parent.Acceleration = Vector3.new(0,0,speed)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(speed,0,speed)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(speed,0,0)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(0,0,0)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(-speed,0,0)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(-speed,0,-speed)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(0,0,-speed)
	wait(0.5)
	script.Parent.Acceleration = Vector3.new(0,0,0)
	wait(0.5)
end