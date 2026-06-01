--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local ClickController = require(script.Parent.Parent.Parent.Controllers.ClickController)
local RebirthConfig = require(ReplicatedStorage.Shared.Config.RebirthConfig)
local Card = require(script.Parent.Parent.Elements.Card)
local Button = require(script.Parent.Parent.Elements.Button)
local Counter = require(script.Parent.Parent.Elements.Counter)

return function(): Instance
	local scope = Fusion.scoped(Fusion)
	local clickState = ClickController:getState()
	return scope:New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			scope:New "TextLabel" {
				Text = "Rebirth & Prestige",
				Size = UDim2.new(0, 400, 0, 50),
				Position = UDim2.new(0.5, 0, 0, 24),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
			},
			Counter {
				Label = "Current Rebirths",
				Value = function(): string
					return tostring(clickState.rebirths:Get())
				end,
				Size = UDim2.new(0, 300, 0, 60),
				Position = UDim2.new(0, 24, 0, 80),
				TextColor = Color3.fromRGB(255, 150, 255),
			},
			scope:New "ScrollingFrame" {
				Size = UDim2.new(1, -48, 0, 400),
				Position = UDim2.new(0, 24, 0, 160),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 0, #RebirthConfig * 120),
				[Children] = {
					scope:New "UIListLayout" {
						Padding = UDim.new(0, 12),
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					(function(): { Instance }
						local items: { Instance } = {}
						for i, tier in RebirthConfig do
							local card = Card {
								Size = UDim2.new(1, 0, 0, 100),
								Title = ("Rebirth Tier %d"):format(i),
								Content = function(): { Instance }
									return {
										scope:New "TextLabel" {
											Text = ("Requires: %s clicks | Multiplier: x%d"):format(
												tostring(tier.minClicks),
												tier.multiplier
											),
											Size = UDim2.new(1, 0, 0, 24),
											Position = UDim2.new(0, 0, 0, 35),
											BackgroundTransparency = 1,
											TextColor3 = Color3.fromRGB(180, 180, 180),
											TextScaled = true,
											Font = Enum.Font.Gotham,
											TextXAlignment = Enum.TextXAlignment.Left,
										},
										Button {
											Text = "Rebirth",
											Size = UDim2.new(0, 120, 0, 32),
											Position = UDim2.new(1, -130, 0, 55),
											BackgroundColor = Color3.fromRGB(200, 50, 200),
											OnClick = function()
												ClickController:requestRebirth()
											end,
										},
									}
								end,
							}
							table.insert(items, card)
						end
						return items
					end)(),
				},
			},
		},
	}
end
