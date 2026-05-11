import numpy as np


def calculate_angle(a, b, c):
    """
    Calculate angle ABC in degrees
    """
    a = np.array(a, dtype=np.float32)
    b = np.array(b, dtype=np.float32)
    c = np.array(c, dtype=np.float32)

    ba = a - b
    bc = c - b

    radians = np.arctan2(bc[1], bc[0]) - np.arctan2(ba[1], ba[0])
    angle = abs(np.degrees(radians))

    if angle > 180:
        angle = 360 - angle

    return float(angle)