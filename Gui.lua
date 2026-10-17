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
        Combat   = "rbxassetid://7734053426",
        Movement = "rbxassetid://7733799901",
        Visuals  = "rbxassetid://7733774602",
        Misc     = "rbxassetid://7734056411",
        User     = "rbxassetid://7733954760",
        Chart    = "rbxassetid://7733749837",
        Clock    = "rbxassetid://7733734762",
        Compass  = "rbxassetid://7733720755",
        Signal   = "rbxassetid://7734058495"
    }

    local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- HUD WATERMARK
    local HudContainer = Instance.new("Frame", ScreenGui)
    HudContainer.Size = UDim2.new(0, 600, 0, 50)
    HudContainer.Position = UDim2.new(0, 16, 0, 48)
    HudContainer.BackgroundTransparency = 1

    local HudVerticalLayout = Instance.new("UIListLayout", HudContainer)
    HudVerticalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    HudVerticalLayout.Padding = UDim.new(0, 4)

    local function createHudRow(name, height, order)
        local row = Instance.new("Frame", HudContainer)
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        local hLayout = Instance.new("UIListLayout", row)
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.SortOrder = Enum.SortOrder.LayoutOrder
        hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        hLayout.Padding = UDim.new(0, 5)
        return row
    end

    local TopHudRow = createHudRow("TopRow", 22, 1)

    local function createHudPill(parent, order)
        local pill = Instance.new("Frame", parent)
        pill.AutomaticSize = Enum.AutomaticSize.X
        pill.Size = UDim2.new(0, 0, 1, 0)
        pill.BackgroundColor3 = THEME.PillBg
        pill.BorderSizePixel = 0
        pill.LayoutOrder = order
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

    local BrandPill = createHudPill(TopHudRow, 1)
    local BrandLogo = Instance.new("ImageLabel", BrandPill)
    BrandLogo.Size = UDim2.new(0, 16, 0, 16)
    BrandLogo.BackgroundTransparency = 1
    BrandLogo.Image = CUSTOM_LOGO_ID
    BrandLogo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    local BrandLogoGrad = Instance.new("UIGradient", BrandLogo)
    BrandLogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
        ColorSequenceKeypoint.new(0.45, THEME.Accent),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(165, 32, 42))
    })
    BrandLogoGrad.Rotation = -35
    addHudDivider(BrandPill, 2)
    local BrandText = addHudText(BrandPill, "SKV FTAP", false, 3)
    local BrandTextGrad = Instance.new("UIGradient", BrandText)
    BrandTextGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, THEME.AccentSoft),
        ColorSequenceKeypoint.new(1.0, THEME.Accent)
    })

    local StatsPill = createHudPill(TopHudRow, 2)
    local FpsLabel = addHudText(StatsPill, "0 Fps", false, 1)
    addHudDivider(StatsPill, 2)
    local HpLabel = addHudText(StatsPill, "100 HP", false, 3)
    addHudDivider(StatsPill, 4)
    local PingLabel = addHudText(StatsPill, "0 Ping", false, 5)

    -- Обновление HUD (FPS, HP, Ping)
    local fpsCounter, lastFpsCheck = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        local now = os.clock()
        if now - lastFpsCheck >= 1 then
            FpsLabel.Text = string.format("%d Fps", fpsCounter)
            fpsCounter = 0
            lastFpsCheck = now
        end
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        PingLabel.Text = string.format("%d Ping", ping)
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            HpLabel.Text = string.format("%d HP", math.max(math.floor(humanoid.Health), 0))
        else
            HpLabel.Text = "0 HP"
        end
    end)

    -- MAIN WINDOW
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 790, 0, 490)
    Main.Position = UDim2.new(0.5, -395, 0.5, -245)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Main).Color = THEME.Border

    -- Dragging (клики по кнопкам/инпутам не двигают окно)
    do
        local dragging, dragStart, startPos
        local function isInteractiveGui(guiObject)
            local current = guiObject
            while current and current ~= Main do
                if current:IsA("TextButton") or current:IsA("ImageButton") or current:IsA("TextBox") then
                    return true
                end
                current = current.Parent
            end
            return false
        end
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if isInteractiveGui(LocalPlayer:GetMouse().Target) then
                    return
                end
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

    -- Показ/скрытие меню по RightShift (при старте меню скрыто)
    local isUIVisible = false
    Main.Visible = false
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.RightShift then
            isUIVisible = not isUIVisible
            Main.Visible = isUIVisible
        end
    end)

    -- Search Bar
    local SearchBox = Instance.new("Frame", Main)
    SearchBox.Size = UDim2.new(0, 250, 0, 26)
    SearchBox.Position = UDim2.new(0, 185, 0, 15)
    SearchBox.BackgroundColor3 = THEME.CardBg
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SearchBox).Color = THEME.Border

    local SearchInput = Instance.new("TextBox", SearchBox)
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search feature..."
    SearchInput.PlaceholderColor3 = THEME.TextMuted
    SearchInput.TextColor3 = THEME.TextPrimary
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 11
    SearchInput.Position = UDim2.new(0, 30, 0, 0)
    SearchInput.Size = UDim2.new(1, -36, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    -- Sidebar Container & Tabs setup
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

    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Size = UDim2.new(1, -195, 1, -62)
    ContentArea.Position = UDim2.new(0, 182, 0, 54)
    ContentArea.BackgroundTransparency = 1

    -- Создаем вкладки (Containers)
    local containers = {}
    local tabButtons = {}
    local activeSidebarTab = nil

    local function createTabContainer(tabName)
        local container = Instance.new("Frame", ContentArea)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Visible = false

        local col1 = Instance.new("ScrollingFrame", container)
        col1.Size = UDim2.new(0.485, 0, 1, 0)
        col1.BackgroundTransparency = 1
        col1.ScrollBarThickness = 0
        Instance.new("UIListLayout", col1).Padding = UDim.new(0, 12)

        local col2 = Instance.new("ScrollingFrame", container)
        col2.Size = UDim2.new(0.485, 0, 1, 0)
        col2.Position = UDim2.new(0.515, 0, 0, 0)
        col2.BackgroundTransparency = 1
        col2.ScrollBarThickness = 0
        Instance.new("UIListLayout", col2).Padding = UDim.new(0, 12)

        containers[tabName] = {Frame = container, Col1 = col1, Col2 = col2}
        return container
    end

    createTabContainer("Combat")
    createTabContainer("Movement")
    createTabContainer("Visuals")
    createTabContainer("Misc")

    local function addSidebarItem(name, iconId, isDefaultActive)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, -4, 0, 29)
        btn.BackgroundColor3 = isDefaultActive and THEME.SidebarActive or THEME.Background
        btn.BackgroundTransparency = isDefaultActive and 0 or 1
        btn.Text = ""
        btn.AutoButtonColor = false

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = THEME.BorderActive
        stroke.Transparency = isDefaultActive and 0 or 1

        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0, 9, 0.5, -7)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageColor3 = isDefaultActive and THEME.Accent or THEME.TextMuted

        local title = Instance.new("TextLabel", btn)
        title.Size = UDim2.new(1, -32, 1, 0)
        title.Position = UDim2.new(0, 30, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 11
        title.TextColor3 = isDefaultActive and THEME.TextPrimary or THEME.TextMuted
        title.TextXAlignment = Enum.TextXAlignment.Left

        if isDefaultActive then
            activeSidebarTab = {Btn = btn, Icon = icon, Title = title, Stroke = stroke, Name = name}
            containers[name].Frame.Visible = true
        else
            containers[name].Frame.Visible = false
        end

        btn.MouseButton1Click:Connect(function()
            if activeSidebarTab.Name == name then return end

            -- Сброс старой вкладки
            TweenService:Create(activeSidebarTab.Btn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
            TweenService:Create(activeSidebarTab.Stroke, TWEEN_FAST, {Transparency = 1}):Play()
            TweenService:Create(activeSidebarTab.Icon, TWEEN_FAST, {ImageColor3 = THEME.TextMuted}):Play()
            TweenService:Create(activeSidebarTab.Title, TWEEN_FAST, {TextColor3 = THEME.TextMuted}):Play()
            containers[activeSidebarTab.Name].Frame.Visible = false

            -- Активация новой
            TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SidebarActive}):Play()
            TweenService:Create(stroke, TWEEN_FAST, {Transparency = 0}):Play()
            TweenService:Create(icon, TWEEN_FAST, {ImageColor3 = THEME.Accent}):Play()
            TweenService:Create(title, TWEEN_FAST, {TextColor3 = THEME.TextPrimary}):Play()
            containers[name].Frame.Visible = true

            activeSidebarTab = {Btn = btn, Icon = icon, Title = title, Stroke = stroke, Name = name}
        end)
    end

    addSidebarItem("Combat", ICONS.Combat, true)
    addSidebarItem("Movement", ICONS.Movement, false)
    addSidebarItem("Visuals", ICONS.Visuals, false)
    addSidebarItem("Misc", ICONS.Misc, false)

    local function createCard(tabName, colNum, titleText)
        local targetCol = (colNum == 1) and containers[tabName].Col1 or containers[tabName].Col2
        local card = Instance.new("Frame", targetCol)
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

    local function addKeybind(card, name, description, defaultKey, callback)
        local row = Instance.new("Frame", card)
        row.Size = UDim2.new(1, 0, 0, description and 30 or 21)
        row.BackgroundTransparency = 1
        table.insert(registeredRows, {Frame = row, Name = name:lower()})

        local rowTitle = Instance.new("TextLabel", row)
        rowTitle.Size = UDim2.new(1, -75, 0, 14)
        rowTitle.BackgroundTransparency = 1
        rowTitle.Text = name
        rowTitle.Font = Enum.Font.GothamMedium
        rowTitle.TextSize = 11
        rowTitle.TextColor3 = THEME.TextPrimary
        rowTitle.TextXAlignment = Enum.TextXAlignment.Left

        if description then
            local rowDesc = Instance.new("TextLabel", row)
            rowDesc.Size = UDim2.new(1, -75, 0, 12)
            rowDesc.Position = UDim2.new(0, 0, 0, 14)
            rowDesc.BackgroundTransparency = 1
            rowDesc.Text = description
            rowDesc.Font = Enum.Font.Gotham
            rowDesc.TextSize = 9
            rowDesc.TextColor3 = THEME.TextMuted
            rowDesc.TextXAlignment = Enum.TextXAlignment.Left
        end

        local bindBtn = Instance.new("TextButton", row)
        bindBtn.Size = UDim2.new(0, 62, 0, 20)
        bindBtn.Position = UDim2.new(1, -62, 0.5, -10)
        bindBtn.BackgroundColor3 = THEME.BadgeBg
        bindBtn.TextColor3 = THEME.AccentSoft
        bindBtn.Font = Enum.Font.GothamBold
        bindBtn.TextSize = 10
        bindBtn.Text = defaultKey.Name
        bindBtn.AutoButtonColor = false
        Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", bindBtn).Color = THEME.Border

        local listening = false
        bindBtn.MouseButton1Click:Connect(function()
            listening = true
            bindBtn.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not listening or gameProcessed then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                bindBtn.Text = input.KeyCode.Name
                if callback then callback(input.KeyCode) end
            end
        end)
        return bindBtn
    end

    -- Наполнение вкладок функциями FTAP
    -- [COMBAT]
    local cCard1 = createCard("Combat", 1, "Fling & Power")
    addToggle(cCard1, "Anti-Fling", "Защита от флинга", true, function(s) if callbacks.OnAntiFlingToggle then callbacks.OnAntiFlingToggle(s) end end)
    addToggle(cCard1, "Super Duper Far Power", "Макс. сила броска", true, function(s) if callbacks.OnPowerBoost then callbacks.OnPowerBoost(s) end end)
    addToggle(cCard1, "Fling Aura", "Швыряние всех вокруг тебя", false, function(s) if callbacks.OnFlingAuraToggle then callbacks.OnFlingAuraToggle(s) end end)

    local cCard2 = createCard("Combat", 2, "Aim Assist")
    local aimEnabled = false
    local aimKey = Enum.KeyCode.Q
    addToggle(cCard2, "Enable Aim Bot", "Наведение по бинду (зажми)", false, function(s)
        aimEnabled = s
        if callbacks.OnAimToggle then callbacks.OnAimToggle(s, "Head", aimKey) end
    end)
    addKeybind(cCard2, "Aim Keybind", "Клавиша прицеливания", aimKey, function(key)
        aimKey = key
        if callbacks.OnAimToggle then callbacks.OnAimToggle(aimEnabled, "Head", key) end
    end)

    -- [VISUALS]
    local vCard1 = createCard("Visuals", 1, "ESP Options")
    local espSettings = {Boxes = false, Names = false, Distance = false, Health = false, Tracers = false, Chams = false}
    local function updateESP() if callbacks.OnESPToggle then callbacks.OnESPToggle(espSettings) end end

    addToggle(vCard1, "Boxes", "Рамки вокруг игроков", false, function(s) espSettings.Boxes = s; updateESP() end)
    addToggle(vCard1, "Names", "Имена игроков", false, function(s) espSettings.Names = s; updateESP() end)
    addToggle(vCard1, "Distance", "Дистанция", false, function(s) espSettings.Distance = s; updateESP() end)
    addToggle(vCard1, "Health", "Полоски здоровья", false, function(s) espSettings.Health = s; updateESP() end)
    addToggle(vCard1, "Tracers", "Линии до игроков", false, function(s) espSettings.Tracers = s; updateESP() end)
    addToggle(vCard1, "Chams", "Подсветка тел (Chams)", false, function(s) espSettings.Chams = s; updateESP() end)

    -- [MISC]
    local mCard1 = createCard("Misc", 1, "Settings")
    addToggle(mCard1, "Third Person View", "Вид от третьего лица", true, function(s)
        if callbacks.OnThirdPersonToggle then
            callbacks.OnThirdPersonToggle(s)
        else
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = s and 150 or 12
        end
    end)

    return GuiLibrary
end

return GuiLibrary
