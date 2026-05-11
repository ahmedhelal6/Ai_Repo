import os
import sys
import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np

from torch.utils.data import (
    DataLoader,
    Dataset,
    WeightedRandomSampler
)

from collections import Counter
from sklearn.model_selection import train_test_split

sys.path.append(
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            ".."
        )
    )
)

from src.model.stgcn import SimpleSTGCN
from src.pose.joints import EXERCISE_CLASSES

# =========================================================
# CONFIG
# =========================================================

DATA_DIR = "data/keypoints"
BATCH_SIZE   = 32
EPOCHS       = 35
LR           = 1e-3

SEQ_LEN      = 35

# 33 mediapipe joints
# + 6 angle joints
NUM_JOINTS   = 39

# x,y,z,visibility
NUM_CHANNELS = 4

device = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

print(f"✅ Using device: {device}")

# =========================================================
# BUILD INPUT
# (B, T, V, C) → (B, C, T, V)
# =========================================================

def build_input(batch_X):

    return batch_X.permute(
        0,
        3,
        1,
        2
    ).contiguous()

# =========================================================
# SIMPLE AUGMENTATION
# =========================================================

def augment_sequence(sequence):

    seq = sequence.copy()

    use_noise = np.random.rand() < 0.4
    use_shift = np.random.rand() < 0.3
    use_scale = np.random.rand() < 0.2

    noise_std = 0.003

    shift_x = np.random.uniform(
        -0.015,
        0.015
    )

    shift_y = np.random.uniform(
        -0.015,
        0.015
    )

    scale = np.random.uniform(
        0.97,
        1.03
    )

    for t in range(len(seq)):

        frame = seq[t]

        # x
        if use_shift:
            frame[:, 0] += shift_x

        # y
        if use_shift:
            frame[:, 1] += shift_y

        # noise
        if use_noise:
            frame += np.random.normal(
                0,
                noise_std,
                frame.shape
            )

        # scale
        if use_scale:
            frame *= scale

        seq[t] = frame

    return seq.astype(np.float32)

# =========================================================
# CUSTOM DATASET
# =========================================================

class ExerciseDataset(Dataset):

    def __init__(
        self,
        X,
        y,
        train=False
    ):

        self.X = X
        self.y = y
        self.train = train

    def __len__(self):

        return len(self.X)

    def __getitem__(self, idx):

        sample = self.X[idx].copy()

        label = self.y[idx]

        if self.train:

            if np.random.rand() < 0.7:

                sample = augment_sequence(
                    sample
                )

        sample = torch.tensor(
            sample,
            dtype=torch.float32
        )

        label = torch.tensor(
            label,
            dtype=torch.long
        )

        return sample, label

# =========================================================
# LOAD DATASET
# =========================================================

def load_dataset():

    X, y = [], []

    classes = EXERCISE_CLASSES

    class_to_idx = {

        cls: i

        for i, cls in enumerate(classes)
    }

    for cls in classes:

        cls_path = os.path.join(
            DATA_DIR,
            cls
        )

        if not os.path.exists(cls_path):

            print(
                f"⚠️ Missing folder: "
                f"{cls_path}"
            )

            continue

        files = [

            f for f in os.listdir(cls_path)

            if f.endswith(".npy")
        ]

        print(
            f"Loading '{cls}': "
            f"{len(files)} files"
        )

        for f in files:

            data = np.load(
                os.path.join(
                    cls_path,
                    f
                )
            )

            # =============================================
            # EXPECTED SHAPE:
            # (T, V, C)
            # =============================================

            if data.ndim != 3:

                print(
                    f"❌ Invalid shape: "
                    f"{data.shape}"
                )

                continue

            # =============================================
            # TEMPORAL CROP
            # =============================================

            if len(data) > SEQ_LEN:

                start = np.random.randint(
                    0,
                    len(data) - SEQ_LEN + 1
                )

                sample = data[
                    start:start + SEQ_LEN
                ]

            else:

                pad_len = (
                    SEQ_LEN - len(data)
                )

                last_frame = data[-1:]

                pad = np.repeat(
                    last_frame,
                    pad_len,
                    axis=0
                )

                sample = np.concatenate(
                    [data, pad],
                    axis=0
                )

            X.append(sample)

            y.append(
                class_to_idx[cls]
            )

    X = np.array(
        X,
        dtype=np.float32
    )

    y = np.array(
        y,
        dtype=np.int64
    )

    print(
        f"\n✅ Dataset shape: "
        f"{X.shape}"
    )

    # =============================================
    # SANITY CHECK
    # =============================================

    assert X.shape[2] == NUM_JOINTS, (

        f"Expected {NUM_JOINTS} joints, "
        f"got {X.shape[2]}"
    )

    assert X.shape[3] == NUM_CHANNELS, (

        f"Expected {NUM_CHANNELS} channels, "
        f"got {X.shape[3]}"
    )

    return X, y

# =========================================================
# BALANCED SAMPLER
# =========================================================

def make_balanced_sampler(y_train):

    counts = Counter(
        y_train.tolist()
    )

    weights = [

        1.0 / counts[label]

        for label in y_train.tolist()
    ]

    return WeightedRandomSampler(

        weights,

        num_samples=len(weights),

        replacement=True
    )

# =========================================================
# TRAIN
# =========================================================

def train():

    print("\n📂 Loading dataset...")

    X, y = load_dataset()

    if len(X) == 0:

        print("❌ No data found!")

        return

    # =============================================
    # SPLIT
    # =============================================

    X_train, X_val, y_train, y_val = train_test_split(

        X,
        y,

        test_size=0.2,

        stratify=y,

        random_state=42
    )

    # =============================================
    # DATASETS
    # =============================================

    train_dataset = ExerciseDataset(

        X_train,
        y_train,

        train=True
    )

    val_dataset = ExerciseDataset(

        X_val,
        y_val,

        train=False
    )

    # =============================================
    # DATALOADERS
    # =============================================

    sampler = make_balanced_sampler(
        y_train
    )

    train_loader = DataLoader(

        train_dataset,

        batch_size=BATCH_SIZE,

        sampler=sampler
    )

    val_loader = DataLoader(

        val_dataset,

        batch_size=BATCH_SIZE,

        shuffle=False
    )

    # =============================================
    # MODEL
    # =============================================

    model = SimpleSTGCN(

        num_joints=NUM_JOINTS,

        num_classes=len(
            EXERCISE_CLASSES
        ),

        in_channels=NUM_CHANNELS

    ).to(device)

    total_params = sum(

        p.numel()

        for p in model.parameters()

        if p.requires_grad
    )

    print(
        f"🧠 Model params: "
        f"{total_params:,}"
    )

    # =============================================
    # LOSS
    # =============================================

    criterion = nn.CrossEntropyLoss(
        label_smoothing=0.1
    )

    optimizer = optim.Adam(

        model.parameters(),

        lr=LR,

        weight_decay=1e-4
    )

    scheduler = optim.lr_scheduler.CosineAnnealingLR(

        optimizer,

        T_max=EPOCHS
    )

    best_acc = 0.0

    patience = 15

    patience_ctr = 0

    print("\n🚀 Starting Training...\n")

    # =============================================
    # TRAIN LOOP
    # =============================================

    for epoch in range(EPOCHS):

        model.train()

        train_loss = 0.0

        for batch_X, batch_y in train_loader:

            batch_X = batch_X.to(device)

            batch_y = batch_y.to(device)

            inp = build_input(batch_X)

            optimizer.zero_grad()

            out = model(inp)

            loss = criterion(
                out,
                batch_y
            )

            loss.backward()

            nn.utils.clip_grad_norm_(
                model.parameters(),
                max_norm=5.0
            )

            optimizer.step()

            train_loss += loss.item()

        scheduler.step()

        # =========================================
        # VALIDATION
        # =========================================

        model.eval()

        correct = 0
        total   = 0

        with torch.no_grad():

            for batch_X, batch_y in val_loader:

                batch_X = batch_X.to(device)

                batch_y = batch_y.to(device)

                inp = build_input(batch_X)

                out = model(inp)

                _, pred = torch.max(
                    out,
                    1
                )

                correct += (
                    pred == batch_y
                ).sum().item()

                total += batch_y.size(0)

        val_acc = correct / total

        lr_now = optimizer.param_groups[0]["lr"]

        print(
            f"Epoch {epoch+1:3}/{EPOCHS} | "
            f"Loss: {train_loss/len(train_loader):.4f} | "
            f"Val Acc: {val_acc:.4f} | "
            f"LR: {lr_now:.6f}"
        )

        # =========================================
        # SAVE BEST
        # =========================================

        if val_acc > best_acc:

            best_acc = val_acc

            patience_ctr = 0

            torch.save(

                {
                    "epoch": epoch + 1,

                    "model_state":
                        model.state_dict(),

                    "val_acc":
                        best_acc,

                    "num_channels":
                        NUM_CHANNELS,

                    "num_joints":
                        NUM_JOINTS,
                },

                "best_model.pth"
            )

            print("💾 Saved best model!")

        else:

            patience_ctr += 1

            if patience_ctr >= patience:

                print(
                    f"\n⏹️ Early stopping "
                    f"at epoch {epoch+1}"
                )

                break

    print(
        f"\n✅ Training Complete! "
        f"Best Val Acc: {best_acc:.4f}"
    )

# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":

    train()