EXERCISE_CLASSES = [
    "bicep_curl",
    "deadlift",
    "lateral_raise",
    "pushup",
    "shoulder_press",
    "squat"
]

CLASS_TO_IDX = {
    name: idx
    for idx, name in enumerate(EXERCISE_CLASSES)
}

IDX_TO_CLASS = {
    idx: name
    for name, idx in CLASS_TO_IDX.items()
}

# ---------------------------------------------------
# MediaPipe Landmark Indices
# ---------------------------------------------------

MEDIAPIPE_LANDMARKS = {

    "nose": 0,

    "left_eye_inner": 1,
    "left_eye": 2,
    "left_eye_outer": 3,

    "right_eye_inner": 4,
    "right_eye": 5,
    "right_eye_outer": 6,

    "left_ear": 7,
    "right_ear": 8,

    "mouth_left": 9,
    "mouth_right": 10,

    "left_shoulder": 11,
    "right_shoulder": 12,

    "left_elbow": 13,
    "right_elbow": 14,

    "left_wrist": 15,
    "right_wrist": 16,

    "left_pinky": 17,
    "right_pinky": 18,

    "left_index": 19,
    "right_index": 20,

    "left_thumb": 21,
    "right_thumb": 22,

    "left_hip": 23,
    "right_hip": 24,

    "left_knee": 25,
    "right_knee": 26,

    "left_ankle": 27,
    "right_ankle": 28,

    "left_heel": 29,
    "right_heel": 30,

    "left_foot_index": 31,
    "right_foot_index": 32,
}

# ---------------------------------------------------
# Selected Joints
# ---------------------------------------------------

SELECTED_JOINTS = [

    "nose",

    "left_eye_inner",
    "left_eye",
    "left_eye_outer",

    "right_eye_inner",
    "right_eye",
    "right_eye_outer",

    "left_ear",
    "right_ear",

    "mouth_left",
    "mouth_right",

    "left_shoulder",
    "right_shoulder",

    "left_elbow",
    "right_elbow",

    "left_wrist",
    "right_wrist",

    "left_pinky",
    "right_pinky",

    "left_index",
    "right_index",

    "left_thumb",
    "right_thumb",

    "left_hip",
    "right_hip",

    "left_knee",
    "right_knee",

    "left_ankle",
    "right_ankle",

    "left_heel",
    "right_heel",

    "left_foot_index",
    "right_foot_index",
]

SELECTED_INDICES = [
    MEDIAPIPE_LANDMARKS[joint]
    for joint in SELECTED_JOINTS
]

# ---------------------------------------------------
# Skeleton Graph Edges
# ---------------------------------------------------

SKELETON_EDGES = [

    # -----------------------------
    # Face
    # -----------------------------

    (0, 1),
    (1, 2),
    (2, 3),

    (0, 4),
    (4, 5),
    (5, 6),

    (0, 7),
    (0, 8),

    # -----------------------------
    # Shoulders
    # -----------------------------

    (11, 12),

    # -----------------------------
    # Left Arm
    # -----------------------------

    (11, 13),
    (13, 15),

    (15, 17),
    (15, 19),
    (15, 21),

    # -----------------------------
    # Right Arm
    # -----------------------------

    (12, 14),
    (14, 16),

    (16, 18),
    (16, 20),
    (16, 22),

    # -----------------------------
    # Torso
    # -----------------------------

    (11, 23),
    (12, 24),
    (23, 24),

    # -----------------------------
    # Left Leg
    # -----------------------------

    (23, 25),
    (25, 27),
    (27, 29),
    (27, 31),

    # -----------------------------
    # Right Leg
    # -----------------------------

    (24, 26),
    (26, 28),
    (28, 30),
    (28, 32),
]