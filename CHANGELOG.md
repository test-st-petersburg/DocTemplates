# Журнал изменений

## Неопубликованные изменения (не вошедшие в релиз)

## 2.8.8

### Новые возможности

- добавлена проверка комментариев к commit для запросов слияния
  [#141](https://github.com/test-st-petersburg/DocTemplates/issues/141)

## 2.8.7

Исправлены ошибки:

- исправлено оформление подписи в письме на бланке (курсив, полужирный)
  [#135](https://github.com/test-st-petersburg/DocTemplates/issues/135)

## 2.8.6

Исправлены ошибки:

- исправлено поведение Release to GitHub при отсутствии опубликованного релиза
  [#140](https://github.com/test-st-petersburg/DocTemplates/issues/140)

## 2.8.5

Исправлены ошибки:

- убраны из readme упоминания о работе без GIT.
  [#136](https://github.com/test-st-petersburg/DocTemplates/issues/136)

## 2.8.4

Исправлены ошибки:

- отключен Static Scan GitHub Action для Dependabot "push" событий.
  Оставлена активация только для Dependabot "pull_request" событий
  [#137](https://github.com/test-st-petersburg/DocTemplates/issues/137)

## 2.8.3

### Новые возможности

- автоматизировано создание выпуска (release) на GitHub Releases
  и заполнение его информацией
  [#37](https://github.com/test-st-petersburg/DocTemplates/issues/37)
- настроена сборка файлов через GitHub Actions и их публикация
  в GitHub Releases
  [#37](https://github.com/test-st-petersburg/DocTemplates/issues/37)

## 2.8.1

Исправлены ошибки:

- после абзаца со стилем "ЗаголовокВиз" должен следовать абзац со стилем визы (Виза2)
  [#112](https://github.com/test-st-petersburg/DocTemplates/issues/112)
- заменены в шаблоне распоряжения слова "приказываю" на "обязываю" либо "предлагаю".
  [#113](https://github.com/test-st-petersburg/DocTemplates/issues/113)

## 2.8.0

Новые возможности:

- добавлена заготовка справки на фирменном бланке
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлен шаблон справки на фирменном бланке
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлена заготовка профессиональной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлен шаблон профессиональной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

## 2.7.1

Исправлены ошибки:

- исправлена конфигурация commitizen
  (ради восстановления записи номеров issues в текст сообщения)

## 2.7.0

Новые возможности:

- добавлена заготовка доверенности на фирменном бланке
  [#45](https://github.com/test-st-petersburg/DocTemplates/issues/45)
- добавлен шаблон доверенности на фирменном бланке
  [#45](https://github.com/test-st-petersburg/DocTemplates/issues/45)

## 2.6.8

Исправлены ошибки:

- Убрать ошибочное определение в качестве ошибки сообщения
  "Skipping up-to-date output..."
  [#106](https://github.com/test-st-petersburg/DocTemplates/issues/106)

## 2.6.7

Прочие изменения:

- при подготовке для печати на типографский бланк отключаем печать не только для
  врезок (текстовых фреймов), но и для графики, наименование которой начинается
  с префикса "Бланки:"

## 2.6.6

Исправлены ошибки:

- отключен вывод "шкалы" РСТ и QR кода в подвале на печать
  при печати на типографском бланке
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)

Прочие изменения:

- восстановлена панель инструментов "Бланки" в ОРД
  (для подготовки документов к печати на типографском фирменном бланке)

## 2.6.5

Новые возможности:

- добавлена заготовка сопроводительного письма (со связанным документом)

## 2.6.4

Новые возможности:

- добавлена заготовка письма сопроводительного к актам сверки

## 2.6.3

Исправлены ошибки:

- в "заготовки" писем добавлены переменные из устаревших
  версий шаблона ОРД (для обеспечения совместимости новых версий
  правил автозаполнения со старыми версиями файлов)
  [#109](https://github.com/test-st-petersburg/DocTemplates/issues/109)

## 2.6.2

Исправлены ошибки:

- "шкала" РСТ и QR код в подвале защищены от изменений
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)

## 2.6.1

Исправлены ошибки:

- Убрать ошибочное определение в качестве ошибки сообщения
  "Skipping up-to-date output..."
  [#106](https://github.com/test-st-petersburg/DocTemplates/issues/106)

## 2.6.0

Новые возможности:

- добавлена заготовка письма о коммерческом предложении
  на работы в сфере обеспечения единства измерений
  [#104](https://github.com/test-st-petersburg/DocTemplates/issues/104)

Прочие изменения:

- изменена форма фирменного бланка в соответствии с требованиями
  приказа ФБУ "Тест-С.-Петербург" от 05.03.2021 № 35/ахд
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)
- QR-код из фирменного бланка изменён для указания на раздел сайта
  с контактами филиала
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)
- при оптимизации удаляем автоматические стили
  (для минимизации изменений из-за перенумерации автоматических стилей).
  При сборке - автоматически генерируем автоматические стили
  [#62](https://github.com/test-st-petersburg/DocTemplates/issues/62)

## 2.5.3

Исправлены ошибки:

- В визах должна быть указана дата
  [#66](https://github.com/test-st-petersburg/DocTemplates/issues/66)

## 2.5.2

Исправлены ошибки:

- в "заготовку" служебной записки добавлены переменные из устаревших
  версий шаблона ОРД (для обеспечения совместимости новых версий
  правил автозаполнения со старыми версиями файлов)

## 2.5.1

Новые возможности:

- исправлена заготовка должностной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

Исправлены ошибки:

- титульный лист должностной инструкции приведён в соответствие с требованиями
  СТО организации
  [#95](https://github.com/test-st-petersburg/DocTemplates/issues/95)

## 2.5.0

Новые возможности:

- добавлена заготовка распоряжения
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

Исправлены ошибки:

- отключена проверка орфографии для стиля `Штрихкод`
  [#95](https://github.com/test-st-petersburg/DocTemplates/issues/95)
- устранена проблема с падением просмотра перед печатью
  распоряжений и приказов
  [#93](https://github.com/test-st-petersburg/DocTemplates/issues/93)

Прочие изменения:

- добавлен шаблон страницы `БланкОРДПервыйЛистСГрифомУтверждения`,
  из шаблона страницы `БланкОРДПервыйЛист` убран гриф утверждения
  [#93](https://github.com/test-st-petersburg/DocTemplates/issues/93)
- добавлен служебный скрытый раздел "РазделяемыеКомпоненты" в content.xml.
  Добавлено его слияние с шаблоном при сборке документов.
  Сейчас в этом разделе размещён шаблон оформления даты подписи.
  В местах использование дублирование кода исключено за счёт
  `text:section-source`
  (замещается кодом при сборке шаблонов и документов)
  [#81](https://github.com/test-st-petersburg/DocTemplates/issues/81)

## 2.4.0

Новые возможности:

- при сборке документа из него удаляются внедрённые шрифты,
  если в настройках установлен запрет внедрения шрифтов
  (необходимо в случае, когда в шаблон внедрены шрифты, но для конкретного
  документа на базе этого шаблона внедрения шрифтов не требуется)
  [#90](https://github.com/test-st-petersburg/DocTemplates/issues/90)
- добавление слияние настроек документа и шаблона при сборке документов
  [#90](https://github.com/test-st-petersburg/DocTemplates/issues/90)

Прочие изменения:

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

- в документы и шаблоны включаются только файлы, указанные в манифесте
  [#74](https://github.com/test-st-petersburg/DocTemplates/issues/74)
- реализована сборка документов на базе шаблонов репозитория
  с включением файлов шаблонов в документа.
  (на этапе препроцессирования).
  В том числе объединяются разделы следующие разделы content.xml:

  - `office:document-content/office:scripts/office:event-listeners`
  - `office:document-content/office:font-face-decls`
  - `office:document-content/office:body/office:text/text:variable-decls`
  - `office:document-content/office:body/office:text/text:section[@text:name="Служебный"]`

  [#75](https://github.com/test-st-petersburg/DocTemplates/issues/75)
- библиотека TestStPetersburg удалена из состава шаблонов документов
  и внедряется на этапе сборки шаблонов документов
  (на этапе препроцессирования)
  [#83](https://github.com/test-st-petersburg/DocTemplates/issues/83)
- "исходные" файлы документов и шаблонов после препроцессора
  хранятся в подкаталоге 'tmp/template' рабочего каталога
  [#83](https://github.com/test-st-petersburg/DocTemplates/issues/83)
- добавлена возможность подготовки контейнеров библиотек
  для последующего включения в состав документов, шаблонов документов
  (команда сборки `BuildLibContainers`)
  [#83](https://github.com/test-st-petersburg/DocTemplates/issues/83)
- добавлена возможность сборки библиотек макросов из "исходных" файлов
  (команда сборки `BuildLibs`)
  [#43](https://github.com/test-st-petersburg/DocTemplates/issues/43)
- добавлено восстановление реквизитов `@manifest:media-type` в манифесте
  для раздела `Configurations2`.
  Libre Office генерирует их пустыми.
  [#89](https://github.com/test-st-petersburg/DocTemplates/issues/89)
- исключены thumbnails из репозитория и генерируемых документов
  и отключена в настройках документов их генерация
  [#88](https://github.com/test-st-petersburg/DocTemplates/issues/88)
- метаданные `meta:generator` указываются с учётом RFC 2616
  [#84](https://github.com/test-st-petersburg/DocTemplates/issues/84)
- метаданные (свойства) документа обновляются при сохранении документа
  из его переменных
  [#82](https://github.com/test-st-petersburg/DocTemplates/issues/82)

## 2.2.0

Прочие изменения:

- вычисляемые при сборке метаданных убираем из `meta.xml`
  [#64](https://github.com/test-st-petersburg/DocTemplates/issues/64)
- при сборке указывается версия в свойствах файла
  [#20](https://github.com/test-st-petersburg/DocTemplates/issues/20)
- при подстановке разделов вместо `text:section-source` осуществляется
  переименование вставляемых разделов, таблиц, врезок с учётом реквизита
  `text:section-source/@xlink:title`
  [#81](https://github.com/test-st-petersburg/DocTemplates/issues/81)
- убраны дублирования в оформлении стилей страниц
  (за счёт применения `text:section-source`)
  [#81](https://github.com/test-st-petersburg/DocTemplates/issues/81)
- обновление метаданных документа при сборке
  (`meta:editing-cycles`, `dc:date`)
  выделено в отдельный XSLT пакет
  (oo-preprocessor.xslt, режим `p:document-meta-updating`)
  [#47](https://github.com/test-st-petersburg/DocTemplates/issues/47)
- убраны файлы `mimetype` из репозитория
  (добавлена автоматическая их генерация при сборке из манифеста)
  [#80](https://github.com/test-st-petersburg/DocTemplates/issues/80)

## 2.1.0

Исправлены ошибки:

- добавлен отдельный стиль страницы для должностной инструкции
  (в соответствии с СТО СК 03-07-16)
  [#76](https://github.com/test-st-petersburg/DocTemplates/issues/76)

Прочие изменения:

- добавлены отдельные стили первого абзаца для каждого вида документа
  [#76](https://github.com/test-st-petersburg/DocTemplates/issues/76)
- и размещены в защищённом от редактирования разделе
  [#76](https://github.com/test-st-petersburg/DocTemplates/issues/76)
- удалены доступные на типовой рабочей станции встроенные шрифты
  (Письмо)
  [#73](https://github.com/test-st-petersburg/DocTemplates/issues/73)
- при оптимизации из content.xml убираем неиспользуемые автоматические стили
  таблиц, графики, врезок, разделов
  [#72](https://github.com/test-st-petersburg/DocTemplates/issues/72)

## 2.0.0

Исправлены ошибки:

- исправлены поля страниц и размеры полей в соответствии с ГОСТ Р 7.0.97-2016

Прочие изменения:

- убран промежуток между верхним колонтитулом на первых страницах
  и текстом. Все интервалы должны определяться стилями абзацев
  (ОРД)
- ФИО в подписи выравнены по аналогии с подписью в сведениях об ознакомлении
  (ОРД)
  [#65](https://github.com/test-st-petersburg/DocTemplates/issues/65)
- шаблон Записки объединён с шаблоном ОРД
  (добавлен шаблон первого листа записки)
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)
- шаблон Документа СМК объединён с шаблоном ОРД
  (добавлен шаблон титульного листа)
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)
  [#67](https://github.com/test-st-petersburg/DocTemplates/issues/67)
- шаблон Внутренние документы преобразован в шаблон ОРД
  (Приказы, Распоряжения, Инструкции без титульного листа)
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)
- исключены стили абзацев Нумерованный список, Маркированный список
  (Письмо, Внутренний документ, Записка, Документ СМК)
  [#68](https://github.com/test-st-petersburg/DocTemplates/issues/68)
- переименована библиотека макросов в `TestStPetersburg`
  (Письмо, Внутренний документ, Записка, Документ СМК)
  [#71](https://github.com/test-st-petersburg/DocTemplates/issues/71)
- удаляются `style:layout-*` при `style:layout-grid-mode="none"`
  [#70](https://github.com/test-st-petersburg/DocTemplates/issues/70)

## 1.8.2

Исправлены ошибки:

- на с/з в Центр восстановлен вывод регистрационных данных в подвале
  [#60](https://github.com/test-st-petersburg/DocTemplates/issues/60)

## 1.8.1

Исправлены ошибки:

- добавлено место составление документа на титульный лист
  (см. ГОСТ Р 7.0.97-2016, Приложение А)
  [#69](https://github.com/test-st-petersburg/DocTemplates/issues/69)

## 1.8.0

Новые возможности:

- добавлен гриф утверждения в шаблон Внутренних документов
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)

Прочие изменения:

- стили Внутреннего документа унифицированы со стилями Документа СМК

## 1.7.0

Новые возможности:

- добавлен шаблон Документ системы менеджмента
  (основа для Положений о подразделениях, Должностных инструкций,
  Стандартов организации, Инструкций).
  В настоящее время обеспечена подготовка только Положений о подразделениях
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)

## 1.6.17

Исправлены ошибки:

- ошибка при обновлении стилей из шаблона (Записка)
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

Прочие изменения:

- все поля обновляются перед сохранением и печатью
  (Записка, Внутренний документ, Письмо)
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

## 1.6.16

Исправлены ошибки:

- некорректно определяются файлы, подлежащие сборке и разборке
  [#61](https://github.com/test-st-petersburg/DocTemplates/issues/61)

## 1.6.15

Исправлены ошибки:

- некорректно определяются файлы, подлежащие сборке и разборке
  [#61](https://github.com/test-st-petersburg/DocTemplates/issues/61)

## 1.6.14

Исправлены ошибки:

- сведения о подписанте сбрасываются в "0" во Внутренних документах

## 1.6.13

Исправлены ошибки:

- не обновляется приветствие в Письмах
  [#59](https://github.com/test-st-petersburg/DocTemplates/issues/59)

## 1.6.12

Исправлены ошибки:

- ошибка при обновлении стилей из шаблона Внутреннего документа
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

## 1.6.11

Исправлены ошибки:

- поле Получатель в письме не укладывается в поля бланка
  [#55](https://github.com/test-st-petersburg/DocTemplates/issues/55)
- поле Исполнитель в письме не укладывается в поля бланка

## 1.6.10

Исправлены ошибки:

- переносы не должны допускаться в поле Получатель в Письмах
  [#54](https://github.com/test-st-petersburg/DocTemplates/issues/54)

## 1.6.9

Исправлены ошибки:

- исправлено описание `@menu:style` в menubar.dtd
  [#42](https://github.com/test-st-petersburg/DocTemplates/issues/42)

Прочие изменения:

- опционально восстанавливаем DTD в XML файлах документов
  [#42](https://github.com/test-st-petersburg/DocTemplates/issues/42)

## 1.6.8

Прочие изменения:

- при сборке документа обновляется количество циклов редактирования
  (`meta:editing-cycles`), [#47](https://github.com/test-st-petersburg/DocTemplates/issues/47)

## 1.6.7

Прочие изменения:

- при сборке документа устанавливается дата и время в метаданных
  (`dc:date`), [#47](https://github.com/test-st-petersburg/DocTemplates/issues/47)

## 1.6.6

Исправлены ошибки:

- восстановлено обновление стилей из шаблона документа при открытии документа
  (выдаётся запрос на обновление в случае изменения шаблона с последнего
  сохранения документа, #44)

## 1.6.5

Исправлены ошибки:

- дата регистрации с/з в Центр не помещалась при печати на листе (#40)

## 1.6.4

Исправлены ошибки:

- обработка DTD в XML файлах документов

## 1.6.3

Исправлены ошибки:

- при открытии Внутреннего документа выполняем обновление полей (ради подписи)

## 1.6.2

Исправлены ошибки:

- исправлен иерархический список в Записке
- исправлен иерархический список в Письме

## 1.6.1

Исправлены ошибки:

- убраны лишние переменные в шаблоне Внутренних документов

## 1.6.0

Новые возможности:

- добавлен шаблон Внутренний документ

## 1.5.6

Исправлены ошибки:

- изменено расстояние между символами в наименовании организации в шапке Записки
  в соответствии с СТО

## 1.5.5

Исправлены ошибки:

- в сведениях об исполнителе в Письме должны быть пробелы после знаков препинания

## 1.5.4

Исправлены ошибки:

- при заполнении с/з в Центр регистрационные данные в шапке не должны отображаться
- при заполнении с/з в Центр регистрационные данные должны отображаться в подвале
- аналогичные изменения обработки условий в Письма

## 1.5.1

Прочие изменения:

- дополнено описание шаблона Записки

## 1.5.0

Новые возможности:

- добавлен шаблон Записка

Прочие изменения:

- оформление бланка внутренних записок (служебных, докладных, объяснительных).
  Шаблон Записки переделан на базе шаблона Письма
- унифицирован перечень переменных документа по аналогии с шаблоном Письма
- добавлено описание шаблона Записки
- изменены инструменты для обработки XML:
  - все файлы одного документа обрабатываются одной XSLT трансформацией
  - XSLT трансформации разделены на модули (packages)

## 1.4.3

Прочие изменения:

- добавлен вывод подробных ошибок компиляции XSLT
- настроен problem matcher в VSCode для фиксации ошибок компиляции XSLT

## 1.4.2

Прочие изменения:

- дополнено описание шаблона Письмо описанием механизма печати на бланках

## 1.4.1

Прочие изменения:

- несущественные правки readme.md

## 1.4.0

Новые возможности:

- добавлена генерация документации на ReadTheDocs

Прочие изменения:

- переоформлены поля в шаблоне Письмо с помощью подстрочника

## 1.3.0

Новые возможности:

- добавлена иерархия шаблонов
- добавлен шаблон Справки (на бланке)
- для условного отображения вида документа в шапке при обновлении
  стилей из шаблона подключены макрокоманды, выполняемые при открытии и
  создании документа

Прочие изменения:

- для задач VSCode использован Invoke-Build
- переименованы стили (убрано наименование документа, утвердившего формы бланков)

## 1.2.0

Исправлены ошибки:

- оформление бланка Письма полностью перенесено в колонтитулы,
  что позволяет при обновлении стилей полностью обновлять оформление бланка
- устранена потеря данных в шапке и подвале бланка Письма при обновлении
  стилей из шаблона (все переменные перенесены в служебную страницу)

Прочие изменения:

- Шаблон Записка переименован в Письмо

## 1.1.0

Исправлены ошибки:

- внедрены шрифты в шаблоны документов
- реализована проверка DTD в XML

## 1.0.0

Новые возможности:

- для работы с XML использован Saxon HE
- форматирование атрибутов
- нормализация пробелов и пустых строк в модулях макросов

## 0.2.0

Новые возможности:

- добавлены инструменты для "чистки" xml
- очищен XML и удалены неиспользуемые стили

## 0.1.0

Новые возможности:

- шаблон стандарта учреждения (СТО).
  Он применим и для документированных процедур системы менеджмента
- шаблона переписки, внутренней и внешней (писем,
  служебных, докладных и объяснительных записок)
