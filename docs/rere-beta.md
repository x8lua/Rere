# Rere Beta

The `rere-beta` branch retains the Rere/Iris API and changes Tab and TabBar presentation.

```lua
local Rere = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua"))()
```

Tabs use Arial, Arial Bold for selection, compact numbered labels, a blue edge,
and a border around the selected tab. The rail is 21 pixels high with 20 pixel tabs.
The top-level tab rail stays below the title bar while the content scrolls vertically.
Narrow windows navigate tabs with arrow buttons; wheel and drag gestures do not scroll the rail.
Selecting the active tab keeps it open; content switches immediately.

Colors come from the active Rere configuration, including its dark background, blue
selection, and hover colors. Existing tab arguments, state, and events remain.

Edit `lib/widgets/Tab.lua`, then run `node tools/build-executor.mjs` to generate both
`src/Rere.lua` and `src/rere-beta.lua`. The source LarpKuran copy remains a separate local
artifact. This branch has not been verified in the Roblox client.
