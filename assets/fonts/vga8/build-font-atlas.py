from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

assets = Path(__file__).resolve().parent
font = ImageFont.truetype(str(assets / "PxPlus_IBM_VGA8.ttf"), 16)
mask = Image.new("1", (128, 96))
draw = ImageDraw.Draw(mask)
for code in range(32, 127):
    index = code - 32
    draw.text(((index % 16) * 8, (index // 16) * 16), chr(code), font=font, fill=1)
atlas = Image.new("RGBA", mask.size, (255, 255, 255, 0))
atlas.putalpha(mask.convert("L"))
atlas.save(assets / "VGA8-atlas.png")
print("Generated 8x16 ASCII atlas from PxPlus IBM VGA8.")
