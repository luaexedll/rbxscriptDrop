--[Modules/Aim.lua]--
local AimModule = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local active = false
local targetPartName = "LeftHand" -- 'LeftHand', 'RightHand', 'LeftFoot', 'RightFoot'
local aimKey = Enum.KeyCode.Q

function AimModule.SetActive(state, partName, key)
    active = state
    if partName then targetPartName = partName end
    if key then aimKey = key end
end

RunService.RenderStepped:Connect(function()
    if not active then return end
    if UserInputService:IsKeyDown(aimKey) then
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(targetPartName) then
                local part = player.Character[targetPartName]
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = part
                    end
                end
            end
        end
        
        -- Если игрок найден, наводим камеру или фокус броска
        if closestPlayer then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestPlayer.Position)
        end
    end
end)

return AimModule
