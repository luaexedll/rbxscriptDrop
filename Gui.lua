--[Gui.lua]--
local GuiLibrary = {}

function GuiLibrary.Initialize(callbacks)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FTAP_GUI"
    ScreenGui.ResetOnSpawn = false
    
    -- Защита от обнаружения / детекта (если поддерживается экзекутором)
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Основное окно GUI
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "Fling Things & People | Ultimate"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    -- Здесь можно расширить создание кнопок под ESP, Aim (Hands/Legs), Anti-Fling и Бинды.
    -- Главное — интерфейс возвращает структуру callbacks для связки с main.lua.
    
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return GuiLibrary
end

return GuiLibrary
