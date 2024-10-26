local Network = {}

Network.Pass = nil
Network.Fetch = nil

local sendEvent = game.ReplicatedStorage:WaitForChild("Send")
local getFunction = game.ReplicatedStorage:WaitForChild("Get")

function Network:Send(...)
	sendEvent:FireServer(...)
end

function Network:Get(...)
	return getFunction:InvokeServer(...)
end

sendEvent.OnClientEvent:connect(function(...)
	if (not Network.Pass) then repeat wait() until Network.Pass end
	Network.Pass:Fire(...)
	
	--Weird bug when player first joins, here's hotfix for it
	local Client = _G.Local.Client
	if (... == "CharacterAdded") and (Client.CharacterAdded == false) then
		repeat Network.Pass:Fire(...) wait() until Client.CharacterAdded
	end
	
end)

getFunction.OnClientInvoke = function(...)
	if (not Network.Fetch) then repeat wait() until Network.Fetch end
	local Value = Network.Fetch:Invoke(...)
	return Value
end

return Network