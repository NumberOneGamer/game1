--!strict

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Shared.Modules.Network)
local DataService = require(script.Parent.DataService)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SizeService = {}
SizeService.__index = SizeService

function SizeService:Init(): ()
	Network.createEvent("UpdateCharacterSize")

	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			task.wait(0.5)
			self:applySize(player, character)
		end)
		if player.Character then
			task.wait(0.5)
			self:applySize(player, player.Character)
		end
	end)

	Network.onEvent("RequestSizeUpdate", function(player: Player)
		local data = DataService:getPlayerData(player)
		if data and player.Character then
			self:applySize(player, player.Character)
		end
	end)
end

function SizeService:applySize(player: Player, character: Model): ()
	local data = DataService:getPlayerData(player)
	if not data then
		return
	end
	local size = data.Size
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		local clampedSize = math.clamp(size, Constants.MIN_SIZE, Constants.MAX_SIZE)
		humanoid:SetAttribute("CurrentSize", clampedSize)
		local walkspeed = Constants.BASE_WALKSPEED
		local jumppower = Constants.BASE_JUMP_POWER
		if clampedSize < 1 then
			walkspeed = walkspeed * clampedSize
			jumppower = jumppower * clampedSize
		elseif clampedSize > 1 then
			walkspeed = walkspeed + (clampedSize * 0.5)
			jumppower = jumppower + (clampedSize * 2)
		end
		humanoid.WalkSpeed = walkspeed
		humanoid.JumpPower = jumppower
	end
	Network.fireClient(player, "UpdateCharacterSize", size)
end

function SizeService:getPlayerSize(player: Player): number
	local data = DataService:getPlayerData(player)
	if data then
		return data.Size
	end
	return Constants.BASE_SIZE
end

function SizeService:Start(): ()
	print("SizeService started")
end

return SizeService
