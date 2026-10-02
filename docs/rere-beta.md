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

## 隱藏 section 導覽列

`BetaVersion = 20261002002`：目前分頁直屬的 `CollapsingHeader` 自動成為 section 捷徑，
無須新增 SubTab 或維護重複標籤。範例位於 `examples/section-navigation.luau`。

導覽列位於主內容 `WindowContainer` 的最頂端。預設高度為 0；頂端繼續向上滾動，
或手機在頂端下拉 22 pixels，會用 0.18 秒 Quart tween 展開至 44 UI pixels。
標籤旋轉 12 度，按文字長度緊密橫向排列，超過可用寬度時可水平捲動。

點選會展開目標 section 並直接設定 CanvasPosition，收起動畫期间持續校正錨點。
向下滾動或放開手機手勢會收起；滑鼠滾輪停止 0.85 秒後收起，移入導覽列可保留以點選。
主分頁維持固定位置。換分頁、隱藏／收合視窗與 Shutdown 都會收起或清理導覽資源。

已透過 Real MCP 在 Shigaku 的 Larpgaku 確認導覽生成、顯示位置、零高度收起和錨點跳轉；
使用者確認頂端滾輪可呼出。手機真機手勢尚未驗證。
