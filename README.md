# SMM-агент Scores24

Автоцикл: Scores24 API / JSON → генератор (текст + Pillow) → валидатор → слоты через Bot API.  
Человек в боте только на ошибках валидатора и при добавлении каналов.

**Инструкция для SMM (доступ, меню, новые языки):** [Для_SMM.md](./Для_SMM.md)  
В боте то же кратко: кнопка **Справка** или `/help`.

## Когда появятся ключи

1. Скопируйте `.env.example` → `.env`.
2. Впишите `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHANNEL_ID` (`@channel` или `-100…`), `OPENAI_API_KEY` (можно позже).
3. Запустите `python -m smm.main run`, напишите боту пароль из `SMM_PASSWORD`.
4. Бот — админ канала (постить и редактировать сообщения).

Без ключа нейронки intro будет шаблонным, посты всё равно уйдут.

## Локально без Telegram

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m smm.main fetch
python -m smm.main preview
```

## Утренний API

Программа делает GET `https://scores24.live/rapi/predictions/top` (`SCORES24_INTERNAL_REQUEST` в `.env`).
LLM ключ не видит — только кэш `data/api_cache/predictions_top_llm.json`.

```powershell
python -m smm.main fetch
python -m smm.main check
```

## Входящий JSON (опционально)

Файл в `data/incoming/*.json` или:

```powershell
python -m smm.main ingest path\to\day.json
```

HTTP (если задан `INGEST_TOKEN`):

```
POST http://127.0.0.1:8088/ingest
X-Ingest-Token: ...
Content-Type: application/json
```

Контракт: объект с `"date"`, `"picks": [...]` и опционально `"channel": "scores24"`, `"matches": [...]`.

## Команды

| Команда | Что делает |
|---|---|
| `python -m smm.main run` | бот + утро generate + слоты + сеттл |
| `python -m smm.main check` | проверить, какие ключи на месте |
| `python -m smm.main preview` | собрать день и напечатать тексты |
| `python -m smm.main ingest [path]` | принять JSON |
| `python -m smm.main fetch` | GET predictions/top |

Тесты: `pytest`.

## CI/CD (GitHub Actions)

Репозиторий: [urhwez/tg_smm](https://github.com/urhwez/tg_smm).

| Workflow | Когда | Что |
|---|---|---|
| `CI` | push/PR → `main` | `pytest` на Python 3.12 |
| `Deploy` | push → `main` или вручную | после тестов: rsync + `docker compose build && up` |

Секреты репозитория (Settings → Secrets → Actions):

| Secret | Пример |
|---|---|
| `DEPLOY_HOST` | `prod-clickhouse-01-msk.leningrad.site` |
| `DEPLOY_USER` | `analyst` |
| `DEPLOY_SSH_KEY` | private key (ed25519), целиком |
| `DEPLOY_DIR` | `/home/analyst/tg_smm` (опционально, по умолчанию `~/tg_smm`) |

`.env` на сервере **не** перезаписывается. Хост должен быть доступен с runner’а GitHub; если только из VPN — поставь [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners) в той же сети и в `.github/workflows/deploy.yml` смени `runs-on` на `self-hosted`.

Локальный деплой (с машины, где есть SSH):

```bash
DEPLOY_HOST=analyst@prod-clickhouse-01-msk.leningrad.site bash scripts/ci_deploy.sh
# или полный цикл со sync+recover:
bash scripts/deploy_docker.sh
```
