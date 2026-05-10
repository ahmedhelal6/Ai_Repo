import torch
import torch.nn as nn

class FormModel(nn.Module):
    def __init__(self, input_size=2, hidden_size=64, num_layers=2, num_classes=2):
        super(FormModel, self).__init__()

        self.hidden_size = hidden_size
        self.num_layers = num_layers

        # 🔥 LSTM أقوى + dropout
        self.lstm = nn.LSTM(
            input_size,
            hidden_size,
            num_layers,
            batch_first=True,
            dropout=0.3
        )

        # 🔥 Fully Connected Layers
        self.fc = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(32, num_classes)
        )

    def forward(self, x):
        batch_size = x.size(0)

        h0 = torch.zeros(self.num_layers, batch_size, self.hidden_size).to(x.device)
        c0 = torch.zeros(self.num_layers, batch_size, self.hidden_size).to(x.device)

        out, _ = self.lstm(x, (h0, c0))

        # 🔥 ناخد آخر timestep
        out = out[:, -1, :]

        out = self.fc(out)

        return out