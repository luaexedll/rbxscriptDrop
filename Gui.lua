--[Gui.lua]--
local GuiLibrary = {}

function GuiLibrary.Initialize(callbacks)
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")

    local LocalPlayer = Players.LocalPlayer
    local CUSTOM_LOGO_ID = "rbxassetid://139568612294283"

    if CoreGui:FindFirstChild("SKVFTAP_UI") then
        CoreGui.SKVFTAP_UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SKVFTAP_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local targetParent = (gethui and gethui()) or (run_secure and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Parent = targetParent

    local THEME = {
        Background    = Color3.fromRGB(12, 9, 11),
        CardBg        = Color3.fromRGB(18, 13, 16),
        PillBg        = Color3.fromRGB(16, 12, 14),
        SidebarActive = Color3.fromRGB(27, 16, 19),
        Border        = Color3.fromRGB(36, 24, 28),
        BorderActive  = Color3.fromRGB(90, 36, 42),
        Accent        = Color3.fromRGB(246, 92, 82),
        AccentSoft    = Color3.fromRGB(255, 165, 155),
        AccentDark    = Color3.fromRGB(130, 40, 42),
        TextPrimary   = Color3.fromRGB(235, 235, 235),
        TextMuted     = Color3.fromRGB(120, 110, 115),
        TextDim       = Color3.fromRGB(72, 64, 68),
        Divider       = Color3.fromRGB(48, 36, 40),
        BadgeBg       = Color3.fromRGB(25, 18, 22),
        ToggleOff     = Color3.fromRGB(36, 28, 32),
        KnobOff       = Color3.fromRGB(78, 68, 73),
        KnobOn        = Color3.fromRGB(255, 255, 255)
    }

    local ICONS = {
        Search   = "rbxassetid://7733911828",
        Chevron  = "rbxassetid://7733717447",
        More     = "rbxassetid://7734021300",
        Menu     = "rbxassetid://7733993211",
        Combat   = "rbxassetid://7734053426",
        Movement = "rbxassetid://7733799901",
        Visuals  = "rbxassetid://7733774602",
        Player   = "rbxassetid://7733954760",
        User     = "rbxassetid://7733954760",
        Chart    = "rbxassetid://7733749837",
        Clock    = "rbxassetid://7733734762",
        Compass  = "rbxassetid://7733720755",
        Signal   = "rbxassetid://7734058495",
        Radar    = "rbxassetid://7734053426",
        Speed    = "rbxassetid://7733799901"
    }

    local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local TWEEN_SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    -- HUD WATERMARK
    local HudContainer = Instance.new("Frame")
    HudContainer.Size = UDim2.new(0, 600, 0, 50)
    HudContainer.Position = UDim2.new(0, 16, 0, 48)
    HudContainer.BackgroundTransparency = 1
    HudContainer.Parent = ScreenGui

    local HudVerticalLayout = Instance.new("UIListLayout")
    HudVerticalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    HudVerticalLayout.Padding = UDim.new(0, 4)
    HudVerticalLayout.Parent = HudContainer

    local function createHudRow(name, height, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        row.Parent = HudContainer
        local hLayout = Instance.new("UIListLayout")
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.SortOrder = Enum.SortOrder.LayoutOrder
        hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        hLayout.Padding = UDim.new(0, 5)
        hLayout.Parent = row
        return row
    end

    local TopHudRow = createHudRow("TopRow", 22, 1)
    local BottomHudRow = createHudRow("BottomRow", 22, 2)

    local function createHudPill(parent, order)
        local pill = Instance.new("Frame")
        pill.AutomaticSize = Enum.AutomaticSize.X
        pill.Size = UDim2.new(0, 0, 1, 0)
        pill.BackgroundColor3 = THEME.PillBg
        pill.BorderSizePixel = 0
        pill.LayoutOrder = order
        pill.Parent = parent
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 5)
        local stroke = Instance.new("UIStroke", pill)
        stroke.Color = THEME.Border
        stroke.Thickness = 1
        local pad = Instance.new("UIPadding", pill)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        local layout = Instance.new("UIListLayout", pill)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 5)
        return pill
    end

    local function addHudDivider(parent, order)
        local div = Instance.new("Frame", parent)
        div.Size = UDim2.new(0, 1, 0, 10)
        div.BackgroundColor3 = THEME.Divider
        div.BorderSizePixel = 0
        div.LayoutOrder = order
    end

    local function addHudText(parent, text, isMuted, order)
        local lbl = Instance.new("TextLabel", parent)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 10.5
        lbl.TextColor3 = isMuted and THEME.TextMuted or THEME.TextPrimary
        lbl.LayoutOrder = order
        return lbl
    end

    local function addHudSmallIcon(parent, iconId, order)
        local icon = Instance.new("ImageLabel", parent)
        icon.Size = UDim2.new(0, 11, 0, 11)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ImageColor3 = THEME.Accent
        icon.LayoutOrder = order
        return icon
    end

    local BrandPill = createHudPill(TopHudRow, 1)
    local HudLogoWrap = Instance.new("Frame", BrandPill)
    HudLogoWrap.Size = UDim2.new(0, 20, 0, 20)
    HudLogoWrap.BackgroundTransparency = 1
    HudLogoWrap.LayoutOrder = 1

    local HudBrandLogo = Instance.new("ImageLabel", HudLogoWrap)
    HudBrandLogo.Size = UDim2.new(1.35, 0, 1.35, 0)
    HudBrandLogo.Position = UDim2.new(-0.175, 0, -0.175, 0)
    HudBrandLogo.BackgroundTransparency = 1
    HudBrandLogo.Image = CUSTOM_LOGO_ID
    HudBrandLogo.ScaleType = Enum.ScaleType.Fit
    HudBrandLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)

    addHudDivider(BrandPill, 2)
    addHudText(BrandPill, "SKV FTAP", false, 3)

    local StatsPill = createHudPill(TopHudRow, 2)
    addHudSmallIcon(StatsPill, ICONS.User, 1)
    addHudText(StatsPill, string.lower(LocalPlayer.Name), false, 2)
    addHudDivider(StatsPill, 3)
    addHudSmallIcon(StatsPill, ICONS.Chart, 4)
    local FpsLabel = addHudText(StatsPill, "0 Fps", false, 5)
    addHudDivider(StatsPill, 6)
    addHudSmallIcon(StatsPill, ICONS.Clock, 7)
    local TimeLabel = addHudText(StatsPill, "00:00:00", false, 8)

    local PosPill = createHudPill(BottomHudRow, 1)
    addHudSmallIcon(PosPill, ICONS.Compass, 1)
    addHudDivider(PosPill, 2)
    local PosLabel = addHudText(PosPill, "0, 0, 0", false, 3)

    local PingPill = createHudPill(BottomHudRow, 2)
    addHudSmallIcon(PingPill, ICONS.Signal, 1)
    addHudDivider(PingPill, 2)
    local PingLabel = addHudText(PingPill, "0 Ping", false, 3)

    -- FPS/Ping updater loop
    local fpsCounter, lastFpsCheck = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        local now = os.clock()
        if now - lastFpsCheck >= 1 then
            FpsLabel.Text = string.format("%d Fps", fpsCounter)
            fpsCounter = 0
            lastFpsCheck = now
        end
        TimeLabel.Text = os.date("%H:%M:%S")
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        PingLabel.Text = string.format("%d Ping", ping)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPos = character.HumanoidRootPart.Position
            PosLabel.Text = string.format("%d, %d, %d", math.floor(currentPos.X), math.floor(currentPos.Y), math.floor(currentPos.Z))
        end
    end)

    -- MAIN GUI WINDOW (SKV FTAP)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 790, 0, 490)
    Main.Position = UDim2.new(0.5, -395, 0.5, -245)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = THEME.Border
    MainStroke.Thickness = 1.2

    local GlowBackdrop = Instance.new("ImageLabel", Main)
    GlowBackdrop.Name = "GlowBackdrop"
    GlowBackdrop.BackgroundTransparency = 1
    GlowBackdrop.Position = UDim2.new(0, -45, 0, -45)
    GlowBackdrop.Size = UDim2.new(1, 90, 1, 90)
    GlowBackdrop.ZIndex = 0
    GlowBackdrop.Image = "rbxassetid://5028857084"
    GlowBackdrop.ImageColor3 = THEME.AccentDark
    GlowBackdrop.ImageTransparency = 0.83
    GlowBackdrop.ScaleType = Enum.ScaleType.Slice
    GlowBackdrop.SliceCenter = Rect.new(24, 24, 276, 276)

    -- Dragging
    do
        local dragging, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    -- TopBar & Search
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.BackgroundTransparency = 1

    local SearchBox = Instance.new("Frame", TopBar)
    SearchBox.Size = UDim2.new(0, 250, 0, 26)
    SearchBox.Position = UDim2.new(0, 185, 0, 15)
    SearchBox.BackgroundColor3 = THEME.CardBg
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SearchBox).Color = THEME.Border

    local SearchInput = Instance.new("TextBox", SearchBox)
    SearchInput.PlaceholderText = "Search feature..."
    SearchInput.PlaceholderColor3 = THEME.TextMuted
    SearchInput.TextColor3 = THEME.TextPrimary
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 11
    SearchInput.Position = UDim2.new(0, 30, 0, 0)
    SearchInput.Size = UDim2.new(1, -36, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 155, 1, -58)
    Sidebar.Position = UDim2.new(0, 14, 0, 54)
    Sidebar.BackgroundTransparency = 1
    local SideList = Instance.new("UIListLayout", Sidebar)
    SideList.Padding = UDim.new(0, 2)

    local function addCategory(name)
        local lbl = Instance.new("TextLabel", Sidebar)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = "   " .. name:upper()
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextColor3 = THEME.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    addCategory("Features")

    -- Content Columns Area
    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Size = UDim2.new(1, -195, 1, -62)
    ContentArea.Position = UDim2.new(0, 182, 0, 54)
    ContentArea.BackgroundTransparency = 1

    local Col1 = Instance.new("ScrollingFrame", ContentArea)
    Col1.Size = UDim2.new(0.485, 0, 1, 0)
    Col1.BackgroundTransparency = 1
    Col1.ScrollBarThickness = 0
    Instance.new("UIListLayout", Col1).Padding = UDim.new(0, 12)

    local Col2 = Instance.new("ScrollingFrame", ContentArea)
    Col2.Size = UDim2.new(0.485, 0, 1, 0)
    Col2.Position = UDim2.new(0.515, 0, 0, 0)
    Col2.BackgroundTransparency = 1
    Col2.ScrollBarThickness = 0
    Instance.new("UIListLayout", Col2).Padding = UDim.new(0, 12)

    local function createCard(parent, titleText)
        local card = Instance.new("Frame", parent)
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = THEME.CardBg
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", card).Color = THEME.Border
        
        local p = Instance.new("UIPadding", card)
        p.PaddingTop = UDim.new(0, 11)
        p.PaddingBottom = UDim.new(0, 13)
        p.PaddingLeft = UDim.new(0, 12)
        p.PaddingRight = UDim.new(0, 12)
        
        local list = Instance.new("UIListLayout", card)
        list.Padding = UDim.new(0, 10)

        local header = Instance.new("Frame", card)
        header.Size = UDim2.new(1, 0, 0, 18)
        header.BackgroundTransparency = 1

        local title = Instance.new("TextLabel", header)
        title.Size = UDim2.new(1, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.TextColor3 = THEME.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left
        return card
    end

    local registeredRows = {}
    local function addToggle(card, name, description, defaultState, callback)
        local row = Instance.new("Frame", card)
        row.Size = UDim2.new(1, 0, 0, description and 30 or 21)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, {Frame = row, Name = name:lower()})

        local rowTitle = Instance.new("TextLabel", row)
        rowTitle.Size = UDim2.new(1, -40, 0, 14)
        rowTitle.BackgroundTransparency = 1
        rowTitle.Text = name
        rowTitle.Font = Enum.Font.GothamMedium
        rowTitle.TextSize = 11
        rowTitle.TextColor3 = THEME.TextPrimary
        rowTitle.TextXAlignment = Enum.TextXAlignment.Left

        if description then
            local rowDesc = Instance.new("TextLabel", row)
            rowDesc.Size = UDim2.new(1, -40, 0, 12)
            rowDesc.Position = UDim2.new(0, 0, 0, 14)
            rowDesc.BackgroundTransparency = 1
            rowDesc.Text = description
            rowDesc.Font = Enum.Font.Gotham
            rowDesc.TextSize = 9
            rowDesc.TextColor3 = THEME.TextMuted
            rowDesc.TextXAlignment = Enum.TextXAlignment.Left
        end

        local switch = Instance.new("TextButton", row)
        switch.Size = UDim2.new(0, 32, 0, 16)
        switch.Position = UDim2.new(1, -32, 0.5, -8)
        switch.BackgroundColor3 = defaultState and THEME.Accent or THEME.ToggleOff
        switch.Text = ""
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", switch)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = defaultState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = defaultState and THEME.KnobOn or THEME.KnobOff
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local isToggled = defaultState
        switch.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            switch.BackgroundColor3 = isToggled and THEME.Accent or THEME.ToggleOff
            knob.BackgroundColor3 = isToggled and THEME.KnobOn or THEME.KnobOff
            knob.Position = isToggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            if callback then callback(isToggled) end
        end)
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, item in ipairs(registeredRows) do
            item.Frame.Visible = (query == "" or string.find(item.Name, query, 1, true) ~= nil)
        end
    end)

    -- Карточки с функциями под FTAP
    local cardProtection = createCard(Col1, "Protection & Power")
    addToggle(cardProtection, "Anti-Fling", "Защита от флинга игроков", true, function(state)
        if callbacks.OnAntiFlingToggle then callbacks.OnAntiFlingToggle(state) end
    end)
    addToggle(cardProtection, "Super Duper Far Power", "Максимальная сила броска", true, function(state)
        if state and callbacks.OnPowerBoost then callbacks.OnPowerBoost() end
    end)

    local cardAim = createCard(Col1, "Aim Bot (Hands & Legs)")
    local aimActive = false
    local currentPart = "LeftHand"
    addToggle(cardAim, "Enable Aim Bot", "Наведение броска по бинду (Q)", false, function(state)
        aimActive = state
        if callbacks.OnAimToggle then callbacks.OnAimToggle(aimActive, currentPart, Enum.KeyCode.Q) end
    end)

    local cardESP = createCard(Col2, "ESP Visuals")
    local espSettings = {Boxes = false, Names = false, Distance = false, Health = false, Tracers = false}
    local function updateESP()
        if callbacks.OnESPToggle then callbacks.OnESPToggle(espSettings) end
    end
    addToggle(cardESP, "Boxes", "Подсветка рамками", false, function(s) espSettings.Boxes = s; updateESP() end)
    addToggle(cardESP, "Names", "Отображение имен", false, function(s) espSettings.Names = s; updateESP() end)
    addToggle(cardESP, "Distance", "Дистанция до игроков", false, function(s) espSettings.Distance = s; updateESP() end)
    addToggle(cardESP, "Health", "Полоски здоровья", false, function(s) espSettings.Health = s; updateESP() end)
    addToggle(cardESP, "Tracers", "Линии до игроков", false, function(s) espSettings.Tracers = s; updateESP() end)

    -- Скрытие меню по RightShift
    local isUIVisible = true
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            isUIVisible = not isUIVisible
            Main.Visible = isUIVisible
        end
    end)

    return GuiLibrary
end

return GuiLibrary
