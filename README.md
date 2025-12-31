# Loan Calculator (SwiftUI + Redux/UDF)

Демо-приложение калькулятора займа на **SwiftUI** с однонаправленным потоком данных (Redux / UDF), асинхронными side-effects на `async/await` и unit-тестами.

Проект сделан как **пример архитектуры и качества**, а не как production-финтех.

---

## Стек

- **SwiftUI** (iOS 17+)
- **Swift Concurrency** (`async/await`)
- **Redux / UDF**
- **URLSession** (без сторонних библиотек)
- **UserDefaults** для локального хранения
- **XCTest** для unit-тестов

---

## Архитектура

Проект организован по **feature-first** принципу.

---

## Поток данных (UDF)

```

UI
↓ dispatch(Action)
Reducer (sync)
↓
State + [Effect]
↓
Effect (async)
↓
dispatch(ResultAction)
↓
Reducer

```

- **State**. Единственный источник истины
- **Reducer**. Чистая синхронная логика
- **Effect**. Асинхронные операции (API, storage)
- **UI**. Только отображает state

---

## Основные сценарии

### Калькуляция
- Сумма и срок выбираются через `Slider`
- При любом изменении:
  - обновляется `LoanTerms`
  - пересчитываются `totalRepayment` и `repayDate`

### Submit
- `submitTapped`
- UI переходит в `loading`
- выполняется API-запрос
- результат:
  - `success(response)`
  - `error(message)`

### Восстановление
- Последние `LoanTerms` сохраняются в `UserDefaults`
- При старте (`onAppear`) восстанавливаются
- После восстановления выполняется пересчет

---

## Формулы расчета

```

interest = amount * (APR / 100) * (days / 365)
totalRepayment = amount + interest
repayDate = now + days

```

Округление:
- банковское (`NSDecimalRound`)
- 2 знака после запятой

---

## Осознанные упрощения

Это **демо**, поэтому сознательно упрощено:

1. **Проценты**
   - APR фиксированный
   - нет compound interest
   - нет комиссий

2. **API**
   - mock-сервер
   - один endpoint
   - нет ретраев и cancellation

3. **Хранилище**
   - `UserDefaults`
   - без миграций
   - без шифрования

4. **Ошибки**
   - маппятся в строку
   - без error codes
   - без retry UI

5. **UI**
   - системные компоненты SwiftUI
   - `Form`, `Section`, `Slider`, `Alert`
   - без кастомных анимаций и дизайна

6. **Безопасность**
   - не реализована
   - не подходит для реального финтеха

---

## Почему именно так

- Redux/UDF выбран ради:
  - предсказуемости
  - тестируемости
  - простоты reasoning
- `Environment` используется как локальный DI
- `Store` generic и не знает про фичи
- Все side-effects изолированы

---

## Как запустить приложение

1. Открыть `wiam_demo.xcodeproj`
2. Выбрать схему **wiam_demo**
3. Выбрать симулятор (iPhone 15 или любой iOS 17+)
4. Нажать **Run** (`⌘R`)

---

## Как запустить тесты

### Все тесты
```

⌘U

```

### Через Test Navigator
- `⌘6`
- `wiam_demoTests`
- ▶️ рядом с тестом или классом

---

## Unit-тесты

### Покрыто тестами
- Расчеты (`totalRepayment`, `repayDate`)
- Reducer:
  - clamp значений
  - submit flow
  - restore terms
  - success / error states

### Что намеренно не тестируется
- SwiftUI View
- Layout
- Animations

---

## Что можно улучшить дальше

- Cancelation в `Effect`
- Retry политики
- Keychain вместо UserDefaults
- SegmentedControl вместо Slider для срока
- Localization
- Snapshot tests для UI

---

## Цель проекта

Показать:
- понимание **SwiftUI**
- уверенную работу с **UDF / Redux**
- чистую архитектуру
- тестируемость
- контроль side-effects

Не production-код.  
Осознанный инженерный пример.

---
```
