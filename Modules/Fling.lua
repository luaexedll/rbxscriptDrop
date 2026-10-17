--[Modules/Fling.lua]--
local FlingModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local active = false
local connection

function FlingModule.SetActive(state)
    active = (state == true)

    if connection then
        connection:Disconnect()
        connection = nil
    end
    if not active then
        return
    end

    connection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or hrp.Anchored then
            return
        end
        if humanoid and humanoid.Health <= 0 then
            return
        end
        -- Принудительное вращение: физика игры разбрасывает всех, кто касается
        hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
    end)
end

return FlingModule
