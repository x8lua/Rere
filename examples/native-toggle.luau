local Rere = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua")))()
Rere.Init()

local feature = Rere.State(false)
local featureKey = Rere.State("None")
local opened = Rere.State(true)
local hideKey = Rere.State("K")

Rere.RegisterKeybind(featureKey, function() feature:set(not feature.value) end, "Feature")
Rere.RegisterKeybind(hideKey, function() opened:set(not opened.value) end, "Hide UI")

Rere:Connect(function()
    Rere.SetNextWidgetID("native-toggle/window")
    Rere.Window({"Native Toggle"}, {isOpened = opened})
    if opened.value then
        Rere.SetNextWidgetID("native-toggle/feature")
        Rere.Toggle({"Feature"}, {isChecked = feature, keybind = featureKey})
        if Rere.Button({"Hide UI key: " .. hideKey.value}).clicked() then
            Rere.BeginKeybindCapture(hideKey)
        end
    end
    Rere.End()
end)

if type(STATE) == "table" and type(STATE.onCleanup) == "function" then
    STATE.onCleanup(Rere.Shutdown)
end
