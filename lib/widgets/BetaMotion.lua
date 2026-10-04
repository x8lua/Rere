local TweenService = game:GetService("TweenService")
local Motion = {}

function Motion.Cancel(widget, slot)
    local motions = rawget(widget, "BetaMotions")
    local previous = motions and motions[slot]
    if not previous then return end
    motions[slot] = nil
    if previous.Connection then previous.Connection:Disconnect() end
    previous.Tween:Cancel()
end

function Motion.Play(widget, slot, object, goals, duration, enabled, completed)
    Motion.Cancel(widget, slot)
    if not enabled then
        for key, value in pairs(goals) do object[key] = value end
        if completed then completed() end
        return
    end
    widget.BetaMotions = rawget(widget, "BetaMotions") or {}
    local motion = {Tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goals)}
    widget.BetaMotions[slot] = motion
    motion.Connection = motion.Tween.Completed:Connect(function(status)
        if widget.BetaMotions[slot] ~= motion then return end
        widget.BetaMotions[slot] = nil
        motion.Connection:Disconnect()
        if status == Enum.PlaybackState.Completed and completed then completed() end
    end)
    motion.Tween:Play()
end

function Motion.Clear(widget)
    widget.BetaMotionGeneration = (rawget(widget, "BetaMotionGeneration") or 0) + 1
    local motions = rawget(widget, "BetaMotions")
    if motions then
        local slots = {}
        for slot in pairs(motions) do table.insert(slots, slot) end
        for _, slot in ipairs(slots) do Motion.Cancel(widget, slot) end
    end
end

function Motion.ContentHeight(container)
    local scale = 1
    local ancestor = container
    while ancestor do
        local transform = ancestor:FindFirstChildWhichIsA("UIScale")
        if transform then scale *= transform.Scale end
        ancestor = ancestor.Parent
    end
    local padding = container.UIPadding
    return container.UIListLayout.AbsoluteContentSize.Y / math.max(scale, 0.001)
        + padding.PaddingTop.Offset + padding.PaddingBottom.Offset
end

return Motion
