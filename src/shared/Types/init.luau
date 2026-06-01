--!strict

export type PlayerData = {
	Clicks: number,
	Size: number,
	Rebirths: number,
	Multipliers: { [string]: number },
	Upgrades: { [string]: number },
	Settings: { [string]: any },
}

export type Upgrade = {
	id: string,
	name: string,
	description: string,
	cost: number,
	multiplier: number,
	maxLevel: number,
	costMultiplier: number,
}

export type RebirthTier = {
	minClicks: number,
	sizeReset: number,
	multiplier: number,
}

export type NotificationType = {
	id: string,
	title: string,
	message: string,
	duration: number,
}

export type ServiceDefinition = {
	Init: (self: any) -> (),
	Start: (self: any) -> (),
	[any]: any,
}

export type ControllerDefinition = {
	Init: (self: any) -> (),
	Start: (self: any) -> (),
	[any]: any,
}

export type NetworkPacket = {
	eventId: string,
	player: Player,
	data: any,
	timestamp: number,
}

return {} -- Types module: runtime value needed for ModuleScript requirement
