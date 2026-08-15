# Menus, tabs, and sections

| Constructor | Details |
| --- | --- |
| `MenuBar` | Horizontal menu container. |
| `Menu` | Dropdown menu. |
| `MenuItem` | Clickable menu action. |
| `MenuToggle` | Checkable menu action. |
| `TabBar` | Page-navigation container. |
| `Tab` | A page inside `TabBar`. |
| `Tree` | Expandable nested section. |
| `CollapsingHeader` | Expandable header section. |

```lua
Rere.TabBar()
Rere.Tab({"Dashboard"})
Rere.Text({"Dashboard page"})
Rere.End()
Rere.End()
```

Expandable arrows animate right (`0°`) to down (`90°`) with a `0.1s` open and reverse-close transition.