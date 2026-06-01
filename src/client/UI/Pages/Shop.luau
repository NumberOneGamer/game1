--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children

local ClickController = require(script.Parent.Parent.Parent.Controllers.ClickController)
local UpgradeConfig = require(script.Parent.Parent.Parent.Parent.shared.Config.UpgradeConfig)
local Card = require(script.Parent.Parent.Elements.Card)
local Button = require(script.Parent.Parent.Elements.Button)

return function(): Instance
	local upgrades = UpgradeConfig
	local upgradeCards: { Instance } = {}
	for id, config in upgrades do
		local card = Card {
			Size = UDim2.new(0, 280, 0, 160),
			Title = config.name,
			Content = function(): { Instance }
				return {
					New "TextLabel" {
						Text = config.description,
						Size = UDim2.new(1, 0, 0, 30),
						Position = UDim2.new(0, 0, 0, 35),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(180, 180, 180),
						TextScaled = true,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					New "TextLabel" {
						Text = ("Max Level: %d"):format(config.maxLevel),
						Size = UDim2.new(1, 0, 0, 24),
						Position = UDim2.new(0, 0, 0, 65),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(140, 140, 140),
						TextScaled = true,
						Font = Enum.Font.Gotham,
						TextXAlignment = Enum.TextXAlignment.Left,
					},
					Button {
						Text = ("Buy - $%d"):format(config.cost),
						Size = UDim2.new(1, 0, 0, 40),
						Position = UDim2.new(0, 0, 0, 105),
						BackgroundColor = Color3.fromRGB(50, 180, 80),
						OnClick = function()
							ClickController:purchaseUpgrade(id)
						end,
					},
				}
			},
		}
		table.insert(upgradeCards, card)
	end
	return New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			New "TextLabel" {
				Text = "Upgrade Shop",
				Size = UDim2.new(0, 400, 0, 50),
				Position = UDim2.new(0.5, 0, 0, 24),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
			},
			New "ScrollingFrame" {
				Size = UDim2.new(1, -48, 1, -100),
				Position = UDim2.new(0, 24, 0, 80),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 0, #upgradeCards * 180),
				[Children] = {
					New "UIGridLayout" {
						CellSize = UDim2.new(0, 280, 0, 160),
						CellPadding = UDim2.new(0, 16, 0, 16),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					table.unpack(upgradeCards),
				},
			},
		},
	}
end
