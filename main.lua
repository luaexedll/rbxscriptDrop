--[main.lua]--
-- Загрузчик: тянет GUI и модули с GitHub, создаёт экземпляры классов,
-- включает дефолтные состояния и связывает всё с колбэками GUI.
-- Вся логика функций живёт в Modules/*.lua — тут только wiring.
local repo = "https://raw.githubusercontent.com/luaexedll/rbxscriptDrop/refs/heads/main/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

local ESPModule = safeLoad("Modules/ESP.lua", "ESP")
local AimModule = safeLoad("Modules/Aim.lua", "Aim")
local FlingModule = safeLoad("Modules/Fling.lua", "Fling")
local AntiFlingClass = safeLoad("Modules/AntiFling.lua", "AntiFling")
local PowerClass = safeLoad("Modules/Power.lua", "Power")

-- Экземпляры классов
local esp = ESPModule
local aim = AimModule
local flingAura = FlingModule
local antiFling = AntiFlingClass and AntiFlingClass.new() or nil
local power = PowerClass and PowerClass.new() or nil

-- Дефолтные состояния (как в GUI)
if antiFling then
    antiFling:SetActive(true)
end
if power then
    power:SetActive(true)
end

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
-- Связка GUI с модулями
---------------------------------------------------------------------------
if GUI.Initialize then
    GUI.Initialize({
        OnAntiFlingToggle = function(state)
            if antiFling then
                antiFling:SetActive(state)
            end
        end,
        OnPowerBoost = function(state)
            if power then
                power:SetActive(state)
            end
        end,
        OnFlingAuraToggle = function(state)
            if flingAura then
                flingAura.SetActive(state)
            end
            if antiFling then
                -- своё вращение от ауры антифлинг гасить не должен
                antiFling.IgnoreSelfSpin = (state == true)
            end
        end,
        OnAimToggle = function(state, targetPart, keybind)
            if aim then
                aim.SetActive(state, targetPart, keybind)
            end
        end,
        OnESPToggle = function(options)
            if esp then
                esp.UpdateSettings(options)
            end
        end,
        OnThirdPersonToggle = function(state)
            setThirdPerson(state)
        end
    })
end

print("[Script] SKV FTAP Loaded Successfully!")
