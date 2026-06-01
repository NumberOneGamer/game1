--!strict

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Shared.Modules.Network)
local DataService = require(script.Parent.DataService)
local Types = require(ReplicatedStorage.Shared.Types)

local LeaderboardService = {}
LeaderboardService.__index = LeaderboardService

type LeaderboardEntry = {
	player: Player,
	clicks: number,
	rebirths: number,
	size: number,
}

local function getLeaderboard(): { LeaderboardEntry }
	local entries: { LeaderboardEntry } = {}
	for _, player in Players:GetPlayers() do
		local data = DataService:getPlayerData(player)
		if data then
			table.insert(entries, {
				player = player,
				clicks = data.Clicks,
				rebirths = data.Rebirths,
				size = data.Size,
			})
		end
	end
	table.sort(entries, function(a: LeaderboardEntry, b: LeaderboardEntry): boolean
		if a.rebirths ~= b.rebirths then
			return a.rebirths > b.rebirths
		end
		return a.clicks > b.clicks
	end)
	return entries
end

function LeaderboardService:Init(): ()
	Network.createEvent("LeaderboardUpdate")
	Network.createFunction("GetLeaderboard")
	Network.onFunction("GetLeaderboard", function(player: Player): { LeaderboardEntry }
		return getLeaderboard()
	end)
	Players.PlayerAdded:Connect(function()
		task.wait(2)
		self:broadcastLeaderboardUpdate()
	end)
	Players.PlayerRemoving:Connect(function()
		task.wait(0.5)
		self:broadcastLeaderboardUpdate()
	end)
end

function LeaderboardService:broadcastLeaderboardUpdate(): ()
	local entries = getLeaderboard()
	Network.fireAllClients("LeaderboardUpdate", entries)
end

function LeaderboardService:Start(): ()
	print("LeaderboardService started")
end

return LeaderboardService
