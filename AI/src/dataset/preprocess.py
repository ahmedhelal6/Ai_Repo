from typing import List, Tuple

import numpy as np
import torch


def pad_or_truncate_sequence(
    sequence: np.ndarray,
    target_length: int
) -> np.ndarray:
    """
    Make every sequence same length.

    Input:
        (T, V, C)

    Output:
        (target_length, V, C)
    """

    if sequence.ndim != 3:
        raise ValueError(
            f"Expected shape (T, V, C), got {sequence.shape}"
        )

    current_length = sequence.shape[0]

    if current_length == target_length:
        return sequence

    if current_length > target_length:
        return sequence[:target_length]

    pad_count = target_length - current_length

    last_frame = sequence[-1:]

    padding = np.repeat(
        last_frame,
        pad_count,
        axis=0
    )

    return np.concatenate(
        [sequence, padding],
        axis=0
    )


def sequence_to_model_input(
    sequence: np.ndarray
) -> np.ndarray:
    """
    Convert:

        (T, V, C)

    To:

        (C, T, V)

    Returns:
        ST-GCN input
    """

    if sequence.ndim != 3:
        raise ValueError(
            f"Expected shape (T, V, C), got {sequence.shape}"
        )

    return np.transpose(
        sequence,
        (2, 0, 1)
    ).astype(np.float32)


def prepare_dataset(
    X: List[np.ndarray],
    y: List[int],
    target_length: int,
) -> Tuple[torch.Tensor, torch.Tensor]:

    if len(X) == 0:
        raise ValueError("X is empty")

    if len(X) != len(y):
        raise ValueError(
            "X and y must have same length"
        )

    processed_sequences = []

    for sequence in X:

        fixed_sequence = pad_or_truncate_sequence(
            sequence,
            target_length
        )

        model_input = sequence_to_model_input(
            fixed_sequence
        )

        processed_sequences.append(
            model_input
        )

    X_array = np.stack(
        processed_sequences,
        axis=0
    )

    y_array = np.array(
        y,
        dtype=np.int64
    )

    X_tensor = torch.tensor(
        X_array,
        dtype=torch.float32
    )

    y_tensor = torch.tensor(
        y_array,
        dtype=torch.long
    )

    return X_tensor, y_tensor