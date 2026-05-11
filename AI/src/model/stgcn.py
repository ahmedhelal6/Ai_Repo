import torch
import torch.nn as nn
import torch.nn.functional as F

from src.pose.joints import SKELETON_EDGES


# =========================================================
# BUILD ADJACENCY MATRIX
# =========================================================

def build_adjacency_matrix(num_joints):

    A = torch.eye(num_joints)

    for i, j in SKELETON_EDGES:

        A[i, j] = 1.0
        A[j, i] = 1.0

    return A


# =========================================================
# GRAPH CONVOLUTION
# =========================================================

class GraphConvolution(nn.Module):

    def __init__(
        self,
        in_channels,
        out_channels,
    ):

        super().__init__()

        self.conv = nn.Conv2d(

            in_channels,
            out_channels,

            kernel_size=(1, 1)
        )

    def forward(self, x, A):

        # x:
        # (B, C, T, V)

        x = torch.einsum(
            "bctv,vw->bctw",
            x,
            A
        )

        x = self.conv(x)

        return x


# =========================================================
# ST-GCN BLOCK
# =========================================================

class STGCNBlock(nn.Module):

    def __init__(
        self,
        in_channels,
        out_channels,
    ):

        super().__init__()

        # ----------------------------------------
        # Spatial graph convolution
        # ----------------------------------------

        self.gcn = GraphConvolution(

            in_channels,
            out_channels
        )

        # ----------------------------------------
        # Temporal convolution
        # ----------------------------------------

        self.tcn = nn.Sequential(

            nn.BatchNorm2d(out_channels),

            nn.ReLU(),

            nn.Conv2d(

                out_channels,
                out_channels,

                kernel_size=(9, 1),

                padding=(4, 0)
            ),

            nn.BatchNorm2d(out_channels),

            nn.Dropout(0.3)
        )

        # ----------------------------------------
        # Residual
        # ----------------------------------------

        if in_channels == out_channels:

            self.residual = nn.Identity()

        else:

            self.residual = nn.Conv2d(

                in_channels,
                out_channels,

                kernel_size=1
            )

        self.relu = nn.ReLU()

    def forward(self, x, A):

        res = self.residual(x)

        x = self.gcn(x, A)

        x = self.tcn(x)

        x = x + res

        return self.relu(x)


# =========================================================
# REAL ST-GCN
# =========================================================

class SimpleSTGCN(nn.Module):

    def __init__(
        self,
        num_joints,
        num_classes,
        in_channels=4,
    ):

        super().__init__()

        self.A = build_adjacency_matrix(
            num_joints
        )

        # ----------------------------------------
        # ST-GCN layers
        # ----------------------------------------

        self.layer1 = STGCNBlock(
            in_channels,
            64
        )

        self.layer2 = STGCNBlock(
            64,
            128
        )

        self.layer3 = STGCNBlock(
            128,
            256
        )

        # ----------------------------------------
        # Classification
        # ----------------------------------------

        self.pool = nn.AdaptiveAvgPool2d(
            (1, 1)
        )

        self.fc = nn.Linear(
            256,
            num_classes
        )

    def forward(self, x):

        # x:
        # (B, C, T, V)

        A = self.A.to(x.device)

        x = self.layer1(x, A)

        x = self.layer2(x, A)

        x = self.layer3(x, A)

        # ----------------------------------------
        # Global pooling
        # ----------------------------------------

        x = self.pool(x)

        x = x.view(
            x.size(0),
            -1
        )

        return self.fc(x)