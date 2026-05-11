from dataclasses import dataclass
from typing import Optional, Tuple, Dict, Any
import math
import numpy as np


# MediaPipe indices
LEFT_SHOULDER = 11
RIGHT_SHOULDER = 12
LEFT_HIP = 23
RIGHT_HIP = 24
LEFT_KNEE = 25
RIGHT_KNEE = 26
LEFT_ANKLE = 27
RIGHT_ANKLE = 28


@dataclass
class BodySignature:
    center_x: float
    center_y: float
    body_size: float
    shoulder_torso_ratio: float
    visibility_score: float


@dataclass
class TrackState:
    locked: bool = False
    paused: bool = False
    stable_frames: int = 0
    suspicious_streak: int = 0
    normal_streak: int = 0
    last_score: float = 0.0


class PersonLockTracker:
    def __init__(
        self,
        lock_frames: int = 12,
        pause_suspicious_frames: int = 4,
        resume_normal_frames: int = 3,
        match_threshold: float = 0.62,
        min_visibility: float = 0.55,
        center_weight: float = 0.45,
        size_weight: float = 0.30,
        ratio_weight: float = 0.25,
        ema_alpha: float = 0.15,
    ):
        self.lock_frames = lock_frames
        self.pause_suspicious_frames = pause_suspicious_frames
        self.resume_normal_frames = resume_normal_frames
        self.match_threshold = match_threshold
        self.min_visibility = min_visibility

        self.center_weight = center_weight
        self.size_weight = size_weight
        self.ratio_weight = ratio_weight

        self.ema_alpha = ema_alpha

        self.reference_signature: Optional[BodySignature] = None
        self.current_signature_ema: Optional[BodySignature] = None
        self.state = TrackState()

    def reset(self):
        self.reference_signature = None
        self.current_signature_ema = None
        self.state = TrackState()

    def update(self, landmarks, frame_width: int, frame_height: int) -> Dict[str, Any]:
        """
        landmarks: list-like of mediapipe landmarks
        returns:
            {
                "valid_pose": bool,
                "locked": bool,
                "paused": bool,
                "match_score": float,
                "status": str,
                "signature": BodySignature | None
            }
        """
        signature = self._extract_signature(landmarks, frame_width, frame_height)

        if signature is None or signature.visibility_score < self.min_visibility:
            return self._handle_invalid_pose()

        if not self.state.locked:
            return self._handle_locking(signature)

        return self._handle_tracking(signature)

    def _handle_invalid_pose(self) -> Dict[str, Any]:
        if self.state.locked and not self.state.paused:
            self.state.suspicious_streak += 1
            self.state.normal_streak = 0

            if self.state.suspicious_streak >= self.pause_suspicious_frames:
                self.state.paused = True

        return {
            "valid_pose": False,
            "locked": self.state.locked,
            "paused": self.state.paused,
            "match_score": self.state.last_score,
            "status": "no_pose",
            "signature": None,
        }

    def _handle_locking(self, signature: BodySignature) -> Dict[str, Any]:
        if self.current_signature_ema is None:
            self.current_signature_ema = signature
            self.state.stable_frames = 1
        else:
            stability_score = self._match_score(signature, self.current_signature_ema)

            if stability_score >= 0.82:
                self.state.stable_frames += 1
                self.current_signature_ema = self._ema_signature(self.current_signature_ema, signature)
            else:
                self.state.stable_frames = 1
                self.current_signature_ema = signature

        if self.state.stable_frames >= self.lock_frames:
            self.reference_signature = self.current_signature_ema
            self.state.locked = True
            self.state.paused = False
            self.state.suspicious_streak = 0
            self.state.normal_streak = 0
            self.state.last_score = 1.0

            return {
                "valid_pose": True,
                "locked": True,
                "paused": False,
                "match_score": 1.0,
                "status": "locked",
                "signature": signature,
            }

        return {
            "valid_pose": True,
            "locked": False,
            "paused": False,
            "match_score": 0.0,
            "status": f"locking_{self.state.stable_frames}/{self.lock_frames}",
            "signature": signature,
        }

    def _handle_tracking(self, signature: BodySignature) -> Dict[str, Any]:
        score = self._match_score(signature, self.reference_signature)
        self.state.last_score = score

        if score < self.match_threshold:
            self.state.suspicious_streak += 1
            self.state.normal_streak = 0

            if self.state.suspicious_streak >= self.pause_suspicious_frames:
                self.state.paused = True

            status = "suspicious"
        else:
            self.state.normal_streak += 1
            self.state.suspicious_streak = 0

            if self.state.paused and self.state.normal_streak >= self.resume_normal_frames:
                self.state.paused = False

            status = "matched"

            # تحديث reference بهدوء عشان يتأقلم مع تغييرات بسيطة
            self.reference_signature = self._ema_signature(self.reference_signature, signature)

        return {
            "valid_pose": True,
            "locked": True,
            "paused": self.state.paused,
            "match_score": score,
            "status": status,
            "signature": signature,
        }

    def _extract_signature(self, landmarks, frame_width: int, frame_height: int) -> Optional[BodySignature]:
        needed = [
            LEFT_SHOULDER, RIGHT_SHOULDER,
            LEFT_HIP, RIGHT_HIP,
            LEFT_KNEE, RIGHT_KNEE,
            LEFT_ANKLE, RIGHT_ANKLE
        ]

        pts = []
        visibilities = []

        for idx in needed:
            if idx >= len(landmarks):
                return None

            lm = landmarks[idx]
            x = lm.x * frame_width
            y = lm.y * frame_height
            v = getattr(lm, "visibility", 1.0)

            pts.append((x, y))
            visibilities.append(v)

        pts = np.array(pts, dtype=np.float32)
        visibility_score = float(np.mean(visibilities))

        center_x = float(np.mean(pts[:, 0]) / frame_width)
        center_y = float(np.mean(pts[:, 1]) / frame_height)

        left_shoulder = self._pt(landmarks, LEFT_SHOULDER, frame_width, frame_height)
        right_shoulder = self._pt(landmarks, RIGHT_SHOULDER, frame_width, frame_height)
        left_hip = self._pt(landmarks, LEFT_HIP, frame_width, frame_height)
        right_hip = self._pt(landmarks, RIGHT_HIP, frame_width, frame_height)
        left_ankle = self._pt(landmarks, LEFT_ANKLE, frame_width, frame_height)
        right_ankle = self._pt(landmarks, RIGHT_ANKLE, frame_width, frame_height)

        shoulder_mid = self._midpoint(left_shoulder, right_shoulder)
        hip_mid = self._midpoint(left_hip, right_hip)
        ankle_mid = self._midpoint(left_ankle, right_ankle)

        shoulder_width = self._distance(left_shoulder, right_shoulder)
        torso_length = self._distance(shoulder_mid, hip_mid)
        full_body_length = self._distance(shoulder_mid, ankle_mid)

        body_size = float(full_body_length / max(frame_height, 1))
        shoulder_torso_ratio = float(shoulder_width / max(torso_length, 1e-6))

        return BodySignature(
            center_x=center_x,
            center_y=center_y,
            body_size=body_size,
            shoulder_torso_ratio=shoulder_torso_ratio,
            visibility_score=visibility_score,
        )

    def _match_score(self, a: BodySignature, b: BodySignature) -> float:
        center_dist = math.sqrt((a.center_x - b.center_x) ** 2 + (a.center_y - b.center_y) ** 2)
        center_score = max(0.0, 1.0 - (center_dist / 0.25))

        size_rel_diff = abs(a.body_size - b.body_size) / max(b.body_size, 1e-6)
        size_score = max(0.0, 1.0 - (size_rel_diff / 0.35))

        ratio_rel_diff = abs(a.shoulder_torso_ratio - b.shoulder_torso_ratio) / max(abs(b.shoulder_torso_ratio), 1e-6)
        ratio_score = max(0.0, 1.0 - (ratio_rel_diff / 0.30))

        score = (
            self.center_weight * center_score +
            self.size_weight * size_score +
            self.ratio_weight * ratio_score
        )

        return float(np.clip(score, 0.0, 1.0))

    def _ema_signature(self, old: BodySignature, new: BodySignature) -> BodySignature:
        a = self.ema_alpha
        return BodySignature(
            center_x=(1 - a) * old.center_x + a * new.center_x,
            center_y=(1 - a) * old.center_y + a * new.center_y,
            body_size=(1 - a) * old.body_size + a * new.body_size,
            shoulder_torso_ratio=(1 - a) * old.shoulder_torso_ratio + a * new.shoulder_torso_ratio,
            visibility_score=(1 - a) * old.visibility_score + a * new.visibility_score,
        )

    @staticmethod
    def _pt(landmarks, idx: int, frame_width: int, frame_height: int) -> Tuple[float, float]:
        lm = landmarks[idx]
        return (lm.x * frame_width, lm.y * frame_height)

    @staticmethod
    def _midpoint(a: Tuple[float, float], b: Tuple[float, float]) -> Tuple[float, float]:
        return ((a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0)

    @staticmethod
    def _distance(a: Tuple[float, float], b: Tuple[float, float]) -> float:
        return math.sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2)