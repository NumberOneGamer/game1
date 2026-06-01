--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children

export type CardProps = {
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	CornerRadius: UDim?,
	Title: string?,
	Content: (() -> { Instance })?,
}

local defaultProps: CardProps = {
	Size = UDim2.new(0, 300, 0, 200),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor = Color3.fromRGB(35, 35, 42),
	CornerRadius = UDim.new(0, 12),
	Title = nil,
	Content = nil,
}

return function(props: CardProps): Instance
	local merged = table.clone(defaultProps)
	for key, value in props do
		merged[key] = value
	end
	local children: { Instance } = {
		New "UICorner" {
			CornerRadius = merged.CornerRadius,
		},
		New "UIStroke" {
			Color = Color3.fromRGB(55, 55, 65),
			Thickness = 1,
			Transparency = 0.5,
		},
		New "UIPadding" {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		},
	}
	if merged.Title then
		table.insert(children, New "TextLabel" {
			Text = merged.Title,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end
	if merged.Content then
		local contentChildren = merged.Content()
		for _, child in contentChildren do
			table.insert(children, child)
		end
	end
	return New "Frame" {
		Size = merged.Size,
		Position = merged.Position,
		AnchorPoint = merged.AnchorPoint,
		BackgroundColor3 = merged.BackgroundColor,
		BorderSizePixel = 0,
		[Children] = children,
	}
end
