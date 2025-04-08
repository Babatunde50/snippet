# Go parameters
BINARY_NAME=snippet
MAIN_DIR=./cmd/web/

# Build parameters
BUILD_DIR=build
LDFLAGS=-ldflags "-s -w"
GCFLAGS=-gcflags="all=-N -l"

# Test parameters
TEST_TIMEOUT=30s
TEST_FLAGS=-v
COVER_FILE=coverage.out

# Docker parameters
DOCKER_IMAGE=snippet
DOCKER_TAG=latest

# Database parameters
DB_DSN="web:pass@/snippetbox?parseTime=true"

# Set the default goal if no targets are specified
.DEFAULT_GOAL := build

# Ensure build directory exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@rm -f $(COVER_FILE)
	@go clean -testcache

# Build the application
.PHONY: build
build: $(BUILD_DIR)
	@echo "Building..."
	@go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_DIR)
	@echo "Build completed: $(BUILD_DIR)/$(BINARY_NAME)"

# Build for debugging
.PHONY: build-debug
build-debug: $(BUILD_DIR)
	@echo "Building with debug info..."
	@go build $(GCFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)_debug $(MAIN_DIR)
	@echo "Debug build completed: $(BUILD_DIR)/$(BINARY_NAME)_debug"

# Run the application
.PHONY: run
run: build
	@echo "Running..."
	@$(BUILD_DIR)/$(BINARY_NAME) -dsn=$(DB_DSN)

# Run without building
.PHONY: run-dev
run-dev:
	@echo "Running in development mode..."
	@go run $(MAIN_DIR) -dsn=$(DB_DSN)

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@go test -timeout $(TEST_TIMEOUT) $(TEST_FLAGS) ./...

# Run tests with coverage
.PHONY: test-cover
test-cover:
	@echo "Running tests with coverage..."
	@go test -timeout $(TEST_TIMEOUT) -coverprofile=$(COVER_FILE) $(TEST_FLAGS) ./...
	@go tool cover -html=$(COVER_FILE)


# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	@go fmt ./...

# Build Docker image
.PHONY: docker-build
docker-build:
	@echo "Building Docker image..."
	@docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

# Run Docker container
.PHONY: docker-run
docker-run:
	@echo "Running Docker container..."
	@docker run --rm -p 4000:4000 $(DOCKER_IMAGE):$(DOCKER_TAG)

# Static analysis
.PHONY: vet
vet:
	@echo "Running go vet..."
	@go vet ./...

# Generate dependencies
.PHONY: deps
deps:
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy

# Get dependency updates
.PHONY: deps-update
deps-update:
	@echo "Updating dependencies..."
	@go get -u ./...
	@go mod tidy

# Show help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build        - Build the application"
	@echo "  build-debug  - Build with debug information"
	@echo "  clean        - Remove build artifacts"
	@echo "  deps         - Download dependencies"
	@echo "  deps-update  - Update dependencies"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run Docker container"
	@echo "  fmt          - Format code"
	@echo "  help         - Show this help"
	@echo "  run          - Build and run the application"
	@echo "  run-dev      - Run without building (development mode)"
	@echo "  test         - Run tests"
	@echo "  test-cover   - Run tests with coverage"
	@echo "  vet          - Run go vet"