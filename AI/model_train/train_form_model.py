import os
import glob
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import TensorDataset, DataLoader

# Update the path to import FormModel correctly if needed
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from src.model.form_model import FormModel

def pad_sequence(seq, max_len=30):
    if len(seq) == 0:
        return None
    
    # seq is a list of [elbow, back]. Convert it to list if it's numpy array
    seq_list = seq.tolist() if isinstance(seq, np.ndarray) else list(seq)
    
    while len(seq_list) < max_len:
        seq_list.insert(0, seq_list[0])
        
    return np.array(seq_list[:max_len], dtype=np.float32)

def main():
    data_dir = os.path.join(os.path.dirname(__file__), '..', 'data', 'pushup')
    
    if not os.path.exists(data_dir):
        print(f"Data directory not found: {data_dir}")
        return

    file_paths = glob.glob(os.path.join(data_dir, "*.npy"))
    if not file_paths:
        print("No .npy files found.")
        return

    sequences = []
    labels = []
    
    count_good = 0
    count_bad = 0

    for file_path in file_paths:
        filename = os.path.basename(file_path)
        if filename.startswith("good"):
            label = 0
            count_good += 1
        elif filename.startswith("bad"):
            label = 1
            count_bad += 1
        else:
            continue

        seq = np.load(file_path)
        
        # Ensure padding to max_len=30
        padded_seq = pad_sequence(seq, max_len=30)
        
        if padded_seq is not None:
            sequences.append(padded_seq)
            labels.append(label)

    print("--- Data Distribution ---")
    print(f"Good: {count_good}")
    print(f"Bad: {count_bad}")
    print("-------------------------")

    if not sequences:
        print("No valid sequences to train on.")
        return

    X = torch.tensor(np.array(sequences), dtype=torch.float32)
    y = torch.tensor(np.array(labels), dtype=torch.long)

    dataset = TensorDataset(X, y)
    dataloader = DataLoader(dataset, batch_size=16, shuffle=True)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = FormModel(input_size=2, hidden_size=64, num_classes=2).to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    num_epochs = 10
    
    print("Starting training...")
    for epoch in range(num_epochs):
        model.train()
        total_loss = 0
        correct = 0
        total = 0
        
        for batch_X, batch_y in dataloader:
            batch_X, batch_y = batch_X.to(device), batch_y.to(device)
            
            optimizer.zero_grad()
            outputs = model(batch_X)
            
            loss = criterion(outputs, batch_y)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
            
            _, predicted = torch.max(outputs.data, 1)
            total += batch_y.size(0)
            correct += (predicted == batch_y).sum().item()
            
        print(f"Epoch [{epoch+1}/{num_epochs}], Loss: {total_loss/len(dataloader):.4f}, Accuracy: {100 * correct / total:.2f}%")

    model_save_path = os.path.join(os.path.dirname(__file__), '..', 'form_model.pth')
    torch.save(model.state_dict(), model_save_path)
    print(f"Model saved to {model_save_path}")

if __name__ == "__main__":
    main()
