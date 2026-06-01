--!strict

print("=== 1 Click = +1 Size - Server Starting ===")

local ServiceLoader = require(script.Parent:WaitForChild("Loaders"):WaitForChild("ServiceLoader"))
ServiceLoader:loadAll()

print("=== Server initialized ===")
