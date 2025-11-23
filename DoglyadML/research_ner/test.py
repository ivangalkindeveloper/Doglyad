from transformers import AutoTokenizer, AutoModelForTokenClassification
import torch

model = AutoModelForTokenClassification.from_pretrained("./ner_model")
tokenizer = AutoTokenizer.from_pretrained("./ner_model")

text = "Пациент мужчина, дата рождения 12 мая 1982, рост 180, вес 90, жалуется на боль в груди."

tokens = text.split()
inputs = tokenizer(tokens, is_split_into_words=True, return_tensors="pt")

with torch.no_grad():
    logits = model(**inputs).logits

predictions = torch.argmax(logits, dim=-1).squeeze().tolist()

for token, pred_id in zip(tokens, predictions):
    print(token, model.config.id2label[pred_id])
