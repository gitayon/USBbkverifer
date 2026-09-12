# ============================================================
# USB BACKUP VERIFIER - GUI VERSION
# ============================================================
# ##Features:
#
# - GUI folder selection
# - Add multiple Source/USB pairs
# - Remove selected pair
# - SHA-256 file comparison
# - MISSING file detection
# - DIFFERENT file detection
# - EXTRA file detection
# - ERROR detection
# - Progress bar
# - Live verification log
# - CSV report
# - Final verification result
#
# ============================================================


# ============================================================
# LOAD WINDOWS FORMS
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()


# ============================================================
# GLOBAL VARIABLES                                         = =
# ============================================================

$pairs = New-Object System.Collections.ArrayList

$results = New-Object System.Collections.ArrayList

$totalFiles = 0
$missingFiles = 0
$differentFiles = 0
$extraFiles = 0
$errorFiles = 0


# ============================================================
# MAIN WINDOW
# ============================================================

$form = New-Object System.Windows.Forms.Form

$form.Text = "USB Backup Verifier"
$form.Size = New-Object System.Drawing.Size(1000, 720)
$form.MinimumSize = New-Object System.Drawing.Size(900, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.MaximizeBox = $true
$form.MinimizeBox = $true
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi


$form.BackColor = [System.Drawing.Color]::White


# ============================================================
# TITLE
# ============================================================

$titleLabel = New-Object System.Windows.Forms.Label

$titleLabel.Text = "USB BACKUP VERIFIER"
$titleLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    18,
    [System.Drawing.FontStyle]::Bold
)

$titleLabel.ForeColor = [System.Drawing.Color]::DarkCyan

$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(25, 20)

$form.Controls.Add($titleLabel)


# ============================================================
# DESCRIPTION
# ============================================================

$descriptionLabel = New-Object System.Windows.Forms.Label

$descriptionLabel.Text = `
    "Add one or more Original → USB Backup folder pairs, then start verification.`n" +
    "Files are compared using SHA-256."

$descriptionLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    10
)

$descriptionLabel.AutoSize = $true
$descriptionLabel.Location = New-Object System.Drawing.Point(28, 60)

$form.Controls.Add($descriptionLabel)


# ============================================================
# PAIR LIST
# ============================================================

$pairLabel = New-Object System.Windows.Forms.Label

$pairLabel.Text = "Folder Pairs"

$pairLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    11,
    [System.Drawing.FontStyle]::Bold
)

$pairLabel.AutoSize = $true
$pairLabel.Location = New-Object System.Drawing.Point(25, 105)

$form.Controls.Add($pairLabel)


$listView = New-Object System.Windows.Forms.ListView

$listView.Location = New-Object System.Drawing.Point(25, 135)
$listView.Size = New-Object System.Drawing.Size(930, 180)

$listView.View = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.HideSelection = $false

[void]$listView.Columns.Add(
    "No.",
    50
)

[void]$listView.Columns.Add(
    "Original / Source Folder",
    410
)

[void]$listView.Columns.Add(
    "USB / Backup Folder",
    410
)

$form.Controls.Add($listView)


# ============================================================
# ADD PAIR BUTTON
# ============================================================

$addButton = New-Object System.Windows.Forms.Button

$addButton.Text = "Add Pair"
$addButton.Size = New-Object System.Drawing.Size(130, 38)
$addButton.Location = New-Object System.Drawing.Point(25, 330)

$addButton.BackColor = [System.Drawing.Color]::LightGreen

$form.Controls.Add($addButton)


# ============================================================
# REMOVE PAIR BUTTON
# ============================================================

$removeButton = New-Object System.Windows.Forms.Button

$removeButton.Text = "Remove Pair"
$removeButton.Size = New-Object System.Drawing.Size(130, 38)
$removeButton.Location = New-Object System.Drawing.Point(165, 330)

$removeButton.BackColor = [System.Drawing.Color]::MistyRose

$form.Controls.Add($removeButton)


# ============================================================
# CLEAR PAIRS BUTTON
# ============================================================

$clearButton = New-Object System.Windows.Forms.Button

$clearButton.Text = "Clear All"
$clearButton.Size = New-Object System.Drawing.Size(130, 38)
$clearButton.Location = New-Object System.Drawing.Point(305, 330)

$form.Controls.Add($clearButton)


# ============================================================
# START VERIFICATION BUTTON
# ============================================================

$startButton = New-Object System.Windows.Forms.Button

$startButton.Text = "Start Verification"
$startButton.Size = New-Object System.Drawing.Size(180, 45)

$startButton.Location = New-Object System.Drawing.Point(775, 325)

$startButton.BackColor = [System.Drawing.Color]::LightSkyBlue

$startButton.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    10,
    [System.Drawing.FontStyle]::Bold
)

$form.Controls.Add($startButton)


# ============================================================
# PROGRESS BAR
# ============================================================

$progressBar = New-Object System.Windows.Forms.ProgressBar

$progressBar.Location = New-Object System.Drawing.Point(25, 385)
$progressBar.Size = New-Object System.Drawing.Size(930, 25)

$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0

$form.Controls.Add($progressBar)


# ============================================================
# STATUS LABEL
# ============================================================

$statusLabel = New-Object System.Windows.Forms.Label

$statusLabel.Text = "Ready."

$statusLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    10,
    [System.Drawing.FontStyle]::Bold
)

$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(25, 420)

$form.Controls.Add($statusLabel)


# ============================================================
# LOG LABEL
# ============================================================

$logLabel = New-Object System.Windows.Forms.Label

$logLabel.Text = "Verification Log"

$logLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    11,
    [System.Drawing.FontStyle]::Bold
)

$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(25, 450)

$form.Controls.Add($logLabel)


# ============================================================
# LOG BOX
# ============================================================

$logBox = New-Object System.Windows.Forms.RichTextBox

$logBox.Location = New-Object System.Drawing.Point(25, 480)
$logBox.Size = New-Object System.Drawing.Size(930, 130)

$logBox.ReadOnly = $true
$logBox.BackColor = [System.Drawing.Color]::Black
$logBox.ForeColor = [System.Drawing.Color]::White

$logBox.Font = New-Object System.Drawing.Font(
    "Consolas",
    9
)

$form.Controls.Add($logBox)


# ============================================================
# HELPER FUNCTION - ADD LOG MESSAGE
# ============================================================

function Add-Log {

    param(
        [string]$Message,
        [System.Drawing.Color]$Color = [System.Drawing.Color]::White
    )

    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0

    $logBox.SelectionColor = $Color

    $logBox.AppendText($Message + [Environment]::NewLine)

    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()

    [System.Windows.Forms.Application]::DoEvents()
}


# ============================================================
# HELPER FUNCTION - UPDATE STATUS
# ============================================================

function Update-Status {

    param(
        [string]$Message
    )

    $statusLabel.Text = $Message

    [System.Windows.Forms.Application]::DoEvents()
}


# ============================================================
# FOLDER PICKER FUNCTION
# ============================================================

function Select-Folder {

    param(
        [string]$Description
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog

    $dialog.Description = $Description
    $dialog.ShowNewFolderButton = $false

    $result = $dialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {

        return $dialog.SelectedPath
    }

    return $null
}


# ============================================================
# REFRESH PAIR LIST
# ============================================================

function Update-PairList {

    $listView.Items.Clear()

    $number = 1

    foreach ($pair in $pairs) {

        $item = New-Object System.Windows.Forms.ListViewItem(
            $number.ToString()
        )

        [void]$item.SubItems.Add($pair.Source)
        [void]$item.SubItems.Add($pair.Backup)

        [void]$listView.Items.Add($item)

        $number++
    }
}


# ============================================================
# ADD PAIR
# ============================================================

$addButton.Add_Click({

    # --------------------------------------------------------
    # Select original folder
    # --------------------------------------------------------

    $sourceFolder = Select-Folder `
        "Select the ORIGINAL / SOURCE folder"

    if ([string]::IsNullOrWhiteSpace($sourceFolder)) {
        return
    }


    # --------------------------------------------------------
    # Select USB backup folder
    # --------------------------------------------------------

    $backupFolder = Select-Folder `
        "Select the USB / BACKUP folder"

    if ([string]::IsNullOrWhiteSpace($backupFolder)) {
        return
    }


    # --------------------------------------------------------
    # Be sure Source and backup aren't the same
    # --------------------------------------------------------

    if (
        $sourceFolder.TrimEnd('\') -ieq
        $backupFolder.TrimEnd('\')
    ) {

        [System.Windows.Forms.MessageBox]::Show(
            "The Original and USB folders cannot be the same folder.",
            "Invalid Pair",
            "OK",
            "Warning"
        )

        return
    }


    # --------------------------------------------------------
    # Add pair
    # --------------------------------------------------------

    $pair = @{
        Source = $sourceFolder
        Backup = $backupFolder
    }

    [void]$pairs.Add($pair)

    Update-PairList

    Update-Status "Pair added."

})


# ============================================================
# REMOVE SELECTED PAIR
# ============================================================

$removeButton.Add_Click({

    if ($listView.SelectedItems.Count -eq 0) {

        [System.Windows.Forms.MessageBox]::Show(
            "Please select a pair to remove.",
            "No Pair Selected",
            "OK",
            "Information"
        )

        return
    }


    $index = $listView.SelectedItems[0].Index

    $pairs.RemoveAt($index)

    Update-PairList

    Update-Status "Pair removed."
})


# ============================================================
# CLEAR ALL PAIRS
# ============================================================

$clearButton.Add_Click({

    if ($pairs.Count -eq 0) {
        return
    }


    $answer = [System.Windows.Forms.MessageBox]::Show(
        "Remove all folder pairs?",
        "Clear All",
        "YesNo",
        "Question"
    )


    if (
        $answer -eq
        [System.Windows.Forms.DialogResult]::Yes
    ) {

        $pairs.Clear()

        Update-PairList

        Update-Status "All pairs removed."
    }
})


# ============================================================
# START VERIFICATION
# ============================================================

$startButton.Add_Click({

    # --------------------------------------------------------
    # Make sure at least one pair exists
    # --------------------------------------------------------

    if ($pairs.Count -eq 0) {

        [System.Windows.Forms.MessageBox]::Show(
            "Please add at least one folder pair first.",
            "No Folder Pairs",
            "OK",
            "Warning"
        )

        return
    }


    # --------------------------------------------------------
    # Disable controls during verification
    # --------------------------------------------------------

    $addButton.Enabled = $false
    $removeButton.Enabled = $false
    $clearButton.Enabled = $false
    $startButton.Enabled = $false


    # --------------------------------------------------------
    # Reset counters
    # --------------------------------------------------------

    $results.Clear()

    $totalFiles = 0
    $missingFiles = 0
    $differentFiles = 0
    $extraFiles = 0
    $errorFiles = 0

    $logBox.Clear()

    $progressBar.Value = 0


    # ========================================================
    # COUNT TOTAL SOURCE FILES
    # ========================================================

    Add-Log ""
    Add-Log "========================================" `
        ([System.Drawing.Color]::Cyan)

    Add-Log "         USB BACKUP VERIFIER" `
        ([System.Drawing.Color]::Cyan)

    Add-Log "========================================" `
        ([System.Drawing.Color]::Cyan)

    Add-Log ""


    $validPairs = @()


    foreach ($pair in $pairs) {

        if (!(Test-Path -LiteralPath $pair.Source)) {

            Add-Log `
                "[ERROR] Original folder not found: $($pair.Source)" `
                ([System.Drawing.Color]::Red)

            $errorFiles++

            continue
        }


        if (!(Test-Path -LiteralPath $pair.Backup)) {

            Add-Log `
                "[ERROR] USB folder not found: $($pair.Backup)" `
                ([System.Drawing.Color]::Red)

            $errorFiles++

            continue
        }


        $validPairs += $pair


        $sourceFiles = Get-ChildItem `
            -LiteralPath $pair.Source `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue


        $totalFiles += $sourceFiles.Count
    }


    # --------------------------------------------------------
    # If no valid pairs exist
    # --------------------------------------------------------

    if ($validPairs.Count -eq 0) {

        Add-Log ""
        Add-Log "No valid folder pairs could be checked." `
            ([System.Drawing.Color]::Red)

        $statusLabel.Text = "Verification failed."

        $startButton.Enabled = $true
        $addButton.Enabled = $true
        $removeButton.Enabled = $true
        $clearButton.Enabled = $true

        return
    }


    # ========================================================
    # PROGRESS CALCULATION
    # ========================================================

    $processedFiles = 0


    # ========================================================
    # CHECK EACH PAIR
    # ========================================================

    foreach ($pair in $validPairs) {

        $sourceFolder = $pair.Source
        $backupFolder = $pair.Backup


        Add-Log ""
        Add-Log "Checking folder pair:" `
            ([System.Drawing.Color]::Yellow)

        Add-Log "Original: $sourceFolder"
        Add-Log "USB     : $backupFolder"
        Add-Log ""


        # ----------------------------------------------------
        # GET SOURCE FILES
        # ----------------------------------------------------

        $sourceFiles = Get-ChildItem `
            -LiteralPath $sourceFolder `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue


        # ----------------------------------------------------
        # GET BACKUP FILES
        # ----------------------------------------------------

        $backupFiles = Get-ChildItem `
            -LiteralPath $backupFolder `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue


        # ====================================================
        # CHECK ORIGINAL FILES
        # ====================================================

        foreach ($sourceFile in $sourceFiles) {

            try {

                # --------------------------------------------
                # Relative path
                # --------------------------------------------

                $relativePath = $sourceFile.FullName.Substring(
                    $sourceFolder.Length
                ).TrimStart('\')


                # --------------------------------------------
                # Expected USB path
                # --------------------------------------------

                $backupFile = Join-Path `
                    $backupFolder `
                    $relativePath


                # --------------------------------------------
                # Check missing file
                # --------------------------------------------

                if (!(Test-Path -LiteralPath $backupFile)) {

                    Add-Log `
                        "[MISSING]   $relativePath" `
                        ([System.Drawing.Color]::Red)


                    [void]$results.Add(
                        [PSCustomObject]@{
                            Status   = "MISSING"
                            File     = $relativePath
                            Original = $sourceFile.FullName
                            USB      = $backupFile
                        }
                    )


                    $missingFiles++

                    continue
                }


                # ============================================
                # SHA-256 ORIGINAL
                # ============================================

                $originalHash = (
                    Get-FileHash `
                        -LiteralPath $sourceFile.FullName `
                        -Algorithm SHA256 `
                        -ErrorAction Stop
                ).Hash


                # ============================================
                # SHA-256 USB
                # ============================================

                $backupHash = (
                    Get-FileHash `
                        -LiteralPath $backupFile `
                        -Algorithm SHA256 `
                        -ErrorAction Stop
                ).Hash


                # ============================================
                # COMPARE HASHES
                # ============================================

                if ($originalHash -eq $backupHash) {

                    Add-Log `
                        "[OK]         $relativePath" `
                        ([System.Drawing.Color]::LightGreen)
                }

                else {

                    Add-Log `
                        "[DIFFERENT]  $relativePath" `
                        ([System.Drawing.Color]::Red)


                    [void]$results.Add(
                        [PSCustomObject]@{
                            Status   = "DIFFERENT"
                            File     = $relativePath
                            Original = $sourceFile.FullName
                            USB      = $backupFile
                        }
                    )


                    $differentFiles++
                }

            }

            catch {

                Add-Log `
                    "[ERROR]      $($sourceFile.FullName)" `
                    ([System.Drawing.Color]::Red)

                Add-Log `
                    "             $($_.Exception.Message)" `
                    ([System.Drawing.Color]::Red)


                [void]$results.Add(
                    [PSCustomObject]@{
                        Status   = "ERROR"
                        File     = $sourceFile.FullName
                        Original = $sourceFile.FullName
                        USB      = $backupFile
                    }
                )


                $errorFiles++
            }


            # ------------------------------------------------
            # Update progress
            # ------------------------------------------------

            $processedFiles++


            if ($totalFiles -gt 0) {

                $percentage = [math]::Round(
                    ($processedFiles / $totalFiles) * 100
                )

                if ($percentage -gt 100) {
                    $percentage = 100
                }

                if ($percentage -lt 0) {
                    $percentage = 0
                }

                $progressBar.Value = $percentage
            }


            Update-Status `
                "Checking file $processedFiles of $totalFiles..."
        }


        # ====================================================
        # FIND EXTRA USB FILES
        # ====================================================

        foreach ($backupFile in $backupFiles) {

            try {

                $relativePath = $backupFile.FullName.Substring(
                    $backupFolder.Length
                ).TrimStart('\')


                $sourceFile = Join-Path `
                    $sourceFolder `
                    $relativePath


                if (!(Test-Path -LiteralPath $sourceFile)) {

                    Add-Log `
                        "[EXTRA]      $relativePath" `
                        ([System.Drawing.Color]::Magenta)


                    [void]$results.Add(
                        [PSCustomObject]@{
                            Status   = "EXTRA"
                            File     = $relativePath
                            Original = $sourceFile
                            USB      = $backupFile.FullName
                        }
                    )


                    $extraFiles++
                }

            }

            catch {

                Add-Log `
                    "[ERROR]      Could not check $($backupFile.FullName)" `
                    ([System.Drawing.Color]::Red)

                Add-Log `
                    "             $($_.Exception.Message)" `
                    ([System.Drawing.Color]::Red)


                $errorFiles++
            }
        }
    }


    # ========================================================
    # FINISH PROGRESS
    # ========================================================

    $progressBar.Value = 100


    # ========================================================
    # FINAL REPORT
    # ========================================================

    Add-Log ""
    Add-Log "========================================" `
        ([System.Drawing.Color]::Cyan)

    Add-Log "             FINAL REPORT" `
        ([System.Drawing.Color]::Cyan)

    Add-Log "========================================" `
        ([System.Drawing.Color]::Cyan)

    Add-Log ""

    Add-Log "Files checked : $totalFiles"
    Add-Log "Missing       : $missingFiles"
    Add-Log "Different     : $differentFiles"
    Add-Log "Extra         : $extraFiles"
    Add-Log "Errors        : $errorFiles"

    Add-Log ""


    # ========================================================
    # SAVE CSV REPORT
    # ========================================================

    $reportPath = Join-Path `
        $env:USERPROFILE `
        "Desktop\USB_Verification_Report.csv"


    if ($results.Count -gt 0) {

        $results |
            Export-Csv `
                -Path $reportPath `
                -NoTypeInformation `
                -Encoding UTF8

        Add-Log ""
        Add-Log "Detailed report saved to:" `
            ([System.Drawing.Color]::Cyan)

        Add-Log $reportPath `
            ([System.Drawing.Color]::Cyan)
    }


    # ========================================================
    # FINAL SUCCESS / FAILURE
    # ========================================================
    #
    # EXTRA IS INCLUDED HERE.
    #
    # Therefore the USB must be an EXACT FILE SET MATCH.
    #
    # ========================================================

    if (
        $missingFiles -eq 0 -and
        $differentFiles -eq 0 -and
        $extraFiles -eq 0 -and
        $errorFiles -eq 0
    ) {

        Add-Log ""
        Add-Log "========================================" `
            ([System.Drawing.Color]::Lime)

        Add-Log "           BACKUP VERIFIED" `
            ([System.Drawing.Color]::Lime)

        Add-Log "========================================" `
            ([System.Drawing.Color]::Lime)

        Add-Log ""
        Add-Log "USB backup is an exact match." `
            ([System.Drawing.Color]::Lime)

        Add-Log "No missing, different, extra, or error files found." `
            ([System.Drawing.Color]::Lime)

        $statusLabel.Text = "BACKUP VERIFIED - Exact Match"
        $statusLabel.ForeColor = [System.Drawing.Color]::Green

        [System.Windows.Forms.MessageBox]::Show(
            "BACKUP VERIFIED`n`nThe USB backup is an exact match.`n`nNo missing, different, extra, or error files were found.",
            "Backup Verified",
            "OK",
            "Information"
        )
    }

    else {

        Add-Log ""
        Add-Log "========================================" `
            ([System.Drawing.Color]::Red)

        Add-Log "        VERIFICATION NOT COMPLETE" `
            ([System.Drawing.Color]::Red)

        Add-Log "========================================" `
            ([System.Drawing.Color]::Red)

        Add-Log ""
        Add-Log "Please check the MISSING, DIFFERENT, EXTRA, or ERROR files." `
            ([System.Drawing.Color]::Red)


        $statusLabel.Text = "VERIFICATION NOT COMPLETE"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red


        [System.Windows.Forms.MessageBox]::Show(
            "Verification is NOT complete.`n`n" +
            "Missing: $missingFiles`n" +
            "Different: $differentFiles`n" +
            "Extra: $extraFiles`n" +
            "Errors: $errorFiles`n`n" +
            "Check the log and CSV report.",
            "Verification Failed",
            "OK",
            "Warning"
        )
    }


    # ========================================================
    # RE-ENABLE BUTTONS
    # ========================================================

    $addButton.Enabled = $true
    $removeButton.Enabled = $true
    $clearButton.Enabled = $true
    $startButton.Enabled = $true

})


# ============================================================
# SHOW THE GUI
# ============================================================

[void]$form.ShowDialog()
