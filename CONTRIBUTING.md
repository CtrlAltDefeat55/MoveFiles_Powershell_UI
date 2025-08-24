# Contributing

Thanks for helping improve **MoveFiles — Drag & Drop Copy/Move Utility**! PRs and issues are welcome as time allows.

## Getting started (Windows)

1. Fork & clone the repo
2. Use Windows PowerShell 5.1 or PowerShell 7.x (on Windows)
3. Run the app with `.\MoveFilesScript_Upgrade.ps1` (see INSTALL.md for ExecutionPolicy notes)

## Project specifics

- **Runtime & UI**: PowerShell + WinForms (`System.Windows.Forms`, `System.Drawing`)
- **Encrypted files**: The app can copy EFS files by decrypting a **temp** copy with `cipher.exe`. If you modify this logic,
  please test both encrypted and non‑encrypted files.
- **Duplicate handling**: Keep the Ask / Skip / Overwrite semantics. New behavior should be opt‑in and clearly communicated in the UI/log.
- **Move mode safety**: Delete the **source** only after a successful copy. Never delete on failure or partial copy.
- **Logging**: User‑visible log should include the action taken (Copied / Moved / Skipped / Error) and the filename.

## Style

- Prefer small, focused changes. Keep UI text concise.
- Run a linter before sending a PR:
  ```powershell
  # Install once per machine (PowerShell Gallery)
  Install-Module PSScriptAnalyzer -Scope CurrentUser
  # Lint in repo root
  Invoke-ScriptAnalyzer -Path . -Recurse
  ```
- Use `Set-StrictMode -Version Latest` in new scripts/functions where feasible.
- Avoid hardcoded, user‑specific paths. Use `$env:TEMP`, `Join-Path`, and relative paths.

## Testing

Please test at least these scenarios on **Windows**:

- Copy from multiple source **files** to a folder
- Copy from source **folder(s)** (with subfolders) to a folder
- Duplicate file present at destination → Ask / Skip / Overwrite
- Encrypted (EFS) source file → Ask / Skip / Copy decrypted
- Move mode → source must be deleted **only** after a successful copy
- Pause / Resume / Stop paths

If adding non‑trivial features, include a short **Test Plan** in your PR description.

## Commit messages

Use clear, descriptive messages (e.g., `ui: add drag-drop to destination box`, `copy: fix EFS detection`).

## Docs

If you change behavior that users will notice (e.g., duplicate handling, EFS support, Move mode), update **README.md** and **INSTALL.md**.
