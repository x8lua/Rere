-- Executor loader for the bundled Iris-compatible Rere library.
local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.17/src/Rere.lua")
return assert(compiler(source))()
