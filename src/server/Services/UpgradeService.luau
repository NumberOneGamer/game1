--!strict

local Network = require(script.Parent.Parent.Parent.shared.Modules.Network)
local DataService = require(script.Parent.DataService)
local UpgradeConfig = require(script.Parent.Parent.Parent.shared.Config.UpgradeConfig)
local Types = require(script.Parent.Parent.Parent.shared.Types)

local UpgradeService = {}
UpgradeService.__index = UpgradeService

function UpgradeService:Init(): ()
	Network.createEvent("PurchaseUpgrade")
	Network.createEvent("UpgradePurchased")
	Network.createFunction("GetUpgradeData")

	Network.addEventMiddleware("PurchaseUpgrade", Network.rateLimit(5, 1))

	Network.onEvent("PurchaseUpgrade", function(player: Player, upgradeId: string)
		self:purchaseUpgrade(player, upgradeId)
	end)

	Network.onFunction("GetUpgradeData", function(player: Player): ({ Types.Upgrade }, { string: number })
		local data = DataService:getPlayerData(player)
		if not data then
			return UpgradeConfig, {}
		end
		return UpgradeConfig, data.Upgrades
	end)
end

function UpgradeService:purchaseUpgrade(player: Player, upgradeId: string): ()
	local config = UpgradeConfig[upgradeId]
	if not config then
		Network.fireClient(player, "UpgradeFailed", "Invalid upgrade")
		return
	end
	local data = DataService:getPlayerData(player)
	if not data then
		return
	end
	local currentLevel = data.Upgrades[upgradeId] or 0
	if currentLevel >= config.maxLevel then
		Network.fireClient(player, "UpgradeFailed", "Max level reached")
		return
	end
	local cost = config.cost * (config.costMultiplier ^ currentLevel)
	local roundedCost = math.floor(cost)
	if data.Clicks < roundedCost then
		Network.fireClient(player, "UpgradeFailed", "Not enough clicks")
		return
	end
	DataService:updatePlayerData(player, function(data_: Types.PlayerData): Types.PlayerData
		data_.Clicks -= roundedCost
		data_.Upgrades[upgradeId] = (data_.Upgrades[upgradeId] or 0) + 1
		return data_
	end)
	Network.fireClient(player, "UpgradePurchased", upgradeId, roundedCost)
end

function UpgradeService:Start(): ()
	print("UpgradeService started")
end

return UpgradeService
