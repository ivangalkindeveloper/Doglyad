.PHONY: set-venv pip-install generate-research-ner-model export-research-transformer-model backend-stub backend-vllm
.SILENT:

venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt
	pip3 install -r ml/requirements.txt

download-research:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir DoglyadIOSClient/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit

export-research-ner:
	python3 ml/research/ner/dataset/generate.py
	python3 ml/research/ner/dataset/prepare.py
	python3 ml/research/ner/train.py
	python3 ml/research/ner/test.py
	python3 ml/research/ner/convert_coreml.py

export-research-transformer:
	python3 ml/research/transformer/export_mistal_1.py

backend-stub:
	STUB_MODE=true docker compose -f backend/docker-compose.yml up --build

backend-vllm:
	STUB_MODE=false docker compose -f backend/docker-compose.yml --profile vllm up --build