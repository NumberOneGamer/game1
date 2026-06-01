--!strict

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local State = require(script.Parent.Parent.Parent.shared.Modules.State)
local SizeComponent = require(script.Parent.Parent.Parent.shared.Components.SizeComponent)

local CameraController = {}
CameraController.__index = CameraController

local currentCamera = Workspace.CurrentCamera
local cameraOffset = State.new(0)

function CameraController:Init(): ()
	RunService.RenderStepped:Connect(function()
		self:updateCamera()
	end)
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		currentCamera = Workspace.CurrentCamera
	end)
end

function CameraController:updateCamera(): ()
	if not currentCamera then
		return
	end
	local player = Players.LocalPlayer
	if not player or not player.Character then
		return
	end
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local sizeAttr = player.Character:GetAttribute("CurrentSize")
	local size = if sizeAttr then sizeAttr else 1
	local distance = SizeComponent.getCameraDistance(size)
	currentCamera.CFrame = CFrame.new(
		humanoidRootPart.Position + Vector3.new(0, distance * 0.4, distance),
		humanoidRootPart.Position
	)
end

function CameraController:setOffset(offset: number): ()
	cameraOffset:Set(offset)
end

function CameraController:Start(): ()
	print("CameraController started")
end

return CameraController
