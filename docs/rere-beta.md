# Rere Beta

The `rere-beta` branch retains the Rere/Iris API and changes Tab and TabBar presentation.

```lua
local Rere = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua"))()
```

Tabs use Arial, Arial Bold for selection, compact numbered labels, a category color edge,
and a border around the selected tab. Narrow windows scroll horizontally with fixed arrow
buttons. Selecting the active tab keeps it open; content switches immediately.

Known LarpKuran utility and setup names receive amber and sage accents. Other tab names
use blue. This affects presentation only; existing tab arguments, state, and events remain.

Edit `lib/widgets/Tab.lua`, then run `node tools/build-executor.mjs` to generate both
`src/Rere.lua` and `src/rere-beta.lua`. The source LarpKuran copy remains a separate local
artifact. This branch has not been verified in the Roblox client.
