import random
import csv
import os

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")

def load_data(filename):
    filepath = os.path.join(DATA_DIR, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip()]

NAMES_RU = load_data("names_ru.txt")
NAMES_EN = load_data("names_en.txt")
GENDERS_RU = load_data("genders_ru.txt")
GENDERS_EN = load_data("genders_en.txt")
MONTHS_RU = load_data("months_ru.txt")
MONTHS_EN = load_data("months_en.txt")
COMPLAINT_RU = load_data("complaints_ru.txt")
COMPLAINT_EN = load_data("complaints_en.txt")
RESEARCH_RU = load_data("research_ru.txt")
RESEARCH_EN = load_data("research_en.txt")
ADDITIONAL_RU = load_data("additional_ru.txt")
ADDITIONAL_EN = load_data("additional_en.txt")

def tokenize(sentence):
    return sentence.replace(", ", " ").replace(". ", " ").replace(":", "").split()

def tag_entity(tokens, entity_tokens, tag, existing_tags):
    tags = existing_tags.copy()
    for i in range(len(tokens) - len(entity_tokens) + 1):
        if tokens[i:i + len(entity_tokens)] == entity_tokens:
            can_tag = all(tags[i + j] == "O" for j in range(len(entity_tokens)))
            if can_tag:
                tags[i] = f"B-{tag}"
                for j in range(1, len(entity_tokens)):
                    tags[i + j] = f"I-{tag}"
                break
    return tags

def generate_example(lang="ru"):
    height = str(random.randint(150, 190))
    weight = str(random.randint(45, 110))

    if lang == "ru":
        name = random.choice(NAMES_RU)
        gender = random.choice(GENDERS_RU)
        complaint = random.choice(COMPLAINT_RU)
        research = random.choice(RESEARCH_RU)
        additional = random.choice(ADDITIONAL_RU)
        birthdate = f"{random.randint(1,31)} {random.choice(MONTHS_RU)} {random.randint(1900,2025)}"
        sentence = f"Пациент {name}, {gender}, дата рождения {birthdate}, рост {height} см, вес {weight} кг. Жалобы: {complaint}. Описание исследования: {research}. Дополнительно: {additional}."
    else:
        name = random.choice(NAMES_EN)
        gender = random.choice(GENDERS_EN)
        complaint = random.choice(COMPLAINT_EN)
        research = random.choice(RESEARCH_EN)
        additional = random.choice(ADDITIONAL_EN)
        birthdate = f"{random.choice(MONTHS_EN)} {random.randint(1,31)}, {random.randint(1900,2025)}"
        sentence = f"Patient {name}, {gender}, date of birth {birthdate}, height {height} cm, weight {weight} kg. Complaints: {complaint}. Research description: {research}. Additional: {additional}."

    tokens = tokenize(sentence)
    tags = ["O"] * len(tokens)

    entity_tokens = tokenize(name)
    tags = tag_entity(tokens, entity_tokens, "NAME", tags)
    
    entity_tokens = tokenize(gender)
    tags = tag_entity(tokens, entity_tokens, "GENDER", tags)
    
    entity_tokens = tokenize(birthdate)
    tags = tag_entity(tokens, entity_tokens, "BIRTHDATE", tags)
    
    entity_tokens = tokenize(height)
    tags = tag_entity(tokens, entity_tokens, "HEIGHT", tags)
    
    entity_tokens = tokenize(weight)
    tags = tag_entity(tokens, entity_tokens, "WEIGHT", tags)
    
    entity_tokens = tokenize(complaint)
    tags = tag_entity(tokens, entity_tokens, "COMPLAINT", tags)
    
    entity_tokens = tokenize(research)
    tags = tag_entity(tokens, entity_tokens, "RESEARCH", tags)
    
    entity_tokens = tokenize(additional)
    tags = tag_entity(tokens, entity_tokens, "ADDITIONAL", tags)

    return tokens, tags

def write_dataset(path, n=2000):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["token", "tag"])
        for _ in range(n):
            lang = "ru"
            tokens, tags = generate_example(lang)
            for t, g in zip(tokens, tags):
                writer.writerow([t, g])
            writer.writerow([])

write_dataset("DoglyadML/ner_research/dataset/train.csv", 10000)
write_dataset("DoglyadML/ner_research/dataset/validation.csv", 10000)

print("Dataset generated successfully")