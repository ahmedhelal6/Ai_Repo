import os
import time
import numpy as np


class DataCollector:
    def __init__(self, base_dir="data"):
        self.base_dir = base_dir
        self.buffer = []

    # 🔥 الآن بياخد features كاملة (مش elbow/back)
    def add_frame(self, features):
        """
        Adds a frame (list of features) to buffer
        Expected shape: [elbow, back, shoulder, hip, speed]
        """
        if features is not None and len(features) == 5:
            self.buffer.append(features)

    # 🔥 حفظ per class (multi-error)
    def save_rep(self, exercise, label):
        """
        Saves buffer as .npy file inside:
        data/{exercise}/{label}/
        """

        if label is None or len(self.buffer) < 10:
            self.buffer = []
            return

        # 📂 folder per exercise + label
        save_dir = os.path.join(self.base_dir, exercise, label)
        os.makedirs(save_dir, exist_ok=True)

        timestamp = int(time.time() * 1000)
        filename = f"{timestamp}.npy"
        filepath = os.path.join(save_dir, filename)

        np.save(filepath, np.array(self.buffer, dtype=np.float32))

        print(f"Saved → {filepath}")

        self.buffer = []

    def reset(self):
        self.buffer = []