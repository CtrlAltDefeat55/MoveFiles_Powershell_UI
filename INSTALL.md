# Install & Run — Windows (MoveFiles)

These steps set up **MoveFiles — Drag & Drop Copy/Move Utility** on **Windows 10/11**.

> The app is a **PowerShell WinForms GUI** for copying/moving files. It does not install services or drivers.

## 1) Get the code

- **ZIP:** Download the repo ZIP from GitHub → extract
- **Git:**

```powershell
git clone https://github.com/<you>/movefiles-ui.git
cd movefiles-ui
```

## 2) (Recommended) Unblock the scripts if Windows has marked them as downloaded

```powershell
# From the repo folder
Get-ChildItem -Recurse -File *.ps1,*.bat | Unblock-File
```

## 3) (If needed) Allow scripts for this PowerShell session

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

> This does **not** change your machine‑wide policy; it only applies to the current PowerShell window.

## 4) Run the app

- **Option A:** Right‑click `MoveFilesScript_Upgrade.ps1` → **Run with PowerShell**
- **Option B (terminal):**

```powershell
# From the repo folder
.\MoveFilesScript_Upgrade.ps1
```

- **Option C (Explorer double‑click):** Use `MoveFiles.bat` to launch PowerShell and run the script from the repo folder.

## 5) Troubleshooting

- **Blocked by policy** → ensure you ran the `Set-ExecutionPolicy` command above *in the same window* you’re launching from.
- **No UI appears** → confirm you’re on **Windows** (WinForms is Windows‑only) and using Windows PowerShell 5.1 or PowerShell 7+ *on Windows*.
- **Encrypted (EFS) files** → The app uses `cipher.exe` to decrypt a **temporary copy** before copying. Your account must be able to decrypt the file.
- **Permissions** → If copying between protected folders, start an **elevated** PowerShell session.
