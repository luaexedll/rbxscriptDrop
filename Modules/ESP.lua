--[Modules/ESP.lua]--111
local ESPModule = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local settings = {
    Boxes = false,
    Names = false,
    Distance = false,
    Health = false,
    Tracers = false,
    Chams = false
}

local ACCENT = Color3.fromRGB(246, 92, 82)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local HEALTH_BACK = Color3.fromRGB(25, 20, 22)

-- У части экзекьюторов нет Drawing API — тогда работают только Chams
local hasDrawing = (Drawing ~= nil)
local espDrawings = {}
local highlights = {}

local function isEspEnabled()
    return settings.Boxes or settings.Names or settings.Distance or settings.Health or settings.Tracers
end

local function createDrawings()
    return {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBack = Drawing.new("Square"),
        HealthFill = Drawing.new("Square")
    }
end

local function hideDrawings(drawings)
    if not drawings then
        return
    end
    drawings.Box.Visible = false
    drawings.Name.Visible = false
    drawings.Tracer.Visible = false
    drawings.HealthBack.Visible = false
    drawings.HealthFill.Visible = false
end

local function destroyHighlight(player)
    local highlight = highlights[player]
    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end
end

function ESPModule.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if settings[key] ~= nil then
            settings[key] = value
        end
    end
    if not settings.Chams then
        for player in pairs(highlights) do
            destroyHighlight(player)
        end
    end
    if not isEspEnabled() then
        for _, drawings in pairs(espDrawings) do
            hideDrawings(drawings)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    local drawings = espDrawings[player]
    if drawings then
        hideDrawings(drawings)
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
        espDrawings[player] = nil
    end
    destroyHighlight(player)
end)

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            -- Chams (Highlight) --------------------------------------------
            if settings.Chams then
                if char and hrp then
                    local highlight = highlights[player]
                    if not highlight or highlight.Parent ~= char then
                        destroyHighlight(player)
                        highlight = Instance.new("Highlight")
                        highlight.Name = "SKV_Chams"
                        highlight.FillColor = ACCENT
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0.2
                        highlight.Adornee = char
                        highlight.Parent = char
                        highlights[player] = highlight
                    end
                else
                    destroyHighlight(player)
                end
            else
                destroyHighlight(player)
            end

            -- Drawing ESP ---------------------------------------------------
            local drawings = espDrawings[player]
            if isEspEnabled() and hasDrawing and char and hrp and humanoid and humanoid.Health > 0 then
                if not drawings then
                    drawings = createDrawings()
                    espDrawings[player] = drawings
                end

                -- Рамка строится по реальному росту персонажа (голова → ноги)
                local head = char:FindFirstChild("Head")
                local topOffset = head and (head.Size.Y * 0.5) or 2.5
                local topPoint, onTop = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, topOffset + 1, 0))
                local bottomPoint, onBottom = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = bottomPoint.Y - topPoint.Y

                if (onTop or onBottom) and height > 4 then
                    local width = height * 0.6
                    local centerX = (topPoint.X + bottomPoint.X) * 0.5
                    local boxTop = topPoint.Y
                    local boxPosition = Vector2.new(centerX - width * 0.5, boxTop)

                    -- Boxes
                    if settings.Boxes then
                        drawings.Box.Visible = true
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = boxPosition
                        drawings.Box.Color = ACCENT
                        drawings.Box.Thickness = 1
                    else
                        drawings.Box.Visible = false
                    end

                    -- Health (полоска справа от рамки)
                    if settings.Health then
                        local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                        local barX = boxPosition.X + width + 3
                        local fillHeight = height * ratio

                        drawings.HealthBack.Visible = true
                        drawings.HealthBack.Size = Vector2.new(3, height)
                        drawings.HealthBack.Position = Vector2.new(barX, boxTop)
                        drawings.HealthBack.Color = HEALTH_BACK
                        drawings.HealthBack.Filled = true

                        drawings.HealthFill.Visible = true
                        drawings.HealthFill.Size = Vector2.new(2, fillHeight)
                        drawings.HealthFill.Position = Vector2.new(barX + 0.5, boxTop + (height - fillHeight))
                        drawings.HealthFill.Color = Color3.new(1 - ratio, ratio, 0)
                        drawings.HealthFill.Filled = true
                    else
                        drawings.HealthBack.Visible = false
                        drawings.HealthFill.Visible = false
                    end

                    -- Names / Distance
                    if settings.Names or settings.Distance then
                        local textParts = {}
                        if settings.Names then
                            table.insert(textParts, player.DisplayName or player.Name)
                        end
                        if settings.Distance then
                            local myChar = LocalPlayer.Character
                            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                            if myHrp then
                                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                                table.insert(textParts, "[" .. distance .. "m]")
                            end
                        end
                        drawings.Name.Visible = #textParts > 0
                        drawings.Name.Text = table.concat(textParts, " ")
                        drawings.Name.Position = Vector2.new(centerX, boxTop - 16)
                        drawings.Name.Size = 13
                        drawings.Name.Center = true
                        drawings.Name.Color = TEXT_COLOR
                        drawings.Name.Outline = true
                        drawings.Name.OutlineColor = Color3.new(0, 0, 0)
                    else
                        drawings.Name.Visible = false
                    end

                    -- Tracers
                    if settings.Tracers then
                        local viewport = camera.ViewportSize
                        drawings.Tracer.Visible = true
                        drawings.Tracer.From = Vector2.new(viewport.X * 0.5, viewport.Y)
                        drawings.Tracer.To = Vector2.new(bottomPoint.X, bottomPoint.Y)
                        drawings.Tracer.Color = ACCENT
                        drawings.Tracer.Thickness = 1
                    else
                        drawings.Tracer.Visible = false
                    end
                else
                    hideDrawings(drawings)
                end
            elseif drawings then
                hideDrawings(drawings)
            end
        end
    end
end)

return ESPModule
