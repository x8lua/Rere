# Rere Beta

The `rere-beta` branch retains the Rere/Iris API and changes Tab and TabBar presentation.

```lua
local Rere = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua"))()
```

Tabs use Arial, Arial Bold for selection, compact numbered labels, a blue edge,
and a border around the selected tab. The rail is 21 pixels high with 20 pixel tabs.
The top-level tab rail stays below the title bar while the content scrolls vertically.
Narrow windows navigate tabs with arrow buttons; wheel and drag gestures do not scroll the rail.
Selecting the active tab keeps it open without restarting its transition.

Colors come from the active Rere configuration, including its dark background, blue
selection, and hover colors. Existing tab arguments, state, and events remain.

Edit `lib/widgets/Tab.lua`, then run `node tools/build-executor.mjs` to generate both
`src/Rere.lua` and `src/rere-beta.lua`. The source LarpKuran copy remains a separate local
artifact.

## Mobile Window Placement

`BetaVersion = 20261006001` fits the intended window size before placing it,
centers new touch windows, and recalculates bounds when the viewport changes.
This avoids checking a new window's `AbsoluteSize` while it is still zero.
Windows with `OutOfBounds = true` retain their unrestricted placement.

Touch dragging starts on the title bar and tracks the initiating finger through
`InputChanged` and `TouchMoved`. Releasing that finger or losing app focus clears
the gesture; a second finger does not take over the drag. Resize grips use the
same ownership rule. Mobile device interaction still needs a live device check.

## 右側懸浮 section 導覽

`BetaVersion = 20261002005`：目前分頁直屬的 `CollapsingHeader` 自動成為 section 捷徑。

主內容保持完整寬度，導覽不佔版面。滑鼠移入內容右側 22 pixels 呼出，移離懸浮區收起；手機點右側邊緣可切換。使用 0.16 秒滑入／淡出、透明背景、淡黑漸層陰影。Arial Bold 標籤旋轉 -40 度，以 23 UI pixels 節距緊密排列；點擊直接跳轉並展開 section。超過高度時可獨立捲動。

換分頁、隱藏／收合視窗會收起，Shutdown 清理輸入連線與 tween。Real MCP 已確認主內容展開前後皆為完整寬度、字型和角度及 UI 無錯；手機真機未驗證。

標籤依旋轉後的文字邊界貼齊右側 3 pixels，頂部只保留避免第一個標籤裁切所需的空間。

## Tab 與 section 動畫

`BetaVersion = 20261004001`：tab 內容依切換方向滑入 10 pixels，搭配 4 pixels 的垂直移動，約 0.2 秒完成；選取色、文字亮度與上緣標記平滑過渡。主 tab rail 固定在原位。

Section／Tree 使用約 0.2 秒展開、0.16 秒收合，箭頭旋轉與標題淡入。動畫結束恢復 AutomaticSize，因此動態新增內容與調整視窗仍照原本 layout 計算。快速切換會取消上一個 tween；Discard／Shutdown 會清除 tween 和完成回呼。動畫只影響呈現，功能 state 立即更新。

預設啟用，可以關閉：

```lua
Rere.UpdateGlobalConfig({BetaAnimations = false})
```

這個版本已完成原始碼整合與 bundle 產生，尚未在 Roblox 實測動畫。
