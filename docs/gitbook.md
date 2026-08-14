# Rere Executor Docs

Rere is an executor-compatible distribution of [Iris](https://github.com/SirMallard/Iris). It keeps Iris's immediate-mode API and bundles every module into `src/Rere.lua`, so it does not call Roblox Studio's `require(script.Parent...)` tree.

## Load

```lua
local compiler = loadstring or load
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()
```

## First Window

```lua
Rere:Connect(function()
    Rere.Window({"Hello from Rere"})
        Rere.Text({"Immediate-mode UI in an executor."})
        Rere.Button({"Run"})
    Rere.End()
end)
```

## GitBook setup

Use this repository's `docs/` directory as the GitBook space content. Set the GitBook repository integration to `x8lua/Rere`, branch `main`, and publish `docs/gitbook.md` as the introduction page.
