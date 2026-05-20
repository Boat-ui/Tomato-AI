import tensorflow as tf

# Load and re-save as SavedModel first
model = tf.keras.models.load_model("tomato_cnn_model.keras")

# Save as SavedModel format
model.export("tomato_saved_model")

# Convert from SavedModel (more compatible)
converter = tf.lite.TFLiteConverter.from_saved_model("tomato_saved_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]

tflite_model = converter.convert()

with open("tomato_model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Done!")
print(f"Size: {len(tflite_model) / 1024 / 1024:.2f} MB")