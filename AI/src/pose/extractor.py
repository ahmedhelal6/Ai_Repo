from pathlib import Path
from typing import List, Tuple

import cv2
import mediapipe as mp
import numpy as np
import math

from src.pose.joints import SELECTED_INDICES
from src.pose.normalization import normalize_keypoints


def calculate_angle(a, b, c):

    a = np.array(a)
    b = np.array(b)
    c = np.array(c)

    radians = np.arctan2(
        c[1] - b[1],
        c[0] - b[0]
    ) - np.arctan2(
        a[1] - b[1],
        a[0] - b[0]
    )

    angle = np.abs(
        radians * 180.0 / np.pi
    )

    if angle > 180:
        angle = 360 - angle

    return angle


class PoseExtractor:

    def __init__(self, model_path: str):

        model_file = Path(model_path)

        if not model_file.exists():

            raise FileNotFoundError(
                f"Model file not found: {model_path}"
            )

        base_options = mp.tasks.BaseOptions(

            model_asset_path=str(model_file)
        )

        options = mp.tasks.vision.PoseLandmarkerOptions(

            base_options=base_options,

            running_mode=mp.tasks.vision.RunningMode.VIDEO,

            num_poses=1,

            min_pose_detection_confidence=0.5,

            min_pose_presence_confidence=0.5,

            min_tracking_confidence=0.5,

            output_segmentation_masks=False,
        )

        self.landmarker = (

            mp.tasks.vision.PoseLandmarker
            .create_from_options(options)
        )

    def close(self) -> None:

        self.landmarker.close()

    @staticmethod
    def _to_mp_image(
        frame_bgr: np.ndarray
    ) -> mp.Image:

        frame_rgb = cv2.cvtColor(

            frame_bgr,
            cv2.COLOR_BGR2RGB
        )

        return mp.Image(

            image_format=mp.ImageFormat.SRGB,

            data=frame_rgb
        )

    @staticmethod
    def _extract_selected_keypoints(
        pose_landmarks
    ) -> np.ndarray:

        keypoints = []

        # ----------------------------------------
        # Original joints
        # ----------------------------------------

        for idx in SELECTED_INDICES:

            landmark = pose_landmarks[idx]

            keypoints.append([

                landmark.x,
                landmark.y,
                landmark.z,

                getattr(
                    landmark,
                    "visibility",
                    1.0
                ),
            ])

        keypoints = np.array(
            keypoints,
            dtype=np.float32
        )

        # ----------------------------------------
        # Normalize
        # ----------------------------------------

        normalized_keypoints = normalize_keypoints(
            keypoints
        )

        # ----------------------------------------
        # Joint indices
        # ----------------------------------------

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

        def point(idx):

            lm = pose_landmarks[idx]

            return [
                lm.x,
                lm.y
            ]

        # ----------------------------------------
        # Angles
        # ----------------------------------------

        left_elbow_angle = calculate_angle(

            point(LEFT_SHOULDER),

            point(LEFT_ELBOW),

            point(LEFT_WRIST),
        )

        right_elbow_angle = calculate_angle(

            point(RIGHT_SHOULDER),

            point(RIGHT_ELBOW),

            point(RIGHT_WRIST),
        )

        left_knee_angle = calculate_angle(

            point(LEFT_HIP),

            point(LEFT_KNEE),

            point(LEFT_ANKLE),
        )

        right_knee_angle = calculate_angle(

            point(RIGHT_HIP),

            point(RIGHT_KNEE),

            point(RIGHT_ANKLE),
        )

        left_hip_angle = calculate_angle(

            point(LEFT_SHOULDER),

            point(LEFT_HIP),

            point(LEFT_KNEE),
        )

        right_hip_angle = calculate_angle(

            point(RIGHT_SHOULDER),

            point(RIGHT_HIP),

            point(RIGHT_KNEE),
        )

        angles = np.array([

            left_elbow_angle,
            right_elbow_angle,

            left_knee_angle,
            right_knee_angle,

            left_hip_angle,
            right_hip_angle,

        ], dtype=np.float32)

        # ----------------------------------------
        # Convert angles to extra joints
        # ----------------------------------------

        angle_joints = np.zeros(
            (6, 4),
            dtype=np.float32
        )

        # Store angle values
        angle_joints[:, 0] = angles

        # ----------------------------------------
        # Combine:
        # original joints + angle joints
        # ----------------------------------------

        combined = np.concatenate(

            [
                normalized_keypoints,
                angle_joints
            ],

            axis=0
        )

        return combined.astype(
            np.float32
        )

    def extract_from_frame(

        self,

        frame_bgr: np.ndarray,

        timestamp_ms: int
    ):

        mp_image = self._to_mp_image(
            frame_bgr
        )

        result = self.landmarker.detect_for_video(

            mp_image,
            timestamp_ms
        )

        if result.pose_landmarks:

            pose_landmarks = result.pose_landmarks[0]

            features = self._extract_selected_keypoints(
                pose_landmarks
            )

            return {

                "raw_keypoints": features,

                "normalized_keypoints": features,

                "detected": True,

                "pose_landmarks": pose_landmarks,
            }

        return {

            "raw_keypoints": None,

            "normalized_keypoints": None,

            "detected": False,

            "pose_landmarks": None,
        }

    def extract_from_video(

        self,

        video_path: str,

    ) -> Tuple[np.ndarray, np.ndarray, List[dict]]:

        video_file = Path(video_path)

        if not video_file.exists():

            raise FileNotFoundError(

                f"Video file not found: {video_path}"
            )

        cap = cv2.VideoCapture(
            str(video_file)
        )

        if not cap.isOpened():

            raise ValueError(

                f"Could not open video: {video_path}"
            )

        fps = cap.get(
            cv2.CAP_PROP_FPS
        )

        if fps <= 0:
            fps = 30.0

        raw_sequence = []

        normalized_sequence = []

        metadata = []

        frame_index = 0

        while True:

            success, frame = cap.read()

            if not success:
                break

            timestamp_ms = int(

                (frame_index / fps) * 1000
            )

            mp_image = self._to_mp_image(
                frame
            )

            result = self.landmarker.detect_for_video(

                mp_image,
                timestamp_ms
            )

            if result.pose_landmarks:

                pose_landmarks = result.pose_landmarks[0]

                features = self._extract_selected_keypoints(
                    pose_landmarks
                )

                raw_sequence.append(
                    features
                )

                normalized_sequence.append(
                    features
                )

                metadata.append({

                    "frame_index": frame_index,

                    "timestamp_ms": timestamp_ms,

                    "detected": True,
                })

            else:

                metadata.append({

                    "frame_index": frame_index,

                    "timestamp_ms": timestamp_ms,

                    "detected": False,
                })

            frame_index += 1

        cap.release()

        raw_sequence_array = np.array(

            raw_sequence,
            dtype=np.float32
        )

        normalized_sequence_array = np.array(

            normalized_sequence,
            dtype=np.float32
        )

        return (

            raw_sequence_array,

            normalized_sequence_array,

            metadata,
        )