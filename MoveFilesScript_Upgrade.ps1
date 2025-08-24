#########################################################################
# Copy-With-UI-Enhanced.ps1  –  PowerShell WinForms                     #
# -------------------------------------------------------------------- #
# A UI tool for copying files with advanced features.                  #
#                                                                      #
# Improvements:                                                        #
# • Source: ListBox for multiple files AND/OR folders.                 #
# • Drag-and-drop support for multiple items.                          #
# • Resizable UI with anchored controls for a responsive layout.       #
# • Dedicated buttons for adding/removing source items.                #
# • Handles duplicate names and NTFS-encrypted files.                  #
# • Pause / Resume and Stop (with confirmation).                       #
# • Live progress bar + detailed log.                                  #
# • Option to move files (delete source after successful copy).        #
#########################################################################

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# ---------------------- 1. GLOBAL STATE ------------------------------
$isPaused  = $false
$isStopped = $false

# ---------------------- 2. BUILD UI ----------------------------------
$form               = New-Object System.Windows.Forms.Form
$form.Text          = 'Enhanced Copy/Move Utility'
$form.Size          = New-Object System.Drawing.Size(800, 720) # Height is fine, no change needed
$form.StartPosition = 'CenterScreen'
$form.MinimumSize   = New-Object System.Drawing.Size(640, 580)
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox   = $true

# --- UI Element Definitions ---

# Informational note
$lblInfo            = New-Object System.Windows.Forms.Label
$lblInfo.Text       = 'All selected source files and folder contents will be copied into the destination folder.'
$lblInfo.Location   = '10,10'
$lblInfo.AutoSize   = $true
$lblInfo.ForeColor  = [System.Drawing.Color]::DarkBlue
$lblInfo.Anchor     = 'Top, Left'

# Source controls (Now a ListBox)
$lblSrc             = New-Object System.Windows.Forms.Label
$lblSrc.Text        = 'Source Files & Folders:'
$lblSrc.Location    = '10,35'
$lblSrc.AutoSize    = $true
$lblSrc.Anchor      = 'Top, Left'

$lstSrc             = New-Object System.Windows.Forms.ListBox
$lstSrc.Location    = '10,55'
$lstSrc.Size        = '640,120'
$lstSrc.AllowDrop   = $true
$lstSrc.SelectionMode = 'MultiExtended'
$lstSrc.Anchor      = 'Top, Left, Right'

$btnAddFiles        = New-Object System.Windows.Forms.Button -Property @{Text = 'Add Files...'; Location = '660,55'; Size = '120,25'; Anchor = 'Top, Right'}
$btnAddFolder       = New-Object System.Windows.Forms.Button -Property @{Text = 'Add Folder...'; Location = '660,85'; Size = '120,25'; Anchor = 'Top, Right'}
$btnRemoveSrc       = New-Object System.Windows.Forms.Button -Property @{Text = 'Remove Selected'; Location = '660,115'; Size = '120,25'; Anchor = 'Top, Right'}
$btnClearSrc        = New-Object System.Windows.Forms.Button -Property @{Text = 'Clear All'; Location = '660,145'; Size = '120,25'; Anchor = 'Top, Right'}

# Destination controls
$lblDst             = New-Object System.Windows.Forms.Label -Property @{Text = 'Destination Folder:'; Location = '10,190'; AutoSize = $true; Anchor = 'Top, Left'}
$txtDst             = New-Object System.Windows.Forms.TextBox -Property @{Location = '140,187'; Width = 510; AllowDrop = $true; Anchor = 'Top, Left, Right'}
$btnDst             = New-Object System.Windows.Forms.Button -Property @{Text = 'Browse...'; Location = '660,185'; Size = '120,25'; Anchor = 'Top, Right'}

# --- NEW: Move files option ---
$chkMoveFiles       = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = 'Move files (delete source files after successful copy)';
    Location = '140,220'; # Aligned with the TextBox for a cleaner look
    AutoSize = $true;
    Anchor   = 'Top, Left'
}

# Option GroupBoxes (shifted down by 35px)
$grpDup             = New-Object System.Windows.Forms.GroupBox -Property @{Text = 'If destination already has the file'; Location = '10,260'; Size = '370,120'; Anchor = 'Top, Left, Right'}
$rDupAsk            = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Ask each time'; Location = '10,30'; AutoSize = $true}
$rDupSkip           = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Skip all (default)'; Location = '10,60'; Checked = $true; AutoSize = $true}
$rDupOver           = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Overwrite all'; Location = '180,30'; AutoSize = $true}
$grpDup.Controls.AddRange(@($rDupAsk, $rDupSkip, $rDupOver))

$grpEnc             = New-Object System.Windows.Forms.GroupBox -Property @{Text = 'When source file is NTFS-encrypted'; Location = '400,260'; Size = '380,120'; Anchor = 'Top, Right'}
$rEncAsk            = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Ask each time'; Location = '10,30'; AutoSize = $true}
$rEncCopy           = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Copy without encryption (default)'; Location = '10,60'; Checked = $true; Width = 350}
$rEncSkip           = New-Object System.Windows.Forms.RadioButton -Property @{Text = 'Skip encrypted files'; Location = '10,90'; AutoSize = $true}
$grpEnc.Controls.AddRange(@($rEncAsk, $rEncCopy, $rEncSkip))

# Buttons (centered in a panel for better resizing, shifted down by 35px)
$pnlButtons         = New-Object System.Windows.Forms.Panel -Property @{Location = '10,395'; Size = '770,30'; Anchor = 'Top, Left, Right'}
$btnStart           = New-Object System.Windows.Forms.Button -Property @{Text = 'Start'; Size = '90,25'; Enabled = $false; Anchor = 'Top'}
$btnPause           = New-Object System.Windows.Forms.Button -Property @{Text = 'Pause'; Size = '90,25'; Enabled = $false; Anchor = 'Top'}
$btnStop            = New-Object System.Windows.Forms.Button -Property @{Text = 'Stop'; Size = '90,25'; Enabled = $false; Anchor = 'Top'}

$btnStart.Location  = New-Object System.Drawing.Point(($pnlButtons.Width / 2 - 150), 0)
$btnPause.Location  = New-Object System.Drawing.Point(($pnlButtons.Width / 2 - 45), 0)
$btnStop.Location   = New-Object System.Drawing.Point(($pnlButtons.Width / 2 + 60), 0)
$pnlButtons.Controls.AddRange(@($btnStart, $btnPause, $btnStop))

# Progress & log (shifted down by 35px)
$prgBar             = New-Object System.Windows.Forms.ProgressBar -Property @{Location = '10,435'; Size = '770,26'; Anchor = 'Top, Left, Right'}
$txtLog             = New-Object System.Windows.Forms.TextBox -Property @{Location = '10,470'; Size = '770,200'; Multiline = $true; ScrollBars = 'Vertical'; ReadOnly = $true; Anchor = 'Top, Bottom, Left, Right'}

# Add controls to form
$form.Controls.AddRange(@(
    $lblInfo, $lblSrc, $lstSrc, $btnAddFiles, $btnAddFolder, $btnRemoveSrc, $btnClearSrc,
    $lblDst, $txtDst, $btnDst,
    $chkMoveFiles, # Added the new checkbox
    $grpDup, $grpEnc,
    $pnlButtons,
    $prgBar, $txtLog
))

# ---------------------- 3. EVENT HANDLERS & HELPERS ----------------------------------

function Log($message) {
    if ($txtLog.InvokeRequired) {
        $txtLog.Invoke([Action[string]]$Log, $message)
    } else {
        $txtLog.AppendText("$(Get-Date -Format 'HH:mm:ss') - $message`r`n")
        $txtLog.ScrollToCaret()
    }
}

function Update-UIState {
    $destPathIsValid = (-not [string]::IsNullOrEmpty($txtDst.Text)) -and (Test-Path $txtDst.Text -PathType Container)
    $btnStart.Enabled = ($lstSrc.Items.Count -gt 0) -and $destPathIsValid

    $btnRemoveSrc.Enabled = ($lstSrc.SelectedItems.Count -gt 0)
    $btnClearSrc.Enabled = ($lstSrc.Items.Count -gt 0)
}

# --- Source ListBox Event Handlers ---
$lstSrc.Add_DragEnter({ param($sender, $e)
    if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) { $e.Effect = 'Copy' }
})

$lstSrc.Add_DragDrop({ param($sender, $e)
    $paths = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    $addedCount = 0
    foreach ($path in $paths) {
        if ((Test-Path $path) -and ($lstSrc.Items -notcontains $path)) {
            $lstSrc.Items.Add($path) | Out-Null
            $addedCount++
        }
    }
    Log "Added $addedCount item(s) via drag-and-drop."
    Update-UIState
})

$btnAddFiles.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog -Property @{Title = "Select Files to Add"; Multiselect = $true}
    if ($dlg.ShowDialog() -eq 'OK') {
        $addedCount = 0
        foreach ($file in $dlg.FileNames) {
            if ($lstSrc.Items -notcontains $file) { $lstSrc.Items.Add($file) | Out-Null; $addedCount++ }
        }
        Log "Added $addedCount file(s)."
        Update-UIState
    }
})

$btnAddFolder.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{Description = "Select a Folder to Add"}
    if ($dlg.ShowDialog() -eq 'OK') {
        if ($lstSrc.Items -notcontains $dlg.SelectedPath) {
            $lstSrc.Items.Add($dlg.SelectedPath) | Out-Null
            Log "Added folder: $($dlg.SelectedPath)"
        }
        Update-UIState
    }
})

$btnRemoveSrc.Add_Click({
    foreach ($item in $lstSrc.SelectedItems | Select-Object -Last ($lstSrc.SelectedItems.Count)) { $lstSrc.Items.Remove($item) }
    Log "Removed selected items."
    Update-UIState
})

$btnClearSrc.Add_Click({
    $lstSrc.Items.Clear()
    Log "Cleared all source items."
    Update-UIState
})

# --- Destination TextBox Event Handlers ---
$txtDst.Add_DragEnter({ param($s, $e)
    if ($e.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) { $e.Effect = 'Copy' }
})

$txtDst.Add_DragDrop({ param($s, $e)
    $path = $e.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)[0]
    if (Test-Path $path -PathType Container) {
        $s.Text = $path
        Log "Set destination: $path"
    } else {
        Log "Drag-drop failed: Destination must be a folder."
    }
})

$btnDst.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq 'OK') { $txtDst.Text = $dlg.SelectedPath; Log "Picked destination: $($dlg.SelectedPath)" }
})

# --- Other UI Events ---
$lstSrc.Add_SelectedIndexChanged({ Update-UIState })
$txtDst.Add_TextChanged({ Update-UIState })

$pnlButtons.Add_Resize({
    $pnl = $pnlButtons
    $btnStart.Left  = ($pnl.Width / 2) - 150
    $btnPause.Left  = ($pnl.Width / 2) - 45
    $btnStop.Left   = ($pnl.Width / 2) + 60
})

# ---------------------- 4. CORE LOGIC --------------------------------

function Get-SourceFiles($sourcePaths) {
    $allFiles = New-Object System.Collections.ArrayList
    $sourcePaths | ForEach-Object {
        $path = $_
        if (-not (Test-Path $path)) {
            Log "Warning: Source path not found, skipping: $path"
            return # continue to next item in ForEach-Object
        }
        if (Test-Path $path -PathType Leaf) { $allFiles.Add((Get-Item $path)) | Out-Null }
        elseif (Test-Path $path -PathType Container) {
            Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $allFiles.Add($_) | Out-Null }
        }
    }
    return $allFiles
}

function Copy-DecryptedFile($sourceItem, $destinationPath, $tempDir) {
    $tempFile = Join-Path $tempDir ([guid]::NewGuid().Guid + $sourceItem.Extension)
    Copy-Item $sourceItem.FullName -Destination $tempFile -Force
    & cipher.exe /d $tempFile | Out-Null
    Copy-Item $tempFile -Destination $destinationPath -Force
}

$btnStart.Add_Click({
    # Disable controls
    $btnStart.Enabled = $false; $btnPause.Enabled = $true; $btnStop.Enabled = $true; $btnPause.Text = 'Pause'
    $form.Controls | Where-Object { $_ -isnot [System.Windows.Forms.Button] -and $_ -isnot [System.Windows.Forms.Panel] } | ForEach-Object { $_.Enabled = $false }
    $pnlButtons.Controls | Where-Object { $_.Name -ne $btnPause.Name -and $_.Name -ne $btnStop.Name } | ForEach-Object { $_.Enabled = $false }
    $isPaused = $false; $isStopped = $false
    $txtLog.Clear(); Log '--- Operation started ---'

    # --- NEW: Get move files option ---
    $moveFiles = $chkMoveFiles.Checked
    if ($moveFiles) {
        Log "Mode: Move (source files will be deleted after copy)."
    } else {
        Log "Mode: Copy."
    }

    $files = Get-SourceFiles $lstSrc.Items
    if ($files.Count -eq 0) {
        [Windows.Forms.MessageBox]::Show('No valid source files found to copy.', 'Information', 'OK', 'Information')
        Log '--- Operation finished: No files to copy. ---'
    } else {
        $tmpDir = Join-Path $env:TEMP ('CopyUI_' + ([guid]::NewGuid()).Guid)
        New-Item $tmpDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

        $dupAsk = $rDupAsk.Checked; $dupSkip = $rDupSkip.Checked; $dupOver = $rDupOver.Checked
        $encAsk = $rEncAsk.Checked; $encCopy = $rEncCopy.Checked; $encSkip = $rEncSkip.Checked

        $prgBar.Maximum = $files.Count; $prgBar.Value = 0
        $idx = 0; $ok = 0; $err = 0; $skipped = 0; $start = Get-Date

        foreach ($f in $files) {
            [Windows.Forms.Application]::DoEvents()
            if ($isStopped) { Log 'Stopped by user.'; break }
            while ($isPaused) { Start-Sleep -Milliseconds 200; [Windows.Forms.Application]::DoEvents(); if ($isStopped) { break } }
            if ($isStopped) { break }

            $idx++; $prgBar.Value = $idx
            $dest = Join-Path $txtDst.Text $f.Name
            $isEnc = ($f.Attributes -band [IO.FileAttributes]::Encrypted)

            try {
                if ($isEnc) {
                    if ($encSkip) { Log "Skipped (encrypted): $($f.Name)"; $skipped++; continue }
                    $ansE = 'No' # Default
                    if ($encAsk) {
                        $ansE = [Windows.Forms.MessageBox]::Show("Source file '$($f.Name)' is encrypted.`n`nCopy it without encryption?", 'Encrypted File Found', 'YesNo', 'Question')
                        if ($ansE -eq 'No') { Log "Skipped (encrypted by user choice): $($f.Name)"; $skipped++; continue }
                    }
                }
                if (Test-Path $dest) {
                    if ($dupSkip) { Log "Skipped (duplicate): $($f.Name)"; $skipped++; continue }
                    $ansD = 'No' # Default
                    if ($dupAsk) {
                        $ansD = [Windows.Forms.MessageBox]::Show("Destination file '$($f.Name)' already exists.`n`nOverwrite it?", 'Duplicate File Found', 'YesNo', 'Exclamation')
                        if ($ansD -eq 'No') { Log "Skipped (duplicate by user choice): $($f.Name)"; $skipped++; continue }
                    }
                }
                
                Log "Copying: $($f.FullName) -> $dest"
                if ($isEnc -and ($encCopy -or ($encAsk -and $ansE -eq 'Yes'))) {
                    Copy-DecryptedFile $f $dest $tmpDir
                } else {
                    Copy-Item $f.FullName -Destination $dest -Force
                }

                # --- NEW: Delete source file if move is enabled ---
                if ($moveFiles) {
                    try {
                        Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                        Log "Moved (deleted source): $($f.FullName)"
                    }
                    catch {
                        # Log the deletion error, but don't count it as a primary copy error ($err)
                        Log "ERROR Deleting Source $($f.Name): $($_.Exception.Message)"
                    }
                }
                
                $ok++
            } catch {
                $err++; Log "ERROR Copying $($f.Name): $($_.Exception.Message)"
            }
        }
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
        $dur = (Get-Date) - $start
        Log '----------------------------------------------'
        Log "Operation Finished."
        Log "Copied/Moved: $ok | Skipped: $skipped | Errors: $err"
        Log ("Elapsed Time: {0:D2}:{1:D2}:{2:D2}" -f $dur.Hours, $dur.Minutes, $dur.Seconds)
    }

    # Re-enable controls
    $pnlButtons.Controls | ForEach-Object { $_.Enabled = $true }
    $form.Controls | Where-Object { $_ -isnot [System.Windows.Forms.Panel] } | ForEach-Object { $_.Enabled = $true }
    $btnPause.Enabled = $false; $btnStop.Enabled = $false
    Update-UIState
})

$btnPause.Add_Click({
    if (-not $isPaused) { $isPaused = $true; $btnPause.Text = 'Resume'; Log '--- Paused ---' }
    else { $isPaused = $false; $btnPause.Text = 'Pause';  Log '--- Resumed ---' }
})

$btnStop.Add_Click({
    if ([Windows.Forms.MessageBox]::Show('Are you sure you want to stop the current operation?', 'Confirm Stop', 'YesNo', 'Warning') -eq 'Yes') {
        $isStopped = $true
    }
})

$form.Add_Load({ Update-UIState })

# ---------------------- 5. SHOW FORM -------------------------------
[void]$form.ShowDialog()
$form.Dispose()