.PHONY: pip-install source generate-llm-research generate-ner-research
.SILENT:

set-venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r DoglyadML/ner_research/requirements.txt

generate-llm-research-model:
	python3 DoglyadML/llm_research/convert_coreml.py

generate-ner-research-model:
	python3 DoglyadML/ner_research/dataset/generate.py
	python3 DoglyadML/ner_research/dataset/prepare.py
	python3 DoglyadML/ner_research/train.py
	python3 DoglyadML/ner_research/test.py
	python3 DoglyadML/ner_research/convert_coreml.py
