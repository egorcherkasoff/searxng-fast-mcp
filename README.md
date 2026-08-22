# searxng-fast-mcp

Локальный SearXNG + MCP-сервер для opencode в пару команд.

- **SearXNG** — метапоисковик, в docker, только на `127.0.0.1:8080`
- **mcp-searxng** (npm, запускается через `npx`) — отдаёт поиск в opencode как MCP-инструменты

## Требования

- docker (+ compose plugin)
- node/npx
- opencode

## Установка

```sh
make setup
```

(это `make up` + `make install`), затем перезапусти opencode — инструменты `searxng_*` появятся автоматически.

Проверка:

```sh
make test          # JSON API отвечает?
opencode mcp list  # сервер searxng: connected
```

В чате opencode: «поищи про X, use searxng».

## Прочие цели

| Команда         | Действие                                          |
|-----------------|---------------------------------------------------|
| `make up`       | запустить SearXNG и дождаться готовности          |
| `make down`     | остановить                                        |
| `make restart`  | перезапустить                                     |
| `make logs`     | логи контейнера                                   |
| `make status`   | статус контейнера                                 |
| `make test`     | проверка JSON API                                 |
| `make install`  | прописать MCP в opencode (идемпотентно)           |
| `make uninstall`| убрать MCP из конфига и остановить контейнер      |

URL инстанса можно переопределить: `make setup SEARXNG_URL=http://127.0.0.1:9090`
(порт также поменяй в `docker-compose.yml`).## Заметки

- `searxng/settings.yml`: `formats: [html, json]` — без `json` API отдаёт 403; `limiter: false` — иначе JSON-запросы ловят 429 (инстанс только на localhost).
- Настройки копируются в образ при сборке (`Dockerfile`), `secret_key` генерируется на этапе сборки — после правки `searxng/settings.yml` делай `make restart`.
- Контейнер слушает только на `127.0.0.1:8080`.
- `make uninstall` переписывает конфиг opencode как чистый JSON (комментарии, если были, пропадут).
