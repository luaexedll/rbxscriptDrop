--[Modules/Fling.lua]--
-- Fling Aura: крутит твоего персонажа на месте, чтобы инерцией вышвыривать
-- предметы и игроков вокруг. Свою линейную скорость прижимаем, чтобы самому
-- не улететь; если всё же вылетел за карту — возвращаем на последнюю
-- безопасную позицию.
local FlingModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SPIN_SPEED = 99999        -- угловая скорость вращения
local SELF_SPEED_CAP = 40       -- ограничение собственной скорости (стад/с)
local SELF_VERTICAL_CAP = 60    -- ограничение вертикальной скорости
local VOID_Y = -80              -- ниже этой высоты — вылетел за карту
local VOID_RECOVER_MARGIN = 20  -- запас высоты для записи безопасной точки
local SAFE_POSITION_INTERVAL = 0.5

local active = false
local connection
local safePosition = nil

local function getCharacterParts()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    return hrp, humanoid
end

function FlingModule.SetActive(state)
    active = (state == true)

    if connection then
        connection:Disconnect()
        connection = nil
    end
    if not active then
        return
    end

    local lastSave = os.clock()
    connection = RunService.Stepped:Connect(function()
        local hrp, humanoid = getCharacterParts()
        if not hrp or hrp.Anchored then
            return
        end
        if humanoid and humanoid.Health <= 0 then
            return
        end

        -- Запоминаем безопасную позицию (для возврата из пустоты)
        local now = os.clock()
        if now - lastSave >= SAFE_POSITION_INTERVAL then
            lastSave = now
            if hrp.Position.Y > VOID_Y + VOID_RECOVER_MARGIN then
                safePosition = hrp.Position
            end
        end

        -- Вылетел за карту — телепорт назад
        if hrp.Position.Y <= VOID_Y and safePosition then
            hrp.CFrame = CFrame.new(safePosition)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            return
        end

        -- Крутимся, но прижимаем свою линейную скорость,
        -- чтобы разлетались только объекты и игроки вокруг
        local v = hrp.AssemblyLinearVelocity
        local xz = Vector3.new(v.X, 0, v.Z)
        if xz.Magnitude > SELF_SPEED_CAP then
            xz = xz.Unit * SELF_SPEED_CAP
        end
        hrp.AssemblyLinearVelocity = Vector3.new(xz.X, math.clamp(v.Y, -SELF_VERTICAL_CAP, SELF_VERTICAL_CAP), xz.Z)
        hrp.AssemblyAngularVelocity = Vector3.new(0, SPIN_SPEED, 0)
    end)
end

return FlingModule
