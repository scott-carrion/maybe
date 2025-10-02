# Makefile for Building and Pushing Docker Images to Churro's Castle Harbor

# ====================================================================================
# VARIABLES
# ====================================================================================

# --- Harbor Registry Details ---
HARBOR_REGISTRY ?= harbor.churroscastle.com

HARBOR_PROJECT  ?= library

# --- Image Details ---
# Set the name of your application's Docker image.
IMAGE_NAME      ?= maybe-churroscastle

# --- Tagging ---
# Define the image tag. By default, it uses the short git commit hash for versioning.
# You can override this from the command line: make push TAG=1.0.0
TAG             ?= $(shell git rev-parse --short HEAD)

# ====================================================================================
# DERIVED VARIABLES - DO NOT EDIT
# ====================================================================================

# Constructs the full image name with the specific tag.
# Example: your-harbor-registry.com/my-project/my-app:a1b2c3d
FULL_IMAGE_NAME := $(HARBOR_REGISTRY)/$(HARBOR_PROJECT)/$(IMAGE_NAME):$(TAG)

# Constructs the full image name with the 'latest' tag.
LATEST_IMAGE_NAME := $(HARBOR_REGISTRY)/$(HARBOR_PROJECT)/$(IMAGE_NAME):latest

# ====================================================================================
# TARGETS
# ====================================================================================

# Use .PHONY to declare targets that don't represent files. This prevents
# 'make' from being confused by any files that have the same name as a target.
.PHONY: all build push login clean help

# The default target that runs when you execute 'make' without specifying a target.
all: build push

# Builds the Docker image and tags it with both the specific version and 'latest'.
build:
	@echo "Building Docker image..."
	docker build -t $(FULL_IMAGE_NAME) -t $(LATEST_IMAGE_NAME) .
	@echo "Image built successfully!"

# Pushes both the version-specific tag and the 'latest' tag to the Harbor registry.
push:
	@echo "Pushing image to Harbor: $(FULL_IMAGE_NAME)"
	docker push $(FULL_IMAGE_NAME)
	@echo "Pushing latest tag: $(LATEST_IMAGE_NAME)"
	docker push $(LATEST_IMAGE_NAME)
	@echo "Image push complete!"

# Logs you into the Harbor registry. You will be prompted for your credentials.
login:
	@echo "Please log in to $(HARBOR_REGISTRY)..."
	docker login $(HARBOR_REGISTRY)

# Removes the generated Docker images from your local machine to save space.
clean:
	@echo "Removing local Docker images..."
	# Use '|| true' to prevent an error if the image doesn't exist locally.
	docker rmi $(FULL_IMAGE_NAME) || true
	docker rmi $(LATEST_IMAGE_NAME) || true
	@echo "Cleanup complete."

# Displays this help message.
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all     Builds the Docker image and pushes it to Harbor (default)."
	@echo "  build   Builds the Docker image."
	@echo "  push    Pushes the built image to Harbor. (Note: Run 'make login' first if needed)."
	@echo "  login   Log in to the Harbor registry interactively."
	@echo "  clean   Removes the built Docker images from your local machine."
	@echo "  help    Shows this help message."
	@echo ""
	@echo "Example to override the tag:"
	@echo "  make push TAG=v1.2.0"
