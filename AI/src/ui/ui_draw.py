import cv2
import numpy as np


def draw_text_with_shadow(
    img,
    text,
    pos,
    font,
    scale,
    color,
    thickness=1,
    shadow_color=(0, 0, 0),
    shadow_offset=(2, 2)
):

    x, y = pos

    cv2.putText(
        img,
        text,
        (x + shadow_offset[0], y + shadow_offset[1]),
        font,
        scale,
        shadow_color,
        thickness + 2
    )

    cv2.putText(
        img,
        text,
        pos,
        font,
        scale,
        color,
        thickness
    )


def draw_rounded_rect(
    img,
    pt1,
    pt2,
    color,
    thickness,
    r,
    alpha=1.0
):

    x1, y1 = pt1
    x2, y2 = pt2

    if alpha < 1.0:

        overlay = img.copy()

        target = overlay

    else:

        target = img

    # Corners
    cv2.circle(
        target,
        (x1 + r, y1 + r),
        r,
        color,
        thickness
    )

    cv2.circle(
        target,
        (x2 - r, y1 + r),
        r,
        color,
        thickness
    )

    cv2.circle(
        target,
        (x1 + r, y2 - r),
        r,
        color,
        thickness
    )

    cv2.circle(
        target,
        (x2 - r, y2 - r),
        r,
        color,
        thickness
    )

    # Cross Rectangles
    if thickness < 0:

        cv2.rectangle(
            target,
            (x1 + r, y1),
            (x2 - r, y2),
            color,
            thickness
        )

        cv2.rectangle(
            target,
            (x1, y1 + r),
            (x2, y2 - r),
            color,
            thickness
        )

    else:

        cv2.line(
            target,
            (x1 + r, y1),
            (x2 - r, y1),
            color,
            thickness
        )

        cv2.line(
            target,
            (x1 + r, y2),
            (x2 - r, y2),
            color,
            thickness
        )

        cv2.line(
            target,
            (x1, y1 + r),
            (x1, y2 - r),
            color,
            thickness
        )

        cv2.line(
            target,
            (x2, y1 + r),
            (x2, y2 - r),
            color,
            thickness
        )

    if alpha < 1.0:

        cv2.addWeighted(
            overlay,
            alpha,
            img,
            1 - alpha,
            0,
            img
        )


def draw_hud(frame, exercise, reps, state):

    h, w, _ = frame.shape

    # =====================================================
    # COLORS
    # =====================================================
    BG_COLOR = (5, 5, 5)

    ACCENT_RED = (0, 0, 255)

    DEEP_RED = (0, 0, 140)

    TEXT_LIGHT = (250, 250, 250)

    TEXT_DIM = (100, 100, 110)

    # =====================================================
    # EXERCISE NAME
    # =====================================================
    ex_name = (

        exercise.replace("_", " ").upper()

        if exercise

        else "AWAITING EXERCISE..."
    )

    pill_color = (

        ACCENT_RED

        if exercise

        else TEXT_DIM
    )

    text_size = cv2.getTextSize(

        ex_name,

        cv2.FONT_HERSHEY_DUPLEX,

        0.7,

        2
    )[0]

    pill_w = text_size[0] + 80

    pill_x1 = (w - pill_w) // 2

    # Pill BG
    draw_rounded_rect(

        frame,

        (pill_x1, 25),

        (pill_x1 + pill_w, 75),

        BG_COLOR,

        -1,

        r=25,

        alpha=0.9
    )

    # Pill Border
    draw_rounded_rect(

        frame,

        (pill_x1, 25),

        (pill_x1 + pill_w, 75),

        pill_color,

        2,

        r=25,

        alpha=1.0
    )

    # Live Dot
    dot_color = (

        ACCENT_RED

        if exercise

        else TEXT_DIM
    )

    cv2.circle(
        frame,
        (pill_x1 + 30, 50),
        6,
        dot_color,
        -1
    )

    draw_text_with_shadow(

        frame,

        ex_name,

        (pill_x1 + 50, 56),

        cv2.FONT_HERSHEY_DUPLEX,

        0.7,

        TEXT_LIGHT,

        2
    )

    # =====================================================
    # LEFT PANEL
    # =====================================================
    panel_x1, panel_y1 = 25, 100

    panel_x2, panel_y2 = 280, 420

    # Panel Body
    draw_rounded_rect(

        frame,

        (panel_x1, panel_y1),

        (panel_x2, panel_y2),

        BG_COLOR,

        -1,

        r=15,

        alpha=0.9
    )

    # Red Line
    cv2.line(

        frame,

        (panel_x1 + 8, panel_y1 + 20),

        (panel_x1 + 8, panel_y2 - 20),

        ACCENT_RED,

        4
    )

    # =====================================================
    # REPS
    # =====================================================
    draw_text_with_shadow(

        frame,

        "TOTAL REPS",

        (panel_x1 + 30, panel_y1 + 35),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.55,

        TEXT_DIM,

        1
    )

    draw_text_with_shadow(

        frame,

        f"{reps:02d}",

        (panel_x1 + 30, panel_y1 + 105),

        cv2.FONT_HERSHEY_DUPLEX,

        2.5,

        TEXT_LIGHT,

        4
    )

    # Divider
    cv2.line(

        frame,

        (panel_x1 + 30, panel_y1 + 130),

        (panel_x2 - 20, panel_y1 + 130),

        (60, 60, 70),

        1
    )

    # =====================================================
    # MOVEMENT STAGE
    # =====================================================
    stage = state.get(
        "stage",
        None
    )

    draw_text_with_shadow(

        frame,

        "MOVEMENT",

        (panel_x1 + 30, panel_y1 + 165),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.55,

        TEXT_DIM,

        1
    )

    if stage == "up":

        stage_text = "UP"

        stage_color = (0, 0, 255)

    elif stage == "down":

        stage_text = "DOWN"

        stage_color = (80, 80, 255)

    else:

        stage_text = "--"

        stage_color = TEXT_DIM

    draw_text_with_shadow(

        frame,

        stage_text,

        (panel_x1 + 30, panel_y1 + 210),

        cv2.FONT_HERSHEY_DUPLEX,

        1.2,

        stage_color,

        2
    )

    # Divider
    cv2.line(

        frame,

        (panel_x1 + 30, panel_y1 + 240),

        (panel_x2 - 20, panel_y1 + 240),

        (60, 60, 70),

        1
    )

    # =====================================================
    # FEEDBACK
    # =====================================================
    draw_text_with_shadow(

        frame,

        "FEEDBACK",

        (panel_x1 + 30, panel_y1 + 275),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.55,

        TEXT_DIM,

        1
    )

    feedbacks = state.get("feedback", [])

    if len(feedbacks) == 0:

        feedback_text = "--"

        feedback_color = TEXT_DIM

    else:

        feedback_text = feedbacks[0]

        feedback_color = (0, 165, 255)

    draw_text_with_shadow(

        frame,

        feedback_text,

        (panel_x1 + 30, panel_y1 + 305),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.5,

        feedback_color,

        1
    )

    return frame


def draw_decision_buttons(frame, clicked_point=None):

    h, w, _ = frame.shape

    overlay = frame.copy()

    cv2.rectangle(
        overlay,
        (0, 0),
        (w, h),
        (10, 15, 20),
        -1
    )

    cv2.addWeighted(
        overlay,
        0.8,
        frame,
        0.2,
        0,
        frame
    )

    modal_w, modal_h = 560, 240

    mx1, my1 = (

        (w - modal_w) // 2,

        (h - modal_h) // 2
    )

    mx2, my2 = mx1 + modal_w, my1 + modal_h

    # Modal Body
    draw_rounded_rect(

        frame,

        (mx1, my1),

        (mx2, my2),

        (5, 5, 5),

        -1,

        r=20,

        alpha=0.98
    )

    draw_rounded_rect(

        frame,

        (mx1, my1),

        (mx2, my2),

        (0, 0, 200),

        2,

        r=20,

        alpha=1.0
    )

    draw_text_with_shadow(

        frame,

        "SESSION PAUSED",

        (mx1 + 160, my1 + 55),

        cv2.FONT_HERSHEY_DUPLEX,

        0.9,

        (255, 255, 255),

        2
    )

    draw_text_with_shadow(

        frame,

        "Select an action to continue",

        (mx1 + 175, my1 + 90),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.55,

        (180, 180, 190),

        1
    )

    bw, bh = 140, 50

    by = my2 - 80

    yes_box = (

        mx1 + 40,

        by,

        mx1 + 40 + bw,

        by + bh
    )

    reset_box = (

        mx1 + 210,

        by,

        mx1 + 210 + bw,

        by + bh
    )

    no_box = (

        mx1 + 380,

        by,

        mx1 + 380 + bw,

        by + bh
    )

    # Resume
    draw_rounded_rect(

        frame,

        (yes_box[0], yes_box[1]),

        (yes_box[2], yes_box[3]),

        (0, 0, 150),

        -1,

        r=12
    )

    draw_rounded_rect(

        frame,

        (yes_box[0], yes_box[1]),

        (yes_box[2], yes_box[3]),

        (0, 0, 255),

        2,

        r=12
    )

    draw_text_with_shadow(

        frame,

        "RESUME",

        (yes_box[0] + 30, yes_box[1] + 32),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.7,

        (255, 255, 255),

        2
    )

    # Restart
    draw_rounded_rect(

        frame,

        (reset_box[0], reset_box[1]),

        (reset_box[2], reset_box[3]),

        (0, 0, 80),

        -1,

        r=12
    )

    draw_text_with_shadow(

        frame,

        "RESTART",

        (reset_box[0] + 25, reset_box[1] + 32),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.7,

        (255, 255, 255),

        2
    )

    # Finish
    draw_rounded_rect(

        frame,

        (no_box[0], no_box[1]),

        (no_box[2], no_box[3]),

        (0, 0, 0),

        -1,

        r=12
    )

    draw_rounded_rect(

        frame,

        (no_box[0], no_box[1]),

        (no_box[2], no_box[3]),

        (0, 0, 180),

        2,

        r=12
    )

    draw_text_with_shadow(

        frame,

        "FINISH",

        (no_box[0] + 40, no_box[1] + 32),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.7,

        (255, 255, 255),

        2
    )

    return frame, yes_box, no_box, reset_box


def draw_report(frame, reps, state):

    h, w, _ = frame.shape

    overlay = frame.copy()

    cv2.rectangle(
        overlay,
        (0, 0),
        (w, h),
        (10, 15, 20),
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

    modal_w, modal_h = 480, 280

    mx1, my1 = (

        (w - modal_w) // 2,

        (h - modal_h) // 2
    )

    mx2, my2 = mx1 + modal_w, my1 + modal_h

    # Modal Body
    draw_rounded_rect(

        frame,

        (mx1, my1),

        (mx2, my2),

        (5, 5, 5),

        -1,

        r=25,

        alpha=0.98
    )

    draw_rounded_rect(

        frame,

        (mx1, my1),

        (mx2, my2),

        (0, 0, 255),

        2,

        r=25,

        alpha=1.0
    )

    draw_text_with_shadow(

        frame,

        "WORKOUT COMPLETE",

        (mx1 + 60, my1 + 65),

        cv2.FONT_HERSHEY_DUPLEX,

        1.0,

        (0, 0, 255),

        2
    )

    # Divider
    cv2.line(

        frame,

        (mx1 + 40, my1 + 95),

        (mx2 - 40, my1 + 95),

        (80, 90, 110),

        1
    )

    # Stats
    draw_text_with_shadow(

        frame,

        "TOTAL REPS",

        (mx1 + 60, my1 + 160),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.8,

        (180, 180, 190),

        2
    )

    draw_text_with_shadow(

        frame,

        f"{reps:02d}",

        (mx1 + 340, my1 + 165),

        cv2.FONT_HERSHEY_DUPLEX,

        1.8,

        (255, 255, 255),

        3
    )

    # Footer
    draw_rounded_rect(

        frame,

        (mx1 + 90, my2 - 60),

        (mx2 - 90, my2 - 25),

        (20, 20, 20),

        -1,

        r=15
    )

    draw_text_with_shadow(

        frame,

        "Press 'R' to Start New Session",

        (mx1 + 115, my2 - 38),

        cv2.FONT_HERSHEY_SIMPLEX,

        0.55,

        (80, 80, 255),

        1
    )

    return frame