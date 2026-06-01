--!strict

export type GameConstants = {
	BASE_SIZE: number,
	BASE_WALKSPEED: number,
	BASE_JUMP_POWER: number,
	MAX_SIZE: number,
	MIN_SIZE: number,
	CLICK_COOLDOWN: number,
	AUTO_SAVE_INTERVAL: number,
	REBIRTH_CLICK_MULTIPLIER: number,
	BASE_CLICK_POWER: number,
	SCALE_INCREMENT: number,
}

local Constants: GameConstants = {
	BASE_SIZE = 1,
	BASE_WALKSPEED = 16,
	BASE_JUMP_POWER = 50,
	MAX_SIZE = 100,
	MIN_SIZE = 0.1,
	CLICK_COOLDOWN = 0.1,
	AUTO_SAVE_INTERVAL = 60,
	REBIRTH_CLICK_MULTIPLIER = 2,
	BASE_CLICK_POWER = 1,
	SCALE_INCREMENT = 0.1,
}

return Constants
