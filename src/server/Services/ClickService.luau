--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Shared.Modules.Network)
local DataService = require(script.Parent.DataService)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local ClickService = {}
ClickService.__index = ClickService

local autoClickerLoops: { [Player]: thread } = {}

function ClickService:Init(): ()
	Network.createEvent("Click")
	Network.createEvent("AutoClickUpdate")
	Network.createEvent("ClickUpdate")
	Network.createEvent("RebirthAvailable")
	Network.createEvent("Notification")

	Network.addEventMiddleware("Click", Network.rateLimit(20, 1))

	Network.onEvent("Click", function(player: Player)
		self:handleClick(player)
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		self:startAutoClicker(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self:stopAutoClicker(player)
	end)
end

function ClickService:calculateClickPower(player: Player): number
	local data = DataService:getPlayerData(player)
	if not data then
		return Constants.BASE_CLICK_POWER
	end
	local power = Constants.BASE_CLICK_POWER
	local upgrades = data.Upgrades
	local multipliers = data.Multipliers
	local rebirthBonus = 1 + (data.Rebirths * Constants.REBIRTH_CLICK_MULTIPLIER * 0.1)
	local clickPowerLevel = upgrades["ClickPower"] or 0
	power += clickPowerLevel
	local multiplierLevel = upgrades["Multiplier"] or 0
	if multiplierLevel > 0 then
		power = power * (multiplierLevel + 1)
	end
	for _, mult in multipliers do
		power = power * mult
	end
	power = power * rebirthBonus
	return math.floor(power)
end

function ClickService:handleClick(player: Player): ()
	local data = DataService:getPlayerData(player)
	if not data then
		return
	end
	local clickPower = self:calculateClickPower(player)
	DataService:updatePlayerData(player, function(data_: Types.PlayerData): Types.PlayerData
		data_.Clicks += clickPower
		data_.Size += Constants.SCALE_INCREMENT * clickPower
		return data_
	end)
	Network.fireClient(player, "ClickUpdate", clickPower, data.Clicks + clickPower, data.Size + Constants.SCALE_INCREMENT * clickPower)
	self:checkRebirthEligibility(player)
end

function ClickService:checkRebirthEligibility(player: Player): ()
	local data = DataService:getPlayerData(player)
	if not data then
		return
	end
	local RebirthConfig = require(ReplicatedStorage.Shared.Config.RebirthConfig)
	local currentTier = data.Rebirths + 1
	local tier = RebirthConfig[currentTier]
	if tier and data.Clicks >= tier.minClicks then
		Network.fireClient(player, "RebirthAvailable", currentTier)
	end
end

function ClickService:startAutoClicker(player: Player): ()
	local thread = task.spawn(function()
		while task.wait(1) do
			local data = DataService:getPlayerData(player)
			if not data then
				break
			end
			local autoClickLevel = data.Upgrades["AutoClicker"] or 0
			if autoClickLevel > 0 then
				for _ = 1, autoClickLevel do
					self:handleClick(player)
				end
			end
		end
	end)
	autoClickerLoops[player] = thread
end

function ClickService:stopAutoClicker(player: Player): ()
	local thread = autoClickerLoops[player]
	if thread then
		task.cancel(thread)
		autoClickerLoops[player] = nil
	end
end

function ClickService:Start(): ()
	print("ClickService started")
end

return ClickService
