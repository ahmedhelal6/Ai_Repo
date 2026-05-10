from src.dataset.builder import DatasetBuilder

MODEL_PATH = "pose_landmark_model/pose_landmarker.task"

VIDEOS_DIR = "data/raw_videos"

def main():

    builder = DatasetBuilder()

    X, y = builder.build_from_folder(

        data_dir=VIDEOS_DIR,

        model_path=MODEL_PATH,
    )

    print(f"\n✅ Finished!")
    print(f"Sequences: {len(X)}")
    print(f"Labels: {len(y)}")


if __name__ == "__main__":

    main()