# Makefile — comandos reproduzíveis do projeto BankMarketing
# Uso: `make <target>`. Requer uv (https://docs.astral.sh/uv/).

.PHONY: help install test lint demo

help:  ## Lista os targets disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install:  ## Sincroniza o ambiente (cria .venv e instala deps do uv.lock)
	uv sync

test:  ## Roda a suíte de testes
	uv run pytest

lint:  ## Roda o linter (ruff)
	uvx ruff check .

demo:  ## Pipeline ponta a ponta (stub: evolui na E5 — sobe API + 5 requests)
	@echo ">> [stub E0] 'make demo' será implementado na E5 (sobe API + 5 requests)."
	@echo ">> Por enquanto valida que o pacote importa e os testes passam."
	uv run python -c "import bankmarketing; print('bankmarketing OK')"
	uv run pytest -q
