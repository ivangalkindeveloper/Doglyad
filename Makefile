.PHONY:
	venv \
	pip-install \
	format \
	download-examination \
	init-ignores \
	init-ios-local \
	init-ios-production \
	start-backend-development-stub \
	start-backend-production-inference-vllm \
	start-local-backend-development-inference-vllm-mlx \
	start-local-backend-production-inference-vllm-mlx \
	docker-run-vllm-medgemma-4b-it \
	start-logs stop-backend
.SILENT:

venv:
	python3.11 -m venv .venv311
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt
	pip3 install -r ml/requirements.txt

format:
	cd ios && swiftformat .

download-examination:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir ios/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit

init-ignores:
	./scripts/init_ignores.sh

init-ios-local:
	cp ios/Config.Development.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig
init-ios-production:
	cp ios/Config.Production.xcconfig ios/Config.xcconfig
	cat ios/Config.xcconfig

start-backend-development-stub:
	ENVIRONMENT=development \
	LLM_MODE=stub \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-production-inference-vllm:
	ENVIRONMENT=production \
	LLM_MODE=inference \
	docker compose -f backend/docker-compose.yml --profile vllm up --build -d
start-local-backend-development-inference-vllm-mlx:
	ENVIRONMENT=development \
	LLM_MODE=inference \
	docker compose -f backend/docker-compose.yml up --build -d
	./backend/scripts/run_vllm_mlx.sh development
start-local-backend-production-inference-vllm-mlx:
	ENVIRONMENT=production \
	LLM_MODE=inference \
	docker compose -f backend/docker-compose.yml up --build -d
	./backend/scripts/run_vllm_mlx.sh production

docker-run-vllm-medgemma-4b-it:
	./backend/scripts/docker_run_vllm.sh google/medgemma-4b-it 8101

start-logs:
	docker compose -f backend/docker-compose.yml logs -f

stop-backend:
	docker compose -f backend/docker-compose.yml --profile vllm down
