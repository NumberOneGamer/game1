--!strict

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Shared.Modules.State)
local Types = require(ReplicatedStorage.Shared.Types)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local DataService = {}
DataService.__index = DataService

type PlayerSession = {
	player: Player,
	data: Types.PlayerData,
	dirty: boolean,
	loaded: boolean,
	saveLock: boolean,
	connections: { RBXScriptConnection },
}

local sessions: { [Player]: PlayerSession } = {}
local dataStore: DataStore? = nil
local selfInstance: typeof(DataService)? = nil

local DEFAULT_DATA: Types.PlayerData = {
	Clicks = 0,
	Size = 1,
	Rebirths = 0,
	Multipliers = {},
	Upgrades = {},
	Settings = {},
}

function DataService:Init(): ()
	selfInstance = self
	local success, result = pcall(function()
		dataStore = DataStoreService:GetDataStore("PlayerData", "Production")
	end)
	if not success then
		warn("DataStore failed to initialize:", result)
	end
	Players.PlayerAdded:Connect(function(player: Player)
		self:loadPlayerData(player)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		self:savePlayerData(player, true)
	end)
	game:BindToClose(function()
		for _, session in sessions do
			self:savePlayerData(session.player, true)
		end
	end)
	task.spawn(function()
		while task.wait(GameConfig.AutoSaveInterval) do
			self:saveAll()
		end
	end)
end

function DataService:loadPlayerData(player: Player): ()
	local session: PlayerSession = {
		player = player,
		data = DEFAULT_DATA,
		dirty = false,
		loaded = false,
		saveLock = false,
		connections = {},
	}
	sessions[player] = session
	local success, savedData = pcall(function()
		if dataStore then
			return dataStore:GetAsync(tostring(player.UserId))
		end
		return nil
	end)
	if success and savedData then
		session.data = self:migrateData(savedData)
	end
	session.loaded = true
	local stateKey = tostring(player.UserId)
	local playerDataState: State.StateObject<Types.PlayerData> = State.new(session.data)
	selfInstance:onDataLoaded(player, session.data)
end

function DataService:onDataLoaded(player: Player, data: Types.PlayerData): ()
	print(("Data loaded for %s: %d clicks, %.2f size"):format(player.Name, data.Clicks, data.Size))
end

function DataService:migrateData(data: { [string]: any }): Types.PlayerData
	local merged = table.clone(DEFAULT_DATA)
	for key, value in data do
		if merged[key] ~= nil then
			merged[key] = value
		end
	end
	return merged :: Types.PlayerData
end

function DataService:getPlayerData(player: Player): Types.PlayerData?
	local session = sessions[player]
	if session then
		return session.data
	end
	return nil
end

function DataService:updatePlayerData(player: Player, updater: (Types.PlayerData) -> Types.PlayerData): ()
	local session = sessions[player]
	if not session then
		return
	end
	session.data = updater(session.data)
	session.dirty = true
end

function DataService:savePlayerData(player: Player, immediate: boolean): boolean
	local session = sessions[player]
	if not session or not session.dirty or session.saveLock then
		return false
	end
	session.saveLock = true
	local success, err = pcall(function()
		if dataStore then
			dataStore:SetAsync(tostring(player.UserId), session.data)
		end
	end)
	if success then
		session.dirty = false
	else
		warn(("Failed to save data for %s: %s"):format(player.Name, tostring(err)))
	end
	session.saveLock = false
	return success
end

function DataService:saveAll(): ()
	for player, session in sessions do
		if session.dirty then
			self:savePlayerData(player, false)
		end
	end
end

function DataService:getOrCreateData(player: Player): Types.PlayerData
	local data = self:getPlayerData(player)
	if not data then
		data = table.clone(DEFAULT_DATA)
	end
	return data
end

function DataService:playerExists(player: Player): boolean
	return sessions[player] ~= nil
end

function DataService:Start(): ()
	print("DataService started")
end

return DataService
