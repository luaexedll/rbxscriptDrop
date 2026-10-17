--[Modules/Power.lua]--
-- Класс "Super Duper Far Power" для Fling Things and People.
--
-- Механика игры: при захвате объекта в Workspace появляется модель "GrabParts"
-- (GrabPart.WeldConstraint.Part1 — схваченная деталь). При отпуске захвата
-- (ПКМ) игра сама делает бросок. Мы подкладываем на деталь BodyVelocity и при
-- отпуске задаём ей огромную скорость — объект летит на сверхдальнюю дистанцию.
local Power = {}
Power.__index = Power

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

-- Сила броска (стад/с). Ванильный бросок — сотни; 2200-5000 — сверхдальний.
local THROW_STRENGTH = 5000

function Power.new(strength)
    local self = setmetatable({}, Power)
    self.Active = false
    self.Strength = strength or THROW_STRENGTH
    self._connection = nil
    return self
end

function Power:_onGrabAdded(model)
    if not self.Active then
        return
    end

    local part = nil
    pcall(function()
        local grabPart = model:FindFirstChild("GrabPart")
        local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
        part = weld and weld.Part1
    end)
    if not part then
        return
    end

    -- Пока держим — BodyVelocity выключен (MaxForce = 0), мешать не будет
    local velocityObj = Instance.new("BodyVelocity")
    velocityObj.MaxForce = Vector3.zero
    velocityObj.Velocity = Vector3.zero
    velocityObj.P = 100000
    velocityObj.Parent = part

    model:GetPropertyChangedSignal("Parent"):Connect(function()
        if model.Parent then
            return
        end
        local launched = false
        pcall(function()
            launched = (UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2)
        end)
        if launched and velocityObj.Parent then
            -- Бросок! Подкидываем с нашей силой
            local direction = Workspace.CurrentCamera.CFrame.LookVector
            velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            velocityObj.Velocity = direction * self.Strength
            Debris:AddItem(velocityObj, 1)
        elseif velocityObj.Parent then
            velocityObj:Destroy()
        end
    end)
end

function Power:SetActive(state)
    self.Active = (state == true)

    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    if not self.Active then
        return
    end

    -- Если объект уже схвачен на момент включения — обрабатываем его
    local existing = Workspace:FindFirstChild("GrabParts")
    if existing then
        task.spawn(function()
            self:_onGrabAdded(existing)
        end)
    end

    self._connection = Workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" then
            self:_onGrabAdded(model)
        end
    end)
end

return Power
