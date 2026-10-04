-- RereNotify: standalone animated notifications. No dependency on Rere.
-- local notifications = RereNotify.new({Parent = player.PlayerGui})
-- local notice = notifications:Notify({Title = "Saved", Text = "Config saved.", Duration = 4})
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Library = {}
local tones = {
    Info = {Icon = "i", Color = Color3.fromRGB(177, 186, 201)},
    Success = {Icon = "✓", Color = Color3.fromRGB(143, 191, 162)},
    Warning = {Icon = "!", Color = Color3.fromRGB(214, 185, 128)},
    Error = {Icon = "×", Color = Color3.fromRGB(209, 139, 139)},
}
local function number(value: any, default: number, low: number, high: number): number
    local n = tonumber(value)
    if not n or n ~= n then return default end
    return math.clamp(n, low, high)
end
local function text(value: any, limit: number): string
    local s = tostring(value or "")
    local length = utf8.len(s)
    if not length then return "Invalid text" end
    if length > limit then return s:sub(1, (utf8.offset(s, limit + 1) or #s + 1) - 1) .. "…" end
    return s
end
local function make(class: string, props: any, parent: Instance): any
    local instance: any = Instance.new(class)
    for key, value in pairs(props) do instance[key] = value end
    instance.Parent = parent
    return instance
end
function Library.new(options: any): any
    options = options or {}
    local parent = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local manager: any = {Alive = true, Items = {}, Pending = {}, Connections = {}, Serial = 0}
    local width = number(options.Width, 320, 240, 480)
    local maximum = math.floor(number(options.MaxVisible, 4, 1, 8))
    local gap = number(options.Gap, 8, 2, 24)
    local padding = number(options.Padding, 20, 8, 48)
    local motion = options.Animated ~= false
    local centered = options.Position == "Center"
    local duration = number(options.Duration, 4.5, 0, 300)
    local gui = make("ScreenGui", {Name = options.Name or "RereNotifications", ResetOnSpawn = false,
        IgnoreGuiInset = centered, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = number(options.DisplayOrder, 100000, 1, 1000000)}, parent)
    local root = make("Frame", {Name = "NotificationSurface", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, ClipsDescendants = true}, gui)
    manager.Gui = gui
    local pump: any
    local layout: any
    local function connect(signal: RBXScriptSignal, callback: any, list: any)
        local connection = signal:Connect(callback)
        table.insert(list or manager.Connections, connection)
        return connection
    end
    local function tween(entry: any, slot: string, object: Instance, goals: any, time: number)
        if entry.Tweens[slot] then entry.Tweens[slot]:Cancel() end
        if not motion then
            for key, value in pairs(goals) do (object :: any)[key] = value end
            return nil
        end
        local value = TweenService:Create(object, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goals)
        entry.Tweens[slot] = value
        value:Play()
        return value
    end
    local function remove(entry: any)
        for _, value in pairs(entry.Tweens) do value:Cancel() end
        for _, connection in ipairs(entry.Connections) do connection:Disconnect() end
        table.clear(entry.Connections)
        if entry.Frame then entry.Frame:Destroy(); entry.Frame = nil end
    end
    local function metrics(entry: any)
        local w = math.max(120, math.min(width, root.AbsoluteSize.X - padding * 2))
        local available = math.max(30, w - 70)
        local measured = TextService:GetTextSize(entry.Text, 12, Enum.Font.Arial, Vector2.new(available, 1000))
        entry.Width = w
        entry.BodyHeight = entry.Text == "" and 0 or math.min(80, math.max(16, measured.Y))
        entry.Height = 48 + entry.BodyHeight + (entry.Action and 30 or 0)
        if entry.Frame then
            entry.Frame.Size = UDim2.fromOffset(w, entry.Height)
            entry.Body.Size = UDim2.new(1, -70, 0, entry.BodyHeight)
            if entry.Button then entry.Button.Visible = entry.Action ~= nil end
        end
    end
    local function close(entry: any, reason: string, immediate: boolean?)
        if entry.Closed then return end
        entry.Closed = true
        local index = table.find(manager.Items, entry)
        if index then table.remove(manager.Items, index) end
        local queued = table.find(manager.Pending, entry)
        if queued then table.remove(manager.Pending, queued) end
        if entry.Frame and not immediate and motion then
            tween(entry, "position", entry.Frame, {Position = entry.Frame.Position + (centered and UDim2.fromOffset(0, -14) or UDim2.fromOffset(26, 0))}, 0.18)
            local exitTween = tween(entry, "opacity", entry.Frame, {GroupTransparency = 1}, 0.18)
            connect(exitTween.Completed, function() remove(entry) end, entry.Connections)
            manager.Exiting[entry] = true
        else remove(entry) end
        if entry.OnClose then task.spawn(function() pcall(entry.OnClose, reason) end) end
        if manager.Alive then pump(); layout() end
    end
    manager.Exiting = {}
    local function build(entry: any)
        local tone = tones[entry.Kind] or tones.Info
        local card = make("CanvasGroup", {Name = "Notice" .. entry.Serial, BackgroundColor3 = Color3.fromRGB(29, 29, 29),
            BorderSizePixel = 0, Size = UDim2.fromOffset(entry.Width, entry.Height),
            AnchorPoint = centered and Vector2.new(0.5, 0.5) or Vector2.new(1, 1),
            Position = centered and UDim2.new(0.5, 0, 0.35, 18) or UDim2.new(1, -padding + 26, 1, -padding),
            GroupTransparency = motion and 1 or 0, ClipsDescendants = true, ZIndex = 2}, root)
        entry.Frame = card
        -- Draw the border inside the CanvasGroup so it fades with all other content.
        for _, edge in ipairs({{UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, 1)},
            {UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1)},
            {UDim2.fromScale(0, 0), UDim2.new(0, 1, 1, 0)},
            {UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0)}}) do
            make("Frame", {BackgroundColor3 = Color3.fromRGB(66, 66, 66), BorderSizePixel = 0,
                Position = edge[1], Size = edge[2], ZIndex = 3}, card)
        end
        make("TextLabel", {Name = "Status", Text = tone.Icon, Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(19, 20), BackgroundTransparency = 1,
            FontFace = Font.fromEnum(Enum.Font.ArialBold), TextSize = 16, TextColor3 = tone.Color, ZIndex = 3}, card)
        entry.TitleLabel = make("TextLabel", {Name = "Title", Text = entry.Title, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(40, 12), Size = UDim2.new(1, -70, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, FontFace = Font.fromEnum(Enum.Font.ArialBold), TextSize = 14,
            TextColor3 = Color3.fromRGB(235, 235, 235), ZIndex = 3}, card)
        entry.Body = make("TextLabel", {Name = "Message", Text = entry.Text, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(40, 34), Size = UDim2.new(1, -70, 0, entry.BodyHeight), TextWrapped = true,
            TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, FontFace = Font.fromEnum(Enum.Font.Arial), TextSize = 12,
            TextColor3 = Color3.fromRGB(160, 160, 160), ZIndex = 3}, card)
        if not centered then
            local dismiss = make("TextButton", {Name = "Dismiss", Text = "×", BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0, 8), Size = UDim2.fromOffset(24, 24),
                FontFace = Font.fromEnum(Enum.Font.Arial), TextSize = 17, TextColor3 = Color3.fromRGB(130, 130, 130), ZIndex = 4}, card)
            connect(dismiss.Activated, function() close(entry, "dismissed") end, entry.Connections)
        end
        entry.Button = make("TextButton", {Name = "Action", Text = entry.ActionText, BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(47, 47, 47), AutoButtonColor = false,
            Position = UDim2.new(0, 40, 1, -33), Size = UDim2.new(1, -70, 0, 23),
            FontFace = Font.fromEnum(Enum.Font.ArialBold), TextSize = 11,
            TextColor3 = Color3.fromRGB(214, 214, 214), Visible = entry.Action ~= nil, ZIndex = 4}, card)
        entry.Progress = make("Frame", {Name = "Lifetime", BackgroundColor3 = tone.Color,
            BackgroundTransparency = 0.35, BorderSizePixel = 0, Position = UDim2.new(0, 1, 1, -2),
            Size = UDim2.new(1, -2, 0, 1), Visible = entry.Duration > 0, ZIndex = 4}, card)
        connect(card.MouseEnter, function() entry.Hovered = true end, entry.Connections)
        connect(card.MouseLeave, function() entry.Hovered = false end, entry.Connections)
        connect(entry.Button.MouseEnter, function() entry.Button.BackgroundColor3 = Color3.fromRGB(61, 61, 61) end, entry.Connections)
        connect(entry.Button.MouseLeave, function() entry.Button.BackgroundColor3 = Color3.fromRGB(47, 47, 47) end, entry.Connections)
        connect(entry.Button.Activated, function()
            if entry.Closed or not entry.Action then return end
            local action = entry.Action
            close(entry, "action")
            task.spawn(function()
                local ok, err = pcall(action)
                if not ok then warn("[RereNotify action] " .. tostring(err)) end
            end)
        end, entry.Connections)
        entry.Remaining = entry.Duration
        entry.Visible = true
        tween(entry, "opacity", card, {GroupTransparency = 0}, 0.24)
    end
    layout = function()
        local total = 0
        for _, entry in ipairs(manager.Items) do
            metrics(entry)
            total += entry.Height + gap
        end
        total = math.max(0, total - gap)
        if centered then
            local y = -total / 2
            for _, entry in ipairs(manager.Items) do
                local goal = UDim2.new(0.5, 0, 0.35, y + entry.Height / 2)
                if entry.Target ~= goal then
                    entry.Target = goal
                    tween(entry, "position", entry.Frame, {Position = goal}, 0.28)
                end
                y += entry.Height + gap
            end
            return
        end
        local y = padding
        for index = #manager.Items, 1, -1 do
            local entry = manager.Items[index]
            local goal = UDim2.new(1, -padding, 1, -y)
            if entry.Target ~= goal then
                entry.Target = goal
                tween(entry, "position", entry.Frame, {Position = goal}, 0.28)
            end
            y += entry.Height + gap
        end
    end
    pump = function()
        if not manager.Alive then return end
        local used = padding
        for _, entry in ipairs(manager.Items) do used += entry.Height + gap end
        local limit = math.max(0, root.AbsoluteSize.Y - padding)
        while #manager.Pending > 0 and #manager.Items < maximum do
            local entry = manager.Pending[1]
            metrics(entry)
            if used + entry.Height > limit then break end
            table.remove(manager.Pending, 1)
            table.insert(manager.Items, entry)
            build(entry)
            used += entry.Height + gap
        end
    end
    function manager:Notify(data: any): any
        assert(self.Alive, "RereNotify has been destroyed")
        data = type(data) == "string" and {Text = data} or data or {}
        self.Serial += 1
        local entry: any = {Serial = self.Serial, Title = text(data.Title or "Notification", 90), Text = text(data.Text, 420),
            Kind = data.Kind or "Info", Duration = number(data.Duration, duration, 0, 300),
            Action = type(data.OnAction) == "function" and data.OnAction or nil, ActionText = text(data.ActionText or "Open", 50),
            OnClose = type(data.OnClose) == "function" and data.OnClose or nil,
            Tweens = {}, Connections = {}, Hovered = false, Closed = false}
        local handle = {}
        function handle:Dismiss() close(entry, "dismissed") end
        function handle:IsClosed(): boolean return entry.Closed end
        function handle:Update(changes: any)
            if entry.Closed or not manager.Alive then return end
            if changes.Title ~= nil then entry.Title = text(changes.Title, 90) end
            if changes.Text ~= nil then entry.Text = text(changes.Text, 420) end
            if changes.Duration ~= nil then entry.Duration = number(changes.Duration, duration, 0, 300) end
            entry.Remaining = entry.Duration
            if entry.Frame then
                entry.TitleLabel.Text = entry.Title
                entry.Body.Text = entry.Text
                entry.Progress.Visible = entry.Duration > 0
                layout()
            end
        end
        if #self.Pending >= 32 then close(self.Pending[1], "queue_limit", true) end
        table.insert(self.Pending, entry)
        pump(); layout()
        return handle
    end
    function manager:Clear()
        local entries = table.clone(self.Items)
        for _, entry in ipairs(self.Pending) do table.insert(entries, entry) end
        table.clear(self.Items); table.clear(self.Pending)
        for _, entry in ipairs(entries) do close(entry, "cleared", true) end
    end
    function manager:Destroy()
        if not self.Alive then return end
        self.Alive = false
        self:Clear()
        for entry in pairs(self.Exiting) do remove(entry) end
        table.clear(self.Exiting)
        for _, connection in ipairs(self.Connections) do connection:Disconnect() end
        table.clear(self.Connections)
        gui:Destroy()
    end
    connect(root:GetPropertyChangedSignal("AbsoluteSize"), function()
        layout()
        local used = padding
        for _, entry in ipairs(manager.Items) do used += entry.Height + gap end
        while used > root.AbsoluteSize.Y - padding and #manager.Items > 0 do
            local entry = table.remove(manager.Items, 1)
            remove(entry); entry.Visible = false; entry.Hovered = false; entry.Target = nil
            table.insert(manager.Pending, 1, entry)
            used -= entry.Height + gap
        end
        pump(); layout()
    end)
    local elapsed = 0
    connect(RunService.Heartbeat, function(dt)
        elapsed += dt
        if elapsed < 1 / 30 then return end
        local delta = elapsed
        elapsed = 0
        for entry in pairs(manager.Exiting) do if not entry.Frame then manager.Exiting[entry] = nil end end
        local expired = {}
        for _, entry in ipairs(manager.Items) do
            if entry.Duration > 0 and not (options.PauseOnHover ~= false and entry.Hovered) then
                entry.Remaining = math.max(0, entry.Remaining - delta)
                entry.Progress.Size = UDim2.fromOffset(math.max(0, (entry.Width - 2) * entry.Remaining / entry.Duration), 1)
                if entry.Remaining <= 0 then table.insert(expired, entry) end
            end
        end
        for _, entry in ipairs(expired) do close(entry, "expired") end
    end)
    return manager
end
return Library
