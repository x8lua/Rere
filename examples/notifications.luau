-- Animated bottom-right notifications. Rerunning replaces the previous demo.
local env: any = if type(getgenv) == "function" then getgenv() else _G
if env.RereNotifyDemo then env.RereNotifyDemo:Destroy() end
local Library = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/src/RereNotify.luau"), "=RereNotify"))()
local notifications = Library.new({Width = 320, MaxVisible = 4, Padding = 22})
env.RereNotifyDemo = notifications
local cleanupState: any = getfenv().STATE
if type(cleanupState) == "table" then cleanupState.onCleanup(function() notifications:Destroy() end) end
notifications:Notify({Title = "Configuration saved", Text = "Your layout and preferences are ready for next time.", Kind = "Success", Duration = 30})
notifications:Notify({Title = "Update available", Text = "A new LarpKuran build is ready to review.", Duration = 30,
    ActionText = "Review update  →", OnAction = function()
        notifications:Notify({Title = "Software Update", Text = "This action opens your update page when connected to your UI.", Duration = 5})
    end})
notifications:Notify({Title = "Keybind already in use", Text = "K is assigned to Hide UI. Choose another key in Settings.", Kind = "Warning", Duration = 30})
print("[RereNotify] Demo ready. Hover pauses expiry; × dismisses a notice.")
