for i = 1,8 do
	for i = 1,0,-.2 do
		script.Parent.SurfaceGui.ImageLabel.ImageTransparency = i
		wait()
	end
	
	for i = 0,1,.2 do
		script.Parent.SurfaceGui.ImageLabel.ImageTransparency = i
		wait()
	end
end

	for i = 1,0,-.2 do
		script.Parent.SurfaceGui.ImageLabel.ImageTransparency = i
		wait()
	end
	for y = 8.2,0.2,-.5 do
		script.Parent.Size = Vector3.new(18.4,y,.02)
		script.Parent.Position = Vector3.new(-2.143, 9.252, -39.852)
		wait()
	end
		for i = 0,1,.2 do
		script.Parent.SurfaceGui.ImageLabel.ImageTransparency = i
		wait()
	end