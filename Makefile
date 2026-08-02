.PHONY:
	venv \
	pip-install \
	pip-install-dev \
	format \
	init-ios-development \
	build-ios-development \
	build-ios-production \
	start-backend-development-stub \
	start-backend-development-inference \
	start-backend-production \
	start-logs \
	stop-backend \
	runpod-plan \
	runpod-apply \
	runpod-urls \
	runpod-destroy \
	download-ios-examination-model
.SILENT:

IOS_DEST ?= platform=iOS Simulator,name=iPhone 17

# Prefer the project venv so `make format` works without activating it first.
RUFF ?= $(shell if [ -x "$(CURDIR)/.venv311/bin/ruff" ]; then echo "$(CURDIR)/.venv311/bin/ruff"; else echo ruff; fi)

venv:
	python3.11 -m venv .venv311
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt

pip-install-dev:
	pip3 install -r backend/requirements-dev.txt

format:
	cd ios && swiftformat .
	cd backend && "$(RUFF)" format app tests

init-ios-development:
	@set -e; \
	IP="$$(ipconfig getifaddr en0)"; \
	sed -i '' 's|^BASE_URL = .*|BASE_URL = http:/$$()/'''"$${IP}:8000"'|' ios/Config/Config.Development.xcconfig; \
	cat ios/Config/Config.Development.xcconfig

build-ios-development:
	cd ios && xcodebuild build \
		-project Doglyad.xcodeproj \
		-scheme Doglyad-Development \
		-destination '$(IOS_DEST)'

build-ios-production:
	cd ios && xcodebuild build \
		-project Doglyad.xcodeproj \
		-scheme Doglyad-Production \
		-destination '$(IOS_DEST)'

start-backend-development-stub:
	ENV_FILE=secrets/.env.development.stub \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-development-inference:
	ENV_FILE=secrets/.env.development.inference \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-production:
	ENV_FILE=secrets/.env.production \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-logs:
	docker compose -f backend/docker-compose.yml logs -f
stop-backend:
	docker compose -f backend/docker-compose.yml down

# Управление serverless-эндпоинтами RunPod из backend/config/runpod_endpoints.json.
runpod-plan:
	cd backend && python3 scripts/runpod_sync.py plan
runpod-apply:
	cd backend && python3 scripts/runpod_sync.py apply
runpod-urls:
	cd backend && python3 scripts/runpod_sync.py urls
runpod-destroy:
	cd backend && python3 scripts/runpod_sync.py destroy

download-ios-examination-model:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir ios/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit
