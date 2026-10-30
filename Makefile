# GuiVerb — build and validation entry points.
# `make help` lists all targets and is the documentation of record.

.PHONY: help build release check clean

help: ## List the available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-10s %s\n", $$1, $$2}'

build: ## Build in validation mode (default Alire profile: warnings are errors)
	alr build

release: ## Build in release mode
	alr build --release

check: ## Run the test suites (bbt scenarios in tests/)
	bbt tests/

clean: ## Remove the build artifacts
	alr clean
	rm -rf bin
