--!strict

local Types = require(script.Parent.Parent.Types)

local RebirthConfig: { Types.RebirthTier } = {
	{ minClicks = 1000, sizeReset = 1, multiplier = 2 },
	{ minClicks = 10000, sizeReset = 1, multiplier = 3 },
	{ minClicks = 100000, sizeReset = 1, multiplier = 5 },
	{ minClicks = 1000000, sizeReset = 1, multiplier = 10 },
	{ minClicks = 10000000, sizeReset = 1, multiplier = 25 },
	{ minClicks = 100000000, sizeReset = 1, multiplier = 50 },
	{ minClicks = 1000000000, sizeReset = 1, multiplier = 100 },
}

return RebirthConfig
