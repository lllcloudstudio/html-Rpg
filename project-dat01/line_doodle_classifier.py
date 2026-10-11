import cv2
import numpy as np
from tensorflow.keras.models import load_model
from pathlib import Path

# Load trained model
model = load_model('line_classifier.h5')

def strokes_to_image(strokes, size=64):
    """Convert stroke list to 64x64 image."""
    img = np.zeros((size, size), dtype=np.uint8)
    for stroke in strokes:
        if len(stroke) < 2:
            continue
        pts = np.array(stroke, dtype=np.int32)
        if pts.shape[1] != 2:
            continue
        pts = np.clip(pts, 0, size-1)
        if len(pts) >= 2:
            cv2.polylines(img, [pts], False, 255, 2)
    return img

def preprocess_frame(frame, size=64):
    """Convert frame to 64x64 grayscale for model."""
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (size, size))
    normalized = resized / 255.0
    return np.expand_dims(np.expand_dims(normalized, axis=0), axis=-1)

def measure_straightness(frame, pixel_size=8):
    """Detect lines and measure straightness."""
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)
    
    lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=50, minLineLength=50, maxLineGap=5)
    
    all_points = []
    if lines is not None:
        lines = lines.reshape(-1, 4)
        for line in lines:
            x1, y1, x2, y2 = line
            all_points.append([x1, y1])
            all_points.append([x2, y2])
    
    all_points = np.array(all_points, dtype=np.float32)
    
    if len(all_points) < 3:
        return "doodle", None
    
    vx, vy, x0, y0 = cv2.fitLine(all_points, cv2.DIST_L2, 0, 0.01, 0.01)
    
    # Calculate slope
    if vx == 0:
        slope = float('inf')
    elif vy == 0:
        slope = 0
    else:
        slope = vy / vx
    
    # Measure straightness (deviation)
    best_straightness = float('inf')
    best_line = None
    
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line
            dist1 = abs((vy * (x1 - x0) - vx * (y1 - y0)) / np.sqrt(vx**2 + vy**2))
            dist2 = abs((vy * (x2 - x0) - vx * (y2 - y0)) / np.sqrt(vx**2 + vy**2))
            max_dev = max(dist1, dist2)
            
            if max_dev < best_straightness:
                best_straightness = max_dev
                best_line = line
    
    if best_straightness > 3:
        return "doodle", None
    
    return "line", best_line, slope, best_straightness

# Main camera loop
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # Detect lines
    result = measure_straightness(frame, pixel_size=8)
    verdict = result[0]
    
    # Classify with quickdraw model
    preprocessed = preprocess_frame(frame)
    pred = model.predict(preprocessed, verbose=0)[0][0]
    
    model_label = "line" if pred > 0.5 else "doodle"
    confidence = pred if pred > 0.5 else 1 - pred
    
    # Display both verdicts
    cv2.putText(frame, f"Straightness: {verdict}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    cv2.putText(frame, f"Model: {model_label} ({confidence:.2f})", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
    
    cv2.imshow('Line/Doodle Detector', frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()