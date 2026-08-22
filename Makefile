SEARXNG_URL ?= http://127.0.0.1:8080
OPENCODE_DIR := $(HOME)/.config/opencode

.PHONY: setup up down restart status logs install uninstall test help

setup: up install ## Поднять SearXNG и прописать MCP-сервер в opencode

up: ## Запустить SearXNG и дождаться готовности JSON API
	docker compose up -d --build
	@printf "Жду SearXNG"
	@i=0; until curl -fsS "$(SEARXNG_URL)/search?q=test&format=json" >/dev/null 2>&1; do \
		printf "."; i=$$((i+1)); \
		if [ $$i -ge 60 ]; then \
			echo; echo "ОШИБКА: SearXNG не ответил за 60с — смотри make logs"; exit 1; \
		fi; \
		sleep 1; \
	done
	@printf " готово: %s\n" "$(SEARXNG_URL)"

down: ## Остановить SearXNG
	docker compose down

restart: down up ## Перезапустить SearXNG

status: ## Статус контейнера
	docker compose ps

logs: ## Логи SearXNG (Ctrl-C для выхода)
	docker compose logs -f searxng

install: ## Прописать searxng в конфиг opencode (идемпотентно)
	@if grep -qE '"searxng"[[:space:]]*:' $(OPENCODE_DIR)/opencode.json $(OPENCODE_DIR)/opencode.jsonc 2>/dev/null; then \
		echo "searxng уже прописан в конфиге opencode"; \
	else \
		opencode mcp add searxng --env SEARXNG_URL=$(SEARXNG_URL) -- npx -y mcp-searxng; \
	fi

uninstall: ## Убрать searxng из конфига opencode и остановить контейнер
	node scripts/uninstall.mjs searxng
	$(MAKE) down

test: ## Проверить JSON API SearXNG
	@curl -fsS "$(SEARXNG_URL)/search?q=searxng&format=json" | \
		node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{const r=JSON.parse(d);console.log('OK, результатов:',r.results.length)})"

help: ## Список целей
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ':.*?## '}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
