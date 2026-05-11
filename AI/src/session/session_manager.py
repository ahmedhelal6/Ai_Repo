import json
from datetime import datetime


class SessionManager:

    def __init__(self):

        # =====================================================
        # SESSION DATA
        # =====================================================
        self.rep_scores = []

        self.exercise = None

        self.current_reps = 0

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
        
        is_good_form=True
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

        self.workout_history.append({

            "exercise":
                self.exercise,

            "total_reps":
                self.current_reps,
                
            "good_form":
                getattr(self, "is_good_form", True)
        })

    # =========================================================
    # GENERATE REPORT
    # =========================================================
    def generate_report(self):

        current_history = list(self.workout_history)

        if self.exercise is not None and self.current_reps > 0:

            current_history.append({

                "exercise":
                    self.exercise,

                "total_reps":
                    self.current_reps,
                    
                "good_form":
                    getattr(self, "is_good_form", True)
            })

        report = {

            "workout_history":
                current_history
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

            print(
                f"Failed to save report: {e}"
            )

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

        self.last_report = None

        self.awaiting_decision = False

        self.show_report = False