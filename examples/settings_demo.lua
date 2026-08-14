local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.14/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

Rere:Connect(function()
    local integerValue = Rere.State(5)
    local floatValue = Rere.State(0.5)

    Rere.Window({"Rere Settings"})
        Rere.MenuBar()
            Rere.Menu({"Settings"})
                Rere.MenuItem({"Runtime Info"})
                Rere.MenuItem({"Style Editor"})
            Rere.End()
        Rere.End()

        -- This is a dropdown only. Page switching is intentionally deferred.
        Rere.Text({"Numeric controls"})
        Rere.SliderNum({"Integer slider", 1, 0, 10}, {number = integerValue})
        Rere.SliderNum({"Float slider", 0.01, 0, 1}, {number = floatValue})
        Rere.DragNum({"Drag slider", 1, 0, 100})
    Rere.End()
end)
