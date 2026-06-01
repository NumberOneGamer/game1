--!strict

print("=== 1 Click = +1 Size - Client Starting ===")

local ControllerLoader = require(script.Parent:WaitForChild("Loaders"):WaitForChild("ControllerLoader"))
ControllerLoader:loadAll()

local App = require(script.Parent:WaitForChild("UI"):WaitForChild("App"))
local app = App.new()
app:mount()

print("=== Client initialized ===")
