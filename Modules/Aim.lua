--[Modules/Aim.lua]--
local AimModule = {}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local active = false
local targetPartName = "Head"
local aimKey = Enum.KeyCode.Q

-- Запасные части тела: имена отличаются между R6 и R15,
-- поэтому при отсутствии выбранной части целимся в голову/корпус
local FALLBACK_PARTS = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }

local function getAimTargetPart(player)
    local char = player.Character
    if not char then
        return nil
    end
    local part = char:FindFirstChild(targetPartName)
    if part then
        return part
    end
    for _, name in ipairs(FALLBACK_PARTS) do
        local fallback = char:FindFirstChild(name)
        if fallback then
            return fallback
        end
    end
    return nil
end

function AimModule.SetActive(state, partName, key)
    active = (state == true)
    if partName then
        targetPartName = partName
    end
    if typeof(key) == "EnumItem" then
        aimKey = key
    end
end

RunService.RenderStepped:Connect(function()
    if not active then
        return
    end
    if not UserInputService:IsKeyDown(aimKey) then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    -- GetMouseLocation() учитывает GUI inset (верхняя панель),
    -- а WorldToViewportPoint() — нет; вычитаем inset, чтобы координаты совпадали
    local mousePos = UserInputService:GetMouseLocation()
    pcall(function()
        mousePos = mousePos - GuiService:GetGuiInset()
    end)

    local closestPart = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local part = getAimTargetPart(player)
            if part then
                local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPart = part
                    end
                end
            end
        end
    end

    if closestPart then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closestPart.Position)
    end
end)

return AimModule
