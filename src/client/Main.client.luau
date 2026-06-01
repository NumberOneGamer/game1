--!strict

print("=== 1 Click = +1 Size - Client Starting ===")

local ControllerLoader = require(script.Parent.Loaders.ControllerLoader)
ControllerLoader:loadAll()

local App = require(script.Parent.UI.App)
local app = App.new()
app:mount()

print("=== Client initialized ===")
