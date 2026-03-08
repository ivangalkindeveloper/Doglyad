.PHONY: venv pip-install format download-examination \
	init-local-stub init-local-model init-production-stub init-production-model \
	init-ios-local init-ios-production \
	start-backend-local-stub start-backend-local-model start-backend-production-stub start-backend-production-model \
	stop-backend
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

init-local-stub: init-ios-local start-backend-local-stub
init-local-model: init-ios-local start-backend-local-model
init-production-stub: init-ios-production start-backend-production-stub
init-production-model: init-ios-production start-backend-production-model

init-ios-local:
	@IP=$$(ipconfig getifaddr en0 2>/dev/null) && \
	if [ -z "$$IP" ]; then echo "Error: no Wi-Fi connection (en0)"; exit 1; fi && \
	sed "s|127.0.0.1|$$IP|" ios/Config.Local.xcconfig > ios/Config.xcconfig && \
	cat ios/Config.xcconfig
init-ios-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig

start-backend-local-stub:
	RUN_MODE=stub docker compose -f backend/docker-compose.yml up --build
start-backend-local-model:
	RUN_MODE=model docker compose -f backend/docker-compose.yml up --build
	./backend/scripts/start_vllm_mlx.sh
start-backend-production-stub:
	RUN_MODE=stub docker compose -f backend/docker-compose.yml up --build
start-backend-production-model:
	RUN_MODE=model docker compose -f backend/docker-compose.yml --profile vllm up --build

stop-backend:
	docker compose -f backend/docker-compose.yml down