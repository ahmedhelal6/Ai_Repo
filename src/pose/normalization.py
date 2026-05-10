import numpy as np


LEFT_SHOULDER_INDEX = 11
RIGHT_SHOULDER_INDEX = 12
LEFT_HIP_INDEX = 23
RIGHT_HIP_INDEX = 24


def get_hip_center(keypoints: np.ndarray) -> np.ndarray:
    """
    Compute the center point between left and right hips.

    Args:
        keypoints: Array of shape (V, 4) where each joint is [x, y, z, visibility].

    Returns:
        Array of shape (2,) containing [x, y] of hip center.
    """
    left_hip = keypoints[LEFT_HIP_INDEX, :2]
    right_hip = keypoints[RIGHT_HIP_INDEX, :2]
    return (left_hip + right_hip) / 2.0


def get_shoulder_center(keypoints: np.ndarray) -> np.ndarray:
    """
    Compute the center point between left and right shoulders.

    Args:
        keypoints: Array of shape (V, 4).

    Returns:
        Array of shape (2,) containing [x, y] of shoulder center.
    """
    left_shoulder = keypoints[LEFT_SHOULDER_INDEX, :2]
    right_shoulder = keypoints[RIGHT_SHOULDER_INDEX, :2]
    return (left_shoulder + right_shoulder) / 2.0


def get_torso_length(keypoints: np.ndarray, min_torso_length: float = 1e-6) -> float:
    """
    Compute torso length as the Euclidean distance between shoulder center and hip center.

    Args:
        keypoints: Array of shape (V, 4).
        min_torso_length: Minimum safe value to avoid division by zero.

    Returns:
        Torso length as a float.
    """
    hip_center = get_hip_center(keypoints)
    shoulder_center = get_shoulder_center(keypoints)

    torso_length = np.linalg.norm(shoulder_center - hip_center)
    if torso_length < min_torso_length:
        torso_length = 1.0

    return float(torso_length)


def normalize_keypoints(keypoints: np.ndarray) -> np.ndarray:
    """
    Normalize keypoints by:
    1. Centering x,y around hip center
    2. Scaling x,y,z by torso length
    3. Keeping visibility unchanged

    Args:
        keypoints: Array of shape (V, 4) with [x, y, z, visibility].

    Returns:
        Normalized array of shape (V, 4).
    """
    if not isinstance(keypoints, np.ndarray):
        raise TypeError("keypoints must be a numpy array")

    if keypoints.ndim != 2 or keypoints.shape[1] != 4:
        raise ValueError(f"Expected shape (V, 4), got {keypoints.shape}")

    normalized = keypoints.copy().astype(np.float32)

    hip_center = get_hip_center(normalized)
    torso_length = get_torso_length(normalized)

    normalized[:, 0] = (normalized[:, 0] - hip_center[0]) / torso_length
    normalized[:, 1] = (normalized[:, 1] - hip_center[1]) / torso_length
    normalized[:, 2] = normalized[:, 2] / torso_length

    return normalized