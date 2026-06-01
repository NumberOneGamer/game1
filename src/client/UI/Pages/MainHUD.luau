--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local ClickController = require(script.Parent.Parent.Parent.Controllers.ClickController)
local Counter = require(script.Parent.Parent.Elements.Counter)
local Constants = require(ReplicatedStorage.Shared.Constants)

return function(): Instance
	local clickState = ClickController:getState()
	return New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			Counter {
				Label = "Clicks",
				Value = function(): string
					return tostring(clickState.clicks:Get())
				end,
				Size = UDim2.new(0, 250, 0, 60),
				Position = UDim2.new(0, 24, 0, 24),
				TextColor = Color3.fromRGB(255, 220, 50),
			},
			Counter {
				Label = "Size",
				Value = function(): string
					return ("%.2f"):format(clickState.size:Get())
				end,
				Size = UDim2.new(0, 250, 0, 60),
				Position = UDim2.new(0, 24, 0, 94),
				TextColor = Color3.fromRGB(80, 200, 255),
			},
			Counter {
				Label = "Click Power",
				Value = function(): string
					return tostring(clickState.clickPower:Get())
				end,
				Size = UDim2.new(0, 250, 0, 60),
				Position = UDim2.new(0, 24, 0, 164),
				TextColor = Color3.fromRGB(120, 255, 120),
			},
			Counter {
				Label = "Rebirths",
				Value = function(): string
					return tostring(clickState.rebirths:Get())
				end,
				Size = UDim2.new(0, 250, 0, 60),
				Position = UDim2.new(0, 24, 0, 234),
				TextColor = Color3.fromRGB(255, 150, 255),
			},
			New "TextLabel" {
				Text = "Click anywhere to grow!",
				Size = UDim2.new(0, 400, 0, 40),
				Position = UDim2.new(0.5, 0, 0.85, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextScaled = true,
				Font = Enum.Font.Gotham,
				TextTransparency = 0.4,
			},
			New "ImageButton" {
				Size = UDim2.new(0, 120, 0, 120),
				Position = UDim2.new(0.5, 0, 0.6, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(50, 50, 60),
				Image = "rbxassetid://0",
				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0, 60),
					},
					New "UIStroke" {
						Color = Color3.fromRGB(100, 100, 120),
						Thickness = 2,
					},
					New "TextLabel" {
						Text = "+1",
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						Font = Enum.Font.GothamBold,
					},
				},
				[OnEvent "MouseButton1Click"] = function()
					ClickController:onClick()
				end,
			},
		},
	}
end
