while true do
wait()
if script.Parent.Enabled ~= true then
script.Parent.Parent.Point.Enabled = false
elseif script.Parent.Enabled == true then
script.Parent.Parent.Point.Enabled = true
end
end
