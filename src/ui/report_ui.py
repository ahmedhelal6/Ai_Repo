import cv2
import json
import os
from datetime import datetime


# =========================================================
# SAVE REPORT JSON
# =========================================================
def save_report_json(report):

    os.makedirs(
        "reports",
        exist_ok=True
    )

    timestamp = datetime.now().strftime(
        "%Y-%m-%d_%H-%M-%S"
    )

    filename = (
        f"workout_report_{timestamp}.json"
    )

    filepath = os.path.join(
        "reports",
        filename
    )

    # =====================================================
    # NEW REPORT FORMAT
    # =====================================================
    report_data = {

        "workout_history": report.get(
            "workout_history",
            []
        ),

        "created_at": datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S"
        )
    }

    with open(
        filepath,
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(

            report_data,

            f,

            indent=4,

            ensure_ascii=False
        )

    print(
        f"✅ Report saved: {filepath}"
    )

    return filepath


# =========================================================
# DRAW REPORT SCREEN
# =========================================================
def draw_report_screen(frame, report):

    h, w, _ = frame.shape

    overlay = frame.copy()

    # =====================================================
    # SAVE JSON ONCE
    # =====================================================
    if not report.get("_saved", False):

        save_report_json(report)

        report["_saved"] = True

    # =====================================================
    # DARK BACKGROUND
    # =====================================================
    cv2.rectangle(

        overlay,

        (50, 50),

        (w - 50, h - 50),

        (0, 0, 0),

        -1
    )

    cv2.addWeighted(

        overlay,

        0.85,

        frame,

        0.15,

        0,

        frame
    )

    # =====================================================
    # MAIN PANEL
    # =====================================================
    cv2.rectangle(

        frame,

        (70, 70),

        (w - 70, h - 70),

        (15, 15, 15),

        -1
    )

    cv2.rectangle(

        frame,

        (70, 70),

        (w - 70, h - 70),

        (0, 0, 255),

        2
    )

    # =====================================================
    # TITLE
    # =====================================================
    cv2.putText(

        frame,

        "WORKOUT SUMMARY",

        (w // 2 - 220, 130),

        cv2.FONT_HERSHEY_DUPLEX,

        1.2,

        (0, 0, 255),

        3
    )

    # Divider
    cv2.line(

        frame,

        (120, 160),

        (w - 120, 160),

        (70, 70, 70),

        1
    )

    # =====================================================
    # HISTORY
    # =====================================================
    workout_history = report.get(
        "workout_history",
        []
    )

    y = 240

    if len(workout_history) == 0:

        cv2.putText(

            frame,

            "No Exercises Found",

            (120, y),

            cv2.FONT_HERSHEY_SIMPLEX,

            1.0,

            (255, 255, 255),

            2
        )

    else:

        for item in workout_history:

            exercise_name = item.get(
                "exercise",
                "UNKNOWN"
            )

            total_reps = item.get(
                "total_reps",
                0
            )

            line = (
                f"{exercise_name}  -  {total_reps} reps"
            )

            cv2.putText(

                frame,

                line,

                (120, y),

                cv2.FONT_HERSHEY_SIMPLEX,

                0.9,

                (255, 255, 255),

                2
            )

            y += 60

    # =====================================================
    # FOOTER
    # =====================================================
    cv2.putText(

        frame,

        "JSON report saved inside reports/",

        (w // 2 - 220, h - 120),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.65,

        (180, 180, 180),

        2
    )

    return frame