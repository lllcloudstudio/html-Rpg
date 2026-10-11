import ndjson
import numpy as np
import cv2
from pathlib import Path

data_path = Path(r'C:\Users\aflac\.kaggle\tinyquickdraw\quickdraw_simplified')
def strokes_to_image(strokes, size=64):
    """Convert stroke list to 64x64 image."""
    img = np.zeros((size, size), dtype=np.uint8)
    for stroke in strokes:
        if len(stroke) < 2:
            continue
        pts = np.array(stroke, dtype=np.int32)
        # Ensure shape is (N, 2)
        if pts.shape[1] != 2:
            continue
        # Clip to image bounds
        pts = np.clip(pts, 0, size-1)
        if len(pts) >= 2:
            cv2.polylines(img, [pts], False, 255, 2)
    return img

# Load lines (positive = 1)
print("Loading lines...")
lines_data = []
with open(data_path / 'line.ndjson') as f:
    for i, line in enumerate(ndjson.load(f)):
        if i >= 5000:
            break
        img = strokes_to_image(line['drawing'])
        lines_data.append((img, 1))

# Load non-lines (negative = 0)
print("Loading doodles...")
doodles_data = []
for ndjson_file in ['squiggle.ndjson', 'zigzag.ndjson']:
    with open(data_path / ndjson_file) as f:
        for i, item in enumerate(ndjson.load(f)):
            if i >= 2500:
                break
            img = strokes_to_image(item['drawing'])
            doodles_data.append((img, 0))

# Combine and split
all_data = lines_data + doodles_data
np.random.shuffle(all_data)

X = np.array([item[0] for item in all_data]).reshape(-1, 64, 64, 1) / 255.0
y = np.array([item[1] for item in all_data])

print(f"X shape: {X.shape}, y shape: {y.shape}")

# Save for training
np.save('X_train.npy', X)
np.save('y_train.npy', y)