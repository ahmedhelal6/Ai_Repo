# MediaPipe indices
LEFT_SHOULDER = 11
RIGHT_SHOULDER = 12
LEFT_ELBOW = 13
RIGHT_ELBOW = 14
LEFT_WRIST = 15
RIGHT_WRIST = 16
LEFT_HIP = 23
RIGHT_HIP = 24
LEFT_KNEE = 25
RIGHT_KNEE = 26
LEFT_ANKLE = 27
RIGHT_ANKLE = 28


EXERCISE_COUNTER_RULES = {

    # =====================================================
    # SQUAT
    # =====================================================
    "squat": {
        "label": "Squat",

        "primary_angles": {
            "right": (
                RIGHT_HIP,
                RIGHT_KNEE,
                RIGHT_ANKLE
            ),
            "left": (
                LEFT_HIP,
                LEFT_KNEE,
                LEFT_ANKLE
            ),
        },

        "secondary_angles": {
            "back_right": (
                RIGHT_SHOULDER,
                RIGHT_HIP,
                RIGHT_KNEE
            ),
            "back_left": (
                LEFT_SHOULDER,
                LEFT_HIP,
                LEFT_KNEE
            ),
        },

        # Standing
        "full_angle": 165,

        # Bottom squat
        "contract_angle": 100,

        "mode": "up_down_up",

        "start_stage": "up",

        "form_checks": [
            {
                "angle_key": "back",

                "min_angle": 120,
                "max_angle": 190,

                "message":
                "Keep your back straight!",

                "penalty": 30
            }
        ]
    },

    # =====================================================
    # PUSHUP
    # =====================================================
    "pushup": {
        "label": "Push-Up",

        "primary_angles": {
            "right": (
                RIGHT_SHOULDER,
                RIGHT_ELBOW,
                RIGHT_WRIST
            ),
            "left": (
                LEFT_SHOULDER,
                LEFT_ELBOW,
                LEFT_WRIST
            ),
        },

        "secondary_angles": {
            "body_right": (
                RIGHT_SHOULDER,
                RIGHT_HIP,
                RIGHT_KNEE
            ),
            "body_left": (
                LEFT_SHOULDER,
                LEFT_HIP,
                LEFT_KNEE
            ),
        },

        "full_angle": 160,

        "contract_angle": 80,

        "mode": "up_down_up",

        "start_stage": "up",

        "form_checks": [
            {
                "angle_key": "body",

                "min_angle": 145,
                "max_angle": 190,

                "message":
                "Don't sag your hips!",

                "penalty": 25
            }
        ]
    },

    # =====================================================
    # BICEP CURL
    # =====================================================
    "bicep_curl": {
        "label": "Bicep Curl",

        "primary_angles": {
            "right": (
                RIGHT_SHOULDER,
                RIGHT_ELBOW,
                RIGHT_WRIST
            ),
            "left": (
                LEFT_SHOULDER,
                LEFT_ELBOW,
                LEFT_WRIST
            ),
        },

        "secondary_angles": {
            "upper_arm_right": (
                RIGHT_HIP,
                RIGHT_SHOULDER,
                RIGHT_ELBOW
            ),
            "upper_arm_left": (
                LEFT_HIP,
                LEFT_SHOULDER,
                LEFT_ELBOW
            ),
        },

        # Arm extended
        "full_angle": 145,

        # Arm contracted
        "contract_angle": 75,

        "mode": "down_up",

        "start_stage": "down",

        "form_checks": [
            {
                "angle_key": "upper_arm",

                "min_angle": 0,
                "max_angle": 40,

                "message":
                "Keep elbows tucked!",

                "penalty": 20
            }
        ]
    },

    # =====================================================
    # SHOULDER PRESS
    # =====================================================
    "shoulder_press": {
        "label": "Shoulder Press",

        "primary_angles": {
            "right": (
                RIGHT_HIP,
                RIGHT_SHOULDER,
                RIGHT_ELBOW
            ),
            "left": (
                LEFT_HIP,
                LEFT_SHOULDER,
                LEFT_ELBOW
            ),
        },

        "secondary_angles": {
            "arm_right": (
                RIGHT_SHOULDER,
                RIGHT_ELBOW,
                RIGHT_WRIST
            ),
            "arm_left": (
                LEFT_SHOULDER,
                LEFT_ELBOW,
                LEFT_WRIST
            ),
        },

        # Arm overhead
        "full_angle": 165,

        # Bottom press
        "contract_angle": 90,

        "mode": "down_up",

        "start_stage": "down",

        "form_checks": [
            {
                "angle_key": "arm",

                "min_angle": 40,
                "max_angle": 190,

                "message":
                "Keep elbows at 90 degrees at bottom!",

                "penalty": 10
            }
        ]
    },

    # =====================================================
    # DEADLIFT
    # =====================================================
    "deadlift": {
        "label": "Deadlift",

        "primary_angles": {
            "right": (
                RIGHT_SHOULDER,
                RIGHT_HIP,
                RIGHT_KNEE
            ),
            "left": (
                LEFT_SHOULDER,
                LEFT_HIP,
                LEFT_KNEE
            ),
        },

        "secondary_angles": {
            "knee_right": (
                RIGHT_HIP,
                RIGHT_KNEE,
                RIGHT_ANKLE
            ),
            "knee_left": (
                LEFT_HIP,
                LEFT_KNEE,
                LEFT_ANKLE
            ),
        },

        "full_angle": 170,
        "contract_angle": 110,
        "mode": "up_down_up",
        "start_stage": "up",

        "form_checks": [
            {
                "angle_key": "knee",

                "min_angle": 100,
                "max_angle": 180,

                "message":
                "Don't turn it into a squat!",

                "penalty": 20
            }
        ]
    },

    # =====================================================
    # LATERAL RAISE
    # =====================================================
    "lateral_raise": {
        "label": "Lateral Raise",

        # 🔥 اتعدل لتقليل اللخبطة
        "primary_angles": {
            "right": (
                RIGHT_HIP,
                RIGHT_SHOULDER,
                RIGHT_ELBOW
            ),
            "left": (
                LEFT_HIP,
                LEFT_SHOULDER,
                LEFT_ELBOW
            ),
        },

        "secondary_angles": {
            "elbow_right": (
                RIGHT_SHOULDER,
                RIGHT_ELBOW,
                RIGHT_WRIST
            ),
            "elbow_left": (
                LEFT_SHOULDER,
                LEFT_ELBOW,
                LEFT_WRIST
            ),
        },

        # Arms raised (top of movement)
        "full_angle": 80,

        # Arms down (bottom of movement)
        "contract_angle": 35,

        "mode": "up_down_up",

        "start_stage": "down",

        "form_checks": [
            {
                "angle_key": "elbow",

                "min_angle": 130,
                "max_angle": 180,

                "message":
                "Keep a slight bend in elbow!",

                "penalty": 15
            }
        ]
    }
}