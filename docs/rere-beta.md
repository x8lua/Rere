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

## 右側 section 導覽列

`BetaVersion = 20261002003`：目前分頁直屬的 `CollapsingHeader` 自動成為 section 捷徑，無須重複維護標籤。範例位於 `examples/section-navigation.luau`。

導覽列固定在主內容右側，垂直緊密排列，使用 Arial Bold 和 -12 度傾斜。它有自己的寬度，不覆蓋內容；窄視窗限制寬度，過長文字截斷。sections 超過高度時導覽列可獨立垂直捲動。點選直接跳轉並展開目標 section。換分頁時自動更新標籤；沒有 sections 時不佔寬度。隱藏／收合視窗和 Shutdown 會隱藏或清理導覽。

Real MCP 已確認 Larpgaku 右側位置、字型、傾斜與 UI 無錯；手機真機尚未驗證。
