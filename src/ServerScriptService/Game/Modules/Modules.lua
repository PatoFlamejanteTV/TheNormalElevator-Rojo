local MyModules = {"Data", "Functions", "Elevator", "Lobby", "Network"}

local Modules = {}

function Modules:Load(modName)
	if (Modules[modName]) then return Modules[modName] end
	local ModuleScript = script.Parent:FindFirstChild(modName)
	local NewModule = require(ModuleScript)
	Modules[modName] = NewModule
	ModuleScript:Destroy()
	return Modules[modName]
end

function Modules:LoadAll()
	for _, Mod in pairs(MyModules) do
		Modules:Load(Mod)
	end
end

return Modules