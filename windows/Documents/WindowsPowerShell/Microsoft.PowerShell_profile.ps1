# PowerShell profile -- loaded by the Alt+E dropdown (sway.ahk runs
# `powershell.exe -NoLogo`, which does read profiles).

# `ya` with no arguments opens the yazi file manager and follows it: whatever
# directory you are sitting in when you quit becomes the shell's directory.
# That is the behaviour yazi's own docs suggest wiring to a short command.
#
# With arguments it forwards to the real ya.exe, so the CLI is not lost --
# `ya pkg add ...`, `ya emit ...` and friends still work. Calling `ya.exe` by
# its full name resolves to the application rather than back into this
# function, so there is no recursion.
function ya {
    if ($args.Count -gt 0) {
        & ya.exe @args
        return
    }

    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        yazi.exe --cwd-file $tmp
        $cwd = $null
        if (Test-Path -LiteralPath $tmp) {
            $cwd = (Get-Content -LiteralPath $tmp -Raw -Encoding UTF8 -ErrorAction SilentlyContinue)
        }
        if ($cwd) { $cwd = $cwd.Trim() }
        if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd)) {
            Set-Location -LiteralPath $cwd
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}
