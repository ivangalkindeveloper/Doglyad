.PHONY: set-venv pip-install generate-research-ner-model export-research-transformer-model
.SILENT:

set-venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r DoglyadML/requirements.txt

export-research-ner:
	python3 DoglyadML/research/ner/dataset/generate.py
	python3 DoglyadML/research/ner/dataset/prepare.py
	python3 DoglyadML/research/ner/train.py
	python3 DoglyadML/research/ner/test.py
	python3 DoglyadML/research/ner/convert_coreml.py

export-research-transformer:
	python3 DoglyadML/research/transformer/export_mistal_1.py