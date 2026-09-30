# Архитектура Scores24 SMM

Полный отчёт: **[ОТЧЕТ_архитектура_пайплайна.md](./ОТЧЕТ_архитектура_пайплайна.md)**  
Автоцикл: **[АВТОЦИКЛ.md](./АВТОЦИКЛ.md)** · оператор: **[Для_SMM.md](./Для_SMM.md)**

```
bootstrap(channel)
  → fetch_data(data_source) → select_rubrics(rubrics)
  → generate → validate ⇄ repair(×3)
  → adapt | escalate → publish → settle
```

Channel yaml: `content_profile`, `rubrics`, `data_source`, `prompt_ids`, `locale`.  
Код: `smm/agent/`, `smm/channels.py`, `smm/data_sources.py`.
