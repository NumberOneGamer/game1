--!strict

-- Automatic Service Loader
-- Finds all Services, requires them, and calls Init/Start in order

local ServiceLoader = {}

type ServiceDefinition = {
	Init: (self: any) -> (),
	Start: (self: any) -> (),
	[any]: any,
}

local SERVICE_PATTERN = "Service"

function ServiceLoader:getServiceList(): { string }
	local services = script.Parent.Parent.Services:GetChildren()
	local serviceNames: { string } = {}
	for _, child in services do
		if child:IsA("ModuleScript") and child.Name:match(SERVICE_PATTERN) then
			table.insert(serviceNames, child.Name)
		end
	end
	table.sort(serviceNames)
	return serviceNames
end

function ServiceLoader:resolveDependencies(serviceName: string): { string }
	local deps: { string } = {}
	local serviceModule = script.Parent.Parent.Services:FindFirstChild(serviceName)
	if not serviceModule or not serviceModule:IsA("ModuleScript") then
		return deps
	end
	local moduleEnv = require(serviceModule)
	for _, child in script.Parent.Parent.Services:GetChildren() do
		if child:IsA("ModuleScript") and child.Name ~= serviceName then
			local depModule = require(child)
			for key, value in depModule do
				if value == moduleEnv then
					table.insert(deps, child.Name)
					break
				end
			end
		end
	end
	return deps
end

function ServiceLoader:loadAll(): ()
	local serviceNames = self:getServiceList()
	local loaded: { [string]: any } = {}
	for _, name in serviceNames do
		local module = require(script.Parent.Parent.Services[name])
		local service = if type(module) == "table" and module.Init then module else module.new()
		loaded[name] = service
	end
	local initOrder = self:topologicalSort(serviceNames)
	for _, name in initOrder do
		local service = loaded[name]
		if service and service.Init then
			local success, err = pcall(function()
				service:Init()
			end)
			if not success then
				warn(("Service %s Init failed: %s"):format(name, tostring(err)))
			end
		end
	end
	for _, name in initOrder do
		local service = loaded[name]
		if service and service.Start then
			local success, err = pcall(function()
				service:Start()
			end)
			if not success then
				warn(("Service %s Start failed: %s"):format(name, tostring(err)))
			end
		end
	end
	print(("[ServiceLoader] Loaded %d services"):format(#serviceNames))
end

function ServiceLoader:topologicalSort(names: { string }): { string }
	local sorted: { string } = {}
	local visited: { [string]: boolean } = {}
	local temp: { [string]: boolean } = {}
	local function visit(name: string)
		if temp[name] then
			return
		end
		if not visited[name] then
			temp[name] = true
			local deps = self:resolveDependencies(name)
			for _, dep in deps do
				visit(dep)
			end
			temp[name] = nil
			visited[name] = true
			table.insert(sorted, name)
		end
	end
	for _, name in names do
		if not visited[name] then
			visit(name)
		end
	end
	return sorted
end

return ServiceLoader
