--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

export type CounterProps = {
	Label: string,
	Value: () -> string | number,
	Size: UDim2?,
	Position: UDim2?,
	TextColor: Color3?,
	LabelColor: Color3?,
}

local defaultProps: CounterProps = {
	Label = "Counter",
	Value = function(): string
		return "0"
	end,
	Size = UDim2.new(0, 250, 0, 60),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
	LabelColor = Color3.fromRGB(160, 160, 160),
}

return function(props: CounterProps): Instance
	local scope = Fusion.scoped(Fusion)
	local merged = table.clone(defaultProps)
	for key, value in props do
		merged[key] = value
	end
	local displayValue = scope:Computed(function(): string
		return tostring(merged.Value())
	end)
	return scope:New "Frame" {
		Size = merged.Size,
		Position = merged.Position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			scope:New "TextLabel" {
				Text = merged.Label,
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = merged.LabelColor,
				TextScaled = true,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			scope:New "TextLabel" {
				Text = displayValue,
				Size = UDim2.new(1, 0, 0, 35),
				Position = UDim2.new(0, 0, 0, 22),
				BackgroundTransparency = 1,
				TextColor3 = merged.TextColor,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
		},
	}
end
