# Libre Office шаблоны документов

[![GitHub release](https://img.shields.io/github/v/release/test-st-petersburg/DocTemplates?sort=semver&style=plastic)](https://github.com/test-st-petersburg/DocTemplates/releases)

Данный проект - Шаблоны внутренних и исходящих документов учреждения.

## Документация

Описание решений по данному проекту расширения формируется с помощью сервиса [ReadTheDocs][].

[![Documentation Status](https://readthedocs.org/projects/doctemplates/badge/?version=master&style=plastic)](https://doctemplates.readthedocs.io/ru/master/?badge=master)

Исходные файлы документации размещены в репозитории в каталоге
[docs](/docs).

Подготовленная документация доступна в сети:
[https://doctemplates.readthedocs.io](https://doctemplates.readthedocs.io).

## Подготовка среды

Для внесения изменений в пакет и повторной сборки проекта потребуются следующие продукты:

Под Windows:

- текстовый редактор, настоятельно рекомендую [VSCode][]
- [LibreOffice][]
- [7Zip4Powershell][]
- [Saxon HE][]

Под Linux:

- [PowerShellCore][]
- [VSCode][]
- [LibreOffice][]
- [7Zip4Powershell][]
- [Saxon HE][]

Для [VSCode][] рекомендую установить расширения, указанные в рабочей области.

Существенно удобнее будет работать с репозиторием, имея установленный `git`.

Далее следует скопировать репозиторий проекта либо как zip архив из [последнего
релиза](https://github.com/test-st-petersburg/DocTemplates), либо клонировав
git репозиторий.
Последнее - предпочтительнее.

Для подготовки среды (установки необходимых приложений)
следует воспользоваться сценарием `prepare.ps1` (запускать от имени администратора):

    install\prepare.ps1

Указанный сценарий установит все необходимые компоненты.

## Сборка шаблонов

Как известно, файлы Open Document представляют из себя zip архив,
в котором размещены XML файлы и бинарные файлы изображений и прочих вложений.
В репозитории файлы шаблонов документов хранятся в виде каталогов с XML и
бинарными файлами (см. [/src/template](/src/template)).
Описание схемы xml файлов, входящих в состав документа: [OASIS][].

Распаковка, форматирование, оптимизация XML файлов осуществляется
с помощью инструментария, размещённого в репозитории.
Через задачи в среде Visual Studio Code.

- **Clean**:
  очистка каталогов с "исходными"
  XML и бинарными файлами ([/src/template](/src/template)).

- Convert Open Office files to plain XML:
  преобразование файлов шаблонов документов в каталоги "исходных"
  (XML и бинарных) файлов.

- Optimize Open Office XML files:
  оптимизация XML файлов документов.
  При этом инструменты оптимизации удаляют ряд атрибутов в стилях,
  сортируют отдельные элементы в целях минимизации количества изменений
  при сохранении документа.
  Кроме того, выполняется ряд дополнительных оптимизаций
  (удаляются автоматические стили символов и прочее).

- Unpack and optimize Open Office XML files:
  преобразование файлов шаблонов документов в каталоги "исходных"
  (XML и бинарных) файлов с оптимизацией
  (комбинация двух приведённых выше задач).

- **Unpack and optimize modified Open Office XML files**:
  преобразование только изменённых файлов шаблонов документов
  в каталоги "исходных" (XML и бинарных) файлов с оптимизацией.
  Изменёнными считаются файлы, время изменения которых более позднее,
  чем время изменения файла манифеста в каталоге документа.

- **Create Open Office files from plain XML**:
  создание .ott файлов шаблонов документов из каталогов
  с XML и бинарными файлами.

- **Create Open Office files from plain XML and open**:
  обновление .ott файлов шаблонов документов из каталогов
  с XML и бинарными файлами и открытие их ассоциированным
  приложением (только для Windows).
  Обновляются и открываются только изменённые шаблоны.
  Данная задача является задачей сборки по умолчанию
  и может быть выполнена в Visual Studio Code через Ctrl+Shift+B.

## Внесение изменений

Репозиторий проекта размещён по адресу
[github.com/test-st-petersburg/DocTemplates](https://github.com/test-st-petersburg/DocTemplates).
Стратегия ветвления - Git Flow.

При необходимости внесения изменений в сам проект предложите Pull Request в основной
репозиторий в ветку `develop`.

[VSCode]: https://code.visualstudio.com/ "Visual Studio Code"
[PowerShellCore]: https://github.com/PowerShell/PowerShell "PowerShell Core"
[LibreOffice]: https://ru.libreoffice.org "Libre Office"
[7Zip4Powershell]: https://github.com/thoemmi/7Zip4Powershell
[Saxon HE]: https://saxonica.com/products/products.xml "Saxon Home Edition"
[ReadTheDocs]: https://readthedocs.org
[OASIS]: https://docs.oasis-open.org/office/OpenDocument/v1.3/cs01/part3-schema/OpenDocument-v1.3-cs01-part3-schema.html "Open Document Format for Office Applications (OpenDocument) Version 1.3. Part 3: OpenDocument Schema"
