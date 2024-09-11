DOCKERFILE_LIST = $(wildcard docker/*.dockerfile)
DOCKERHUB_USER = Silva97


.PHONY: default
default:
	@echo "You should specify a target!"
	@echo "Usage examples:"
	@echo "  make build-all                     # Build all docker images"
	@echo "  make docker/python3.12.dockerfile  # Build this specific image"
	@exit 1


.PHONY: build-all
build-all: $(DOCKERFILE_LIST)


.PHONY: push-all
push-all:
	@for dockerfile in $(DOCKERFILE_LIST); do \
		docker push "$(DOCKERHUB_USER)/$$(basename -s .dockerfile $$dockerfile):latest"; \
	done


docker/%.dockerfile: force
	docker build -t "$(DOCKERHUB_USER)/$(basename $(notdir $@)):latest" \
		-f "$@" \
		.


force:
