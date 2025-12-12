import pandas as pd
from datasets import Dataset, DatasetDict

def load_ner_dataset(csv_path):
    df = pd.read_csv(csv_path)
    
    sentences = []
    current_sentence = []
    current_tags = []
    
    for _, row in df.iterrows():
        if pd.isna(row["token"]) or row["token"] == "":
            if current_sentence:
                sentences.append({
                    "token": current_sentence,
                    "tag": current_tags
                })
                current_sentence = []
                current_tags = []
        else:
            current_sentence.append(str(row["token"]))
            current_tags.append(str(row["tag"]))
    
    if current_sentence:
        sentences.append({
            "token": current_sentence,
            "tag": current_tags
        })
    
    return sentences

train_data = load_ner_dataset("DoglyadML/ner_research/dataset/train.csv")
validation_data = load_ner_dataset("DoglyadML/ner_research/dataset/validation.csv")

dataset = DatasetDict({
    "train": Dataset.from_list(train_data),
    "validation": Dataset.from_list(validation_data),
})

dataset.save_to_disk("DoglyadML/ner_research/dataset")
print("Dataset saved to DoglyadML/ner_research/dataset/")
