.PHONY: venv pip-install format download-examination \
	init-local-stub init-local-inference init-production-stub init-production-inference \
	init-ios-local init-ios-production \
	start-backend-local-stub start-backend-local-inference start-backend-production-stub start-backend-production-inference \
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
init-local-inference: init-ios-local start-backend-local-inference
init-production-stub: init-ios-production start-backend-production-stub
init-production-inference: init-ios-production start-backend-production-inference

init-ios-local:
	@IP=$$(ipconfig getifaddr en0 2>/dev/null) && \
	if [ -z "$$IP" ]; then echo "Error: no Wi-Fi connection (en0)"; exit 1; fi && \
	sed "s|127.0.0.1|$$IP|" ios/Config.Local.xcconfig > ios/Config.xcconfig && \
	cat ios/Config.xcconfig
init-ios-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig

start-backend-local-stub:
	LLM_MODE=stub docker compose -f backend/docker-compose.yml up --build -d
	$(MAKE) start-logs
start-backend-local-inference:
	LLM_MODE=inference docker compose -f backend/docker-compose.yml up --build -d
	./backend/scripts/start_vllm_mlx.sh
	$(MAKE) start-logs
start-backend-production-stub:
	LLM_MODE=stub docker compose -f backend/docker-compose.yml up --build -d
	$(MAKE) start-logs
start-backend-production-inference:
	LLM_MODE=inference docker compose -f backend/docker-compose.yml --profile vllm up --build -d
	$(MAKE) start-logs

start-logs:
	docker compose -f backend/docker-compose.yml logs -f

stop-backend:
	docker compose -f backend/docker-compose.yml down
