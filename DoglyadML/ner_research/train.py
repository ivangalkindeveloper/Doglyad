from datasets import load_from_disk
from transformers import (
    AutoTokenizer,
    AutoModelForTokenClassification,
    DataCollatorForTokenClassification,
    Trainer,
    TrainingArguments
)
import numpy as np
import evaluate

MODEL_NAME = "xlm-roberta-base"

dataset = load_from_disk("./research_ner/dataset")

label_list = sorted(list(set(tag for tags in dataset["train"]["tag"] for tag in tags)))
label_to_id = {label: i for i, label in enumerate(label_list)}
id_to_label = {i: label for label, i in label_to_id.items()}

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

def tokenize_and_align_labels(example):
    tokenized = tokenizer(example["token"], truncation=True, is_split_into_words=True)
    labels = []
    for i, word_id in enumerate(tokenized.word_ids()):
        if word_id is None:
            labels.append(-100)
        else:
            labels.append(label_to_id[example["tag"][word_id]])
    tokenized["labels"] = labels
    return tokenized

tokenized_datasets = dataset.map(tokenize_and_align_labels)

model = AutoModelForTokenClassification.from_pretrained(
    MODEL_NAME,
    num_labels=len(label_list),
    id2label=id_to_label,
    label2id=label_to_id
)

data_collator = DataCollatorForTokenClassification(tokenizer)
metric = evaluate.load("seqeval")

def compute_metrics(p):
    predictions, labels = p
    predictions = np.argmax(predictions, axis=2)

    true_predictions = [
        [id_to_label[p] for p, l in zip(pred, lab) if l != -100]
        for pred, lab in zip(predictions, labels)
    ]

    true_labels = [
        [id_to_label[l] for p, l in zip(pred, lab) if l != -100]
        for pred, lab in zip(predictions, labels)
    ]

    return metric.compute(predictions=true_predictions, references=true_labels)

args = TrainingArguments(
    output_dir="./research_ner/model",
    eval_strategy="epoch",
    learning_rate=3e-5,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    num_train_epochs=4,
    weight_decay=0.01
)

trainer = Trainer(
    model=model,
    args=args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["validation"],
    tokenizer=tokenizer,
    data_collator=data_collator,
    compute_metrics=compute_metrics,
)

trainer.train()
trainer.save_model("./research_ner/model")
tokenizer.save_pretrained("./research_ner/model")
