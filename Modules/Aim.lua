--[Modules/Aim.lua]--111
-- Аим по зажатой клавише с настройками: резкость, FOV, дальность,
-- рисование круга FOV и вайтлистом игроков.
local AimModule = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local active = false
local targetPartName = "Head"
local aimKey = Enum.KeyCode.Q

local settings = {
    Smoothness = 100, -- 1 (плавно) .. 100 (мгновенно)
    Fov = 35,         -- градусы конуса наведения
    Range = 1000,     -- дальность до цели (стады)
    DrawFov = false   -- рисовать круг FOV на экране
}

local whitelist = {} -- [Имя игрока] = true -> аим игнорирует

-- Запасные части тела: имена отличаются между R6 и R15
local FALLBACK_PARTS = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }

-- Круг FOV (Drawing API, если доступен)
local fovCircle = nil
local function getFovCircle()
    if fovCircle or Drawing == nil then
        return fovCircle
    end
    local ok, circle = pcall(function()
        return Drawing.new("Circle")
    end)
    if ok and circle then
        circle.Visible = false
        circle.Color = Color3.fromRGB(246, 92, 82)
        circle.Thickness = 1.5
        circle.Filled = false
        fovCircle = circle
    end
    return fovCircle
end

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

local function fovToScreenRadius(camera)
    local viewport = camera.ViewportSize
    local halfFov = math.rad(settings.Fov * 0.5)
    local halfScreenFov = math.rad(camera.FieldOfView * 0.5)
    local tanFov = math.tan(halfFov)
    local tanScreen = math.tan(halfScreenFov)
    if tanScreen <= 0 then
        return 0
    end
    return (tanFov / tanScreen) * (viewport.Y * 0.5)
end

function AimModule.SetActive(state, partName, key)
    active = (state == true)
    if partName then
        targetPartName = partName
    end
    if typeof(key) == "EnumItem" then
        aimKey = key
    end
    if not active then
        local circle = getFovCircle()
        if circle then
            circle.Visible = false
        end
    end
end

function AimModule.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if settings[key] ~= nil then
            settings[key] = value
        end
    end
end

function AimModule.SetWhitelisted(playerName, state)
    if state then
        whitelist[playerName] = true
    else
        whitelist[playerName] = nil
    end
end

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local circle = getFovCircle()

    if not active or not UserInputService:IsKeyDown(aimKey) then
        if circle then
            circle.Visible = false
        end
        return
    end

    -- Прицел — центр экрана; круг FOV рисуем от него же
    local viewport = camera.ViewportSize
    local screenCenter = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    local fovRadius = fovToScreenRadius(camera)

    if circle then
        circle.Visible = (settings.DrawFov == true)
        circle.Position = screenCenter
        circle.Radius = fovRadius
    end

    local bestPart = nil
    local bestScore = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not whitelist[player.Name] then
            local part = getAimTargetPart(player)
            if part then
                local distance = (part.Position - camera.CFrame.Position).Magnitude
                if distance <= settings.Range then
                    local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local toTarget = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                        if toTarget <= fovRadius and toTarget < bestScore then
                            bestScore = toTarget
                            bestPart = part
                        end
                    end
                end
            end
        end
    end

    if bestPart then
        local targetCFrame = CFrame.new(camera.CFrame.Position, bestPart.Position)
        local alpha = math.clamp((settings.Smoothness or 100) / 100, 0.02, 1)
        if alpha >= 0.999 then
            camera.CFrame = targetCFrame
        else
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
        end
    end
end)

return AimModule
