--[Modules/ESP.lua]--
local ESPModule = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local settings = {
    Boxes = false,
    Names = false,
    Distance = false,
    Health = false,
    Tracers = false
}

local espDrawings = {}

function ESPModule.UpdateSettings(newSettings)
    for k, v in pairs(newSettings) do
        settings[k] = v
    end
end

Players.PlayerRemoving:Connect(function(player)
    if espDrawings[player] then
        for _, drawing in pairs(espDrawings[player]) do
            drawing:Remove()
        end
        espDrawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espDrawings[player] then
                espDrawings[player] = {
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text"),
                    Tracer = Drawing.new("Line")
                }
                espDrawings[player].Box.Visible = false
                espDrawings[player].Name.Visible = false
                espDrawings[player].Tracer.Visible = false
            end
            
            local char = player.Character
            local drawings = espDrawings[player]
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local humanoid = char.Humanoid
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if onScreen and humanoid.Health > 0 then
                    -- Boxes
                    if settings.Boxes then
                        drawings.Box.Visible = true
                        drawings.Box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                        drawings.Box.Position = Vector2.new(vector.X - drawings.Box.Size.X / 2, vector.Y - drawings.Box.Size.Y / 2)
                        drawings.Box.Color = Color3.fromRGB(0, 255, 120)
                        drawings.Box.Thickness = 1
                        drawings.Box.Filled = false
                    else
                        drawings.Box.Visible = false
                    end
                    
                    -- Names, Distance, Health
                    if settings.Names or settings.Distance or settings.Health then
                        drawings.Name.Visible = true
                        local infoText = player.Name
                        
                        if settings.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            infoText = infoText .. " [" .. dist .. "m]"
                        end
                        if settings.Health then
                            infoText = infoText .. " | HP: " .. math.floor(humanoid.Health)
                        end
                        
                        drawings.Name.Text = infoText
                        drawings.Name.Position = Vector2.new(vector.X, vector.Y - 45)
                        drawings.Name.Size = 13
                        drawings.Name.Center = true
                        drawings.Name.Color = Color3.fromRGB(255, 255, 255)
                        drawings.Name.Outline = true
                    else
                        drawings.Name.Visible = false
                    end
                    
                    -- Tracers
                    if settings.Tracers then
                        drawings.Tracer.Visible = true
                        drawings.Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(vector.X, vector.Y)
                        drawings.Tracer.Color = Color3.fromRGB(0, 255, 120)
                        drawings.Tracer.Thickness = 1
                    else
                        drawings.Tracer.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Tracer.Visible = false
            end
        end
    end
end)

return ESPModule
