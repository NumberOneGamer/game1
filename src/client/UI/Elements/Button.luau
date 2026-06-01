--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

export type ButtonProps = {
	Text: string | (() -> string),
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	TextColor: Color3?,
	OnClick: (() -> ())?,
	Disabled: boolean?,
	CornerRadius: UDim?,
}

local defaultProps: ButtonProps = {
	Text = "Button",
	Size = UDim2.new(0, 200, 0, 50),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor = Color3.fromRGB(60, 60, 60),
	TextColor = Color3.fromRGB(255, 255, 255),
	OnClick = nil,
	Disabled = false,
	CornerRadius = UDim.new(0, 8),
}

return function(props: ButtonProps): Instance
	local merged = table.clone(defaultProps)
	for key, value in props do
		merged[key] = value
	end
	local isHovered = Value(false)
	local bgColor = Computed(function(): Color3
		if merged.Disabled then
			return Color3.fromRGB(40, 40, 40)
		end
		if isHovered:Get() then
			return merged.BackgroundColor:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
		end
		return merged.BackgroundColor
	end)
	return New "TextButton" {
		Size = merged.Size,
		Position = merged.Position,
		AnchorPoint = merged.AnchorPoint,
		BackgroundColor3 = bgColor,
		TextColor3 = merged.TextColor,
		Text = merged.Text,
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		[Children] = {
			New "UICorner" {
				CornerRadius = merged.CornerRadius,
			},
			New "UIPadding" {
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			},
		},
		[OnEvent "MouseButton1Click"] = function()
			if not merged.Disabled and merged.OnClick then
				merged.OnClick()
			end
		end,
		[OnEvent "MouseEnter"] = function()
			isHovered:Set(true)
		end,
		[OnEvent "MouseLeave"] = function()
			isHovered:Set(false)
		end,
	}
end
