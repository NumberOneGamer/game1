--!strict

-- Shared SizeComponent: core size logic and calculations
-- Used by both server (scaling validation) and client (visual scaling)

local Constants = require(script.Parent.Parent.Constants)

local SizeComponent = {}

export type SizeData = {
	currentSize: number,
	baseWalkSpeed: number,
	baseJumpPower: number,
}

function SizeComponent.calculateStats(size: number): SizeData
	local clamped = math.clamp(size, Constants.MIN_SIZE, Constants.MAX_SIZE)
	local walkspeed = Constants.BASE_WALKSPEED
	local jumppower = Constants.BASE_JUMP_POWER
	if clamped < 1 then
		walkspeed = math.max(1, walkspeed * clamped)
		jumppower = math.max(1, jumppower * clamped)
	elseif clamped > 1 then
		walkspeed = walkspeed + (clamped * 0.5)
		jumppower = jumppower + (clamped * 2)
	end
	return {
		currentSize = clamped,
		baseWalkSpeed = walkspeed,
		baseJumpPower = jumppower,
	}
end

function SizeComponent.getScaleFactor(size: number): number
	return math.clamp(size, Constants.MIN_SIZE, Constants.MAX_SIZE)
end

function SizeComponent.getCameraDistance(size: number): number
	return 10 + (math.clamp(size, Constants.MIN_SIZE, Constants.MAX_SIZE) * 2)
end

function SizeComponent.getCollisionSize(size: number): Vector3
	local factor = SizeComponent.getScaleFactor(size)
	return Vector3.new(factor, factor * 1.5, factor)
end

return SizeComponent
