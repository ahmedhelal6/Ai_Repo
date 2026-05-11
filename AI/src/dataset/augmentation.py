import numpy as np

# =========================================================
# MEDIAPIPE LEFT / RIGHT LANDMARKS
# =========================================================
LEFT_RIGHT_PAIRS = [

    (11, 12),  # shoulders
    (13, 14),  # elbows
    (15, 16),  # wrists

    (23, 24),  # hips
    (25, 26),  # knees
    (27, 28),  # ankles

    (29, 30),  # heels
    (31, 32),  # foot index
]

# =========================================================
# GAUSSIAN NOISE
# =========================================================
def add_gaussian_noise(
    keypoints,
    std=0.003
):

    noise = np.random.normal(
        0,
        std,
        keypoints.shape
    )

    return keypoints + noise


# =========================================================
# RANDOM SCALE
# =========================================================
def random_scale(
    keypoints,
    scale_range=(0.97, 1.03)
):

    scale = np.random.uniform(
        *scale_range
    )

    return keypoints * scale


# =========================================================
# RANDOM SHIFT
# =========================================================
def random_shift(
    keypoints,
    shift_range=0.015
):

    kp = keypoints.copy()

    shift_x = np.random.uniform(
        -shift_range,
        shift_range
    )

    shift_y = np.random.uniform(
        -shift_range,
        shift_range
    )

    kp[0::2] += shift_x

    kp[1::2] += shift_y

    return kp


# =========================================================
# HORIZONTAL FLIP
# =========================================================
def horizontal_flip(keypoints):

    kp = keypoints.copy()

    # =====================================================
    # FLIP X
    # =====================================================
    kp[0::2] = (
        1.0 - kp[0::2]
    )

    # =====================================================
    # SWAP LEFT / RIGHT
    # =====================================================
    for left, right in LEFT_RIGHT_PAIRS:

        lx = left * 2
        rx = right * 2

        # swap x
        kp[[lx, rx]] = (
            kp[[rx, lx]]
        )

        # swap y
        kp[[lx + 1, rx + 1]] = (
            kp[[rx + 1, lx + 1]]
        )

    return kp


# =========================================================
# JOINT DROPOUT
# =========================================================
def random_joint_dropout(
    keypoints,
    p=0.01
):

    kp = keypoints.copy()

    joints = len(kp) // 2

    for j in range(joints):

        if np.random.rand() < p:

            kp[
                j * 2:(j * 2 + 2)
            ] = 0

    return kp


# =========================================================
# MAIN AUGMENTATION
# =========================================================
def augment_keypoints(keypoints):

    kp = keypoints.copy()

    # =====================================================
    # SPLIT FEATURES
    # =====================================================
    # أول 66 = keypoints
    pose = kp[:66]

    # آخر 66 = velocity / extra features
    extra = kp[66:]

    # =====================================================
    # Gaussian Noise
    # =====================================================
    if np.random.rand() < 0.4:

        pose = add_gaussian_noise(
            pose
        )

    # =====================================================
    # Shift
    # =====================================================
    if np.random.rand() < 0.3:

        pose = random_shift(
            pose
        )

    # =====================================================
    # Horizontal Flip
    # =====================================================
    if np.random.rand() < 0.1:

        pose = horizontal_flip(
            pose
        )

    # =====================================================
    # Scale
    # =====================================================
    if np.random.rand() < 0.2:

        pose = random_scale(
            pose
        )

    # =====================================================
    # Joint Dropout
    # =====================================================
    if np.random.rand() < 0.02:

        pose = random_joint_dropout(
            pose
        )

    # =====================================================
    # RECOMBINE
    # =====================================================
    kp = np.concatenate([
        pose,
        extra
    ])

    return kp.astype(np.float32)