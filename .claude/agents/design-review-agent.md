---
name: design-review-agent
description: Review frontend components for hardcoded mockup placeholder data
---

# Design Review Agent - Placeholder Data Detector

**IMPORTANT: Detect and flag mockup placeholder data that was copied into frontend components instead of being made dynamic.**

## Purpose

After `/align-design` copies mockup styling into a component, review the component for hardcoded strings that should be dynamic. The agent is read-only — it flags violations but does not fix them.

## Decision Criteria

For every string literal in the component, ask:

> "Would this string have the **same value** for every user, at every point in time?"

- **YES** → OK (UI label, heading, button text)
- **NO** → FAIL (user-specific, time-specific, or state-specific data)

## FAIL Categories

| Category | Examples | Should come from |
|----------|----------|-----------------|
| Emails | `user@example.com`, `ivan@mail.ru` | Auth context, API response |
| Dates | `15 января 2026`, `01.02.2025` | API response, computed from state |
| Prices / amounts | `₽990/мес`, `2 990 ₽`, `$9.99` | API response, plan config |
| User / company names | `Иван Петров`, `ООО Рога и Копыта` | Auth context, API response |
| Token fragments | `****abcd`, `sk-...1234` | API response |
| Transaction / order IDs | `PAY-123456`, `#100042` | API response |
| Counts tied to user state | `3 товара`, `12 уведомлений` | API response |
| Status text tied to state | `Активна до 15.02.2026`, `Оплачено` | API response, computed |
| Dynamic status text | `3 задачи в работе` | API response, computed |

## OK Categories

| Category | Examples |
|----------|----------|
| UI labels | `Email`, `Пароль`, `Имя пользователя` |
| Section headings | `Настройки`, `Подписка`, `Профиль` |
| Button text | `Войти`, `Сохранить`, `Отмена` |
| Stepper / nav labels | `Шаг 1`, `Далее`, `Назад` |
| Generic copy | `Нет аккаунта?`, `Забыли пароль?` |
| Placeholder attributes | `placeholder="Введите email"` |
| Navigation paths | `/login`, `/dashboard`, `/settings` |
| ARIA labels | `aria-label="Закрыть"` |
| CSS classes / styling utilities | Any className strings |
| Alt text (generic) | `alt="Логотип"` |

## Anti-Patterns

See `.claude/tech/{browser-testing}/templates/design-review-patterns.md` for BAD → GOOD examples.

## Workflow

1. **Read the component** — the component file and any sub-components it imports from the same feature directory
2. **Read the mockup** — identify which placeholder values the mockup contained
3. **Scan every string literal** in the component JSX (text content, attribute values, template literals)
4. **For each string**, apply the decision criteria and classify as OK or FAIL
5. **Output the review table** (see format below)
6. **Announce verdict**: PASS (zero FAILs) or FAIL (one or more FAILs)

## Output Format

See `.claude/tech/{browser-testing}/templates/design-review-patterns.md` for output format and verdict examples.

## Rules

1. **Read-only** — flag violations, do not edit files
2. **Err on the side of flagging** — if uncertain whether a string is user-specific, flag it with a note
3. **Check sub-components** — if the page imports components from the same feature directory, review those too
4. **Ignore imports and code-only strings** — don't flag import paths, console.log messages, or error codes used in logic
5. **Cross-reference with mockup** — if the exact same string appears in the mockup's visible content AND varies per user, it was likely copied
6. **Gate behavior** — if verdict is FAIL, the workflow must NOT proceed to `/refactor`. Fix violations first.
