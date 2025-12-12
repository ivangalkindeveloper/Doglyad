.PHONY: pip-install source generate-llm-research generate-ner-research
.SILENT:

set-venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r DoglyadML/requirements.txt

generate-research-ner-model:
	python3 DoglyadML/research/ner/dataset/generate.py
	python3 DoglyadML/research/ner/dataset/prepare.py
	python3 DoglyadML/research/ner/train.py
	python3 DoglyadML/research/ner/test.py
	python3 DoglyadML/research/ner/convert_coreml.py

generate-research-transfomer-model:
	python3 DoglyadML/research/transformer/convert_coreml.py