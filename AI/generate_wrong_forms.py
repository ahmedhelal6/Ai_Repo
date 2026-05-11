import numpy as np

# ======================
# LOAD CORRECT SEQUENCES
# ======================

X = np.load("X_sequences.npy")

print("Original Shape:", X.shape)

# ======================
# COPY DATA
# ======================

X_wrong = X.copy()

# ======================
# GENERATE WRONG FORMS
# ======================

for i in range(len(X_wrong)):

    # Random error type
    error_type = np.random.choice([
        "angle",
        "speed",
        "stability"
    ])

    # ======================
    # ANGLE ERROR
    # ======================

    if error_type == "angle":

        # knee angle
        X_wrong[i, :, 2] += np.random.uniform(
            20,
            50
        )

    # ======================
    # SPEED ERROR
    # ======================

    elif error_type == "speed":

        # duplicate frames
        X_wrong[i] = X_wrong[i][::2]

        # pad
        while len(X_wrong[i]) < 30:

            X_wrong[i] = np.vstack([
                X_wrong[i],
                X_wrong[i][-1]
            ])

    # ======================
    # STABILITY ERROR
    # ======================

    elif error_type == "stability":

        noise = np.random.normal(
            0,
            10,
            X_wrong[i].shape
        )

        X_wrong[i] += noise

# ======================
# LABELS
# ======================

y_correct = np.zeros(len(X))

y_wrong = np.ones(len(X_wrong))

# ======================
# COMBINE
# ======================

X_final = np.concatenate([
    X,
    X_wrong
])

y_final = np.concatenate([
    y_correct,
    y_wrong
])

# ======================
# SHUFFLE
# ======================

indices = np.arange(len(X_final))

np.random.shuffle(indices)

X_final = X_final[indices]
y_final = y_final[indices]

# ======================
# SAVE
# ======================

np.save("X_final.npy", X_final)
np.save("y_final.npy", y_final)

print("\nFINAL DATASET READY!")

print("X:", X_final.shape)
print("y:", y_final.shape)