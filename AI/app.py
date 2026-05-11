import cv2
import traceback
import time

from src.pipeline.realtime_pipeline import RealtimePipeline

from src.ui.ui_draw import (
    draw_hud,
    draw_decision_buttons
)

from src.ui.report_ui import draw_report_screen

# =========================================================
# INIT
# =========================================================
pipeline = RealtimePipeline()

cap = cv2.VideoCapture(0)

WINDOW = "AI Fitness Coach"

cv2.namedWindow(WINDOW)

clicked_point = None

last_rep_time = time.time()

previous_reps = 0

report_data = {}

# =========================================================
# MOUSE CALLBACK
# =========================================================
def mouse_callback(event, x, y, flags, param):

    global clicked_point

    if event == cv2.EVENT_LBUTTONDOWN:

        clicked_point = (x, y)


cv2.setMouseCallback(
    WINDOW,
    mouse_callback
)

# =========================================================
# CHECK CAMERA
# =========================================================
if not cap.isOpened():

    print("❌ Camera not opened")

    exit()

# =========================================================
# LOOP
# =========================================================
while True:

    try:

        # =================================================
        # READ FRAME
        # =================================================
        ret, frame = cap.read()

        if not ret:

            print("❌ Failed to read frame")

            continue

        # =================================================
        # PIPELINE
        # =================================================
        frame, exercise, reps, *_ = (
            pipeline.process_frame(frame)
        )

        # =================================================
        # CURRENT STATE
        # =================================================
        state = pipeline.current_state

        # =================================================
        # HUD
        # =================================================
        frame = draw_hud(

            frame,

            exercise,

            reps,

            state
        )

        # =================================================
        # REP ACTIVITY TIMER
        # =================================================
        if reps > previous_reps:

            last_rep_time = time.time()

            previous_reps = reps

        # =================================================
        # SHOW DECISION MENU AFTER 10 SEC IDLE
        # =================================================
        idle_time = (
            time.time() - last_rep_time
        )

        if (

            reps > 0

            and idle_time >= 10

            and not pipeline.session.awaiting_decision

            and not pipeline.session.show_report
        ):

            pipeline.session.awaiting_decision = True

        # =================================================
        # DECISION BUTTONS
        # =================================================
        if pipeline.session.awaiting_decision:

            frame, yes_box, no_box, reset_box = (

                draw_decision_buttons(

                    frame,

                    clicked_point
                )
            )

            # =============================================
            # HANDLE MOUSE CLICK
            # =============================================
            if clicked_point is not None:

                x, y = clicked_point

                # =========================================
                # RESUME
                # =========================================
                if (

                    yes_box[0] <= x <= yes_box[2]

                    and

                    yes_box[1] <= y <= yes_box[3]
                ):

                    pipeline.session.awaiting_decision = False

                    last_rep_time = time.time()

                    clicked_point = None

                # =========================================
                # FINISH
                # =========================================
                elif (

                    no_box[0] <= x <= no_box[2]

                    and

                    no_box[1] <= y <= no_box[3]
                ):

                    report_data = (

                        pipeline.session.generate_report()
                    )

                    pipeline.session.awaiting_decision = False

                    pipeline.session.show_report = True

                    clicked_point = None

                # =========================================
                # RESTART
                # =========================================
                elif (

                    reset_box[0] <= x <= reset_box[2]

                    and

                    reset_box[1] <= y <= reset_box[3]
                ):

                    pipeline.session.restart_session(pipeline)

                    pipeline.session.awaiting_decision = False

                    pipeline.session.show_report = False

                    previous_reps = 0

                    reps = 0

                    last_rep_time = time.time()

                    clicked_point = None

                    report_data = {}

        # =================================================
        # REPORT
        # =================================================
        if pipeline.session.show_report:

            frame = draw_report_screen(

                frame,

                report_data
            )

        # =================================================
        # SHOW
        # =================================================
        cv2.imshow(
            WINDOW,
            frame
        )

        # =================================================
        # KEYS
        # =================================================
        key = cv2.waitKey(1) & 0xFF

        # ESC
        if key == 27:

            break

        # RESET
        if key == ord('r'):

            pipeline.session.restart_session(
                pipeline
            )

            pipeline.session.awaiting_decision = False

            pipeline.session.show_report = False

            previous_reps = 0

            reps = 0

            last_rep_time = time.time()

            clicked_point = None

            report_data = {}

        # FINISH SESSION
        if key == ord('f'):

            report_data = (

                pipeline.session.generate_report()
            )

            pipeline.session.show_report = True

    # =====================================================
    # ERROR HANDLER
    # =====================================================
    except Exception as e:

        print("\n❌ ERROR DETECTED\n")

        print(e)

        traceback.print_exc()

        cv2.waitKey(0)

        break

# =========================================================
# CLOSE
# =========================================================
cap.release()

cv2.destroyAllWindows()

pipeline.close()