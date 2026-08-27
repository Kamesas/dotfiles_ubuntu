# Windows-side setup for the parts that are not files.
#
# The config files themselves are copied in by `sync-windows push`, run from
# WSL. This script covers the rest: the login shortcut and yazi's MIME
# detection. Both live in the registry, so a file copy cannot carry them.
#
# Safe to re-run. Needs no admin.
#
#   powershell -ExecutionPolicy Bypass -File windows\install.ps1

$ErrorActionPreference = 'Stop'

$ahkExe    = "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe"
$ahkScript = "$env:USERPROFILE\.config\ahk\sway.ahk"
$startup   = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\sway.ahk.lnk"
$fileExe   = "$env:ProgramFiles\Git\usr\bin\file.exe"

# --- what has to be installed first -------------------------------------

$missing = @()
if (-not (Test-Path $ahkExe))    { $missing += "AutoHotkey v2   winget install AutoHotkey.AutoHotkey" }
if (-not (Test-Path $ahkScript)) { $missing += "sway.ahk        run 'sync-windows push' in WSL first" }
if ($missing.Count -gt 0) {
    Write-Output "Missing, stopping:"
    $missing | ForEach-Object { Write-Output "  $_" }
    exit 1
}

# --- run sway.ahk at login ----------------------------------------------

# The shortcut is built here rather than stored in the repo because a .lnk
# bakes in absolute paths, and the user name differs between machines.
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($startup)
$lnk.TargetPath       = $ahkExe
$lnk.Arguments        = '"' + $ahkScript + '"'
$lnk.WorkingDirectory = Split-Path $ahkScript
$lnk.Save()
Write-Output "startup shortcut -> $startup"

# --- yazi needs the Unix `file` to detect MIME types --------------------

# There is no standalone file/libmagic package in winget. Git for Windows
# bundles one, which is the only reason git is wanted here.
if (Test-Path $fileExe) {
    [Environment]::SetEnvironmentVariable('YAZI_FILE_ONE', $fileExe, 'User')
    Write-Output "YAZI_FILE_ONE    -> $fileExe"
} else {
    Write-Output "skipped YAZI_FILE_ONE: no $fileExe (winget install Git.Git)"
}

# --- left for you to decide ---------------------------------------------

Write-Output ""
Write-Output "Still manual:"
Write-Output "  Win+L as 'next desktop'  ->  run .config\ahk\enable-winl.reg as admin, then sign out"
Write-Output "  Alt+U for PowerToys Run  ->  set it in PowerToys Run settings"
Write-Output ""
Write-Output "Start it now without waiting for a login:"
Write-Output "  & '$ahkExe' '$ahkScript'"
