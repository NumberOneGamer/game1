--!strict

-- Reactive state management system
-- Provides observable values with automatic dependency tracking

local State = {}
State.__index = State

export type StateObject<T> = {
	Get: (self: StateObject<T>) -> T,
	Set: (self: StateObject<T>, value: T) -> (),
	OnChange: (self: StateObject<T>, callback: (T, T) -> ()) -> () -> (),
	Connect: (self: StateObject<T>, callback: (T) -> ()) -> () -> (),
	Destroy: (self: StateObject<T>) -> (),
	_value: T,
	_listeners: { { callback: (T, T) -> (), once: boolean } },
}

type Listener<T> = {
	callback: (T, T) -> (),
	once: boolean,
}

function State.new<T>(initialValue: T): StateObject<T>
	local self_obj: StateObject<T> = {
		_value = initialValue,
		_listeners = {},
	}
	self_obj.Get = function(self: StateObject<T>): T
		return self._value
	end
	self_obj.Set = function(self: StateObject<T>, value: T): ()
		if self._value == value then
			return
		end
		local oldValue = self._value
		self._value = value
		for _, listener in self._listeners do
			task.spawn(listener.callback, value, oldValue)
		end
	end
	self_obj.OnChange = function(self: StateObject<T>, callback: (T, T) -> ()): () -> ()
		local listener: Listener<T> = { callback = callback, once = false }
		table.insert(self._listeners, listener)
		return function()
			local idx = table.find(self._listeners, listener)
			if idx then
				table.remove(self._listeners, idx)
			end
		end
	end
	self_obj.Connect = function(self: StateObject<T>, callback: (T) -> ()): () -> ()
		callback(self._value)
		return self:OnChange(function(newValue, _)
			callback(newValue)
		end)
	end
	self_obj.Destroy = function(self: StateObject<T>): ()
		self._listeners = {}
	end
	return setmetatable(self_obj, State)
end

function State.derived<T>(deps: { StateObject<any> }, compute: () -> T): StateObject<T>
	local result = State.new(compute())
	local function recompute()
		result:Set(compute())
	end
	for _, dep in deps do
		dep:OnChange(function()
			recompute()
		end)
	end
	return result
end

function State.join<T>(states: { [string]: StateObject<any> }): StateObject<{ [string]: any }>
	local keys = {}
	for key, _ in states do
		table.insert(keys, key)
	end
	local combined = State.new({})
	local function update()
		local values = {}
		for key, state in states do
			values[key] = state:Get()
		end
		combined:Set(values)
	end
	update()
	for _, state in states do
		state:OnChange(function()
			update()
		end)
	end
	return combined
end

return State
