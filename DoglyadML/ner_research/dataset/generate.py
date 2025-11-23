import random
import csv

NAMES_RU = ["Иван", "Петр", "Анна", "Мария", "Сергей", "Александр", "Дарья"]
NAMES_EN = ["John", "Michael", "Sarah", "Emily", "David", "Anna", "James"]

GENDERS_RU = ["мужчина", "мужской", "женщина", "женский"]
GENDERS_EN = ["male", "female"]

COMPLAINTS_RU = [
    "периодические боли в животе",
    "дискомфорт при глотании",
    "ощущение комка в горле",
    "неприятные покалывания в правом боку",
]

COMPLAINTS_EN = [
    "intermittent abdominal pain",
    "discomfort when swallowing",
    "a sensation of a lump in the throat",
    "mild tingling in the right side",
]

RESEARCH_RU = [
    "Проведено ультразвуковое исследование щитовидной железы",
    "УЗИ органов брюшной полости",
    "Ультразвуковое исследование почек",
]

RESEARCH_EN = [
    "Ultrasound examination of the thyroid gland was performed",
    "Ultrasound of the abdominal organs",
    "Kidney ultrasound examination",
]

ADDITIONAL_RU = [
    "исследование выполнено на аппарате GE Logiq P9",
    "изображения сохранены",
    "технических артефактов не выявлено",
]

ADDITIONAL_EN = [
    "the study was performed on a GE Logiq P9 device",
    "images were saved",
    "no technical artifacts detected",
]

def tokenize(sentence):
    return sentence.replace(",", " ,").replace(".", " .").split()

def tag_entity(tokens, entity_tokens, tag):
    tags = ["O"] * len(tokens)
    for i in range(len(tokens)):
        if tokens[i:i + len(entity_tokens)] == entity_tokens:
            tags[i] = f"B-{tag}"
            for j in range(1, len(entity_tokens)):
                tags[i + j] = f"I-{tag}"
    return tags

def generate_example(lang="ru"):
    if lang == "ru":
        name = random.choice(NAMES_RU)
        gender = random.choice(GENDERS_RU)
        complaint = random.choice(COMPLAINTS_RU)
        research = random.choice(RESEARCH_RU)
        additional = random.choice(ADDITIONAL_RU)
    else:
        name = random.choice(NAMES_EN)
        gender = random.choice(GENDERS_EN)
        complaint = random.choice(COMPLAINTS_EN)
        research = random.choice(RESEARCH_EN)
        additional = random.choice(ADDITIONAL_EN)

    birthdate = f"{random.randint(1,28)} {random.choice(['января','февраля','марта','апреля'])} {random.randint(1970,2005)}"
    height = str(random.randint(150, 190))
    weight = str(random.randint(45, 110))

    sentence = f"Пациент {name}, {gender}, дата рождения {birthdate}, рост {height} см, вес {weight} кг. Жалобы: {complaint}. Описание исследования: {research}. Дополнительно: {additional}."

    tokens = tokenize(sentence)
    tags = ["O"] * len(tokens)

    # Apply tagging
    def apply(entity_text, tag):
        nonlocal tags
        entity_tokens = tokenize(entity_text)
        t = tag_entity(tokens, entity_tokens, tag)
        tags = [nt if nt != "O" else old for nt, old in zip(t, tags)]

    apply(name, "NAME")
    apply(gender, "GENDER")
    apply(birthdate, "BIRTHDATE")
    apply(height, "HEIGHT")
    apply(weight, "WEIGHT")
    apply(complaint, "COMPLAINT")
    apply(research, "RESEARCH")
    apply(additional, "ADDITIONAL")

    return tokens, tags

def write_dataset(path, n=2000):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["token", "tag"])
        for _ in range(n):
            lang = "ru" if random.random() < 0.6 else "en"
            tokens, tags = generate_example(lang)
            for t, g in zip(tokens, tags):
                writer.writerow([t, g])
            writer.writerow([])

write_dataset("research_ner/dataset/train.csv", 8000)
write_dataset("research_ner/dataset/validation.csv", 2000)

print("Dataset generated successfully")
