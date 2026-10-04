# Section Headings

`Rere.Section({"Walk & Sprint Speed"})` draws the same plain heading as
`Rere.Text`. A section directly inside a tab also appears in the beta section
navigation alongside that tab's collapsing headers. Clicking its navigation
item scrolls to the heading; the section has no collapse button or state.

```lua
Rere.Tab({"Movement"})
    Rere.Section({"Walk & Sprint Speed"})
    Rere.Toggle({"Speed Modifier"}, {isChecked = speedEnabled})
    Rere.SliderNum({"Walk Speed", 1, 1, 30}, {number = walkSpeed})
Rere.End()
```

No `Rere.End()` is needed for the section itself. Ordinary `Rere.Text` labels,
status messages, and headings nested in collapsing headers stay out of the
tab's section navigation. Section navigation entries are removed when their
widgets are discarded.
