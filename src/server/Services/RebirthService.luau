--!strict

local Network = require(script.Parent.Parent.Parent.shared.Modules.Network)
local DataService = require(script.Parent.DataService)
local RebirthConfig = require(script.Parent.Parent.Parent.shared.Config.RebirthConfig)
local Constants = require(script.Parent.Parent.Parent.shared.Constants)
local Types = require(script.Parent.Parent.Parent.shared.Types)

local RebirthService = {}
RebirthService.__index = RebirthService

function RebirthService:Init(): ()
	Network.createEvent("PerformRebirth")
	Network.createEvent("RebirthCompleted")
	Network.createFunction("GetRebirthStatus")

	Network.addEventMiddleware("PerformRebirth", Network.rateLimit(3, 5))

	Network.onEvent("PerformRebirth", function(player: Player)
		self:performRebirth(player)
	end)

	Network.onFunction("GetRebirthStatus", function(player: Player): { currentTier: number, nextTierClicks: number, multiplier: number }
		local data = DataService:getPlayerData(player)
		if not data then
			return { currentTier = 0, nextTierClicks = 0, multiplier = 1 }
		end
		local nextTier = RebirthConfig[data.Rebirths + 1]
		local multiplier = 1 + (data.Rebirths * Constants.REBIRTH_CLICK_MULTIPLIER * 0.1)
		return {
			currentTier = data.Rebirths,
			nextTierClicks = if nextTier then nextTier.minClicks else math.huge,
			multiplier = multiplier,
		}
	end)
end

function RebirthService:performRebirth(player: Player): ()
	local data = DataService:getPlayerData(player)
	if not data then
		return
	end
	local currentTier = data.Rebirths + 1
	local tierConfig = RebirthConfig[currentTier]
	if not tierConfig then
		Network.fireClient(player, "RebirthFailed", "Max rebirths reached")
		return
	end
	if data.Clicks < tierConfig.minClicks then
		Network.fireClient(player, "RebirthFailed", "Not enough clicks")
		return
	end
	DataService:updatePlayerData(player, function(data_: Types.PlayerData): Types.PlayerData
		data_.Rebirths += 1
		data_.Clicks = 0
		data_.Size = tierConfig.sizeReset
		data_.Upgrades = {}
		data_.Multipliers = {}
		return data_
	end)
	Network.fireClient(player, "RebirthCompleted", data.Rebirths, tierConfig.multiplier)
end

function RebirthService:Start(): ()
	print("RebirthService started")
end

return RebirthService
