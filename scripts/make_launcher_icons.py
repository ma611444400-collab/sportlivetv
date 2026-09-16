from pathlib import Path
from PIL import Image

source = Image.open('/home/ubuntu/sportlivetv/assets/images/app_logo.png').convert('RGBA')
for density, size in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    image = source.copy()
    image.thumbnail((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    left = (size - image.width) // 2
    top = (size - image.height) // 2
    canvas.alpha_composite(image, (left, top))
    canvas.save(f'/home/ubuntu/sportlivetv/android/app/src/main/res/mipmap-{density}/ic_launcher.png')
