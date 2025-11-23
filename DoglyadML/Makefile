.PHONY: generate-research-ner-model
.SILENT:

pip-install:
	pip3 install -r research_ner/requirements.txt

generate-research-ner-model:
	python3 research_ner/dataset/generate.py
	python3 research_ner/dataset/prepare.py
	python3 research_ner/train.py
	python3 research_ner/test.py
	python3 research_ner/convert_coreml.py