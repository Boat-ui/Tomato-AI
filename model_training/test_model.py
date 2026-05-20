import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image

# Load model
model = tf.keras.models.load_model("tomato_model.h5")

# Load image
img_path = "test.jpg"

img = image.load_img(img_path, target_size=(224, 224))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0) / 255.0

# Predict
predictions = model.predict(img_array)

# Get class names automatically
class_names = [
    "Bacterial_spot",
    "Early_blight",
    "Healthy",
    "Late_blight",
    "Leaf_Mold",
    "Mosaic_virus",
    "Septoria_leaf_spot",
    "Target_Spot",
    "Yellow_Leaf_Curl_Virus"
]

predicted_class = class_names[np.argmax(predictions)]
confidence = np.max(predictions)

print("Prediction:", predicted_class)
print("Confidence:", confidence)