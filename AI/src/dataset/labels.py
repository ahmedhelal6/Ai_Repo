from src.pose.joints import CLASS_TO_IDX, IDX_TO_CLASS


def get_label_from_name(exercise_name: str) -> int:
    """
    Convert exercise name to label index.

    Args:
        exercise_name: Name of the exercise (e.g., 'squat')

    Returns:
        Integer label corresponding to the exercise
    """
    if exercise_name not in CLASS_TO_IDX:
        raise ValueError(f"Unknown exercise: {exercise_name}")

    return CLASS_TO_IDX[exercise_name]


def get_name_from_label(label: int) -> str:
    """
    Convert label index back to exercise name.

    Args:
        label: Integer label

    Returns:
        Exercise name
    """
    if label not in IDX_TO_CLASS:
        raise ValueError(f"Unknown label: {label}")

    return IDX_TO_CLASS[label]


def is_valid_exercise(exercise_name: str) -> bool:
    """
    Check if exercise name is valid.

    Args:
        exercise_name: Name of the exercise

    Returns:
        True if valid, False otherwise
    """
    return exercise_name in CLASS_TO_IDX