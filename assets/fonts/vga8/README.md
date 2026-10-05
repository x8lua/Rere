# PxPlus IBM VGA8

Retro 8 x 16 pixel font used by the Rere script-error screen.

## Files

- `PxPlus_IBM_VGA8.ttf`: original PxPlus IBM VGA8 Regular font, downloaded without modification.
- `VGA8-atlas.png`: derived transparent ASCII glyph atlas, codes 32 through 126. Each cell is 8 x 16 pixels; 16 columns, 6 rows; total 128 x 96 pixels.
- `build-font-atlas.py`: reproducible atlas generator, requires Python and Pillow. Run it from any directory.

## Attribution and license

PxPlus IBM VGA8 outline (vector) version copyright 2015 **VileR**.
Original project: [The Ultimate Oldschool PC Font Pack](https://int10h.org/oldschool-pc-fonts/).

The font's embedded license is **Creative Commons Attribution-ShareAlike 4.0 International**:
[License summary](https://creativecommons.org/licenses/by-sa/4.0/) and [full license text](https://creativecommons.org/licenses/by-sa/4.0/legalcode).

The bitmap atlas is a modification made for Rere by x8lua: glyphs rendered at 16 pixels without antialiasing and arranged in a transparent PNG. It is distributed under the same CC BY-SA 4.0 license. These font assets retain their own license independently of the repository's code license.

Downloaded font source: https://db.onlinewebfonts.com/t/0bae535590ffdc6ffb2cfa45b8fb2ae3.ttf . Attribution and license above were read from the font's embedded name table.

## Roblox bitmap rendering

An arbitrary local TTF cannot be selected through `Enum.Font`. The Rere error screen renders the atlas through `ImageLabel`, `ImageRectOffset`, and `ImageRectSize`, with `ResampleMode = Enum.ResamplerMode.Pixelated`.

Direct downloads:

- https://raw.githubusercontent.com/x8lua/Rere/main/assets/fonts/vga8/PxPlus_IBM_VGA8.ttf
- https://raw.githubusercontent.com/x8lua/Rere/main/assets/fonts/vga8/VGA8-atlas.png

For Real, place both assets in `Workspace/RereErrorScreen/`. The error-screen renderer uses `getcustomasset("RereErrorScreen/VGA8-atlas.png")`.
