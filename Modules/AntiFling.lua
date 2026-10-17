--[Modules/AntiFling.lua]--
-- Класс антифлинга для Fling Things and People.
--
-- Механика игры: тебя швыряют через захват. Пока у тебя IsHeld == true,
-- тебя могут подбросить и уронить. Защита:
--   1) пока держат — обнуляем скорость персонажа каждый кадр;
--   2) дёргаем игровой remote Struggle, чтобы разорвать захват;
--   3) страховка — гасим аномальную скорость, если уже в полёте.
local AntiFling = {}
AntiFling.__index = AntiFling

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local SPIKE_LINEAR_SPEED = 150 -- порог горизонтальной скорости (стад/с)
local SPIKE_ANGULAR_SPEED = 50 -- порог угловой скорости вращения

function AntiFling.new()
    local self = setmetatable({}, AntiFling)
    self.Active = false
    -- true, когда включён Fling Aura: своё вращение — это норма, не гасим
    self.IgnoreSelfSpin = false
    self._connections = {}
    self._isHeld = LocalPlayer:FindFirstChild("IsHeld")
    self._struggleEvent = nil

    self:_resolveGameObjects()

    task.spawn(function()
        if not self._isHeld then
            self._isHeld = LocalPlayer:WaitForChild("IsHeld", 60)
        end
    end)

    return self
end

function AntiFling:_resolveGameObjects()
    pcall(function()
        local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
        if characterEvents then
            self._struggleEvent = characterEvents:FindFirstChild("Struggle")
        end
    end)

    if not self._struggleEvent then
        -- игра могла ещё не подгрузиться — пробуем дождаться
        task.spawn(function()
            local ok, characterEvents = pcall(function()
                return ReplicatedStorage:WaitForChild("CharacterEvents", 30)
            end)
            if ok and characterEvents then
                pcall(function()
                    self._struggleEvent = characterEvents:WaitForChild("Struggle", 10)
                end)
            end
        end)
    end
end

function AntiFling:_onRenderStepped()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or hrp.Anchored then
        return
    end
    if humanoid and humanoid.Health <= 0 then
        return
    end

    local held = self._isHeld and self._isHeld.Value == true
    if held then
        -- Нас схватили: гасим разгон и разрываем захват
        hrp.AssemblyLinearVelocity = Vector3.zero
        if not self.IgnoreSelfSpin then
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if humanoid and humanoid.PlatformStanding then
            humanoid.PlatformStanding = false
        end
        if self._struggleEvent then
            pcall(function()
                self._struggleEvent:FireServer(LocalPlayer)
            end)
        else
            self:_resolveGameObjects()
        end
    elseif not self.IgnoreSelfSpin then
        -- Страховка: уже в полёте (флингнули до включения или сброса)
        local linVel = hrp.AssemblyLinearVelocity
        local angVel = hrp.AssemblyAngularVelocity
        local horizontal = Vector3.new(linVel.X, 0, linVel.Z).Magnitude
        if horizontal > SPIKE_LINEAR_SPEED or angVel.Magnitude > SPIKE_ANGULAR_SPEED then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

function AntiFling:SetActive(state)
    self.Active = (state == true)

    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    self._connections = {}

    if not self.Active then
        return
    end

    table.insert(self._connections, RunService.RenderStepped:Connect(function()
        self:_onRenderStepped()
    end))
end

return AntiFling
