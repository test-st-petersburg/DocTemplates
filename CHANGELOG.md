# Журнал изменений

Формат этого файла базируется на рекомендациях
[Keep a Changelog](https://keepachangelog.com/ru/1.0.0/).

Этот проект придерживается
[![Semantic Versioning](https://img.shields.io/static/v1?label=Semantic%20Versioning&message=v2.0.0&color=green&logo=semver)](https://semver.org/lang/ru/spec/v2.0.0.html).

## [Unreleased] Неопубликованные изменения (не вошедшие в релиз)

## [2.9.5]

### Изменено

- расширена проверка PowerShell сценариев (сценарии сборки, тестирования)

## [2.9.4]

### Изменено

- версия Saxon HE обновлена до 10.6.0
  [#170](https://github.com/test-st-petersburg/DocTemplates/pull/170)
- убран fix-saxon.xslt

## [2.9.3]

### Добавлено

- автоматическое обновление пакетов QRCoder, Saxon HE, ODFValidator
  [#165](https://github.com/test-st-petersburg/DocTemplates/issues/165)

## [2.9.2]

### Исправлено

- исправлена ошибка загрузки артефактов doc при сборке на GitHub
  (GitHub action 'Build ant test')

### Изменено

- добавлена задача сборки 'pre-build' в целях установки необходимых инструментов
  для сборки
- выделена задача для установки nuget
- добавлена задача сборки 'distclean' в целях соответствия
  [стандартным целям make](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html)
- добавлена задача сборки 'maintainer-clean' в целях соответствия
  [стандартным целям make](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html)
- добавлена задача сборки 'check' в целях соответствия
  [стандартным целям make](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html)
- добавлена задача сборки 'all' в целях соответствия
  [стандартным целям make](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html)
- переименованы задачи сборки в целях соответствия
  [стандартным целям make](https://www.gnu.org/software/make/manual/html_node/Standard-Targets.html)
- сборка для XSLT 3.0 Saxon HE устанавливается с помощью NuGet CLI и
  packages.config
  [#161](https://github.com/test-st-petersburg/DocTemplates/issues/161)

## [2.9.1]

### Исправлено

- исправлена ошибка при сборке на GitHub (убран параметр Version для build.ps1)
  (GitHub action 'Release to GihHub')
- устранено замечание по качеству кода Update-FileLastWriteTime.ps1:
  "Command accepts pipeline input but has not defined a process block".
- устранено замечание по качеству кода:
  "The cmdlet 'Write-CompilerWarningAndErrors' uses a plural noun.
  A singular noun should be used instead".
- устранено замечание по качеству кода Out-vCardFile.ps1:
  "Command accepts pipeline input but has not defined a process block".

## [2.9.0]

### Добавлено

- добавлен дополнительный этап обработки в XSLT при подготовке для Android
  [#126](https://github.com/test-st-petersburg/DocTemplates/issues/126)
- добавлена в XML схему (XSD) для визитных карт (xCard)
  поддержка `X-GROUP-MEMBERSHIP`
  [#126](https://github.com/test-st-petersburg/DocTemplates/issues/126)
- добавлена XML схема (XSD) для визитных карт (xCard)
  [#117](https://github.com/test-st-petersburg/DocTemplates/issues/117)
- добавлена конвертация xCard в vCard версии 4.0
  [#118](https://github.com/test-st-petersburg/DocTemplates/issues/118)

### Изменено

- выделены сценарии сборки библиотек и их контейнеров
  [#133](https://github.com/test-st-petersburg/DocTemplates/issues/133)
- выделены сценарии сборки QR кодов для URI
  [#133](https://github.com/test-st-petersburg/DocTemplates/issues/133)
- выделены сценарии сборки QR кодов для xCard/vCard
  [#133](https://github.com/test-st-petersburg/DocTemplates/issues/133)
- выделены сценарии сборки шаблонов документов
  [#133](https://github.com/test-st-petersburg/DocTemplates/issues/133)
- выделены отдельные папки для объединения нескольких генерируемых файлов
  документов
  [#132](https://github.com/test-st-petersburg/DocTemplates/issues/132)
- выделены сценарии сборки документов
  [#133](https://github.com/test-st-petersburg/DocTemplates/issues/133)
- сборка для обработки QR кодов устанавливается с помощью NuGet CLI и
  packages.config
  [#167](https://github.com/test-st-petersburg/DocTemplates/issues/167)

### Исправлено

- fix XSLT.resources.xsltPackages paths

## [2.8.19]

### Исправлено

- устранено замечание по качеству кода:
  "The cmdlet 'Write-CompilerWarningAndErrors' uses a plural noun.
  A singular noun should be used instead".

## [2.8.18]

### Исправлено

- исправлены ошибки тестов PS-Rule

## [2.8.17]

### Изменено

- ODF Validator загружается при помощи maven и pom.xml
  [#159](https://github.com/test-st-petersburg/DocTemplates/issues/159)

## [2.8.16]

### Изменено

- разделы подписи в документах на фирменном бланке заменены
  ссылкой (`text:section-source`) в целях нормализации
  [#135](https://github.com/test-st-petersburg/DocTemplates/issues/135)

### Исправлено

- исправлена ошибка сборки документов для случая, когда
  `text:section-source[ not @xlink:title ]`
- восстановление включение разделов (`text:section-source`)
  во время сборки документов и шаблонов
  [#81](https://github.com/test-st-petersburg/DocTemplates/issues/81)

## [2.8.15]

### Исправлено

- исправлена ошибка выравнивания при использовании нумерованного списка
  для заголовков
  (исключено использование отступа для первой строки из стилей списков)
  [#111](https://github.com/test-st-petersburg/DocTemplates/issues/111)

## [2.8.14]

### Исправлено

- исправлены ошибки при создании релиза без соответствующей вехи
  [#153](https://github.com/test-st-petersburg/DocTemplates/issues/153)

### Изменено

- изменено тестирование через Pester,
  обеспечена поддержка консоли тестирования в VSCode
  [#156](https://github.com/test-st-petersburg/DocTemplates/issues/156)

## [2.8.13]

### Исправлено

- исправлена генерация release notes

## [2.8.12]

### Добавлено

- добавлена проверка собранных файлов документов с помощью ODF Validator
  [#146](https://github.com/test-st-petersburg/DocTemplates/issues/146)
- добавлено тестирование через Pester,
  в том числе - и через [ODF Validator](https://odfvalidator.org)
  [#156](https://github.com/test-st-petersburg/DocTemplates/issues/156)

## [2.8.11]

### Исправлено

- исправлены ошибки проверки [ODF Validator](https://odfvalidator.org)
  [#147](https://github.com/test-st-petersburg/DocTemplates/issues/147)

## [2.8.10]

### Исправлено

- удалены декларации DOCTYPE из XML файлов документов
  [#110](https://github.com/test-st-petersburg/DocTemplates/issues/110)
- добавлена Relax NG схема .odt файлов и .ott файлов
  [#110](https://github.com/test-st-petersburg/DocTemplates/issues/110)

## [2.8.9]

### Исправлено

- исправлена конфигурация в commitlint.config.js,
  для исправления ошибок проверки сообщений dependabot
  [#144](https://github.com/test-st-petersburg/DocTemplates/issues/144)

## [2.8.8]

### Добавлено

- добавлена проверка комментариев к commit для запросов слияния
  [#141](https://github.com/test-st-petersburg/DocTemplates/issues/141)

## [2.8.7]

### Исправлено

- исправлено оформление подписи в письме на бланке (курсив, полужирный)
  [#135](https://github.com/test-st-petersburg/DocTemplates/issues/135)

## [2.8.6]

### Исправлено

- исправлено поведение Release to GitHub при отсутствии опубликованного релиза
  [#140](https://github.com/test-st-petersburg/DocTemplates/issues/140)

## [2.8.5]

### Исправлено

- убраны из readme упоминания о работе без GIT.
  [#136](https://github.com/test-st-petersburg/DocTemplates/issues/136)

## [2.8.4]

### Исправлено

- отключен Static Scan GitHub Action для Dependabot "push" событий.
  Оставлена активация только для Dependabot "pull_request" событий
  [#137](https://github.com/test-st-petersburg/DocTemplates/issues/137)

## [2.8.3]

### Добавлено

- автоматизировано создание выпуска (release) на GitHub Releases
  и заполнение его информацией
  [#37](https://github.com/test-st-petersburg/DocTemplates/issues/37)
- настроена сборка файлов через GitHub Actions и их публикация
  в GitHub Releases
  [#37](https://github.com/test-st-petersburg/DocTemplates/issues/37)

## [2.8.1]

### Исправлено

- после абзаца со стилем "ЗаголовокВиз" должен следовать абзац со стилем визы (Виза2)
  [#112](https://github.com/test-st-petersburg/DocTemplates/issues/112)
- заменены в шаблоне распоряжения слова "приказываю" на "обязываю" либо "предлагаю".
  [#113](https://github.com/test-st-petersburg/DocTemplates/issues/113)

## [2.8.0]

### Добавлено

- добавлена заготовка справки на фирменном бланке
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлен шаблон справки на фирменном бланке
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлена заготовка профессиональной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)
- добавлен шаблон профессиональной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

## [2.7.1]

### Исправлено

- исправлена конфигурация commitizen
  (ради восстановления записи номеров issues в текст сообщения)

## [2.7.0]

### Добавлено

- добавлена заготовка доверенности на фирменном бланке
  [#45](https://github.com/test-st-petersburg/DocTemplates/issues/45)
- добавлен шаблон доверенности на фирменном бланке
  [#45](https://github.com/test-st-petersburg/DocTemplates/issues/45)

## [2.6.8]

### Исправлено

- Убрать ошибочное определение в качестве ошибки сообщения
  "Skipping up-to-date output..."
  [#106](https://github.com/test-st-petersburg/DocTemplates/issues/106)

## [2.6.7]

### Изменено

- при подготовке для печати на типографский бланк отключаем печать не только для
  врезок (текстовых фреймов), но и для графики, наименование которой начинается
  с префикса "Бланки:"

## [2.6.6]

### Исправлено

- отключен вывод "шкалы" РСТ и QR кода в подвале на печать
  при печати на типографском бланке
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)

### Изменено

- восстановлена панель инструментов "Бланки" в ОРД
  (для подготовки документов к печати на типографском фирменном бланке)

## [2.6.5]

### Добавлено

- добавлена заготовка сопроводительного письма (со связанным документом)

## [2.6.4]

### Добавлено

- добавлена заготовка письма сопроводительного к актам сверки

## [2.6.3]

### Исправлено

- в "заготовки" писем добавлены переменные из устаревших
  версий шаблона ОРД (для обеспечения совместимости новых версий
  правил автозаполнения со старыми версиями файлов)
  [#109](https://github.com/test-st-petersburg/DocTemplates/issues/109)

## [2.6.2]

### Исправлено

- "шкала" РСТ и QR код в подвале защищены от изменений
  [#105](https://github.com/test-st-petersburg/DocTemplates/issues/105)

## [2.6.1]

### Исправлено

- Убрать ошибочное определение в качестве ошибки сообщения
  "Skipping up-to-date output..."
  [#106](https://github.com/test-st-petersburg/DocTemplates/issues/106)

## [2.6.0]

### Добавлено

- добавлена заготовка письма о коммерческом предложении
  на работы в сфере обеспечения единства измерений
  [#104](https://github.com/test-st-petersburg/DocTemplates/issues/104)

### Изменено

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

## [2.5.3]

### Исправлено

- В визах должна быть указана дата
  [#66](https://github.com/test-st-petersburg/DocTemplates/issues/66)

## [2.5.2]

### Исправлено

- в "заготовку" служебной записки добавлены переменные из устаревших
  версий шаблона ОРД (для обеспечения совместимости новых версий
  правил автозаполнения со старыми версиями файлов)

## [2.5.1]

### Добавлено

- исправлена заготовка должностной инструкции
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

### Исправлено

- титульный лист должностной инструкции приведён в соответствие с требованиями
  СТО организации
  [#95](https://github.com/test-st-petersburg/DocTemplates/issues/95)

## [2.5.0]

### Добавлено

- добавлена заготовка распоряжения
  [#92](https://github.com/test-st-petersburg/DocTemplates/issues/92)

### Исправлено

- отключена проверка орфографии для стиля `Штрихкод`
  [#95](https://github.com/test-st-petersburg/DocTemplates/issues/95)
- устранена проблема с падением просмотра перед печатью
  распоряжений и приказов
  [#93](https://github.com/test-st-petersburg/DocTemplates/issues/93)

### Изменено

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

## [2.4.0]

### Добавлено

- при сборке документа из него удаляются внедрённые шрифты,
  если в настройках установлен запрет внедрения шрифтов
  (необходимо в случае, когда в шаблон внедрены шрифты, но для конкретного
  документа на базе этого шаблона внедрения шрифтов не требуется)
  [#90](https://github.com/test-st-petersburg/DocTemplates/issues/90)
- добавление слияние настроек документа и шаблона при сборке документов
  [#90](https://github.com/test-st-petersburg/DocTemplates/issues/90)

### Изменено

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

## [2.3.0]

### Изменено

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

## [2.2.0]

### Изменено

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

## [2.1.0]

### Исправлено

- добавлен отдельный стиль страницы для должностной инструкции
  (в соответствии с СТО СК 03-07-16)
  [#76](https://github.com/test-st-petersburg/DocTemplates/issues/76)

### Изменено

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

## [2.0.0]

### Исправлено

- исправлены поля страниц и размеры полей в соответствии с ГОСТ Р 7.0.97-2016

### Изменено

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

## [1.8.2]

### Исправлено

- на с/з в Центр восстановлен вывод регистрационных данных в подвале
  [#60](https://github.com/test-st-petersburg/DocTemplates/issues/60)

## [1.8.1]

### Исправлено

- добавлено место составление документа на титульный лист
  (см. ГОСТ Р 7.0.97-2016, Приложение А)
  [#69](https://github.com/test-st-petersburg/DocTemplates/issues/69)

## [1.8.0]

### Добавлено

- добавлен гриф утверждения в шаблон Внутренних документов
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)

### Изменено

- стили Внутреннего документа унифицированы со стилями Документа СМК

## [1.7.0]

### Добавлено

- добавлен шаблон Документ системы менеджмента
  (основа для Положений о подразделениях, Должностных инструкций,
  Стандартов организации, Инструкций).
  В настоящее время обеспечена подготовка только Положений о подразделениях
  [#46](https://github.com/test-st-petersburg/DocTemplates/issues/46)

## [1.6.17]

### Исправлено

- ошибка при обновлении стилей из шаблона (Записка)
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

### Изменено

- все поля обновляются перед сохранением и печатью
  (Записка, Внутренний документ, Письмо)
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

## [1.6.16]

### Исправлено

- некорректно определяются файлы, подлежащие сборке и разборке
  [#61](https://github.com/test-st-petersburg/DocTemplates/issues/61)

## [1.6.15]

### Исправлено

- некорректно определяются файлы, подлежащие сборке и разборке
  [#61](https://github.com/test-st-petersburg/DocTemplates/issues/61)

## [1.6.14]

### Исправлено

- сведения о подписанте сбрасываются в "0" во Внутренних документах

## [1.6.13]

### Исправлено

- не обновляется приветствие в Письмах
  [#59](https://github.com/test-st-petersburg/DocTemplates/issues/59)

## [1.6.12]

### Исправлено

- ошибка при обновлении стилей из шаблона Внутреннего документа
  [#52](https://github.com/test-st-petersburg/DocTemplates/issues/52)

## [1.6.11]

### Исправлено

- поле Получатель в письме не укладывается в поля бланка
  [#55](https://github.com/test-st-petersburg/DocTemplates/issues/55)
- поле Исполнитель в письме не укладывается в поля бланка

## [1.6.10]

### Исправлено

- переносы не должны допускаться в поле Получатель в Письмах
  [#54](https://github.com/test-st-petersburg/DocTemplates/issues/54)

## [1.6.9]

### Исправлено

- исправлено описание `@menu:style` в menubar.dtd
  [#42](https://github.com/test-st-petersburg/DocTemplates/issues/42)

### Изменено

- опционально восстанавливаем DTD в XML файлах документов
  [#42](https://github.com/test-st-petersburg/DocTemplates/issues/42)

## [1.6.8]

### Изменено

- при сборке документа обновляется количество циклов редактирования
  (`meta:editing-cycles`), [#47](https://github.com/test-st-petersburg/DocTemplates/issues/47)

## [1.6.7]

### Изменено

- при сборке документа устанавливается дата и время в метаданных
  (`dc:date`), [#47](https://github.com/test-st-petersburg/DocTemplates/issues/47)

## [1.6.6]

### Исправлено

- восстановлено обновление стилей из шаблона документа при открытии документа
  (выдаётся запрос на обновление в случае изменения шаблона с последнего
  сохранения документа, #44)

## [1.6.5]

### Исправлено

- дата регистрации с/з в Центр не помещалась при печати на листе (#40)

## [1.6.4]

### Исправлено

- обработка DTD в XML файлах документов

## [1.6.3]

### Исправлено

- при открытии Внутреннего документа выполняем обновление полей (ради подписи)

## [1.6.2]

### Исправлено

- исправлен иерархический список в Записке
- исправлен иерархический список в Письме

## [1.6.1]

### Исправлено

- убраны лишние переменные в шаблоне Внутренних документов

## [1.6.0]

### Добавлено

- добавлен шаблон Внутренний документ

## [1.5.6]

### Исправлено

- изменено расстояние между символами в наименовании организации в шапке Записки
  в соответствии с СТО

## [1.5.5]

### Исправлено

- в сведениях об исполнителе в Письме должны быть пробелы после знаков препинания

## [1.5.4]

### Исправлено

- при заполнении с/з в Центр регистрационные данные в шапке не должны отображаться
- при заполнении с/з в Центр регистрационные данные должны отображаться в подвале
- аналогичные изменения обработки условий в Письма

## [1.5.1]

### Изменено

- дополнено описание шаблона Записки

## [1.5.0]

### Добавлено

- добавлен шаблон Записка

### Изменено

- оформление бланка внутренних записок (служебных, докладных, объяснительных).
  Шаблон Записки переделан на базе шаблона Письма
- унифицирован перечень переменных документа по аналогии с шаблоном Письма
- добавлено описание шаблона Записки
- изменены инструменты для обработки XML:
  - все файлы одного документа обрабатываются одной XSLT трансформацией
  - XSLT трансформации разделены на модули (packages)

## [1.4.3]

### Изменено

- добавлен вывод подробных ошибок компиляции XSLT
- настроен problem matcher в VSCode для фиксации ошибок компиляции XSLT

## [1.4.2]

### Изменено

- дополнено описание шаблона Письмо описанием механизма печати на бланках

## [1.4.1]

### Изменено

- несущественные правки readme.md

## [1.4.0]

### Добавлено

- добавлена генерация документации на ReadTheDocs

### Изменено

- переоформлены поля в шаблоне Письмо с помощью подстрочника

## [1.3.0]

### Добавлено

- добавлена иерархия шаблонов
- добавлен шаблон Справки (на бланке)
- для условного отображения вида документа в шапке при обновлении
  стилей из шаблона подключены макрокоманды, выполняемые при открытии и
  создании документа

### Изменено

- для задач VSCode использован Invoke-Build
- переименованы стили (убрано наименование документа, утвердившего формы бланков)

## [1.2.0]

### Исправлено

- оформление бланка Письма полностью перенесено в колонтитулы,
  что позволяет при обновлении стилей полностью обновлять оформление бланка
- устранена потеря данных в шапке и подвале бланка Письма при обновлении
  стилей из шаблона (все переменные перенесены в служебную страницу)

### Изменено

- Шаблон Записка переименован в Письмо

## [1.1.0]

### Исправлено

- внедрены шрифты в шаблоны документов
- реализована проверка DTD в XML

## [1.0.0]

### Добавлено

- для работы с XML использован Saxon HE
- форматирование атрибутов
- нормализация пробелов и пустых строк в модулях макросов

## [0.2.0]

### Добавлено

- добавлены инструменты для "чистки" xml
- очищен XML и удалены неиспользуемые стили

## [0.1.0]

### Добавлено

- шаблон стандарта учреждения (СТО).
  Он применим и для документированных процедур системы менеджмента
- шаблона переписки, внутренней и внешней (писем,
  служебных, докладных и объяснительных записок)

[Unreleased]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.5...HEAD
[2.9.5]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.4...2.9.5
[2.9.4]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.3...2.9.4
[2.9.3]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.2...2.9.3
[2.9.2]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.1...2.9.2
[2.9.1]: https://github.com/test-st-petersburg/DocTemplates/compare/2.9.0...2.9.1
[2.9.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.19...2.9.0
[2.8.19]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.18...2.8.19
[2.8.18]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.17...2.8.18
[2.8.17]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.16...2.8.17
[2.8.16]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.15...2.8.16
[2.8.15]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.14...2.8.15
[2.8.14]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.13...2.8.14
[2.8.13]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.12...2.8.13
[2.8.12]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.11...2.8.12
[2.8.11]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.10...2.8.11
[2.8.10]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.9...2.8.10
[2.8.9]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.8...2.8.9
[2.8.8]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.7...2.8.8
[2.8.7]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.6...2.8.7
[2.8.6]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.5...2.8.6
[2.8.5]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.4...2.8.5
[2.8.4]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.3...2.8.4
[2.8.3]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.2...2.8.3
[2.8.1]: https://github.com/test-st-petersburg/DocTemplates/compare/2.8.0...2.8.1
[2.8.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.7.1...2.8.0
[2.7.1]: https://github.com/test-st-petersburg/DocTemplates/compare/2.7.0...2.7.1
[2.7.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.8...2.7.0
[2.6.8]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.7...2.6.8
[2.6.7]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.6...2.6.7
[2.6.6]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.5...2.6.6
[2.6.5]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.4...2.6.5
[2.6.4]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.3...2.6.4
[2.6.3]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.2...2.6.3
[2.6.2]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.1...2.6.2
[2.6.1]: https://github.com/test-st-petersburg/DocTemplates/compare/2.6.0...2.6.1
[2.6.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.5.3...2.6.0
[2.5.3]: https://github.com/test-st-petersburg/DocTemplates/compare/2.5.2...2.5.3
[2.5.2]: https://github.com/test-st-petersburg/DocTemplates/compare/2.5.1...2.5.2
[2.5.1]: https://github.com/test-st-petersburg/DocTemplates/compare/2.5.0...2.5.1
[2.5.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.4.0...2.5.0
[2.4.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.3.0...2.4.0
[2.3.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/test-st-petersburg/DocTemplates/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.8.2...2.0.0
[1.8.2]: https://github.com/test-st-petersburg/DocTemplates/compare/1.8.1...1.8.2
[1.8.1]: https://github.com/test-st-petersburg/DocTemplates/compare/1.8.0...1.8.1
[1.8.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.7.0...1.8.0
[1.7.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.17...1.7.0
[1.6.17]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.16...1.6.17
[1.6.16]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.15...1.6.16
[1.6.15]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.14...1.6.15
[1.6.14]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.13...1.6.14
[1.6.13]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.12...1.6.13
[1.6.12]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.11...1.6.12
[1.6.11]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.10...1.6.11
[1.6.10]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.9...1.6.10
[1.6.9]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.8...1.6.9
[1.6.8]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.7...1.6.8
[1.6.7]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.6...1.6.7
[1.6.6]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.5...1.6.6
[1.6.5]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.4...1.6.5
[1.6.4]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.3...1.6.4
[1.6.3]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.2...1.6.3
[1.6.2]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.1...1.6.2
[1.6.1]: https://github.com/test-st-petersburg/DocTemplates/compare/1.6.0...1.6.1
[1.6.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.5.6...1.6.0
[1.5.6]: https://github.com/test-st-petersburg/DocTemplates/compare/1.5.5...1.5.6
[1.5.5]: https://github.com/test-st-petersburg/DocTemplates/compare/1.5.4...1.5.5
[1.5.4]: https://github.com/test-st-petersburg/DocTemplates/compare/1.5.1...1.5.4
[1.5.1]: https://github.com/test-st-petersburg/DocTemplates/compare/1.5.0...1.5.1
[1.5.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.4.3...1.5.0
[1.4.3]: https://github.com/test-st-petersburg/DocTemplates/compare/1.4.2...1.4.3
[1.4.2]: https://github.com/test-st-petersburg/DocTemplates/compare/1.4.1...1.4.2
[1.4.1]: https://github.com/test-st-petersburg/DocTemplates/compare/1.4.0...1.4.1
[1.4.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/test-st-petersburg/DocTemplates/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/test-st-petersburg/DocTemplates/compare/0.2.0...1.0.0
[0.2.0]: https://github.com/test-st-petersburg/DocTemplates/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/test-st-petersburg/DocTemplates/releases/tag/0.1.0
