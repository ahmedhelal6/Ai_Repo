class FeedbackEngine:

    def __init__(self):
        self.prev_angles = {}
        self.buffers = {}

        # 🔥 NEW
        self.rep_angles = []
        self.rep_back = []

    # ==============================
    # 🔧 SMOOTHING
    # ==============================
    def smooth(self, key, value, alpha=0.7):
        if key not in self.prev_angles:
            self.prev_angles[key] = value
            return value
        smoothed = alpha * self.prev_angles[key] + (1 - alpha) * value
        self.prev_angles[key] = smoothed
        return smoothed

    # ==============================
    # 📦 BUFFER
    # ==============================
    def buffer(self, key, value, size=5):
        if key not in self.buffers:
            self.buffers[key] = deque(maxlen=size)
        self.buffers[key].append(value)
        return np.mean(self.buffers[key])

    # ==============================
    # 🔥 COLLECT DATA
    # ==============================
    def update_rep(self, elbow, back=None):
        if elbow is not None:
            self.rep_angles.append(elbow)

        if back is not None:
            self.rep_back.append(back)

    # ==============================
    # 🧠 FINAL EVALUATION (PER REP)
    # ==============================
    def evaluate_rep(self, exercise):

        if not self.rep_angles:
            return "", 0

        feedback = []
        score = 100

        min_angle = min(self.rep_angles)
        max_angle = max(self.rep_angles)

        # 🔴 DEPTH
        if min_angle > 90:
            feedback.append("Go deeper")
            score -= 25

        # 🔴 FULL EXTENSION
        if max_angle < 140:
            feedback.append("Extend more")
            score -= 20

        # 🔴 BACK
        if self.rep_back:
            avg_back = sum(self.rep_back) / len(self.rep_back)
            if avg_back > 20:
                feedback.append("Keep back straight")
                score -= 25

        if not feedback:
            feedback.append("Perfect rep")

        return " | ".join(feedback), max(score, 0)

    # ==============================
    # 🔄 RESET AFTER REP
    # ==============================
    def reset_rep(self):
        self.rep_angles = []
        self.rep_back = []