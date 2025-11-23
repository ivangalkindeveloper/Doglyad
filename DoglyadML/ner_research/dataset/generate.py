import random
import csv

NAMES_RU = ["Иван", "Петр", "Анна", "Мария", "Сергей", "Александр", "Дарья"]
NAMES_EN = ["John", "Michael", "Sarah", "Emily", "David", "Anna", "James"]

GENDERS_RU = ["мужчина", "мужской", "женщина", "женский"]
GENDERS_EN = ["male", "female"]

MONTHS_RU = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
MONTHS_EN = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december']

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
                break  # Помечаем только первое вхождение
    return tags

def generate_example(lang="ru"):
    height = str(random.randint(150, 190))
    weight = str(random.randint(45, 110))

    if lang == "ru":
        name = random.choice(NAMES_RU)
        gender = random.choice(GENDERS_RU)
        complaint = random.choice(COMPLAINTS_RU)
        research = random.choice(RESEARCH_RU)
        additional = random.choice(ADDITIONAL_RU)
        birthdate = f"{random.randint(1,28)} {random.choice(MONTHS_RU)} {random.randint(1970,2005)}"
        sentence = f"Пациент {name}, {gender}, дата рождения {birthdate}, рост {height} см, вес {weight} кг. Жалобы: {complaint}. Описание исследования: {research}. Дополнительно: {additional}."
    else:
        name = random.choice(NAMES_EN)
        gender = random.choice(GENDERS_EN)
        complaint = random.choice(COMPLAINTS_EN)
        research = random.choice(RESEARCH_EN)
        additional = random.choice(ADDITIONAL_EN)
        birthdate = f"{random.choice(MONTHS_EN)} {random.randint(1,28)}, {random.randint(1970,2005)}"
        sentence = f"Patient {name}, {gender}, date of birth {birthdate}, height {height} cm, weight {weight} kg. Complaints: {complaint}. Research description: {research}. Additional: {additional}."

    tokens = tokenize(sentence)
    tags = ["O"] * len(tokens)

    # Применяем тегирование в правильном порядке
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
