"use strict";

module.exports = {
  // Добавим описание на русском языке ко всем типам
  types: [
    {
      value: "build",
      name: "build: Сборка проекта или изменения внешних зависимостей"
    },
    { value: "ci", name: "ci: Настройка CI и работа со скриптами" },
    { value: "docs", name: "docs: Обновление документации" },
    { value: "feat", name: "feat: Добавление нового функционала" },
    { value: "update", name: "update: Обновление функционала" },
    { value: "fix", name: "fix: Исправление ошибок" },
    {
      value: "refactor",
      name: "refactor: Правки без исправления ошибок или добавления новых функций"
    },
    { value: "revert", name: "revert: Откат на предыдущие версии" },
    {
      value: "style",
      name: "style: Правки по стилю (отступы, точки, запятые и т.д.)"
    },
    { value: "test", name: "test: Добавление тестов" },
    { value: "WIP", name: "WIP: В процессе реализации..." },
    { value: "init", name: "init: Initial commit" }
  ],

  // Область. Она характеризует фрагмент кода, которую затронули изменения
  scopes: [
    { name: "ott" },
    { name: "build" },
    { name: "design" },
    { name: "git" },
    { name: "other" }
  ],

  // Возможность задать спец ОБЛАСТЬ для определенного типа типа изменения
  scopeOverrides: {
    build: [],
    ci: [],
    test: [
      { name: "ott" },
      { name: "build" },
    ],
    docs: [
      { name: "changelog" },
      { name: "readme" },
      { name: "ott" },
      { name: "build" },
      { name: "design" },
      { name: "git" },
      { name: "other" },
    ],
  },

  // Поменяем вопросы
  messages: {
    type: "Какие изменения вы вносите?",
    scope: "Выберите ОБЛАСТЬ, которую вы изменили (опционально):",
    // Спросим если allowCustomScopes в true
    customScope: "Укажите свою ОБЛАСТЬ:",
    subject: "Напишите КОРОТКОЕ описание в ПОВЕЛИТЕЛЬНОМ наклонении:\n",
    body:
      'Напишите ПОДРОБНОЕ описание (опционально). Используйте "|" для новой строки:\n',
    breaking: "Список BREAKING CHANGES (опционально):\n",
    footer:
      "Место для мета данных (билетов, ссылок и остального). Например: MRKT-700, #5:\n",
    confirmCommit: "Вас устраивает получившийся комментарий к изменению?"
  },

  // Разрешим собственную ОБЛАСТЬ
  allowCustomScopes: false,

  allowBreakingChanges: ["feat", "fix"],

  // Префикс для нижнего колонтитула
  // footerPrefix: "МЕТАДАННЫЕ:",

  // limit subject length
  subjectLimit: 72
};
