local Functions = _G.Modules:Load("Functions")
local Network = _G.Modules:Load("Network")
local Elevator = _G.Modules:Load("Elevator")

local Floor = {}

Floor.Model = nil

Floor.Settings = {
	DOORS_OPEN = true,
	INTERACTIVE = false,
	TIME = 18 --seconds
}


function Floor:initPlayer(Player)
	--Network:Send(Player, "ChangeMusicProperties", {{Music = Floor.Music, Properties = Floor.MusicProperties}})
	Network:Send(Player, "LoadLighting", {Sky = Floor.Skybox})
	local Handler = Floor.Model.LocalHandler:Clone()
	Handler.Parent = Player.Backpack
	Handler.Disabled = false
end

function Floor:init(Map)
	Floor.Model = Map
	Elevator:enableSkybox(Floor.Skybox)
	for _, Player in pairs(Elevator.Players) do
		Floor:initPlayer(Player)
	end
	Floor.Sounds.Music:Play()
	
	Elevator:changeLightProperties({BrickColor = BrickColor.new("Medium blue")},{Color = Color3.new(30/255, 60/255, 125/255)})
	wait(Floor.Settings.TIME)
	for _, Player in pairs(Elevator.Players) do
		local Handler = Player.Backpack:FindFirstChild("LocalHandler")
		if (Handler) then
			Handler.Disabled = true
			Handler:Destroy()
		end
	end
	Floor.Sounds.Music:Stop()
end

return Floor