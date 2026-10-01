-- Executor loader for the bundled Iris-compatible Rere library.
local compiler = loadstring or load
assert(type(compiler) == "function", "Rere: executor must expose loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua")
return assert(compiler(source))()
