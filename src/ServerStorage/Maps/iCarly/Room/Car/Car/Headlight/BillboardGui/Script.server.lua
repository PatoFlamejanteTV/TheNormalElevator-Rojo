b = script.Parent

local oh,om = 6	-- Open Time (hours,minutes)
local ch,cm = 18  -- Close Time (hours, minutes)

local l = game:service("Lighting")
if (om == nil) then om = 0 end
if (cm == nil) then cm = 0 end


function TimeChanged()
	local ot = (oh + (om/60)) * 60
	local ct = (ch + (cm/60)) * 60
	if (ot < ct) then
		if (l:GetMinutesAfterMidnight() >= ot) and (l:GetMinutesAfterMidnight() <= ct) then
b.Enabled = false
		else
b.Enabled = true
		end
	elseif (ot > ct) then
		if (l:GetMinutesAfterMidnight() >= ot) or (l:GetMinutesAfterMidnight() <= ct) then
b.Enabled = false
		else
b.Enabled = true
		end
	end
end

TimeChanged()
game.Lighting.Changed:connect(function(property)
			if (property == "TimeOfDay") then
				TimeChanged()
			end
		end)

-- Ganondude