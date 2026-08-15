---
description: "Customize Rere colors, fonts, sizing, and runtime behavior."
icon: sliders
---

# Configuration

```lua
Rere.UpdateGlobalConfig({
    TextSize = 14,
    FramePadding = Vector2.new(6, 4),
    ItemSpacing = Vector2.new(8, 6),
})
```

Useful configuration groups include text (`TextColor`, `TextFont`, `TextSize`), windows (`WindowBgColor`, `WindowPadding`, `WindowRounding`), buttons (`ButtonColor`, `ButtonHoveredColor`), headers (`HeaderColor`, `HeaderHoveredColor`), popups (`PopupBgColor`), and layout (`ContentWidth`, `ItemSpacing`, `FramePadding`).

Use `PushConfig` and `PopConfig` for a temporary local style:

```lua
Rere.PushConfig({TextColor = Color3.fromRGB(255, 220, 120)})
Rere.Text({"Highlighted"})
Rere.PopConfig()
```

The bundled source also exposes `Rere.TemplateConfig` for the built-in dark, light, and size templates.
