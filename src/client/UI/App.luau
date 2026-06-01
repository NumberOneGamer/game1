--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local scope = Fusion.scoped(Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local MainHUD = require(script.Parent.Pages.MainHUD)
local Shop = require(script.Parent.Pages.Shop)
local Upgrades = require(script.Parent.Pages.Upgrades)
local Button = require(script.Parent.Elements.Button)

local App = {}
App.__index = App

type AppInstance = {
	screenGui: ScreenGui?,
	currentPage: any,
}

function App.new(): AppInstance
	return setmetatable({
		screenGui = nil,
		currentPage = scope:Value("MainHUD"),
	}, App)
end

function App:mount(): ()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	local playerGui = player:WaitForChild("PlayerGui")
	if self.screenGui then
		self.screenGui:Destroy()
	end
	self.screenGui = New "ScreenGui" {
		Name = "GameUI",
		DisplayOrder = 10,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Parent = playerGui,
		[Children] = {
			self:buildLayout(),
		},
	}
end

function App:buildLayout(): Instance
	return New "Frame" {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			self:createPageContainer(),
			self:createNavBar(),
		},
	}
end

function App:createNavBar(): Instance
	return New "Frame" {
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 1, -50),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
		[Children] = {
			New "UIStroke" {
				Color = Color3.fromRGB(50, 50, 60),
				Thickness = 1,
			},
			New "Frame" {
				Size = UDim2.new(1, -48, 1, 0),
				Position = UDim2.new(0, 24, 0, 0),
				BackgroundTransparency = 1,
				[Children] = {
					New "UIListLayout" {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 12),
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					Button {
						Text = "Game",
						Size = UDim2.new(0, 100, 0, 36),
						BackgroundColor = Color3.fromRGB(50, 50, 60),
						OnClick = function()
							self.currentPage:Set("MainHUD")
						end,
					},
					Button {
						Text = "Shop",
						Size = UDim2.new(0, 100, 0, 36),
						BackgroundColor = Color3.fromRGB(50, 50, 60),
						OnClick = function()
							self.currentPage:Set("Shop")
						end,
					},
					Button {
						Text = "Rebirth",
						Size = UDim2.new(0, 100, 0, 36),
						BackgroundColor = Color3.fromRGB(50, 50, 60),
						OnClick = function()
							self.currentPage:Set("Upgrades")
						end,
					},
				},
			},
		},
	}
end

function App:createPageContainer(): Instance
	local currentPage = self.currentPage
	return New "Frame" {
		Name = "PageContainer",
		Size = UDim2.new(1, 0, 1, -50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Children] = {
			New "Frame" {
				Name = "MainHUD",
				Visible = scope:Computed(function(): boolean
					return currentPage:Get() == "MainHUD"
				end),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Children] = { MainHUD() },
			},
			New "Frame" {
				Name = "Shop",
				Visible = scope:Computed(function(): boolean
					return currentPage:Get() == "Shop"
				end),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Children] = { Shop() },
			},
			New "Frame" {
				Name = "Upgrades",
				Visible = scope:Computed(function(): boolean
					return currentPage:Get() == "Upgrades"
				end),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				[Children] = { Upgrades() },
			},
		},
	}
end

function App:unmount(): ()
	if self.screenGui then
		self.screenGui:Destroy()
		self.screenGui = nil
	end
end

return App
