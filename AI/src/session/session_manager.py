import json
from datetime import datetime
from collections import Counter


class SessionManager:

    def __init__(self):

        # =====================================================
        # SESSION DATA
        # =====================================================
        self.rep_scores = []

        self.exercise = None

        self.current_reps = 0

        self.good_reps = 0

        self.bad_reps = 0

        self.feedback_counts = Counter()

        self.last_report = None

        # =====================================================
        # WORKOUT HISTORY
        # =====================================================
        self.workout_history = []

        # =====================================================
        # UI STATES
        # =====================================================
        self.awaiting_decision = False

        self.show_report = False

    # =========================================================
    # EXERCISE
    # =========================================================
    def update_exercise(
        self,
        exercise,
        reps,
        is_good_form=True,
        good_reps=0,
        bad_reps=0,
        feedback=None
    ):

        invalid = [
            "WAITING",
            "MOVE_TO_START",
            "BUFFERING",
            "NO_PERSON"
        ]

        if exercise in invalid:
            return

        self.exercise = exercise
        self.current_reps = reps
        self.is_good_form = is_good_form
        self.good_reps = good_reps
        self.bad_reps = bad_reps

        # Track feedback frequency
        if feedback:
            for fb in feedback:
                self.feedback_counts[fb] += 1

    # =========================================================
    # ADD REP
    # =========================================================
    def add_rep(self, quality):

        self.rep_scores.append(quality)

    # =========================================================
    # SAVE CURRENT ROUND
    # =========================================================
    def save_current_round(self):

        if self.exercise is None:
            return

        # Calculate form score
        total = self.good_reps + self.bad_reps
        form_score = round(
            (self.good_reps / total * 100) if total > 0 else 100
        )

        # Get top mistakes
        top_mistakes = [
            msg for msg, _ in self.feedback_counts.most_common(3)
        ] if self.feedback_counts else []

        self.workout_history.append({
            "exercise": self.exercise,
            "total_reps": self.current_reps,
            "good_reps": self.good_reps,
            "bad_reps": self.bad_reps,
            "form_score": form_score,
            "top_mistakes": top_mistakes,
            "good_form": getattr(self, "is_good_form", True)
        })

    # =========================================================
    # GENERATE REPORT
    # =========================================================
    def generate_report(self):

        current_history = list(self.workout_history)

        if self.exercise is not None and self.current_reps > 0:

            total = self.good_reps + self.bad_reps
            form_score = round(
                (self.good_reps / total * 100) if total > 0 else 100
            )

            top_mistakes = [
                msg for msg, _ in self.feedback_counts.most_common(3)
            ] if self.feedback_counts else []

            current_history.append({
                "exercise": self.exercise,
                "total_reps": self.current_reps,
                "good_reps": self.good_reps,
                "bad_reps": self.bad_reps,
                "form_score": form_score,
                "top_mistakes": top_mistakes,
                "good_form": getattr(self, "is_good_form", True)
            })

        # Calculate totals
        total_reps_all = sum(h["total_reps"] for h in current_history)
        total_good = sum(h.get("good_reps", 0) for h in current_history)
        total_bad = sum(h.get("bad_reps", 0) for h in current_history)
        overall_score = round(
            (total_good / (total_good + total_bad) * 100)
            if (total_good + total_bad) > 0 else 100
        )

        report = {
            "workout_history": current_history,
            "summary": {
                "total_exercises": len(current_history),
                "total_reps": total_reps_all,
                "total_good_reps": total_good,
                "total_bad_reps": total_bad,
                "overall_form_score": overall_score,
            }
        }

        self.last_report = report

        # =====================================================
        # SAVE REPORT
        # =====================================================
        try:
            with open(
                "workout_reports.txt",
                "a",
                encoding="utf-8"
            ) as f:

                date_str = datetime.now().strftime(
                    "%Y-%m-%d %H:%M:%S"
                )

                line = (
                    f"[{date_str}] "
                    f"{json.dumps(report, ensure_ascii=False)}\n"
                )

                f.write(line)

        except Exception as e:
            print(f"Failed to save report: {e}")

        return report

    # =========================================================
    # SHOW BUTTONS
    # =========================================================
    def trigger_decision(self):
        self.awaiting_decision = True

    # =========================================================
    # CONTINUE SESSION
    # =========================================================
    def continue_session(self, pipeline):
        self.awaiting_decision = False
        self.show_report = False

    # =========================================================
    # FINISH SESSION
    # =========================================================
    def finish_session(self):
        self.awaiting_decision = False
        self.show_report = True
        self.generate_report()

    # =========================================================
    # RESTART SESSION
    # =========================================================
    def restart_session(self, pipeline):

        self.awaiting_decision = False
        self.show_report = False

        # =====================================================
        # SAVE CURRENT ROUND
        # =====================================================
        self.save_current_round()

        # =====================================================
        # RESET SESSION DATA
        # =====================================================
        self.rep_scores.clear()
        self.exercise = None
        self.current_reps = 0
        self.good_reps = 0
        self.bad_reps = 0
        self.feedback_counts.clear()
        self.last_report = None

        # =====================================================
        # RESET PIPELINE
        # =====================================================
        pipeline.reset_session()

    # =========================================================
    # RESET EVERYTHING
    # =========================================================
    def reset(self):

        self.rep_scores.clear()
        self.exercise = None
        self.current_reps = 0
        self.good_reps = 0
        self.bad_reps = 0
        self.feedback_counts.clear()
        self.last_report = None
        self.awaiting_decision = False
        self.show_report = False