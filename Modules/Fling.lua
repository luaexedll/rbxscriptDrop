--[Modules/Fling.lua]--
local FlingModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local active = false
local connection

function FlingModule.SetActive(state)
    active = state
    if active then
        if not connection then
            connection = RunService.Stepped:Connect(function()
                if not active then return end
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    -- Принудительное вращение и разгон для раскидывания игроков физикой игры
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
                end
            end)
        end
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

return FlingModule
