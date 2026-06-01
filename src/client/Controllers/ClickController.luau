--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Network = require(script.Parent.Parent.Parent.shared.Modules.Network)
local State = require(script.Parent.Parent.Parent.shared.Modules.State)
local Constants = require(script.Parent.Parent.Parent.shared.Constants)

local ClickController = {}
ClickController.__index = ClickController

export type ClickState = {
	clicks: State.StateObject<number>,
	size: State.StateObject<number>,
	clickPower: State.StateObject<number>,
	rebirths: State.StateObject<number>,
	clickCooldown: State.StateObject<boolean>,
}

local state: ClickState = {
	clicks = State.new(0),
	size = State.new(1),
	clickPower = State.new(1),
	rebirths = State.new(0),
	clickCooldown = State.new(false),
}

local lastClickTime = 0

function ClickController:getState(): ClickState
	return state
end

function ClickController:Init(): ()
	Network.onClientEvent("ClickUpdate", function(clickPower: number, totalClicks: number, newSize: number)
		state.clicks:Set(totalClicks)
		state.size:Set(newSize)
		state.clickPower:Set(clickPower)
	end)

	Network.onClientEvent("RebirthAvailable", function(tier: number)
		print(("Rebirth tier %d available!"):format(tier))
	end)

	Network.onClientEvent("RebirthCompleted", function(newRebirths: number, multiplier: number)
		state.rebirths:Set(newRebirths)
		state.clicks:Set(0)
		state.size:Set(1)
		state.clickPower:Set(Constants.BASE_CLICK_POWER)
	end)

	Network.onClientEvent("UpgradePurchased", function(upgradeId: string, cost: number)
		ClickController:loadUpgradeData()
	end)

	Network.onClientEvent("UpgradeFailed", function(message: string)
		warn("Upgrade failed:", message)
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:onClick()
		end
	end)

	if RunService:IsStudio() then
		UserInputService.TouchTap:Connect(function(position: Vector2, processed: boolean)
			if not processed then
				self:onClick()
			end
		end)
	end
end

function ClickController:onClick(): ()
	local now = os.clock()
	if now - lastClickTime < Constants.CLICK_COOLDOWN then
		return
	end
	lastClickTime = now
	Network.fireServer("Click")
end

function ClickController:requestRebirth(): ()
	Network.fireServer("PerformRebirth")
end

function ClickController:purchaseUpgrade(upgradeId: string): ()
	Network.fireServer("PurchaseUpgrade", upgradeId)
end

function ClickController:loadUpgradeData(): ()
	local success, result = pcall(function()
		return Network.invokeServer("GetUpgradeData")
	end)
	if success and result then
		self:onUpgradeDataLoaded(result)
	end
end

function ClickController:onUpgradeDataLoaded(data: { { name: string, cost: number }, { [string]: number } }): ()
	print("Upgrade data loaded")
end

function ClickController:Start(): ()
	ClickController:loadUpgradeData()
end

return ClickController
