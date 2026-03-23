.PHONY: venv pip-install format download-examination \
	init-domain init-ios-local init-ios-production \
	start-backend-stub start-backend-stub-caddy \
	start-backend-inference-caddy-vllm start-backend-inference-vllm-mlx start-backend-inference-caddy-vllm-mlx \
	start-logs stop-backend
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

init-domain:
	./scripts/init_domain.sh

init-ios-local:
	cp ios/Config.Development.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig
init-ios-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig

start-backend-stub:
	LLM_MODE=stub BACKEND_PORT=127.0.0.1:8000:8000 docker compose -f backend/docker-compose.yml up --build -d
start-backend-stub-caddy:
	LLM_MODE=stub BACKEND_PORT=127.0.0.1:8000:8000 docker compose -f backend/docker-compose.yml --profile caddy up --build -d
start-backend-inference-caddy-vllm:
	LLM_MODE=inference BACKEND_PORT=127.0.0.1:8000:8000 docker compose -f backend/docker-compose.yml --profile caddy --profile vllm up --build -d
start-backend-inference-vllm-mlx:
	LLM_MODE=inference docker compose -f backend/docker-compose.yml up --build -d
	./backend/scripts/start_vllm_mlx.sh
start-backend-inference-caddy-vllm-mlx:
	LLM_MODE=inference BACKEND_PORT=127.0.0.1:8000:8000 docker compose -f backend/docker-compose.yml --profile caddy --profile vllm up --build -d
	./backend/scripts/start_vllm_mlx.sh

start-logs:
	docker compose -f backend/docker-compose.yml logs -f

stop-backend:
	docker compose -f backend/docker-compose.yml --profile caddy --profile vllm down
