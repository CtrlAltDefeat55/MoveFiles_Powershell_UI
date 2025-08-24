# MoveFiles — Drag & Drop Copy/Move Utility (PowerShell)

A Windows GUI tool for copying **and** moving files with quality-of-life features like drag & drop, multi-select sources (files and/or folders), duplicate handling (ask/skip/overwrite), NTFS‑encrypted file handling, pause/resume/stop controls, and a live progress log. Built with **PowerShell** + **WinForms**.

> Core script: `MoveFilesScript_Upgrade.ps1` (WinForms UI). Optional launcher: `MoveFiles.bat`.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Usage](#usage)
- [Command-Line & Arguments](#command-line--arguments)
- [Notes & Limitations](#notes--limitations)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project provides a **friendly Windows UI** for bulk copying or moving files. You can drop in individual files or whole folders, pick a destination, and control how duplicates and **NTFS‑encrypted** files are handled. A progress bar and log keep you informed; you can **pause**, **resume**, or **stop** safely at any time.

The app does **not** modify files in place unless you choose **Move** mode; in **Copy** mode, sources remain untouched.

## Features

- **Multiple sources**: add files *and/or* folders
- **Drag & drop** onto source list and destination textbox
- **Responsive UI** (resizable window; anchored controls)
- **Duplicate handling**: ask / skip / overwrite
- **Encrypted file handling** (EFS): ask / skip / copy decrypted
- **Move mode**: delete source only after a successful copy
- **Pause / Resume / Stop** controls with confirmation on stop
- **Progress bar** and **detailed log** with per-file outcomes

## Screenshots

*(Optional: add screenshots to the `assets/` folder and reference them here.)*

## Installation

For quick-start instructions, see below. For a step‑by‑step guide (including ExecutionPolicy tips), read **[INSTALL.md](INSTALL.md)**.

### Quick Start (Windows 10/11)

1. Download or clone the repo.
2. Right‑click `MoveFilesScript_Upgrade.ps1` → **Run with PowerShell**  
   *OR* start it from a PowerShell prompt:

   ```powershell
   # From the repository folder
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\MoveFilesScript_Upgrade.ps1
   ```

3. (Optional) Use `MoveFiles.bat` to launch if you prefer double‑clicking in Explorer.

## Usage

1. **Add sources**: Click **Add Files…** or **Add Folder…**, or drag & drop files/folders into the Source list.
2. **Pick destination**: Click **Browse…** under Destination, or drag & drop a folder path onto the box.
3. **Choose behavior**:
   - **Duplicates**: Ask / Skip / Overwrite when the destination already has a file with the same name.
   - **Encrypted (EFS)**: Ask / Skip / **Copy decrypted**. (Decryption uses `cipher.exe` on a temporary copy.)
   - **Mode**: **Copy** (default) or **Move** (delete source after a successful copy).
4. Click **Start** to begin. Use **Pause/Resume** and **Stop** as needed. Watch the **Log** for results.

> **Safety**: In **Move** mode, a source file is deleted **only after** its copy completes successfully.

## Command-Line & Arguments

This tool is designed as a **GUI**; there are **no command‑line arguments** required or supported at this time. If you need a non‑interactive/CLI mode (e.g., for automation), please open an issue or PR.

## Notes & Limitations

- **Windows‑only**: Uses WinForms and `cipher.exe` (EFS), which are Windows features.
- **Permissions**: Copying protected locations may require elevated privileges.
- **Network paths**: UNC paths are supported if the account has access.
- **Very large folders**: First pass enumerates files; initial indexing may take time on huge trees.

## Dependencies

- **Runtime**: Windows 10/11 with **Windows PowerShell 5.1** or **PowerShell 7.x** (on Windows)
- **.NET**: WinForms (`System.Windows.Forms`) and `System.Drawing` (available on Windows)
- **External**: `cipher.exe` (built into Windows) for handling EFS files
- **Python requirements**: *None* (this is a PowerShell project)

If you use the provided `requirements.txt`, note it's intentionally minimal for this project.

## Contributing

We welcome improvements! See **[CONTRIBUTING.md](CONTRIBUTING.md)** for coding style, testing tips, and PR guidance.

## License

This project is provided as‑is; see repository license if present. If you plan to redistribute binaries, please clarify licensing in your fork.
