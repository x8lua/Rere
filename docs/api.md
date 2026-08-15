---
description: "Public executor API and lifecycle methods."
icon: brackets-curly
---

# Public API

| API | Description |
| --- | --- |
| `Rere.Init(parent?, event?, allowMultiple?)` | Starts Rere |
| `Rere:Connect(callback)` | Registers an immediate-mode render callback |
| `Rere.Shutdown()` | Stops rendering and removes the root |
| `Rere:GetVersion()` | Returns the distribution version |
| `Rere.State(value)` | Creates a persistent mutable state |
| `Rere.WeakState(value)` | Creates a weak state reference |
| `Rere.VariableState(value, callback)` | State backed by a variable callback |
| `Rere.TableState(table, key)` | State backed by a table entry |
| `Rere.ComputedState(state, callback)` | Derived state |
| `Rere.Append(instance)` | Adds an existing GuiObject to the current parent |
| `Rere.End()` | Closes a parent widget |
| `Rere.ForceRefresh()` | Rebuilds the UI |
| `Rere.PushId(id)` / `Rere.PopId()` | Controls stable widget identity |
| `Rere.SetNextWidgetID(id)` | Sets the next widget identity |
| `Rere.SetFocusedWindow(window)` | Focuses a window |
| `Rere.UpdateGlobalConfig(config)` | Applies global style changes |
| `Rere.PushConfig(config)` / `Rere.PopConfig()` | Applies temporary style changes |
