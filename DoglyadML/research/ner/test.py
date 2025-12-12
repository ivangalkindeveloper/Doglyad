from transformers import AutoTokenizer, AutoModelForTokenClassification
from transformers import pipeline
from collections import defaultdict
import json
import os

MODEL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model")
TEST_TEXT = """
Пациент номер 184562, женщина дата рождения 12 марта 1984 года рост 167 сантиметров вес 68 килограммов
Жалобы периодические ощущения комка в горле дискомфорт при глотании эпизодические колебания уровня энергии
Описание исследования Проведено ультразвуковое исследование щитовидной железы Железа расположена типично Правая доля размерами 17 на 19 на 42 миллиметра объем около 6,8 миллилитров Левая доля 16 на 18 на 40 миллиметров объем около 6,1 миллилитра. Перешеек толщиной 3 миллиметра. Контуры железы ровные четкие. Эхогенность слегка понижена структура умеренно неоднородная. В правой доле визуализируется гипоэхогенный узловой участок размерами 6 на 5 миллиметров без признаков макрокальцинатов и слабо выраженной периферической васкуляризацией. В левой доле очаговых образований не выявлено. Регионарные лимфатические узлы без особенностей размеры в пределах нормы структура сохранена.
Дополнительные данные об исследовании исследование выполнено на аппарате GE Logiq P9 с использованием линейного датчика частотой 7–12 МГц. Запись и измерения сохранены в архиве системы. Технических артефактов мешающих оценке структуры железы не отмечено.
"""

tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForTokenClassification.from_pretrained(MODEL_PATH)

pipe = pipeline("token-classification", model=model, tokenizer=tokenizer, aggregation_strategy="simple")
result = pipe(TEST_TEXT)

print("\n=== ALL PREDICTIONS ===\n")
for ent in result:
    entity_name = ent['entity_group']
    if entity_name.startswith('B-') or entity_name.startswith('I-'):
        entity_name = entity_name[2:]
    print(f"{entity_name}: '{ent['word']}' (score: {ent['score']:.3f})")

filtered_result = [ent for ent in result]

print("\n=== FILTERED OUTPUT ===\n")
for ent in filtered_result:
    entity_name = ent['entity_group']
    if entity_name.startswith('B-') or entity_name.startswith('I-'):
        entity_name = entity_name[2:]
    print(f"{entity_name}: {ent['word']} (score: {ent['score']:.3f})")

entities = defaultdict(list)
for ent in filtered_result:
    tag = ent["entity_group"]
    if tag.startswith('B-') or tag.startswith('I-'):
        tag = tag[2:]
    value = ent["word"]
    entities[tag].append(value)

print("\n=== NORMALIZED OUTPUT ===\n")
print(json.dumps(entities, ensure_ascii=False, indent=2))

