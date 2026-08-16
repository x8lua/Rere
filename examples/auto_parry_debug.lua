-- Complete Rere executor example: Gakuran auto-parry plus live diagnostics.
local compiler = loadstring or load
assert(type(compiler) == "function", "Rere requires loadstring or load")
if _G.__CodexAutoParryRere and _G.__CodexAutoParryRere.Shutdown then
    pcall(_G.__CodexAutoParryRere.Shutdown)
end
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.24/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()
_G.__CodexAutoParryRere = Rere

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
if _G.__CodexAutoParry and _G.__CodexAutoParry.Stop then _G.__CodexAutoParry.Stop() end

local controller = {
    Enabled = true, Radius = 14, HoldTime = 0.24, HeavyDelay = 0.4,
    TriggerCount = 0, SuccessfulBlocks = 0, RejectedBlocks = 0,
    Connections = {}, BlockingUntil = 0, PulseActive = false,
    LastBlockState = "Never attempted",
    LastAnimation = "", LastTarget = "", LastError = "", Events = {},
}
local function logEvent(message)
    table.insert(controller.Events, 1, os.date("%H:%M:%S") .. "  " .. message)
    while #controller.Events > 40 do table.remove(controller.Events) end
end
local function getBlockModule()
    local character = LocalPlayer.Character
    local data = character and character:FindFirstChild("PlayerData")
    local combatType = data and data:GetAttribute("CombatType") or "Base"
    local root = ReplicatedStorage:FindFirstChild("CombatSystemClient")
    local combat = root and root:FindFirstChild("Combat")
    local folder = combat and (combat:FindFirstChild(combatType) or combat:FindFirstChild("Base"))
    local script = folder and folder:FindFirstChild("Block")
    if not script then return nil, "Block module not found" end
    local ok, module = pcall(require, script)
    if not ok then return nil, tostring(module) end
    return module
end
local function canReact(enemyCharacter)
    if not controller.Enabled then return false end
    local character = LocalPlayer.Character
    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
    local enemyRoot = enemyCharacter and enemyCharacter:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local enemyHumanoid = enemyCharacter and enemyCharacter:FindFirstChildOfClass("Humanoid")
    if not localRoot or not enemyRoot or not humanoid or humanoid.Health <= 0 then return false end
    if not enemyHumanoid or enemyHumanoid.Health <= 0 then return false end
    local offset = localRoot.Position - enemyRoot.Position
    if offset.Magnitude > controller.Radius or offset.Magnitude < 0.05 then return false end
    if enemyRoot.CFrame.LookVector:Dot(offset.Unit) < -0.15 then return false end
    for _, attribute in ipairs({"Ragdoll", "Downed", "GrappleWinnerStun", "CantAnything"}) do
        if character:GetAttribute(attribute) == true then return false end
    end
    return true, offset.Magnitude
end
local attackAnimations = {
    ["83491849294956"] = {Name = "Punch 1", Delay = 0},
    ["89420531853362"] = {Name = "Punch 2", Delay = 0},
    ["83730275893449"] = {Name = "Punch 3", Delay = 0},
    ["106980660082799"] = {Name = "Punch 4", Delay = 0},
    ["78888626472394"] = {Name = "Heavy punch", Heavy = true},
}
local function startOrExtendBlockPulse()
    controller.BlockingUntil = math.max(controller.BlockingUntil, os.clock() + controller.HoldTime)
    if controller.PulseActive then
        logEvent(string.format("BLOCK extended to %.2fs", controller.BlockingUntil - os.clock()))
        return
    end
    controller.PulseActive = true
    task.spawn(function()
        local block, errorMessage = getBlockModule()
        if not block or typeof(block.Block) ~= "function" then
            controller.LastError = errorMessage or "Block function missing"
            controller.LastBlockState = "Module error"
            controller.PulseActive = false
            logEvent("ERROR " .. controller.LastError)
            return
        end
        local character, accepted = LocalPlayer.Character, false
        while controller.Enabled and os.clock() < controller.BlockingUntil do
            local ok, callError = pcall(block.Block)
            if not ok then
                controller.LastError = tostring(callError)
                logEvent("ERROR Block(): " .. controller.LastError)
                break
            end
            local credit = _G.__GakuranAcCombatInputCreditAt
            if typeof(credit) ~= "table" then credit = {}; _G.__GakuranAcCombatInputCreditAt = credit end
            credit["Block.Activated"] = tick()
            accepted = accepted or (character and character:GetAttribute("Blocking") == true)
            task.wait()
        end
        if typeof(block.Unblock) == "function" then pcall(block.Unblock) end
        controller.PulseActive = false
        if accepted then
            controller.SuccessfulBlocks += 1
            controller.LastBlockState = "Accepted"
            logEvent("BLOCK accepted and released")
        else
            controller.RejectedBlocks += 1
            controller.LastBlockState = "Rejected by game state"
            logEvent("BLOCK rejected: Blocking attribute never became true")
        end
    end)
end
local function parry(enemyCharacter, animationId, attack)
    local allowed, distance = canReact(enemyCharacter)
    if not allowed then return end
    controller.LastAnimation = animationId or ""
    controller.LastTarget = enemyCharacter.Name
    controller.TriggerCount += 1
    local delay = attack.Heavy and controller.HeavyDelay or attack.Delay
    logEvent(string.format("PARRY #%d %s target=%s distance=%.1f delay=%.2f", controller.TriggerCount, attack.Name, enemyCharacter.Name, distance, delay))
    task.spawn(function()
        if delay > 0 then task.wait(delay) end
        local stillAllowed = canReact(enemyCharacter)
        if not stillAllowed then logEvent("CANCEL target left valid parry range/state"); return end
        startOrExtendBlockPulse()
    end)
end
local function watchCharacter(character)
    if not character or character == LocalPlayer.Character then return end
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 8)
        local animator = humanoid and (humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 8))
        if not animator then return end
        table.insert(controller.Connections, animator.AnimationPlayed:Connect(function(track)
            local animation = track.Animation
            local animationId = animation and animation.AnimationId or ""
            local numericId = string.match(animationId, "%d+")
            local attack = numericId and attackAnimations[numericId]
            if not attack then return end
            parry(character, animationId, attack)
        end))
    end)
end
local enabledState
local function watchPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then watchCharacter(player.Character) end
    table.insert(controller.Connections, player.CharacterAdded:Connect(watchCharacter))
end
for _, player in ipairs(Players:GetPlayers()) do watchPlayer(player) end
table.insert(controller.Connections, Players.PlayerAdded:Connect(watchPlayer))
table.insert(controller.Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.H then
        controller.Enabled = not controller.Enabled
        if enabledState then enabledState:set(controller.Enabled) end
        logEvent("TOGGLE enabled=" .. tostring(controller.Enabled))
    end
end))
function controller.Stop()
    controller.Enabled = false
    controller.BlockingUntil = 0
    for _, connection in ipairs(controller.Connections) do pcall(function() connection:Disconnect() end) end
    table.clear(controller.Connections)
    local block = getBlockModule()
    if block and typeof(block.Unblock) == "function" then pcall(block.Unblock) end
    logEvent("STOP listeners disconnected")
end
_G.__CodexAutoParry = controller
logEvent("START listeners=" .. tostring(#controller.Connections))

enabledState = Rere.State(true)
local enabled, radius = enabledState, Rere.State(14)
local holdTime, heavyDelay, filter = Rere.State(0.24), Rere.State(0.4), Rere.State("")
Rere:Connect(function()
    controller.Enabled, controller.Radius = enabled:get(), radius:get()
    controller.HoldTime, controller.HeavyDelay = holdTime:get(), heavyDelay:get()
    Rere.Window({"Auto Parry Debugger"})
        Rere.TabBar()
            Rere.Tab({"Dashboard"})
                Rere.Text({"Status: " .. (controller.Enabled and "ENABLED" or "DISABLED")})
                Rere.Text({"Triggers: " .. controller.TriggerCount})
                Rere.Text({"Accepted blocks: " .. controller.SuccessfulBlocks})
                Rere.Text({"Rejected blocks: " .. controller.RejectedBlocks})
                Rere.Text({"Listeners: " .. #controller.Connections})
                Rere.Text({"Last block state: " .. controller.LastBlockState})
                Rere.Text({"Pulse active: " .. tostring(controller.PulseActive)})
                Rere.Text({"Last target: " .. (controller.LastTarget ~= "" and controller.LastTarget or "None")})
                Rere.Text({"Last animation: " .. (controller.LastAnimation ~= "" and controller.LastAnimation or "None")})
                Rere.Text({"Last error: " .. (controller.LastError ~= "" and controller.LastError or "None")})
                Rere.Separator()
                Rere.Text({"Player: " .. LocalPlayer.Name})
                Rere.Text({"Place ID: " .. game.PlaceId})
            Rere.End()
            Rere.Tab({"Controls"})
                Rere.Checkbox({"Enabled"}, {isChecked = enabled})
                Rere.SliderNum({"Radius", 0.5, 2, 30, "%.1f studs"}, {number = radius})
                Rere.SliderNum({"Hold time", 0.01, 0.05, 0.6, "%.2f s"}, {number = holdTime})
                Rere.SliderNum({"Heavy delay", 0.01, 0, 0.8, "%.2f s"}, {number = heavyDelay})
                if Rere.Button({"Stop and disconnect"}).clicked() then controller.Stop() end
                Rere.Text({"Press H to toggle enabled state."})
            Rere.End()
            Rere.Tab({"Event log"})
                Rere.InputText({"Filter", "target, animation, error..."}, {text = filter})
                Rere.Separator()
                local query, shown = string.lower(filter:get()), 0
                for _, event in ipairs(controller.Events) do
                    if query == "" or string.find(string.lower(event), query, 1, true) then Rere.Text({event}); shown += 1 end
                    if shown >= 25 then break end
                end
                if shown == 0 then Rere.Text({"No matching events."}) end
            Rere.End()
            Rere.Tab({"Diagnostics"})
                Rere.CollapsingHeader({"Detection pipeline"})
                    Rere.Text({"Animator.AnimationPlayed -> exact punch ID allowlist -> range/facing/state checks."})
                    Rere.Text({"Heavy punch waits 0.40s; rapid punches extend one shared block pulse."})
                Rere.End()
                Rere.CollapsingHeader({"Block pipeline"})
                    Rere.Text({"Resolve CombatType Block module -> set Block.Activated credit -> Block() -> hold -> Unblock()."})
                Rere.End()
                Rere.CollapsingHeader({"Rollback"})
                    Rere.Text({"Run _G.__CodexAutoParry.Stop() to disconnect listeners and release block."})
                Rere.End()
            Rere.End()
        Rere.End()
    Rere.End()
end)
