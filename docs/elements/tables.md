# Tables and columns

| Constructor | Details |
| --- | --- |
| `Table` | Multi-column layout. |
| `NextColumn` / `NextRow` | Advances the current cell. |
| `SetColumnIndex` / `SetRowIndex` | Selects a specific cell position. |
| `NextHeaderColumn` | Advances through header cells. |
| `SetHeaderColumnIndex` | Selects a header cell. |
| `SetColumnWidth` | Sets a column width. |

```lua
Rere.Table({"Stats", 2})
Rere.Text({"Name"}); Rere.NextColumn(); Rere.Text({"Value"})
Rere.NextRow(); Rere.Text({"Coins"}); Rere.NextColumn(); Rere.Text({"100"})
Rere.End()
```