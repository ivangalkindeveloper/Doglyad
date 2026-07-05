.PHONY:
	venv \
	pip-install \
	pip-install-dev \
	format \
	format-backend \
	lint-backend \
	typecheck-backend \
	test-backend \
	build-ios \
	test-ios \
	download-examination \
	init-ignores \
	init-ios-local \
	init-ios-production \
	start-backend-development-stub \
	start-backend-development-runpod \
	start-backend-production-stub \
	start-backend-production-runpod \
	start-logs \
	stop-backend
.SILENT:

# iOS build/test destination (override: make test-ios IOS_DEST='platform=iOS Simulator,name=iPhone 15')
IOS_DEST ?= platform=iOS Simulator,name=iPhone 16

venv:
	python3.11 -m venv .venv311
	source .venv311/bin/activate

pip-install:
	pip3 install -r backend/requirements.txt

pip-install-dev:
	pip3 install -r backend/requirements-dev.txt

format:
	cd ios && swiftformat .

format-backend:
	cd backend && ruff format app tests

lint-backend:
	cd backend && ruff check app tests

typecheck-backend:
	cd backend && mypy app

test-backend:
	cd backend && pytest

build-ios:
	cd ios && xcodebuild build \
		-project Doglyad.xcodeproj \
		-scheme Doglyad \
		-destination '$(IOS_DEST)'

test-ios:
	cd ios && xcodebuild test \
		-project Doglyad.xcodeproj \
		-scheme Doglyad \
		-destination '$(IOS_DEST)'

download-examination:
	sudo hf download mlx-community/Qwen2.5-1.5B-Instruct-4bit --local-dir ios/DoglyadNeuralModel/Resources/mlx-Qwen2.5-1.5B-Instruct-4bit

init-ignores:
	./scripts/init_ignores.sh

init-ios-local:
	@set -e; \
	IP="$$(ipconfig getifaddr en0)"; \
	cp ios/Config/Config.Development.xcconfig ios/Config/Config.xcconfig; \
	sed -i '' 's|^BASE_URL = .*|BASE_URL = http:/$$()/'''"$${IP}:8000"'|' ios/Config/Config.xcconfig; \
	cat ios/Config/Config.xcconfig
init-ios-production:
	cp ios/Config/Config.Production.xcconfig ios/Config/Config.xcconfig
	cat ios/Config/Config.xcconfig

start-backend-development-stub:
	ENVIRONMENT=development \
	LLM_MODE=stub \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-development-runpod:
	ENVIRONMENT=development \
	LLM_MODE=runpod \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-production-stub:
	ENVIRONMENT=production \
	LLM_MODE=stub \
	docker compose -f backend/docker-compose.yml up --build -d
start-backend-production-runpod:
	ENVIRONMENT=production \
	LLM_MODE=runpod \
	docker compose -f backend/docker-compose.yml up --build -d

start-logs:
	docker compose -f backend/docker-compose.yml logs -f

stop-backend:
	docker compose -f backend/docker-compose.yml down
