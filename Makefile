.PHONY: set-venv pip-install generate-research-ner-model export-research-transformer-model backend-stub backend-vllm ios-env-local ios-env-staging ios-env-production
.SILENT:

venv:
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt
	pip3 install -r ml/requirements.txt

format:
	cd ios && swiftformat .

download-research:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir DoglyadIOSClient/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit

start-locale:
	ios-env-local
	backend-stub

start-stage:
	backend-stub

start-producation:
	backend-vllm

ios-env-local:
	@IP=$$(ipconfig getifaddr en0 2>/dev/null) && \
	if [ -z "$$IP" ]; then echo "Error: no Wi-Fi connection (en0)"; exit 1; fi && \
	sed "s|127.0.0.1|$$IP|" ios/Config.Local.xcconfig > ios/Config.xcconfig && \
	cat ios/Config.xcconfig

ios-env-stage:
	cp ios/Config.Staging.xcconfig ios/Config.xcconfig && \
	cat ios/Config.xcconfig

ios-env-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig && \
	cat ios/Config.xcconfig

backend-stub:
	STUB_MODE=true docker compose -f backend/docker-compose.yml up --build

backend-vllm:
	STUB_MODE=false docker compose -f backend/docker-compose.yml --profile vllm up --build

backend-stop:
	docker compose -f backend/docker-compose.yml down