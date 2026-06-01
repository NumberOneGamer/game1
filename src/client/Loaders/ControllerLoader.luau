--!strict

-- Automatic Controller Loader
-- Finds all Controllers, requires them, and calls Init/Start in order

local ControllerLoader = {}

type ControllerDefinition = {
	Init: (self: any) -> (),
	Start: (self: any) -> (),
	[any]: any,
}

local CONTROLLER_PATTERN = "Controller"

function ControllerLoader:getControllerList(): { string }
	local controllers = script.Parent.Parent.Controllers:GetChildren()
	local names: { string } = {}
	for _, child in controllers do
		if child:IsA("ModuleScript") and child.Name:match(CONTROLLER_PATTERN) then
			table.insert(names, child.Name)
		end
	end
	table.sort(names)
	return names
end

function ControllerLoader:resolveDependencies(name: string): { string }
	local deps: { string } = {}
	local module = script.Parent.Parent.Controllers:FindFirstChild(name)
	if not module or not module:IsA("ModuleScript") then
		return deps
	end
	local env = require(module)
	for _, child in script.Parent.Parent.Controllers:GetChildren() do
		if child:IsA("ModuleScript") and child.Name ~= name then
			local depModule = require(child)
			for key, value in depModule do
				if value == env then
					table.insert(deps, child.Name)
					break
				end
			end
		end
	end
	return deps
end

function ControllerLoader:topologicalSort(names: { string }): { string }
	local sorted: { string } = {}
	local visited: { [string]: boolean } = {}
	local temp: { [string]: boolean } = {}
	local function visit(name: string)
		if temp[name] then
			return
		end
		if not visited[name] then
			temp[name] = true
			for _, dep in self:resolveDependencies(name) do
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

function ControllerLoader:loadAll(): ()
	local names = self:getControllerList()
	local loaded: { [string]: any } = {}
	for _, name in names do
		local module = require(script.Parent.Parent.Controllers[name])
		local controller = if type(module) == "table" and module.Init then module else module.new()
		loaded[name] = controller
	end
	local initOrder = self:topologicalSort(names)
	for _, name in initOrder do
		local controller = loaded[name]
		if controller and controller.Init then
			local success, err = pcall(function()
				controller:Init()
			end)
			if not success then
				warn(("Controller %s Init failed: %s"):format(name, tostring(err)))
			end
		end
	end
	for _, name in initOrder do
		local controller = loaded[name]
		if controller and controller.Start then
			local success, err = pcall(function()
				controller:Start()
			end)
			if not success then
				warn(("Controller %s Start failed: %s"):format(name, tostring(err)))
			end
		end
	end
	print(("[ControllerLoader] Loaded %d controllers"):format(#names))
end

return ControllerLoader
