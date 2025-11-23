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

MODEL_NAME = "alexyalunin/RuBioRoBERTa"

dataset = load_from_disk("./DoglyadML/ner_research/dataset")

label_list = sorted(list(set(tag for tags in dataset["train"]["tag"] for tag in tags)))
# Добавляем все возможные I- метки, если их нет
for label in label_list[:]:
    if label.startswith("B-"):
        i_label = label.replace("B-", "I-")
        if i_label not in label_list:
            label_list.append(i_label)

label_list = sorted(label_list)
label_to_id = {label: i for i, label in enumerate(label_list)}
id_to_label = {i: label for label, i in label_to_id.items()}

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, add_prefix_space=True)

def tokenize_and_align_labels(example):
    tokenized = tokenizer(example["token"], truncation=True, max_length=512, is_split_into_words=True)
    labels = []
    previous_word_idx = None
    for i, word_id in enumerate(tokenized.word_ids()):
        if word_id is None:
            # Специальные токены (CLS, SEP, PAD) - игнорируем
            labels.append(-100)
        elif word_id != previous_word_idx:
            # Первый подтокен слова - используем оригинальную метку
            labels.append(label_to_id[example["tag"][word_id]])
        else:
            # Последующие подтокены того же слова
            label = example["tag"][word_id]
            if label.startswith("B-"):
                # Если B- метка, то для подтокенов делаем I-
                i_label = label.replace("B-", "I-")
                labels.append(label_to_id.get(i_label, label_to_id[label]))
            elif label.startswith("I-") or label == "O":
                # Если уже I- или O, оставляем как есть
                labels.append(label_to_id[label])
            else:
                # Fallback - используем оригинальную метку
                labels.append(label_to_id[label])
        previous_word_idx = word_id
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
    output_dir="./DoglyadML/ner_research/model",
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
trainer.save_model("./DoglyadML/ner_research/model")
tokenizer.save_pretrained("./DoglyadML/ner_research/model")
