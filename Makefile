# CT Reconstruction Project - Student Package Makefile

PACKAGE_DIR := .
DATA_DIR := data

.PHONY: help build push run run-tier test clean dev submit check-submit t1 t2 t3 t4 p1 p2 p3 p4

# Student Submission Settings
SUBMISSION_NAME := submission.zip
RESULTS_DIR := results
EXTRA_FILES := 

help:
	@echo "CT Reconstruction - Student Package Commands"
	@echo "=============================================="
	@echo ""
	@echo "Build & Run:"
	@echo "  make build              - Build student Docker image (ct-student)"
	@echo "  make push               - Push to registry (requires Docker Hub login)"
	@echo "  make run                - Run student package (default: tier=1 practice)"
	@echo "  make dev                - Start development shell"
	@echo ""
	@echo "Submission:"
	@echo "  make submit              - Create submission zip file"
	@echo "  make check-submit        - Verify submission zip contents in Docker"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean              - Remove submission zip"
	@echo ""

# Build commands
build:
	@echo "Building student Docker image..."
	docker build -t ct-student $(PACKAGE_DIR)

push:
	@echo "Pushing student Docker image..."
	docker push ct-student

# Run commands
run: build
	@echo "Running student package..."
	$(MAKE) run-tier TIER=1 USE_PRACTICE=true

run-tier: build
	@echo "Running student package for tier $(TIER) (practice=$(USE_PRACTICE))..."
	@mkdir -p $(RESULTS_DIR)
	docker run --rm -v $(shell pwd)/$(DATA_DIR)/competition:/workspace/data/competition -v $(shell pwd)/$(RESULTS_DIR):/workspace/results ct-student octave --no-gui --no-window-system --eval "tier=$(TIER); use_practice=$(USE_PRACTICE); run_tier"

# Development shell
dev: build
	@echo "Starting development shell..."
	docker run --rm -it ct-student bash

# Cleanup
clean:
	@echo "Cleaning submission zip... "
	rm -f $(SUBMISSION_NAME)
	@echo "Submission zip cleaned."

# Submission
submit:
	@echo "Creating submission zip: $(SUBMISSION_NAME)..."
	zip $(SUBMISSION_NAME) reconstruct.m $(EXTRA_FILES)
	@echo "Submission created successfully."

check-submit: build
	@if [ ! -f $(SUBMISSION_NAME) ]; then echo "Error: $(SUBMISSION_NAME) not found. Run 'make submit' first."; exit 1; fi
	@echo "Verifying submission contents in Docker..."
	docker run --rm -v $(shell pwd)/$(SUBMISSION_NAME):/tmp/submission.zip ct-student bash -c "unzip -l /tmp/submission.zip"
	@echo ""
	@echo "If you see reconstruct.m and your helper files above, your submission is valid."

# Shortcuts
t1:
	@echo "Running Tier 1..."
	$(MAKE) run-tier TIER=1 USE_PRACTICE=false

t2:
	@echo "Running Tier 2..."
	$(MAKE) run-tier TIER=2 USE_PRACTICE=false

t3:
	@echo "Running Tier 3..."
	$(MAKE) run-tier TIER=3 USE_PRACTICE=false

t4:
	@echo "Running Tier 4..."
	$(MAKE) run-tier TIER=4 USE_PRACTICE=false

p1:
	@echo "Running Tier 1 practice..."
	$(MAKE) run-tier TIER=1 USE_PRACTICE=true

p2:
	@echo "Running Tier 2 practice..."
	$(MAKE) run-tier TIER=2 USE_PRACTICE=true

p3:
	@echo "Running Tier 3 practice..."
	$(MAKE) run-tier TIER=3 USE_PRACTICE=true

p4:
	@echo "Running Tier 4 practice..."
	$(MAKE) run-tier TIER=4 USE_PRACTICE=true
