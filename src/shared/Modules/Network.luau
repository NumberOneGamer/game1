--!strict

-- Networking abstraction layer
-- Provides typed RemoteEvent/RemoteFunction wrappers with validation

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Network = {}
Network.__index = Network

local REMOTE_FOLDER_NAME = "NetworkRemotes"
local remoteFolder: Instance? = nil

type MiddlewareFn = (player: Player, ... any) -> (boolean, ... any)
type NetworkEvent = {
	id: string,
	remote: RemoteEvent,
	middleware: { MiddlewareFn },
}
type NetworkFunction = {
	id: string,
	remote: RemoteFunction,
	middleware: { MiddlewareFn },
}

local events: { [string]: NetworkEvent } = {}
local functions: { [string]: NetworkFunction } = {}

local function getRemoteFolder(): Instance
	if not remoteFolder then
		remoteFolder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
		if not remoteFolder then
			remoteFolder = Instance.new("Folder")
			remoteFolder.Name = REMOTE_FOLDER_NAME
			remoteFolder.Parent = ReplicatedStorage
		end
	end
	return remoteFolder :: Instance
end

local function runMiddleware(middleware: { MiddlewareFn }, player: Player, ...: any): (boolean, ... any)
	local args = { ... }
	for _, fn in middleware do
		local ok, result = fn(player, table.unpack(args))
		if not ok then
			return false, result
		end
		args = { result }
	end
	return true, table.unpack(args)
end

function Network.createEvent(eventId: string): ()
	local folder = getRemoteFolder()
	local existing = folder:FindFirstChild(eventId)
	if existing then
		return
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = eventId
	remote.Parent = folder
	events[eventId] = {
		id = eventId,
		remote = remote,
		middleware = {},
	}
end

function Network.createFunction(functionId: string): ()
	local folder = getRemoteFolder()
	local existing = folder:FindFirstChild(functionId)
	if existing then
		return
	end
	local remote = Instance.new("RemoteFunction")
	remote.Name = functionId
	remote.Parent = folder
	functions[functionId] = {
		id = functionId,
		remote = remote,
		middleware = {},
	}
end

function Network.addEventMiddleware(eventId: string, fn: MiddlewareFn): ()
	local event = events[eventId]
	if event then
		table.insert(event.middleware, fn)
	end
end

function Network.addFunctionMiddleware(functionId: string, fn: MiddlewareFn): ()
	local fnObj = functions[functionId]
	if fnObj then
		table.insert(fnObj.middleware, fn)
	end
end

function Network.onEvent(eventId: string, callback: (Player, ... any) -> ()): ()
	local event = events[eventId]
	if not event then
		error(("Network event '%s' not created"):format(eventId))
	end
	event.remote.OnServerEvent:Connect(function(player: Player, ...: any)
		local ok, args = runMiddleware(event.middleware, player, ...)
		if ok then
			callback(player, table.unpack(args))
		end
	end)
end

function Network.onFunction(functionId: string, callback: (Player, ... any) -> any): ()
	local fnObj = functions[functionId]
	if not fnObj then
		error(("Network function '%s' not created"):format(functionId))
	end
	fnObj.remote.OnServerInvoke = function(player: Player, ...: any): any
		local ok, args = runMiddleware(fnObj.middleware, player, ...)
		if ok then
			return callback(player, table.unpack(args))
		end
		return nil
	end
end

function Network.fireClient(player: Player, eventId: string, ...: any): ()
	local event = events[eventId]
	if not event then
		error(("Network event '%s' not created"):format(eventId))
	end
	event.remote:FireClient(player, ...)
end

function Network.fireAllClients(eventId: string, ...: any): ()
	local event = events[eventId]
	if not event then
		error(("Network event '%s' not created"):format(eventId))
	end
	event.remote:FireAllClients(...)
end

function Network.fireAllClientsExcept(player: Player, eventId: string, ...: any): ()
	local event = events[eventId]
	if not event then
		error(("Network event '%s' not created"):format(eventId))
	end
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer ~= player then
			event.remote:FireClient(otherPlayer, ...)
		end
	end
end

function Network.invokeClient(player: Player, functionId: string, ...: any): any
	local fnObj = functions[functionId]
	if not fnObj then
		error(("Network function '%s' not created"):format(functionId))
	end
	return fnObj.remote:InvokeClient(player, ...)
end

-- Client-side API
function Network.onClientEvent(eventId: string, callback: (... any) -> ()): ()
	local folder = getRemoteFolder()
	local remote = folder:FindFirstChild(eventId)
	if not remote or not remote:IsA("RemoteEvent") then
		error(("Network event '%s' not found"):format(eventId))
	end
	remote.OnClientEvent:Connect(function(...: any)
		callback(...)
	end)
end

function Network.invokeServer(functionId: string, ...: any): any
	local folder = getRemoteFolder()
	local remote = folder:FindFirstChild(functionId)
	if not remote or not remote:IsA("RemoteFunction") then
		error(("Network function '%s' not found"):format(functionId))
	end
	return remote:InvokeServer(...)
end

function Network.fireServer(eventId: string, ...: any): ()
	local folder = getRemoteFolder()
	local remote = folder:FindFirstChild(eventId)
	if not remote or not remote:IsA("RemoteEvent") then
		error(("Network event '%s' not found"):format(eventId))
	end
	remote:FireServer(...)
end

function Network.getEvent(eventId: string): RemoteEvent?
	local folder = getRemoteFolder()
	return folder:FindFirstChild(eventId) :: RemoteEvent?
end

function Network.getFunction(functionId: string): RemoteFunction?
	local folder = getRemoteFolder()
	return folder:FindFirstChild(functionId) :: RemoteFunction?
end

-- Rate limiting middleware factory
function Network.rateLimit(maxCalls: number, window: number): MiddlewareFn
	local callCounts: { [Player]: { number, number } } = {}
	return function(player: Player, ...: any): (boolean, ... any)
		local now = os.clock()
		local entry = callCounts[player]
		if not entry then
			callCounts[player] = { 1, now }
			return true, ...
		end
		local count = entry[1]
		local startTime = entry[2]
		if now - startTime > window then
			callCounts[player] = { 1, now }
			return true, ...
		end
		count += 1
		entry[1] = count
		if count > maxCalls then
			return false, ("Rate limited: max %d calls per %d seconds"):format(maxCalls, window)
		end
		return true, ...
	end
end

-- Validation middleware factory
function Network.validate(schema: (any) -> boolean): MiddlewareFn
	return function(player: Player, ...: any): (boolean, ... any)
		for _, arg in { ... } do
			if not schema(arg) then
				return false, "Validation failed"
			end
		end
		return true, ...
	end
end

return Network
