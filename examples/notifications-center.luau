-- Animated notifications above the screen midpoint, with no X button.
local env: any = if type(getgenv) == "function" then getgenv() else _G
if env.RereNotifyDemo then env.RereNotifyDemo:Destroy() end
local Library = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/src/RereNotify.luau"), "=RereNotify"))()
local notifications = Library.new({Position = "Center", Width = 360, MaxVisible = 3})
env.RereNotifyDemo = notifications
local cleanupState: any = getfenv().STATE
if type(cleanupState) == "table" then cleanupState.onCleanup(function() notifications:Destroy() end) end
notifications:Notify({
    Title = "Configuration saved",
    Text = "Your layout and preferences are ready for next time.",
    Kind = "Success",
    Duration = 30,
    ActionText = "Got it",
    OnAction = function() end,
})
print("[RereNotify] Center preview ready.")
