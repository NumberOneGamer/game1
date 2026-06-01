--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Shared.Modules.State)
local Network = require(ReplicatedStorage.Shared.Modules.Network)
local Types = require(ReplicatedStorage.Shared.Types)

local UIController = {}
UIController.__index = UIController

type NotificationEntry = {
	id: string,
	title: string,
	message: string,
	duration: number,
	createdAt: number,
}

local notifications: State.StateObject<{ NotificationEntry }> = State.new({})

function UIController:Init(): ()
	Network.onClientEvent("Notification", function(title: string, message: string, duration: number)
		self:showNotification(title, message, duration)
	end)
end

function UIController:showNotification(title: string, message: string, duration: number): ()
	local current = notifications:Get()
	local entry: NotificationEntry = {
		id = tostring(os.clock()),
		title = title,
		message = message,
		duration = duration or 3,
		createdAt = os.clock(),
	}
	table.insert(current, entry)
	notifications:Set(current)
	task.delay(duration or 3, function()
		local updated = notifications:Get()
		for i, notif in updated do
			if notif.id == entry.id then
				table.remove(updated, i)
				break
			end
		end
		notifications:Set(updated)
	end)
end

function UIController:getNotifications(): State.StateObject<{ NotificationEntry }>
	return notifications
end

function UIController:openPage(pageName: string): ()
	print(("Opening page: %s"):format(pageName))
end

function UIController:Start(): ()
	print("UIController started")
end

return UIController
