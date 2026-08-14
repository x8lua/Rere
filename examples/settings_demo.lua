local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.2/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

local function countWidgets()
    local count = 0
    for _ in Rere.Internal._widgets do
        count += 1
    end
    return count
end

Rere:Connect(function()
    local integerValue = Rere.State(5)
    local floatValue = Rere.State(0.5)

    Rere.Window({"Rere Settings"})
        Rere.MenuBar()
            Rere.Menu({"Tabs"})
                Rere.MenuItem({"Settings"})
                Rere.MenuItem({"Runtime Info"})
                Rere.MenuItem({"Style Editor"})
            Rere.End()
        Rere.End()

        -- Page switching is intentionally deferred; Settings is shown below.
        Rere.Text({"Numeric controls"})
        Rere.SliderNum({"Integer slider", 1, 0, 10}, {number = integerValue})
        Rere.SliderNum({"Float slider", 0.01, 0, 1}, {number = floatValue})
        Rere.DragNum({"Drag slider", 1, 0, 100})
        Rere.Text({"Cycle: " .. tostring(Rere.Internal._cycleTick)})
        Rere.Text({"Delta time: " .. string.format("%.4f", Rere.Internal._deltaTime)})
        Rere.Text({"Registered widgets: " .. tostring(countWidgets())})
        Rere.Text({"Style Editor: use the built-in demo for live theme editing."})
    Rere.End()
end)
