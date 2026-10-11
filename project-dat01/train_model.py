import numpy as np
import tensorflow as tf
from tensorflow.keras import Sequential, layers

# Load data
X = np.load('X_train.npy')
y = np.load('y_train.npy')

print(f"Data loaded: X={X.shape}, y={y.shape}")

# Build model
model = Sequential([
    layers.Conv2D(32, 3, activation='relu', input_shape=(64, 64, 1)),
    layers.MaxPooling2D(2),
    layers.Conv2D(64, 3, activation='relu'),
    layers.MaxPooling2D(2),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(1, activation='sigmoid')
])

model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Train
model.fit(X, y, epochs=10, batch_size=32, validation_split=0.2)

# Save
model.save('line_classifier.h5')
print("Model saved as line_classifier.h5")