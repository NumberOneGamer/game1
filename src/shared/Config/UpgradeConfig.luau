--!strict

local Types = require(script.Parent.Parent.Types)

local UpgradeConfig: { [string]: Types.Upgrade } = {
	ClickPower = {
		id = "ClickPower",
		name = "Click Power",
		description = "Gain +1 click per click",
		cost = 10,
		multiplier = 1,
		maxLevel = 100,
		costMultiplier = 1.5,
	},
	AutoClicker = {
		id = "AutoClicker",
		name = "Auto Clicker",
		description = "Auto clicks every second",
		cost = 50,
		multiplier = 1,
		maxLevel = 50,
		costMultiplier = 1.8,
	},
	SizeBooster = {
		id = "SizeBooster",
		name = "Size Booster",
		description = "Grow 2x faster per level",
		cost = 100,
		multiplier = 2,
		maxLevel = 25,
		costMultiplier = 2.0,
	},
	Multiplier = {
		id = "Multiplier",
		name = "Click Multiplier",
		description = "Double all clicks",
		cost = 500,
		multiplier = 2,
		maxLevel = 20,
		costMultiplier = 2.5,
	},
}

return UpgradeConfig
