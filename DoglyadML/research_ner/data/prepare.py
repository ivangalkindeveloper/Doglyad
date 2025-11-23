import pandas as pd
from datasets import Dataset, DatasetDict

train = pd.read_csv("data/train.csv")
valid = pd.read_csv("data/validation.csv")

dataset = DatasetDict({
    "train": Dataset.from_pandas(train),
    "validation": Dataset.from_pandas(valid),
})

dataset.save_to_disk("ner_dataset")
print("Dataset saved to ner_dataset/")