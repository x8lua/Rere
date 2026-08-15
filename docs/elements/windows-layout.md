# Windows and layout

## `Window`
Creates a movable root container. Close it with `Rere.End()`.
```lua
Rere.Window({"Tools"})
Rere.Text({"Window content"})
Rere.End()
```

## `Tooltip`
Creates hover-only child content.
```lua
Rere.Button({"Hover me"})
Rere.Tooltip({"Helpful text"})
Rere.End()
```

## Text and layout

| Constructor | Details |
| --- | --- |
| `Text` | Single-line plain text. |
| `TextWrapped` | Text that wraps to available width. |
| `TextColored` | Text with a `Color3` color argument. |
| `Separator` | Horizontal divider. |
| `SeparatorText` | Divider with a caption. |
| `Indent` | Indents children until `End`. |
| `SameLine` | Places the next widget on the current row. |
| `Group` | Groups children without a visible frame. |
| `Root` | Internal root created by `Rere.Init()`. |
| `End` | Closes the active container. |