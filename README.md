# USB Backup Verifier

 A small PowerShell GUI tool for checking whether a USB backup actually matches the original folder.

 I made this because copying files to a USB drive is one thing, but actually checking that everything copied correctly is another. This tool compares the files using SHA-256 hashes and reports anything that doesn't match.

 ## What it does

 - Select an original folder and a USB backup folder
- Add multiple folder pairs
- Check files recursively, including files inside subfolders
- Compare files using SHA-256
- Detect missing files
- Detect different files
- Detect extra files on the USB
- Show errors if something can't be checked
- Show verification progress
- Display a live verification log
- Generate a CSV report
- Give a final pass/fail result

 The backup only passes if the file sets match exactly.

 ## Requirements

 - Windows
- PowerShell
- .NET / Windows Forms

 The script uses:

```
System.Windows.Forms
System.Drawing
```

 These are normally available on Windows.

 ## How to run

 Save the script as:

```
USB-Backup-Verifier.ps1
```

 Open PowerShell and go to the folder where you saved it.

 For example, if it's on your Desktop:

```
cd "$HOME\Desktop"
```

 Then run:

```
.\USB-Backup-Verifier.ps1
```

 If PowerShell blocks the script because of the execution policy, run:

```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

 Then run the script again.

 ## How to use

 1. Open the program.
2. Click **Add Pair**.
3. Select the original/source folder.
4. Select the corresponding folder on the USB.
5. Add more pairs if needed.
6. Click **Start Verification**.
7. Wait for the verification to finish.
8. Check the log and final result.

 Example:

```
Original:
D:\Photos

USB:
E:\Backup\Photos
```

 The program checks files based on their relative paths.

 For example, if the original contains:

```
D:\Photos\2025\trip.jpg
```

 the USB should contain:

```
E:\Backup\Photos\2025\trip.jpg
```

 ## Verification results

 ### OK

 The file exists in both locations and the SHA-256 hashes are identical.

 ### MISSING

 The file exists in the original folder but not on the USB.

 ### DIFFERENT

 The file exists in both places, but their SHA-256 hashes don't match.

 ### EXTRA

 A file exists on the USB but doesn't exist in the original folder.

 ### ERROR

 The program couldn't read or compare something.

 ## CSV report

 When there are problems, the program saves a report to the Desktop:

```
USB_Verification_Report.csv
```

 The report contains the status, file path, original path, and USB path for files that need attention.

 ## Important

 This is a **verification tool**, not a backup/copy tool.

 It does not copy, delete, move, or synchronize files.

 It only checks what's already there.

 SHA-256 verification can take some time with large backups because the contents of the files have to be read to calculate their hashes.

 ## Notes

 The progress bar is based on the number of files in the original folders. Extra files on the USB are checked as well, but they don't add to that file count.

 For important backups, I would still keep another copy somewhere else. A verification tool can tell you that two folders match, but it can't protect you from accidentally deleting both copies later.

 ## License

 Use it, modify it, break it, improve it.

 Just make sure you know what a PowerShell script is doing before running one from someone else.
