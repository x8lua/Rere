-- This surface must survive shutting down the failed immediate-mode renderer.
local Cards = require(script.Parent.CrashCards)

return function(Iris, reason, options)
    local card = Cards[Random.new():NextInteger(1, #Cards)]
    local report = table.concat({
        "Rere beta crash report",
        "error code: " .. card.code,
        "library version: " .. tostring(Iris.BetaVersion or Iris.Version),
        "time (UTC): " .. os.date("!%Y-%m-%dT%H:%M:%SZ"),
        "", reason,
    }, "\n")
    local player = game:GetService("Players").LocalPlayer
    local parent = player and player:FindFirstChildOfClass("PlayerGui")
    if not parent then parent = game:GetService("CoreGui") end
    local existing = parent:FindFirstChild("RereCrashPopup")
    if existing then existing:Destroy() end

    local config = Iris.Internal._config
    local gui = Instance.new("ScreenGui")
    gui.Name = "RereCrashPopup"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local panel = Instance.new("Frame")
    panel.Name = "CrashWindow"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.new(1, -24, 1, -24)
    panel.BackgroundColor3 = config.WindowBgColor or Color3.fromRGB(32, 32, 32)
    panel.BorderSizePixel = 0
    panel.Parent = gui
    local constraint = Instance.new("UISizeConstraint")
    constraint.MaxSize = Vector2.new(500, 410)
    constraint.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = config.BorderColor or Color3.fromRGB(76, 76, 76)
    stroke.Thickness = 1
    stroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.fromOffset(0, 0)
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = config.TitleBgActiveColor or Color3.fromRGB(55, 55, 55)
    title.BorderSizePixel = 0
    title.Text = "  Rere / crash report"
    title.TextColor3 = config.TextColor or Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local content = Instance.new("ScrollingFrame")
    content.Name = "Report"
    content.Position = UDim2.fromOffset(12, 44)
    content.Size = UDim2.new(1, -24, 1, -104)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.CanvasSize = UDim2.new()
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = panel
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    layout.Parent = content
    local function text(name, value, color, font)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, -8, 0, 0)
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.BackgroundTransparency = 1
        label.Font = font or Enum.Font.Code
        label.TextSize = 14
        label.TextColor3 = color or title.TextColor3
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextWrapped = true
        label.Text = value
        label.LayoutOrder = #content:GetChildren()
        label.Parent = content
        return label
    end
    text("Art", card.art)
    text("Code", "error code: " .. card.code, Color3.fromRGB(255, 172, 135))
    if card.detail ~= "" then text("Detail", card.detail) end
    text("Reason", reason, Color3.fromRGB(168, 168, 168))

    local footer = Instance.new("Frame")
    footer.Name = "Actions"
    footer.BackgroundTransparency = 1
    footer.Position = UDim2.new(0, 12, 1, -48)
    footer.Size = UDim2.new(1, -24, 0, 36)
    footer.Parent = panel
    local buttons = Instance.new("UIListLayout")
    buttons.SortOrder = Enum.SortOrder.LayoutOrder
    buttons.FillDirection = Enum.FillDirection.Horizontal
    buttons.Padding = UDim.new(0, 8)
    buttons.Parent = footer
    local action = options.Actions and options.Actions[card.code]
    if not action and card.restart then action = options.OnRestart end
    local count = type(action) == "function" and card.action and 3 or 2
    local function button(name, caption, callback)
        local item = Instance.new("TextButton")
        item.Name = name
        item.Size = UDim2.new(1 / count, -(8 * (count - 1)) / count, 1, 0)
        item.BackgroundColor3 = config.ButtonColor or Color3.fromRGB(62, 62, 62)
        item.BorderSizePixel = 0
        item.Font = Enum.Font.Code
        item.TextColor3 = title.TextColor3
        item.TextSize = 13
        item.TextWrapped = true
        item.TextScaled = true
        local textSize = Instance.new("UITextSizeConstraint")
        textSize.MinTextSize = 8
        textSize.MaxTextSize = 13
        textSize.Parent = item
        item.Text = caption
        item.LayoutOrder = #footer:GetChildren()
        item.Parent = footer
        item.Activated:Connect(function() callback(item) end)
        return item
    end
    button("CopyError", "copy error", function(item)
        local copy = (type(setclipboard) == "function" and setclipboard)
            or (type(toclipboard) == "function" and toclipboard)
        local ok = copy and pcall(copy, report)
        item.Text = ok and "copied!" or "clipboard unavailable"
    end)
    if count == 3 then
        button("Restart", card.action, function()
            local ok, err = pcall(action, card.code, report)
            if ok then gui:Destroy() else text("RestartError", tostring(err)) end
        end)
    end
    button("Close", "close", function() gui:Destroy() end)
    gui.Parent = parent
    return gui, card
end
