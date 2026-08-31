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

# --- kanata: the keyboard layout ----------------------------------------

# The wintercept build, not winIOv2: only it can limit kanata to the built-in
# keyboard, leaving the Corne and the Ferris Sweep on the layout their own
# firmware applies. The allowlist itself lives in kanata.kbd. Needs the
# Interception driver and interception.dll beside the exe -- see "Kanata" in
# WINDOWS-SETUP.md.
$kanataExe = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse `
    -Filter "kanata_windows_gui_wintercept_x64.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName
$kanataCfg = "$env:USERPROFILE\.config\kanata\kanata.kbd"

if (-not $kanataExe) {
    Write-Output "skipped kanata: not installed (winget install jtroo.kanata_gui)"
} elseif (-not (Test-Path $kanataCfg)) {
    Write-Output "skipped kanata: no $kanataCfg (run 'sync-windows push' in WSL)"
} elseif (-not (Test-Path (Join-Path (Split-Path $kanataExe) "interception.dll"))) {
    # A kanata upgrade replaces the package folder and takes the dll with it.
    # Without it kanata exits with 0xC0000135 and prints nothing, so no shortcut
    # is better than one that fails silently at every login.
    Write-Output "skipped kanata: no interception.dll beside the exe"
    Write-Output "  copy library\x64\interception.dll from the Interception zip to:"
    Write-Output "  $(Split-Path $kanataExe)"
} else {
    $klnk = $shell.CreateShortcut("$(Split-Path $startup)\kanata.lnk")
    $klnk.TargetPath       = $kanataExe
    $klnk.Arguments        = '--cfg "' + $kanataCfg + '"'
    $klnk.WorkingDirectory = Split-Path $kanataExe
    $klnk.Save()
    Write-Output "kanata startup   -> $(Split-Path $startup)\kanata.lnk"
}

# --- left for you to decide ---------------------------------------------

Write-Output ""
Write-Output "Still manual:"
Write-Output "  Win+L as 'next desktop'  ->  run .config\ahk\enable-winl.reg as admin, then sign out"
Write-Output "  Expo on a phone          ->  open port 8081, see WINDOWS-SETUP.md, needs admin"
Write-Output "  Alt+U for PowerToys Run  ->  set it in PowerToys Run settings"
Write-Output "  kanata needs the Interception driver  ->  see 'Kanata' in WINDOWS-SETUP.md"
Write-Output ""
Write-Output "Start it now without waiting for a login:"
Write-Output "  & '$ahkExe' '$ahkScript'"
