local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.20/src/Rere.lua")
local Rere = assert(compiler(source))()
-- Defaults to gethui()/get_hidden_gui(), then CoreGui when those are unavailable.
Rere.Init()

Rere:Connect(function()
    Rere.Window({"Rere executor demo"})
        Rere.Text({"Iris running without Roblox Studio modules."})
        Rere.Button({"Click me"})
        Rere.InputNum({"Value"})
    Rere.End()
end)
