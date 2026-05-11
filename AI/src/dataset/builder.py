from pathlib import Path
from typing import List, Tuple

import numpy as np

from src.pose.extractor import PoseExtractor
from src.dataset.labels import get_label_from_name


class DatasetBuilder:
    def build_from_folder(
        self,
        data_dir: str,
        model_path: str,
    ) -> Tuple[List[np.ndarray], List[int]]:
        data_path = Path(data_dir)

        if not data_path.exists():
            raise FileNotFoundError(f"Data directory not found: {data_dir}")

        X = []
        y = []

        for exercise_folder in data_path.iterdir():
            if not exercise_folder.is_dir():
                continue

            exercise_name = exercise_folder.name

            try:
                label = get_label_from_name(exercise_name)
            except ValueError:
                print(f"Skipping unknown folder: {exercise_name}")
                continue

            output_dir = Path("data/keypoints") / exercise_name
            output_dir.mkdir(parents=True, exist_ok=True)

            for video_file in exercise_folder.glob("*.mp4"):
                extractor = None
                try:
                    extractor = PoseExtractor(model_path)

                    _, normalized_seq, _ = extractor.extract_from_video(str(video_file))

                    if len(normalized_seq) == 0:
                        print(f"Empty sequence: {video_file}")
                        continue

                    save_path = output_dir / f"{video_file.stem}.npy"
                    np.save(save_path, normalized_seq)

                    X.append(normalized_seq)
                    y.append(label)

                    print(f"Saved: {save_path}")

                except Exception as e:
                    print(f"Error processing {video_file}: {e}")

                finally:
                    if extractor is not None:
                        extractor.close()

        return X, y