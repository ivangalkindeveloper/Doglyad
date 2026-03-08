.PHONY: set-venv pip-install generate-research-ner-model export-research-transformer-model backend-stub backend-vllm ios-env-local ios-env-staging ios-env-production start-locale start-stage start-production
.SILENT:

venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt
	pip3 install -r ml/requirements.txt

format:
	cd ios && swiftformat .

download-examination:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir DoglyadIOSClient/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit



init-locale: init-ios-env-local start-backend-local start-vllm-mlx-local 

init-stage: init-ios-env-stage start-backend-stub

init-production: init-ios-env-production start-backend-model



init-ios-env-local:
	@IP=$$(ipconfig getifaddr en0 2>/dev/null) && \
	if [ -z "$$IP" ]; then echo "Error: no Wi-Fi connection (en0)"; exit 1; fi && \
	sed "s|127.0.0.1|$$IP|" ios/Config.Local.xcconfig > ios/Config.xcconfig && \
	cat ios/Config.xcconfig

init-ios-env-stage:
	cp ios/Config.Staging.xcconfig ios/Config.xcconfig && \
	cat ios/Config.xcconfig

init-ios-env-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig && \
	cat ios/Config.xcconfig



start-backend-local:
	RUN_MODE=model docker compose -f backend/docker-compose.yml up --build
	
start-vllm-mlx-local:
	vllm-mlx serve google/medgemma-4b-it --port 8001

start-backend-stub:
	RUN_MODE=stub docker compose -f backend/docker-compose.yml up --build

start-backend-model:
	RUN_MODE=model docker compose -f backend/docker-compose.yml --profile vllm up --build

backend-stop:
	docker compose -f backend/docker-compose.yml down