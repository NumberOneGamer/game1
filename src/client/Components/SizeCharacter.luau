--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Shared.Modules.State)
local Network = require(ReplicatedStorage.Shared.Modules.Network)
local SizeComponent = require(ReplicatedStorage.Shared.Components.SizeComponent)

local SizeCharacter = {}
SizeCharacter.__index = SizeCharacter

type SizeCharacterInstance = {
	player: Player,
	character: Model?,
	currentSize: State.StateObject<number>,
	targetSize: State.StateObject<number>,
	connections: { RBXScriptConnection },
}

function SizeCharacter.new(player: Player): SizeCharacterInstance
	return setmetatable({
		player = player,
		character = nil,
		currentSize = State.new(1),
		targetSize = State.new(1),
		connections = {},
	}, SizeCharacter)
end

function SizeCharacter:Init(): ()
	local function onCharacterAdded(character: Model)
		self.character = character
		self:connectCharacterEvents(character)
	end
	if self.player.Character then
		onCharacterAdded(self.player.Character)
	end
	table.insert(self.connections, self.player.CharacterAdded:Connect(onCharacterAdded))
	Network.onClientEvent("UpdateCharacterSize", function(size: number)
		self.targetSize:Set(size)
	end)
	RunService.RenderStepped:Connect(function()
		self:updateScale()
	end)
end

function SizeCharacter:connectCharacterEvents(character: Model): ()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		table.insert(self.connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if humanoid.Health <= 0 then
				self.character = nil
			end
		end))
	end
end

function SizeCharacter:updateScale(): ()
	if not self.character then
		return
	end
	local current = self.currentSize:Get()
	local target = self.targetSize:Get()
	local diff = target - current
	if math.abs(diff) > 0.001 then
		self.currentSize:Set(current + (diff * 0.1))
	end
	local factor = SizeComponent.getScaleFactor(self.currentSize:Get())
	local primaryPart = self.character:FindFirstChild("HumanoidRootPart") or self.character:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		primaryPart.Size = SizeComponent.getCollisionSize(self.currentSize:Get())
	end
	for _, part in self.character:GetDescendants() do
		if part:IsA("BasePart") and part ~= primaryPart then
			local originalSize = part:GetAttribute("OriginalSize")
			if not originalSize then
				part:SetAttribute("OriginalSize", part.Size)
				originalSize = part.Size
			end
			if typeof(originalSize) == "Vector3" then
				part.Size = originalSize * factor
			end
		end
	end
end

function SizeCharacter:Destroy(): ()
	for _, conn in self.connections do
		conn:Disconnect()
	end
	self.connections = {}
end

return SizeCharacter
