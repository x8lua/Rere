-- This surface must survive shutting down the failed immediate-mode renderer.
local Cards = require(script.Parent.CrashCards)

return function(Iris, reason, options, notice)
    local critical = notice == nil
    local card = Cards[Random.new():NextInteger(1, #Cards)]
    local report = table.concat({
        critical and "Rere beta critical crash report" or "Rere beta recoverable error report",
        "error code: " .. card.code,
        "library version: " .. tostring(Iris.BetaVersion or Iris.Version),
        "time (UTC): " .. os.date("!%Y-%m-%dT%H:%M:%SZ"),
        critical and "This session has terminated." or "This session is still running.",
        "", reason,
    }, "\n")
    local player = game:GetService("Players").LocalPlayer
    local parent = player and (player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10))
    if not parent then return nil end
    local name = critical and "RereCrashPopup" or "RereErrorNotice"
    local existing = parent:FindFirstChild(name)
    if existing then existing:Destroy() end

    local config = Iris.Internal._config
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local panel = Instance.new("Frame")
    panel.Name = "CrashWindow"
    panel.AnchorPoint = critical and Vector2.new(0.5, 0.5) or Vector2.new(1, 1)
    panel.Position = critical and UDim2.fromScale(0.5, 0.5) or UDim2.new(1, -12, 1, -12)
    panel.Size = UDim2.new(1, -24, 1, -24)
    panel.BackgroundColor3 = config.WindowBgColor or Color3.fromRGB(32, 32, 32)
    panel.BorderSizePixel = 0
    panel.Parent = gui
    local constraint = Instance.new("UISizeConstraint")
    constraint.MaxSize = critical and Vector2.new(500, 440) or Vector2.new(360, 300)
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
    title.Text = critical and "  Rere / crash report" or "  Rere / error"
    title.TextColor3 = config.TextColor or Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    if critical then
        local status = Instance.new("TextLabel")
        status.Name = "SessionStatus"
        status.Position = UDim2.fromOffset(12, 42)
        status.Size = UDim2.new(1, -24, 0, 22)
        status.BackgroundTransparency = 1
        status.Font = Enum.Font.Code
        status.TextSize = 14
        status.TextColor3 = Color3.fromRGB(255, 172, 135)
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.Text = "This session has terminated."
        status.Parent = panel
    end

    local content = Instance.new("ScrollingFrame")
    content.Name = "Report"
    content.Position = UDim2.fromOffset(12, critical and 76 or 44)
    content.Size = UDim2.new(1, -24, 1, critical and -136 or -146)
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
    if notice then
        local count = text("Occurrences", "Occurrences: " .. tostring(notice.count), Color3.fromRGB(168, 168, 168))
        notice.UpdateCount = function(value)
            if count.Parent then count.Text = "Occurrences: " .. tostring(value) end
        end
        local mute = Instance.new("TextButton")
        mute.Name = "MuteThisError"
        mute.Position = UDim2.new(0, 12, 1, -92)
        mute.Size = UDim2.new(1, -24, 0, 36)
        mute.BackgroundTransparency = 1
        mute.Text = ""
        mute.Parent = panel
        local box = Instance.new("TextLabel")
        box.Name = "Check"
        box.Position = UDim2.new(0, 0, 0.5, -9)
        box.Size = UDim2.fromOffset(18, 18)
        box.BackgroundColor3 = config.FrameBgColor or Color3.fromRGB(58, 58, 58)
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Code
        box.TextSize = 14
        box.TextColor3 = title.TextColor3
        box.Text = ""
        box.Parent = mute
        local caption = Instance.new("TextLabel")
        caption.Name = "Caption"
        caption.Position = UDim2.fromOffset(26, 0)
        caption.Size = UDim2.new(1, -26, 1, 0)
        caption.BackgroundTransparency = 1
        caption.Font = Enum.Font.Code
        caption.TextSize = 12
        caption.TextColor3 = title.TextColor3
        caption.TextWrapped = true
        caption.TextXAlignment = Enum.TextXAlignment.Left
        caption.Text = "Don't remind me for this error again"
        caption.Parent = mute
        local checked = false
        mute.Activated:Connect(function()
            checked = not checked
            box.Text = checked and "X" or ""
            notice.OnMute(checked)
        end)
    end

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
    local action = critical and options.Actions and options.Actions[card.code]
    if critical and not action and card.restart then action = options.OnRestart end
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
    button("Close", "close", function()
        gui:Destroy()
        if notice and notice.OnDismiss then notice.OnDismiss() end
    end)
    gui.Parent = parent
    return gui, card
end
