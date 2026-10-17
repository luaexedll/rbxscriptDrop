--[Gui.lua]--
local GuiLibrary = {}

function GuiLibrary.Initialize(callbacks)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FTAP_UltimateGUI"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        pcall(function()
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = "Fling Things & People | Ultimate Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    -- Контейнер для настроек
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ScrollingFrame

    -- Функция создания секций/заголовков
    local function createSection(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. text
        lbl.TextColor3 = Color3.fromRGB(120, 170, 255)
        lbl.TextSize = 14
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = ScrollingFrame
    end

    -- Функция создания переключателя (Toggle)
    local function createToggle(text, defaultState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        btn.Text = "  " .. text .. ": " .. (defaultState and "[ON]" or "[OFF]")
        btn.TextColor3 = defaultState and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = ScrollingFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        local state = defaultState
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = "  " .. text .. ": " .. (state and "[ON]" or "[OFF]")
            btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
            callback(state)
        end)
        return btn
    end

    -- Состояние ESP
    local espSettings = { Boxes = false, Names = false, Distance = false, Health = false, Tracers = false }
    local function updateESP()
        if callbacks.OnESPToggle then callbacks.OnESPToggle(espSettings) end
    end

    -- Настройка интерфейса
    createSection("🛡️ ЗАЩИТА & СИЛА")
    createToggle("Anti-Fling (Защита)", true, function(state)
        if callbacks.OnAntiFlingToggle then callbacks.OnAntiFlingToggle(state) end
    end)

    createToggle("Power: Super Duper Far & Level", true, function(state)
        if state and callbacks.OnPowerBoost then callbacks.OnPowerBoost() end
    end)

    createSection("🎯 АИМ (НА РУКИ И НОГИ)")
    local aimActive = false
    local currentPart = "LeftHand" -- LeftHand, RightHand, LeftFoot, RightFoot
    local currentKey = Enum.KeyCode.Q

    createToggle("Включить Aim Bot", false, function(state)
        aimActive = state
        if callbacks.OnAimToggle then callbacks.OnAimToggle(aimActive, currentPart, currentKey) end
    end)

    -- Кнопка выбора части тела
    local partBtn = Instance.new("TextButton")
    partBtn.Size = UDim2.new(1, 0, 0, 35)
    partBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    partBtn.Text = "  Цель Аима: Левая рука (LeftHand)"
    partBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    partBtn.TextSize = 13
    partBtn.Font = Enum.Font.GothamMedium
    partBtn.TextXAlignment = Enum.TextXAlignment.Left
    partBtn.Parent = ScrollingFrame
    Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)

    local partsList = {"LeftHand", "RightHand", "LeftFoot", "RightFoot"}
    local partNamesRu = {["LeftHand"] = "Левая рука", ["RightHand"] = "Правая рука", ["LeftFoot"] = "Левая нога", ["RightFoot"] = "Правая нога"}
    local partIndex = 1
    partBtn.MouseButton1Click:Connect(function()
        partIndex = partIndex % #partsList + 1
        currentPart = partsList[partIndex]
        partBtn.Text = "  Цель Аима: " .. partNamesRu[currentPart] .. " (" .. currentPart .. ")"
        if callbacks.OnAimToggle then callbacks.OnAimToggle(aimActive, currentPart, currentKey) end
    end)

    createSection("👁️ ESP ОПЦИИ")
    createToggle("ESP: Boxes (Рамки)", false, function(s) espSettings.Boxes = s; updateESP() end)
    createToggle("ESP: Names (Имена)", false, function(s) espSettings.Names = s; updateESP() end)
    createToggle("ESP: Distance (Дистанция)", false, function(s) espSettings.Distance = s; updateESP() end)
    createToggle("ESP: Health (Здоровье)", false, function(s) espSettings.Health = s; updateESP() end)
    createToggle("ESP: Tracers (Линии)", false, function(s) espSettings.Tracers = s; updateESP() end)

    -- Бинды и управление видимостью меню по RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return GuiLibrary
end

return GuiLibrary
