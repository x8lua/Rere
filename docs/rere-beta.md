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
artifact.

## 右側懸浮 section 導覽

`BetaVersion = 20261002005`：目前分頁直屬的 `CollapsingHeader` 自動成為 section 捷徑。

主內容保持完整寬度，導覽不佔版面。滑鼠移入內容右側 22 pixels 呼出，移離懸浮區收起；手機點右側邊緣可切換。使用 0.16 秒滑入／淡出、透明背景、淡黑漸層陰影。Arial Bold 標籤旋轉 -40 度，以 23 UI pixels 節距緊密排列；點擊直接跳轉並展開 section。超過高度時可獨立捲動。

換分頁、隱藏／收合視窗會收起，Shutdown 清理輸入連線與 tween。Real MCP 已確認主內容展開前後皆為完整寬度、字型和角度及 UI 無錯；手機真機未驗證。

標籤依旋轉後的文字邊界貼齊右側 3 pixels，頂部只保留避免第一個標籤裁切所需的空間。
