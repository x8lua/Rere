local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.1/src/Rere.lua")
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
        Rere.TabBar()
            Rere.Tab({"Settings"})
                Rere.Text({"Numeric controls"})
                Rere.SliderNum({"Integer slider", 1, 0, 10}, {number = integerValue})
                Rere.SliderNum({"Float slider", 0.01, 0, 1}, {number = floatValue})
                Rere.DragNum({"Drag slider", 1, 0, 100})
            Rere.End()

            Rere.Tab({"Runtime Info"})
                Rere.Text({"Cycle: " .. tostring(Rere.Internal._cycleTick)})
                Rere.Text({"Delta time: " .. string.format("%.4f", Rere.Internal._deltaTime)})
                Rere.Text({"Registered widgets: " .. tostring(countWidgets())})
            Rere.End()

            Rere.Tab({"Style Editor"})
                Rere.Text({"Apply a built-in theme"})
                if Rere.Button({"Dark theme"}).clicked() then
                    Rere.UpdateGlobalConfig(Rere.TemplateConfig.colorDark)
                end
                if Rere.Button({"Light theme"}).clicked() then
                    Rere.UpdateGlobalConfig(Rere.TemplateConfig.colorLight)
                end
                if Rere.Button({"Clear layout"}).clicked() then
                    Rere.UpdateGlobalConfig(Rere.TemplateConfig.sizeClear)
                end
            Rere.End()
        Rere.End()
    Rere.End()
end)
