local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.2/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

Rere:Connect(function()
    local volume = Rere.State(50)
    Rere.Window({"Slider example"})
        Rere.Text({"Volume: " .. volume:get() .. "%"})
        Rere.SliderNum({"Volume", 1, 0, 100, "%d%%"}, {
            number = volume,
        })
    Rere.End()
end)
