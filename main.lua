--[main.lua]--
local repo = "https://raw.githubusercontent.com/luaexedll/rbxscriptDrop/refs/heads/main/"

-- Загрузка GUI
local success, GUI = pcall(function()
    return loadstring(game:HttpGet(repo .. "Gui.lua"))()
end)

if not success or not GUI then
    warn("[Script Error] Failed to load GUI: " .. tostring(GUI))
    return
end

-- Загрузка модулей
local successAim, AimModule = pcall(function()
    return loadstring(game:HttpGet(repo .. "Modules/Aim.lua"))()
end)

local successESP, ESPModule = pcall(function()
    return loadstring(game:HttpGet(repo .. "Modules/ESP.lua"))()
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 1. Anti-Fling (Включена по умолчанию)
local antiFlingConnection
local function toggleAntiFling(state)
    if state then
        if not antiFlingConnection then
            antiFlingConnection = RunService.Stepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    else
        if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
        end
    end
end
toggleAntiFling(true) -- Включаем по умолчанию

-- 2. Power: Super Duper Far (Максимальная сила броска)
local function setSuperDuperFarPower()
    pcall(function()
        -- Модификация параметров броска/силы в игре
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "ThrowPower") then
                v.ThrowPower = 999999 -- Максимальное значение
            end
        end
    end)
end
setSuperDuperFarPower()

-- 3. Вид от третьего лица
LocalPlayer.CameraMaxZoomDistance = 150
LocalPlayer.CameraMinZoomDistance = 0.5

-- 4. Инициализация элементов в GUI
if GUI.Initialize then
    GUI.Initialize({
        OnAntiFlingToggle = function(state)
            toggleAntiFling(state)
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
        end
    })
end

print("[Script] Fling Things and People loaded successfully!")
