# Изменения, несовместимые с предыдущими версиями

## Неопубликованные изменения (не вошедшие в релиз)

## 2.4.0

Прочие изменения:

- заполнение обращения к адресату реализовано через
  переменную "ВступительноеОбращение" (вместо "ПолучателиВОбращении")
- оформление даты сведений об ознакомлении реализовано
  без таблиц, с помощью позиций табуляции
  [#91](https://github.com/test-st-petersburg/DocTemplates/issues/91)
- оформление даты виз реализовано без таблиц, с помощью позиций табуляции
  [#91](https://github.com/test-st-petersburg/DocTemplates/issues/91)
- оформление подписей (Подпись2) и виз (Виза2) реализовано без
  таблиц, с помощью позиций табуляции
  [#91](https://github.com/test-st-petersburg/DocTemplates/issues/91)
- переменная документа `Название` переименована в `НазваниеДокумента`
  (Переменная `Название` воспринимается LibreOffice как переменная `Caption`)
- вступительное обращение в Письме перенесено в шаблон первой страницы
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)
- шаблон Письмо включен в состав шаблона ОРД v2
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)

## 2.3.0

Прочие изменения:

- команда **Clean** теперь очищает не исходные каталоги,
  а каталоги с временными файлами и собранными документами и их шаблонами

## 2.0.0

Прочие изменения:

- шаблон Записки объединён с шаблоном ОРД
  (добавлен шаблон первого листа записки).
  Отдельный шаблон Записки более не поддерживается
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)
- шаблон Документа СМК объединён с шаблоном ОРД
  (добавлен шаблон титульного листа).
  Отдельный шаблон Документа СМК более не поддерживается
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)
- шаблон Внутренние документы преобразован в шаблон ОРД v2
  (Приказы, Распоряжения, Инструкции без титульного листа).
  Отдельный шаблон Внутренние документы более не поддерживается
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)
- исключены стили абзацев Нумерованный список, Маркированный список
  (Письмо, ОРД)
  [#68](https://github.com/test-st-petersburg/DocTemplates/issues/68)
- переименована библиотека макросов в `TestStPetersburg`
  (Письмо, ОРД)
  [#71](https://github.com/test-st-petersburg/DocTemplates/issues/71)
