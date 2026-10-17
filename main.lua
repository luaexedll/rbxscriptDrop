--[main.lua]--
local repo = "https://raw.githubusercontent.com/luaexedll/rbxscriptDrop/refs/heads/main/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Безопасная загрузка: ошибка одного модуля не ломает весь скрипт
local function safeLoad(path, name)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(repo .. path))()
    end)
    if not ok then
        warn("[SKV FTAP] Не удалось загрузить " .. name .. ": " .. tostring(result))
        return nil
    end
    if type(result) ~= "table" then
        warn("[SKV FTAP] Модуль " .. name .. " вернул не таблицу: " .. tostring(result))
        return nil
    end
    return result
end

local GUI = safeLoad("Gui.lua", "GUI")
if not GUI then
    return
end

local AimModule = safeLoad("Modules/Aim.lua", "Aim")
local ESPModule = safeLoad("Modules/ESP.lua", "ESP")
local FlingModule = safeLoad("Modules/Fling.lua", "Fling")

---------------------------------------------------------------------------
-- 1. Anti-Fling — защищает СВОЁГО персонажа от разгона чужими флингами.
--    Работает по порогу: обычный бег/прыжок/падение не превышают лимитов,
--    гасим только аномально сильный разгон или вращение.
---------------------------------------------------------------------------
local WALK_SPEED_LIMIT = 150 -- горизонтальная скорость (стад/с)
local JUMP_SPEED_LIMIT = 120 -- обычный прыжок даёт ~50-70 стад/с вверх
local SPIN_SPEED_LIMIT = 50  -- угловая скорость вращения

local antiFlingActive = true
local flingAuraActive = false
local antiFlingConnection

local function updateAntiFling()
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    if not antiFlingActive then
        return
    end
    antiFlingConnection = RunService.Stepped:Connect(function()
        if flingAuraActive then
            return -- Fling Aura сам крутит персонажа — антифлингу мешать нельзя
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or hrp.Anchored then
            return
        end
        if humanoid and humanoid.Health <= 0 then
            return
        end
        local linVel = hrp.AssemblyLinearVelocity
        local angVel = hrp.AssemblyAngularVelocity
        local horizontal = Vector3.new(linVel.X, 0, linVel.Z).Magnitude
        if horizontal > WALK_SPEED_LIMIT or linVel.Y > JUMP_SPEED_LIMIT or angVel.Magnitude > SPIN_SPEED_LIMIT then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end
updateAntiFling()

---------------------------------------------------------------------------
-- 2. Power: "Super Duper Far" — максимальная сила броска.
--    Игра держит силу броска в своих таблицах (и в upvalue функций) и может
--    перезаписывать её, поэтому повторяем применение каждые POWER_REAPPLY сек.
---------------------------------------------------------------------------
local POWER_VALUE = 999999
local POWER_REAPPLY = 5
local POWER_KEYS = { ThrowPower = true, PowerLevel = true, MaxPower = true }

local powerActive = true

local function patchPowerTable(t)
    for key in pairs(POWER_KEYS) do
        local value = rawget(t, key)
        if type(value) == "number" and value < POWER_VALUE then
            pcall(function()
                t[key] = POWER_VALUE
            end)
        end
    end
end

local function scanUpvalues(func)
    pcall(function()
        local index = 1
        while true do
            local name, value = debug.getupvalue(func, index)
            if not name then
                break
            end
            if type(value) == "table" then
                patchPowerTable(value)
            end
            index = index + 1
        end
    end)
end

local function applySuperPower(scanFunctions)
    if not getgc then
        warn("[SKV FTAP] getgc() недоступен в этом экзекьюторе — Power не применён")
        return
    end
    pcall(function()
        for _, value in pairs(getgc(true)) do
            local valueType = type(value)
            if valueType == "table" then
                patchPowerTable(value)
            elseif valueType == "function" and scanFunctions then
                scanUpvalues(value)
            end
        end
    end)
end

local function setPowerEnabled(state)
    powerActive = state ~= false
    if powerActive then
        applySuperPower(true)
        task.spawn(function()
            while powerActive do
                task.wait(POWER_REAPPLY)
                if powerActive then
                    applySuperPower(false)
                end
            end
        end)
    end
end
setPowerEnabled(true)

-- Вид от третьего лица (зум в обе стороны)
local function setThirdPerson(enabled)
    pcall(function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = enabled and 150 or 12
    end)
end
setThirdPerson(true)

---------------------------------------------------------------------------
-- Инициализация GUI и связка колбэков
---------------------------------------------------------------------------
if GUI.Initialize then
    GUI.Initialize({
        OnAntiFlingToggle = function(state)
            antiFlingActive = state
            updateAntiFling()
        end,
        OnPowerBoost = function(state)
            setPowerEnabled(state)
        end,
        OnFlingAuraToggle = function(state)
            flingAuraActive = state
            if FlingModule and FlingModule.SetActive then
                FlingModule.SetActive(state)
            end
        end,
        OnAimToggle = function(state, targetPart, keybind)
            if AimModule and AimModule.SetActive then
                AimModule.SetActive(state, targetPart, keybind)
            end
        end,
        OnESPToggle = function(options)
            if ESPModule and ESPModule.UpdateSettings then
                ESPModule.UpdateSettings(options)
            end
        end,
        OnThirdPersonToggle = function(state)
            setThirdPerson(state)
        end
    })
end

print("[Script] SKV FTAP Loaded Successfully!")
