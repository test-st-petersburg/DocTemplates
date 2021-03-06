module.exports = {
  rules: {
    // https://commitlint.js.org/#/reference-rules

    "body-leading-blank": [2, "always"],
    "body-max-line-length": [2, "always", 72],
    "footer-leading-blank": [2, "always"],
    "footer-max-line-length": [2, "always", 72],
    "header-max-length": [2, "always", 72],
    "header-case": [2, "never", "sentence-case"],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "type-enum": [2, "always", [
      "feat",
      "update",
      "fix",
      "chore",
      "docs",
      "style",
      "refactor",
      "perf",
      "ci",
      "test",
      "revert",
      "WIP",
      "init"
    ]],
    "scope-case": [2, "always", "lower-case"],
    "scope-enum": [1, "always", [
      "ott",
      "odt",
      "design",
      "vscode",
      "git",
      "github",
      "github-actions",
      "other",
      "changelog",
      "readme"
    ]],
    "subject-case": [1, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."]
  }
};
