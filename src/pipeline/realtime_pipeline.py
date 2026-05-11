import time
import os
import torch
import numpy as np

from collections import Counter, deque

from src.core.config import (
    POSE_TASK_PATH,
)

from src.pose.extractor import PoseExtractor
from src.pose.joints import IDX_TO_CLASS

from src.session.session_manager import SessionManager

from src.model.stgcn import SimpleSTGCN

from src.counter.rep_counter import RepCounter
from src.counter.rules import EXERCISE_COUNTER_RULES
from src.counter.angles import calculate_angle


# =========================================================
# REALTIME PIPELINE
# =========================================================
class RealtimePipeline:

    def __init__(self, use_camera: bool = True):

        self.device = torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        )

        # =================================================
        # MODEL
        # =================================================
        weights_path = "best_model.pth"

        self.num_channels = 4
        self.num_joints = 39

        if not os.path.exists(weights_path):

            raise FileNotFoundError(
                "best_model.pth not found"
            )

        checkpoint = torch.load(
            weights_path,
            map_location=self.device,
            weights_only=True
        )

        self.num_channels = checkpoint.get(
            "num_channels",
            self.num_channels
        )

        self.num_joints = checkpoint.get(
            "num_joints",
            self.num_joints
        )

        self.model = SimpleSTGCN(

            num_joints=self.num_joints,

            num_classes=len(
                IDX_TO_CLASS
            ),

            in_channels=self.num_channels
        )

        self.model.load_state_dict(
            checkpoint["model_state"]
        )

        self.model.to(self.device)

        self.model.eval()

        print(
            f"✅ ST-GCN Loaded: "
            f"{self.num_channels} channels, "
            f"{self.num_joints} joints"
        )

        # =================================================
        # SETTINGS
        # =================================================
        self.seq_len = 20

        self.motion_threshold = 0.0008

        self.motion_required_frames = 2

        self.prediction_threshold = 0.45

        # =================================================
        # BUFFERS
        # =================================================
        self.sequence_buffer = []

        self.prediction_history = deque(
            maxlen=5
        )

        self.prev_features = None

        # =================================================
        # COMPONENTS
        # =================================================
        # Only init extractor when running with local camera
        if use_camera:
            self.extractor = PoseExtractor(
                str(POSE_TASK_PATH)
            )
        else:
            self.extractor = None

        self.session = SessionManager()

        self.rep_counter = None

        # =================================================
        # STATE
        # =================================================
        self.allow_detection = False

        self.motion_frames = 0

        self.current_label = "WAITING"

        self.current_confidence = 0.0

        self.exercise_locked = False

        # =================================================
        # COUNTDOWN
        # =================================================
        self.countdown_active = False

        self.countdown_finished = False
        self.inference_counter = 0

        self.countdown_seconds = 3

        # --- Integrated from app.py ---
        self.last_rep_time = time.time()
        self.previous_reps = 0
        # -----------------------------

    # =====================================================
    # RESET SESSION (preserves workout history)
    # =====================================================
    def reset_session(self):
        """Reset pipeline state for a new exercise round, keeping session history."""
        self.sequence_buffer = []
        self.prediction_history.clear()
        self.prev_features = None
        self.rep_counter = None

        self.allow_detection = False
        self.motion_frames = 0
        self.current_label = "WAITING"
        self.current_confidence = 0.0
        self.exercise_locked = False

        self.countdown_active = False
        self.countdown_finished = False
        self.inference_counter = 0

        self.last_rep_time = time.time()
        self.previous_reps = 0

    # =====================================================
    # BUILD INPUT
    # =====================================================
    def _build_input(self, seq_np):

        seq = torch.from_numpy(
            seq_np
        ).float()

        seq = seq.permute(
            2,
            0,
            1
        )

        return seq.unsqueeze(0)

    # =====================================================
    # BUILD ANGLES DICT
    # =====================================================
    def _build_angles_dict(

        self,

        exercise_name,

        landmarks
    ):

        if exercise_name not in EXERCISE_COUNTER_RULES:

            return None

        config = EXERCISE_COUNTER_RULES[
            exercise_name
        ]

        def get_point(idx):

            return [

                landmarks[idx].x,

                landmarks[idx].y
            ]

        def get_angle(triplet):

            p1 = get_point(triplet[0])

            p2 = get_point(triplet[1])

            p3 = get_point(triplet[2])

            return calculate_angle(p1, p2, p3)

        angles_dict = {}

        # =================================================
        # PRIMARY ANGLE
        # =================================================
        primary_cfg = config[
            "primary_angles"
        ]

        right_angle = get_angle(primary_cfg["right"])

        left_angle = get_angle(primary_cfg["left"])

        # Determine resting angle
        mode = config.get("mode", "")

        start_stage = config.get("start_stage", "")

        if mode == "up_down_up" and start_stage == "down":

            rest_angle = config.get("contract_angle", 0)

        else:

            rest_angle = config.get("full_angle", 0)

        # Select the active side (furthest from rest angle)
        diff_right = abs(right_angle - rest_angle)

        diff_left = abs(left_angle - rest_angle)

        if diff_right >= diff_left:

            primary_angle = right_angle

            active_side = "right"

        else:

            primary_angle = left_angle

            active_side = "left"

        angles_dict["primary"] = primary_angle

        # =================================================
        # SECONDARY ANGLES
        # =================================================
        secondary_cfg = config.get(

            "secondary_angles",

            {}
        )

        for key, triplet in secondary_cfg.items():

            if key.endswith(f"_{active_side}"):

                ang = get_angle(triplet)

                clean_key = key.replace(f"_{active_side}", "")

                angles_dict[clean_key] = ang

        # =================================================
        # STABILITY CHECKS
        # =================================================
        # Disabled for better mobile stability
        angles_dict["feet_stable"] = True

        pass

        return angles_dict

    # =====================================================
    # RESET
    # =====================================================
    def reset_session(self):

        self.session.reset()

        self.rep_counter = None

        self.sequence_buffer.clear()

        self.prediction_history.clear()

        self.prev_features = None

        self.allow_detection = False

        self.motion_frames = 0

        self.current_label = "WAITING"

        self.current_confidence = 0.0

        self.exercise_locked = False

        # countdown
        self.countdown_active = False

        self.countdown_finished = False

        self.countdown_start_time = None

    # =====================================================
    # CURRENT STATE
    # =====================================================
    @property
    def current_state(self):

        countdown_value = None

        if self.countdown_active and not self.countdown_finished:

            elapsed = int(
                time.time()
                -
                self.countdown_start_time
            )

            remaining = max(
                0,
                self.countdown_seconds - elapsed
            )

            countdown_value = remaining

        return {

            "exercise":
                self.current_label,

            "reps": (

                self.rep_counter.reps

                if self.rep_counter is not None

                else 0
            ),

            "stage": (

                self.rep_counter.stage

                if self.rep_counter is not None

                else None
            ),

            "confirmed":
                self.allow_detection,

            "confidence":
                self.current_confidence,

            "countdown":
                countdown_value,

            "locked":
                self.exercise_locked,

            "feedback": (

                self.rep_counter.feedbacks 
                
                if self.rep_counter is not None and hasattr(self.rep_counter, "feedbacks")

                else []
            )
        }

    # =====================================================
    # PROCESS FRAME
    # =====================================================
    def process_frame(self, frame):

        if frame is None:

            return (
                None,
                "NO_FRAME",
                0,
                0,
                0,
                0,
                None,
                ""
            )

        # =================================================
        # EXTRACT POSE
        # =================================================
        res = self.extractor.extract_from_frame(

            frame,

            int(time.time() * 1000)
        )

        # =================================================
        # NO PERSON
        # =================================================
        if not res["detected"]:

            self.reset_session()

            return (

                frame,

                "NO_PERSON",

                0,

                0,

                0,

                0,

                None,

                ""
            )

        lm = res["pose_landmarks"]

        features = res["normalized_keypoints"]

        # =================================================
        # MOTION DETECTION
        # =================================================
        if self.prev_features is None:

            motion = 0.0

        else:

            motion = np.mean(

                np.abs(

                    features[:, :2]
                    -
                    self.prev_features[:, :2]
                )
            )

        self.prev_features = features.copy()

        # =================================================
        # WAIT FOR MOVEMENT
        # =================================================
        if not self.allow_detection:

            if motion > self.motion_threshold:

                self.motion_frames += 1

            else:

                self.motion_frames = max(
                    0,
                    self.motion_frames - 1
                )

            if self.motion_frames >= self.motion_required_frames:

                self.allow_detection = True

                self.countdown_active = True

                self.countdown_start_time = time.time()

            return (

                frame,

                "MOVE_TO_START",

                0,

                motion,

                0,

                0,

                None,

                ""
            )

        # =================================================
        # COUNTDOWN
        # =================================================
        if self.countdown_active and not self.countdown_finished:

            elapsed = int(
                time.time()
                -
                self.countdown_start_time
            )

            remaining = (

                self.countdown_seconds
                -
                elapsed
            )

            if remaining > 0:

                return (

                    frame,

                    f"COUNTDOWN_{remaining}",

                    0,

                    0,

                    0,

                    0,

                    None,

                    ""
                )

            else:

                self.countdown_finished = True

        # =================================================
        # BUFFER
        # =================================================
        self.sequence_buffer.append(
            features
        )

        if len(self.sequence_buffer) > self.seq_len:

            self.sequence_buffer.pop(0)

        # =================================================
        # WAIT FOR BUFFER
        # =================================================
        if len(self.sequence_buffer) < self.seq_len:

            return (

                frame,

                "BUFFERING",

                0,

                0,

                0,

                0,

                None,

                ""
            )

        # =================================================
        # PREDICTION
        # =================================================
        movement_active = (
            motion > self.motion_threshold
        )

        if (

            not self.exercise_locked

            and movement_active
        ):

            seq_np = np.array(

                self.sequence_buffer,

                dtype=np.float32
            )

            inp = self._build_input(
                seq_np
            ).to(self.device)

            # =============================================
            # INFERENCE
            # =============================================
            with torch.no_grad():

                output = self.model(inp)

                probs = torch.softmax(
                    output,
                    dim=1
                )

                conf, pred = torch.max(
                    probs,
                    dim=1
                )

            confidence_value = conf.item()

            pred_name = IDX_TO_CLASS[
                pred.item()
            ]

            self.current_confidence = confidence_value

            # =============================================
            # CONFIDENCE FILTER
            # =============================================
            if confidence_value >= self.prediction_threshold:

                self.prediction_history.append(
                    pred_name
                )

            # =============================================
            # SMOOTHING
            # =============================================
            if len(self.prediction_history) >= 3:

                pred_counter = Counter(
                    self.prediction_history
                )

                stable_pred, stable_count = (

                    pred_counter.most_common(1)[0]
                )

                # =========================================
                # LOCK EXERCISE
                # =========================================
                if stable_count >= 2:

                    self.current_label = stable_pred

                    self.exercise_locked = True

                    print(
                        f"🔒 LOCKED: {stable_pred}"
                    )

                    # =====================================
                    # LOAD REP COUNTER
                    # =====================================
                    config = EXERCISE_COUNTER_RULES[
                        stable_pred
                    ]

                    self.rep_counter = RepCounter(

                        config=config,

                        min_frames_confirm=3
                    )

        # =================================================
        # REP COUNTING
        # =================================================
        rep_data = None

        # =============================================
        # REQUIRE REAL MOVEMENT
        # =============================================
        movement_active = (
            motion > self.motion_threshold
        )

        if (

            self.exercise_locked

            and self.rep_counter is not None

            and movement_active
        ):

            angles_dict = self._build_angles_dict(

                self.current_label,

                lm
            )

            if angles_dict is not None:

                rep_data = self.rep_counter.update(
                    angles_dict
                )

                # =================================================
        # UPDATE SESSION HISTORY
        # =================================================
        current_reps = (

            rep_data["reps"]

            if rep_data is not None

            else 0
        )
        
        if rep_data is not None and current_reps > 0:
            good_reps = rep_data.get("good_reps", 0)
            bad_reps = rep_data.get("bad_reps", 0)
            is_good_form = good_reps >= bad_reps
        else:
            is_good_form = True

        self.session.update_exercise(

            self.current_label,

            current_reps,
            
            is_good_form
        )

        # =================================================
        # RETURN
        # =================================================
        return (

            frame,

            self.current_label,

            rep_data["reps"]

            if rep_data is not None

            else 0,

            self.current_confidence,

            0,

            0,

            None,

            ""
        )

    # =====================================================
    # FULL RESET
    # =====================================================
    def full_reset(self):

        # =================================================
        # SESSION
        # =================================================
        self.session.reset()

        # =================================================
        # REP COUNTER
        # =================================================
        self.rep_counter = None

        # =================================================
        # BUFFERS
        # =================================================
        self.sequence_buffer.clear()

        self.prediction_history.clear()

        self.prev_features = None

        # =================================================
        # MOTION GATE
        # =================================================
        self.allow_detection = False

        self.motion_frames = 0

        # =================================================
        # LABELS
        # =================================================
        self.current_label = "WAITING"

        self.current_confidence = 0.0

        self.exercise_locked = False

        # =================================================
        # COUNTDOWN
        # =================================================
        self.countdown_active = False

        self.countdown_finished = False

        self.countdown_start_time = None

    # =====================================================
    # PROCESS KEYPOINTS  (Flutter API mode)
    # =====================================================
    def process_keypoints(self, features, lm_proxies):
        """
        Called by api.py instead of process_frame().
        features   : np.ndarray (39, 4)
        lm_proxies : list of 39 LandmarkProxy objects (first 33 are real)
        """
        # =================================================
        # MOTION DETECTION
        # =================================================
        if self.prev_features is None:
            motion = 0.0
        else:
            motion = float(np.mean(
                np.abs(features[:, :2] - self.prev_features[:, :2])
            ))

        self.prev_features = features.copy()

        # =================================================
        # WAIT FOR MOVEMENT
        # =================================================
        if not self.allow_detection:
            if motion > self.motion_threshold:
                self.motion_frames += 1
            else:
                self.motion_frames = max(0, self.motion_frames - 1)

            if self.motion_frames >= self.motion_required_frames:
                self.allow_detection = True
                self.countdown_active = True
                self.countdown_start_time = time.time()

            return {
                "state": "MOVE_TO_START",
                "exercise": "WAITING",
                "reps": 0,
                "stage": None,
                "feedback": [],
                "confidence": 0.0,
                "locked": False,
                "good_reps": 0,
                "bad_reps": 0,
                "awaiting_decision": self.session.awaiting_decision,
                "show_report": self.session.show_report
            }

        # =================================================
        # COUNTDOWN
        # =================================================
        if self.countdown_active and not self.countdown_finished:
            elapsed = int(time.time() - self.countdown_start_time)
            remaining = self.countdown_seconds - elapsed
            if remaining > 0:
                return {
                    "state": f"COUNTDOWN_{remaining}",
                    "exercise": "WAITING",
                    "reps": 0,
                    "stage": None,
                    "feedback": [],
                    "confidence": 0.0,
                    "locked": False,
                    "good_reps": 0,
                    "bad_reps": 0,
                    "awaiting_decision": self.session.awaiting_decision,
                    "show_report": self.session.show_report
                }
            else:
                self.countdown_finished = True

        # =================================================
        # BUFFER
        # =================================================
        self.sequence_buffer.append(features)
        if len(self.sequence_buffer) > self.seq_len:
            self.sequence_buffer.pop(0)

        if len(self.sequence_buffer) < self.seq_len:
            return {
                "state": "BUFFERING",
                "exercise": "WAITING",
                "reps": 0,
                "stage": None,
                "feedback": [],
                "confidence": 0.0,
                "locked": False,
                "good_reps": 0,
                "bad_reps": 0,
                "awaiting_decision": self.session.awaiting_decision,
                "show_report": self.session.show_report
            }

        # =================================================
        # PREDICTION
        # =================================================
        movement_active = motion > self.motion_threshold

        if not self.exercise_locked and movement_active:
            from collections import Counter
            
            self.inference_counter += 1
            if self.inference_counter % 5 == 0:
                seq_np = np.array(self.sequence_buffer, dtype=np.float32)
                inp = self._build_input(seq_np).to(self.device)
                
                with torch.no_grad():
                    output = self.model(inp)
                    probs = torch.softmax(output, dim=1)
                    conf, pred = torch.max(probs, dim=1)
                
                self._cached_conf = conf.item()
                self._cached_pred = IDX_TO_CLASS[pred.item()]

            confidence_value = getattr(self, '_cached_conf', 0.0)
            pred_name = getattr(self, '_cached_pred', 'WAITING')
            self.current_confidence = confidence_value

            if confidence_value >= self.prediction_threshold:
                self.prediction_history.append(pred_name)

            if len(self.prediction_history) >= 3:
                pred_counter = Counter(self.prediction_history)
                stable_pred, stable_count = pred_counter.most_common(1)[0]
                if stable_count >= 2:
                    self.current_label = stable_pred
                    self.exercise_locked = True
                    print(f"🔒 LOCKED: {stable_pred}")
                    config = EXERCISE_COUNTER_RULES[stable_pred]
                    self.rep_counter = RepCounter(
                        config=config,
                        min_frames_confirm=3
                    )

        # =================================================
        # REP COUNTING
        # =================================================
        rep_data = None
        movement_active = motion > self.motion_threshold

        if self.exercise_locked and self.rep_counter is not None and movement_active:
            angles_dict = self._build_angles_dict(self.current_label, lm_proxies)
            if angles_dict is not None:
                rep_data = self.rep_counter.update(angles_dict)

        # =================================================
        # UPDATE SESSION
        # =================================================
        current_reps = rep_data["reps"] if rep_data is not None else 0
        if rep_data is not None and current_reps > 0:
            good_reps = rep_data.get("good_reps", 0)
            bad_reps  = rep_data.get("bad_reps", 0)
            is_good_form = good_reps >= bad_reps
        else:
            is_good_form = True

        self.session.update_exercise(self.current_label, current_reps, is_good_form)

        # =================================================
        # IDLE DETECTION (10 seconds)
        # =================================================
        if current_reps > self.previous_reps:
            self.last_rep_time = time.time()
            self.previous_reps = current_reps

        idle_time = time.time() - self.last_rep_time
        if current_reps > 0 and idle_time >= 5 and not self.session.awaiting_decision and not self.session.show_report:
            self.session.awaiting_decision = True

        # =================================================
        # RETURN
        # =================================================
        return {
            "state": "ACTIVE",
            "exercise": self.current_label,
            "reps": current_reps,
            "stage": rep_data["stage"] if rep_data else None,
            "confidence": round(self.current_confidence, 3),
            "locked": self.exercise_locked,
            "feedback": rep_data["feedback"] if rep_data else [],
            "good_reps": rep_data.get("good_reps", 0) if rep_data else 0,
            "bad_reps":  rep_data.get("bad_reps",  0) if rep_data else 0,
            "awaiting_decision": self.session.awaiting_decision,
            "show_report": self.session.show_report
        }

    # =====================================================
    # CLOSE
    # =====================================================
    def close(self):

        if self.extractor is not None:
            self.extractor.close()