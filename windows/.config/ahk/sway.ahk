#Requires AutoHotkey v2.0
#SingleInstance Force

; sway.ahk -- Sway-ish hotkeys for Windows.
;
;   Alt+W        toggle the Linux dropdown  (WezTerm -> WSL Ubuntu, zsh)
;   Alt+E        toggle the Windows dropdown (WezTerm -> PowerShell)
;                raising either one puts the other away; see DROP_EXCLUSIVE
;   Win+Shift+W  rescue: unhide every dropdown window
;   Win+C        close the focused window (sway's kill)
;   Win+H        previous virtual desktop
;   Win+L        next virtual desktop
;   Win+1..5     jump straight to that desktop
;   Win+Shift+L  lock the workstation
;
; Also draws a waybar-style workspace indicator over the taskbar's empty left
; end. See the workspace section at the bottom.
;
; Hidden windows are matched by class along with visible ones. WezTerm keeps
; no helper top-level windows, so a class match only ever returns real
; terminals -- and a window we hid stays findable even if the script is
; reloaded and forgets which handle it was tracking.
;
; Hiding the dropdown also has to hand focus back. WinHide does not: Windows
; leaves the hidden window as the foreground window, so keystrokes go nowhere
; until something is clicked. See RestoreFocus().

; ---------------------------------------------------------------- config ---

TERM_EXE   := "C:\Program Files\WezTerm\wezterm-gui.exe"

; The Windows dropdown gets its own config file, which loads the shared
; .wezterm.lua and adds WezTerm's tabs and panes on top. Only that instance
; reads it, so its keys cannot reach tmux in the Linux dropdown.
WIN_CONF   := EnvGet("USERPROFILE") "\.wezterm-win.lua"

; Two dropdowns on the same terminal. The Linux one opens into WSL (WezTerm's
; default_domain); the Windows one runs PowerShell for driving Windows itself.
;
; They are told apart by window class, which means the Windows one must be a
; separate WezTerm *instance*: `--class` applies to every window an instance
; owns, so without `--always-new-process` the new window would join the running
; WezTerm and inherit its class, leaving the two indistinguishable here.
;
; `--domain local` is what picks PowerShell over WSL -- the config's
; default_domain is WSL:Ubuntu, so a bare `-- powershell.exe` would try to run
; powershell inside Ubuntu.
WSL_CLASS := "org.wezfurlong.wezterm"
WIN_CLASS := "org.wezfurlong.wezterm.winshell"
WIN_PROG  := "powershell.exe -NoLogo"

; Share of the monitor's work area a dropdown covers. 100 = maximized.
HEIGHT_PCT := 100

; Only one dropdown on screen at a time -- raising one puts the other away.
; They cover the same space at HEIGHT_PCT 100, so the newer one buries the older
; one regardless; this just makes it deliberate and keeps the hidden one tracked.
; False = let both stay up.
DROP_EXCLUSIVE := true

ALWAYS_ON_TOP := false

; Workspace indicator. Sizes are in unscaled pixels; BarPx() applies the
; monitor's DPI. Colours are picked to sit invisibly on the dark taskbar --
; BAR_BG only shows in the gaps between numbers.
BAR_ENABLED := true
BAR_MARGIN  := 18      ; from the taskbar's left edge
BAR_CELL    := 26      ; width of one desktop number
BAR_HEIGHT  := 30
BAR_BG      := "1F1F1F"
BAR_DIM     := "8A8A8A"
BAR_ACTIVE  := "FFFFFF"
BAR_POLL    := 300     ; ms

; A fixed set of numbered workspaces, sway style, created at startup if they
; are not already there. Win+1..Win+<n> jump straight to one.
VD_DESKTOPS := 5

; How long to wait for the shell to actually carry out a desktop switch before
; giving up on it. Measured on this machine: under 30ms with the slide
; suppressed. This is slack for a busy moment, not a delay we normally pay.
VD_TIMEOUT  := 500     ; ms

; Suppress the desktop-switch slide for the instant of a switch, leaving the
; system-wide animation setting alone. See the animation section below for why
; this is done per-switch rather than once and for all. False = let Windows
; animate desktop switches normally.
VD_QUIET_SWITCH := true

; Writes every toggle decision to sway.log next to this script. Flip to true
; and Reload from the tray if the toggle ever misbehaves again.
DEBUG := false

; ---------------------------------------------------------------- setup ----

; Set once, for the whole script: every window lookup below is meant to see
; hidden windows.
DetectHiddenWindows true

; Exact matching, which ahk_class does NOT get by default -- mode 2 matches on
; "contains", and the Windows dropdown's class begins with the Linux one's, so
; a lookup for org.wezfurlong.wezterm would happily return the PowerShell
; window and the two dropdowns would fight over each other.
SetTitleMatchMode 3

A_IconTip := "sway.ahk  |  Alt+W WSL, Alt+E Windows, Win+H/L workspaces"
A_TrayMenu.Delete()
A_TrayMenu.Add("Reload", (*) => Reload())
A_TrayMenu.Add("Edit", (*) => Edit())
A_TrayMenu.Add("Open log", (*) => Run('notepad.exe "' A_ScriptDir '\sway.log"'))
A_TrayMenu.Add()
A_TrayMenu.Add("Unhide all terminals", (*) => UnhideAll())
A_TrayMenu.Add("Workspace bar", (*) => BarToggle())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Reload"

; One descriptor per dropdown. Each carries its own tracked window and its own
; memory of what it covered up, so hiding the Windows one never hands focus to
; the Linux one or vice versa.
;
;   hwnd  the window this dropdown owns, once found or launched
;   prev  what had focus when it was last raised, to give focus back on hide
global DROPS := Map(
    "wsl", { name:  "wsl"
           , match: "ahk_class " WSL_CLASS
           , run:   '"' TERM_EXE '" start'
           , hwnd:  0
           , prev:  0 },
    "win", { name:  "win"
           , match: "ahk_class " WIN_CLASS
           , run:   '"' TERM_EXE '" --config-file "' WIN_CONF '"'
                    . ' start --always-new-process'
                    . ' --class ' WIN_CLASS ' --domain local -- ' WIN_PROG
           , hwnd:  0
           , prev:  0 })

; The indicator's Gui, its per-desktop Text controls, the colour each one is
; currently painted (so BarPaint can skip untouched cells), how many desktops
; the controls were built for, and the last geometry passed to Show.
global Bar      := 0
global BarCells := []
global BarTones := []
global BarCount := 0
global BarGeom  := ""

; Last index the registry gave us. Kept so a read that cannot resolve the
; current desktop -- which happens for a moment mid-switch -- leaves the
; highlight where it was instead of blanking the bar.
global BarIndex := 1

Log(msg) {
    if (!DEBUG)
        return
    try FileAppend FormatTime(A_Now, "HH:mm:ss") " " msg "`n", A_ScriptDir "\sway.log", "UTF-8"
}

if (BAR_ENABLED)
    BarStart()

; Win+1..Win+<n>: sway's jump-straight-to-a-workspace. Registered in a loop so
; the set follows VD_DESKTOPS instead of needing one line per desktop. This
; takes Win+<n> away from the shell, where it launches the nth taskbar app --
; nothing here drives windows from taskbar icons.
Loop VD_DESKTOPS
    Hotkey "#" A_Index, VdJump.Bind(A_Index)

OnExit AnimOnExit
if (VD_QUIET_SWITCH)
    SetTimer AnimWatchdog, 1000

VdEnsure()

; ---------------------------------------------------------------- dropdown -

!w::ToggleTerm(DROPS["wsl"])      ; Linux: WSL Ubuntu, zsh, tmux
!e::ToggleTerm(DROPS["win"])      ; Windows: PowerShell

ToggleTerm(d) {
    hwnd := FindTerm(d)
    if (!hwnd) {
        Log(d.name " toggle: no terminal found -> launching")
        d.prev := ForegroundOther(0)
        LaunchTerm(d)
        return
    }

    visible := IsVisible(hwnd)
    active  := WinActive("ahk_id " hwnd) ? true : false
    Log(d.name " toggle: hwnd=" hwnd " visible=" visible " active=" active
        . " fg=" WinExist("A") " title='" SafeTitle(hwnd) "'")

    if (visible && active) {
        ; Pick the window to focus *before* hiding: once the terminal is gone
        ; the foreground window is a hidden one and tells us nothing.
        back := RestoreTarget(d, hwnd)
        WinHide "ahk_id " hwnd
        RestoreFocus(d, back)
        Log("  -> hidden, focus back to " back " '" (back ? SafeTitle(back) : "") "'")
    } else {
        ; Put the other dropdown away first, so the foreground window noted
        ; below is a real window rather than the one we just hid.
        HideOthers(d)

        ; Whatever we are covering up is what this key should uncover again.
        if (fg := ForegroundOther(hwnd))
            d.prev := fg
        ShowTerm(d, hwnd)
    }
}

; Hide every dropdown except the one being raised. No focus restoration here --
; `keep` is about to take the foreground, and handing focus somewhere else on
; the way would just cause a flicker.
HideOthers(keep) {
    if (!DROP_EXCLUSIVE)
        return

    for , d in DROPS {
        if (d.name = keep.name || !d.hwnd)
            continue
        if (!WinExist("ahk_id " d.hwnd) || !IsVisible(d.hwnd))
            continue

        ; Pass on what this dropdown was covering. Without it the incoming one
        ; would record the outgoing dropdown as "underneath" and, when hidden
        ; later, try to focus a window that is itself hidden by then -- landing
        ; the user somewhere arbitrary instead of where they started.
        if (d.prev)
            keep.prev := d.prev
        d.prev := 0

        WinHide "ahk_id " d.hwnd
        Log(keep.name " raise: put " d.name " away (hwnd=" d.hwnd ")")
    }
}

; The current foreground window, unless it is the terminal itself (or a window
; not worth returning to, like the taskbar after a tray click).
ForegroundOther(termHwnd) {
    fg := DllCall("user32\GetForegroundWindow", "ptr")
    if (!fg || fg = termHwnd || !IsAltTabWindow(fg))
        return 0
    return fg
}

; Prefer the window the dropdown was raised over. If it is gone, minimized, or
; sitting on another virtual desktop, fall back to the topmost ordinary window
; behind the terminal -- which is what the shell would have focused anyway had
; the terminal been closed instead of hidden.
RestoreTarget(d, termHwnd) {
    if (d.prev && d.prev != termHwnd && IsAltTabWindow(d.prev)
        && !IsMinimized(d.prev))
        return d.prev

    ; WinGetList returns windows in Z-order, topmost first.
    for hwnd in WinGetList() {
        if (hwnd = termHwnd || !IsAltTabWindow(hwnd) || IsMinimized(hwnd))
            continue
        return hwnd
    }

    return 0
}

IsMinimized(hwnd) {
    try return WinGetMinMax("ahk_id " hwnd) = -1
    return true
}

RestoreFocus(d, hwnd) {
    d.prev := 0
    if (hwnd && WinExist("ahk_id " hwnd))
        Activate(hwnd)
}

; An ordinary, focusable, on-this-desktop window -- the kind Alt-Tab lists.
; Owned windows, tool windows and the shell's own surfaces are all things we
; must not park the focus on.
IsAltTabWindow(hwnd) {
    if (!hwnd || !IsVisible(hwnd) || IsCloaked(hwnd))
        return false
    if (DllCall("user32\GetWindow", "ptr", hwnd, "uint", 4, "ptr"))   ; GW_OWNER
        return false

    try {
        ex := WinGetExStyle("ahk_id " hwnd)
        if (ex & 0x80)                                               ; WS_EX_TOOLWINDOW
            return false
        if (ex & 0x08000000)                                         ; WS_EX_NOACTIVATE
            return false
        if (PROTECTED.Has(WinGetClass("ahk_id " hwnd)))
            return false
        return WinGetTitle("ahk_id " hwnd) != ""
    }
    return false
}

; Windows on another virtual desktop stay "visible" but are cloaked by DWM.
; Activating one would drag the user off the desktop they are looking at.
IsCloaked(hwnd) {
    cloaked := 0
    hr := DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 14
        , "int*", &cloaked, "uint", 4, "uint")                       ; DWMWA_CLOAKED
    return (hr = 0) && cloaked != 0
}

; Order matters: a hidden terminal is one this script put away, so it wins
; over any visible window -- otherwise a second terminal opened in the
; meantime would strand the hidden one for good.
FindTerm(d) {
    if (d.hwnd && WinExist("ahk_id " d.hwnd))
        return d.hwnd

    for hwnd in WinGetList(d.match) {
        if (!IsVisible(hwnd)) {
            d.hwnd := hwnd
            Log(d.name " find: adopted hidden hwnd=" hwnd)
            return hwnd
        }
    }

    if (hwnd := WinExist(d.match)) {
        d.hwnd := hwnd
        Log(d.name " find: adopted visible hwnd=" hwnd)
        return hwnd
    }

    return 0
}

ShowTerm(d, hwnd) {
    PlaceTerm(hwnd)              ; position while hidden, so it never jumps
    WinShow "ahk_id " hwnd
    if (ALWAYS_ON_TOP)
        WinSetAlwaysOnTop true, "ahk_id " hwnd
    ok := Activate(hwnd)
    Log("  -> shown, activate=" ok)
}

LaunchTerm(d) {
    if (!FileExist(TERM_EXE)) {
        MsgBox "sway.ahk: WezTerm not found at`n" TERM_EXE, "sway.ahk", "Icon!"
        return
    }
    Run d.run
    ; The Windows dropdown starts a whole second WezTerm process, so give it
    ; room -- the first launch of an instance is slower than a new window on
    ; one that is already up.
    if (!WinWait(d.match, , 20)) {
        Log(d.name " launch: timed out waiting for a window")
        return
    }
    d.hwnd := WinExist(d.match)
    PlaceTerm(d.hwnd)
    Activate(d.hwnd)
    Log(d.name " launch: hwnd=" d.hwnd)
}

; WinMove is safe on a hidden window, but WinRestore and WinMaximize both go
; through ShowWindow and un-hide it -- so any restore/maximize here plays out
; on screen instead of being set up behind the scenes. Hence: touch the window
; as little as possible, and never leave it at an intermediate size.
PlaceTerm(hwnd) {
    MonitorGetWorkArea MonitorUnderMouse(), &l, &t, &r, &b
    state := WinGetMinMax("ahk_id " hwnd)

    if (HEIGHT_PCT >= 100) {
        ; Already maximized on the monitor we want: nothing to do at all.
        ; This is the steady state, so a normal toggle does no resizing.
        if (state = 1 && OnMonitor(hwnd, l, t, r, b))
            return
        if (state != 0)
            WinRestore "ahk_id " hwnd
        ; Full height, not half: if this does become visible, it is already
        ; the final size and the maximize below is not a visible jump.
        WinMove l, t, r - l, b - t, "ahk_id " hwnd
        WinMaximize "ahk_id " hwnd
        return
    }

    if (state != 0)
        WinRestore "ahk_id " hwnd
    WinMove l, t, r - l, Round((b - t) * HEIGHT_PCT / 100), "ahk_id " hwnd
}

OnMonitor(hwnd, l, t, r, b) {
    try WinGetPos &x, &y, &w, &h, "ahk_id " hwnd
    catch
        return false
    cx := x + w // 2
    cy := y + h // 2
    return (cx >= l && cx < r && cy >= t && cy < b)
}

; WinActivate alone loses to the foreground lock often enough to make the
; toggle feel random: the window ends up visible but unfocused, so the next
; Alt+W tries to focus it again instead of hiding it. Borrowing the current
; foreground thread's input state makes SetForegroundWindow stick.
; Waits are deliberately short. AHK drops a hotkey press that arrives while
; the previous one is still running (#MaxThreadsPerHotkey is 1), so a long
; wait here silently eats the second half of a quick Alt+W Alt+W.
Activate(hwnd) {
    WinActivate "ahk_id " hwnd
    if (WinWaitActive("ahk_id " hwnd, , 0.15))
        return true

    fg := DllCall("user32\GetForegroundWindow", "ptr")
    me := DllCall("kernel32\GetCurrentThreadId", "uint")
    other := DllCall("user32\GetWindowThreadProcessId", "ptr", fg, "ptr", 0, "uint")
    attached := (other && other != me)
        && DllCall("user32\AttachThreadInput", "uint", me, "uint", other, "int", true)

    DllCall("user32\BringWindowToTop", "ptr", hwnd)
    DllCall("user32\SetForegroundWindow", "ptr", hwnd)

    if (attached)
        DllCall("user32\AttachThreadInput", "uint", me, "uint", other, "int", false)

    return WinWaitActive("ahk_id " hwnd, , 0.2) ? true : false
}

IsVisible(hwnd) {
    return DllCall("user32\IsWindowVisible", "ptr", hwnd) ? true : false
}

SafeTitle(hwnd) {
    try return WinGetTitle("ahk_id " hwnd)
    return "?"
}

MonitorUnderMouse() {
    MouseGetPos &mx, &my
    Loop MonitorGetCount() {
        MonitorGet A_Index, &l, &t, &r, &b
        if (mx >= l && mx < r && my >= t && my < b)
            return A_Index
    }
    return MonitorGetPrimary()
}

; ---------------------------------------------------------------- rescue ---

#+w::UnhideAll()

; Covers both dropdowns -- whichever one got stranded, this is the way back.
UnhideAll() {
    n := 0
    for , d in DROPS {
        for hwnd in WinGetList(d.match) {
            if (!IsVisible(hwnd)) {
                WinShow "ahk_id " hwnd
                n++
            }
        }
    }
    Log("rescue: unhid " n " window(s)")
    TrayTip "sway.ahk", n " hidden terminal(s) restored"
}

; ---------------------------------------------------------------- close ----

; Shell windows that must never be closed: taking out the taskbar or the
; desktop leaves the session in a state only a restart of explorer fixes.
global PROTECTED := Map(
    "Progman",                       true,   ; desktop
    "WorkerW",                       true,   ; wallpaper layer
    "Shell_TrayWnd",                 true,   ; taskbar
    "Shell_SecondaryTrayWnd",        true,   ; taskbar, other monitors
    "Windows.UI.Core.CoreWindow",    true,   ; Start, Search, system flyouts
    "XamlExplorerHostIslandWindow",  true,   ; Task View / Alt-Tab
    "MultitaskingViewFrame",         true)

#c::CloseActive()

; sway's kill. WinClose sends WM_CLOSE, so an app still runs its own shutdown
; path -- unsaved-changes prompts and the like -- instead of being killed.
CloseActive() {
    hwnd := WinExist("A")
    if (!hwnd)
        return

    ; Alt+W hands focus back to the window underneath, but if there was no
    ; such window the hidden dropdown is still the foreground one. Without
    ; this check, Win+C would then close the terminal just tucked away.
    if (!IsVisible(hwnd))
        return

    cls := ""
    try cls := WinGetClass("ahk_id " hwnd)
    if (PROTECTED.Has(cls))
        return

    WinClose "ahk_id " hwnd
}

; ---------------------------------------------------------------- desktops -

; Sway's numbered workspaces: a fixed set that is simply always there. Windows
; can create and destroy desktops on the fly, but only through keystrokes that
; drag you along with them -- disposing of an empty desktop means closing the
; one you are standing on and then correcting for wherever the shell drops you.
; A fixed set needs none of that, and it makes Win+1..5 a plain jump.
;
; Behaviour measured on this machine (Windows 11 25H2):
;
;   Win+Ctrl+D          appends a desktop at the END and switches to it
;                       (1/3 -> 4/4) -- the only way to create one.
;   Win+Ctrl+Left/Right steps one desktop, stopping at the ends. No wrap-around
;                       is offered and none is faked here: from desktop 5,
;                       Win+1 is a better way home than four Win+H presses.

#h::VdGoto(ReadDesktops().index - 1)
#l::VdGoto(ReadDesktops().index + 1)

; Hotkey() passes the key name to its callback, hence the ignored parameter.
VdJump(n, *) {
    VdGoto(n)
}

; Tops the set up to VD_DESKTOPS at startup. Creating drags us to the new
; desktop each time, so we note where we were and walk back. Once the desktops
; exist this does nothing, which is the normal case on reload.
VdEnsure() {
    d := ReadDesktops()
    if (!d.count || d.count >= VD_DESKTOPS)
        return

    home := d.index ? d.index : 1
    Loop VD_DESKTOPS - d.count
        VdSend(VdKeys("d"))
    VdGoto(home)
}

; Out-of-range targets are ignored rather than clamped, so Win+H on the first
; desktop and Win+L on the last are simply no-ops.
VdGoto(target) {
    ; Held across the whole walk, so a multi-step Win+1 suppresses once rather
    ; than toggling per step.
    AnimSuppress()
    try {
        ; Bounded rather than "until we arrive": if a keystroke is ever
        ; swallowed, a while-loop here would spin sending arrows forever.
        Loop VD_DESKTOPS + 2 {
            d := ReadDesktops()
            if (!d.index || target < 1 || target > d.count || d.index = target)
                return
            after := VdSend(VdKeys(d.index < target ? "{Right}" : "{Left}"))

            ; A step that moved nothing means the keystroke never landed.
            ; Retrying only burns another timeout, and every one of those is
            ; time spent with the animation setting held down -- which is
            ; invisible from outside except as websites dropping their motion.
            if (after.index = d.index) {
                Log("vd: step made no progress; abandoning the walk to " target)
                return
            }
        }
    } finally {
        AnimRelease()
    }
}

; The hotkeys fire while Win is still physically held, and {Blind} leaves that
; press alone instead of having Send release and retype it. A click on the
; indicator has no Win held, so there the key has to be sent in full.
VdKeys(tail) {
    if (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
        return "{Blind}^" tail
    return "^#" tail
}

; Sends a desktop command and waits for the shell to actually do it, rather
; than sleeping a fixed guess. Chained sends need this: an arrow that arrives
; while the shell is still busy with the previous one is dropped.
;
; With animation effects turned off system-wide, a switch lands in under 30ms
; (it was ~400ms of slide before), so the poll is fine-grained -- the interval
; is most of what a multi-step Win+1 now costs.
;
; #MaxThreadsPerHotkey is 1, so a second Win+L arriving during the wait is
; discarded rather than queued. At these speeds that is hard to hit on purpose.
VdSend(keys) {
    AnimSuppress()          ; nested inside VdGoto's hold; a no-op there
    try {
        before := ReadDesktops()
        Send keys

        deadline := A_TickCount + VD_TIMEOUT
        Loop {
            Sleep 10
            now := ReadDesktops()
            if (now.count != before.count || (now.index && now.index != before.index))
                return now
        } Until (A_TickCount > deadline)

        Log("vd: '" keys "' did not take within " VD_TIMEOUT "ms")
        return ReadDesktops()
    } finally {
        AnimRelease()
    }
}

; ---------------------------------------------------------------- animation -

; The desktop-switch slide is governed by SPI_CLIENTAREAANIMATION -- and so is
; what Chrome reports to every website as prefers-reduced-motion. Turning it off
; system-wide (the first attempt at this) made instant switching, and also told
; every page on the web that alex wanted animation cut. The two are one switch;
; Windows offers no way to separate them, and Chromium has no flag to ignore the
; setting -- only --force-prefers-reduced-motion, which forces it the wrong way.
;
; The way out is that the shell reads the value *live*, while apps only re-read
; it when a WM_SETTINGCHANGE arrives. Passing fWinIni = 0 changes it for the
; session without writing the registry and without broadcasting, so the shell
; drops the slide and nothing else ever finds out. It is put back within about
; 30ms either way.
;
; Measured here: 402ms of slide with it on, 0ms with it quietly off, Chrome
; unaffected in both cases.

global AnimDepth := 0
global AnimWas   := 1
global AnimSince := 0

AnimGet() {
    v := 0
    DllCall("user32\SystemParametersInfoW", "uint", 0x1042    ; GETCLIENTAREAANIMATION
        , "uint", 0, "int*", &v, "uint", 0)
    return v
}

; fWinIni = 0 is the whole trick: no SPIF_UPDATEINIFILE, no SPIF_SENDCHANGE.
AnimSet(on) {
    DllCall("user32\SystemParametersInfoW", "uint", 0x1043    ; SETCLIENTAREAANIMATION
        , "uint", 0, "ptr", on ? 1 : 0, "uint", 0)
}

; Depth-counted so VdGoto can hold it across a walk while VdSend takes it per
; step. Only the outermost holder touches the setting.
AnimSuppress() {
    global AnimDepth, AnimWas, AnimSince
    if (!VD_QUIET_SWITCH)
        return
    if (AnimDepth = 0) {
        AnimWas := AnimGet()
        AnimSince := A_TickCount
        ; If animations are already off system-wide, leave the setting alone --
        ; there is nothing to suppress and nothing to put back.
        if (AnimWas)
            AnimSet(false)
    }
    AnimDepth++
}

AnimRelease() {
    global AnimDepth, AnimWas
    if (!VD_QUIET_SWITCH)
        return
    if (--AnimDepth <= 0) {
        AnimDepth := 0
        if (AnimWas)
            AnimSet(true)
    }
}

; Nothing is persisted, so a crash mid-switch would heal at the next sign-in --
; but leaving the session with animations off would still be rude.
AnimOnExit(*) {
    global AnimDepth, AnimWas
    if (AnimDepth > 0 && AnimWas)
        AnimSet(true)
}

; A leaked suppression is silent: the only symptom is every website quietly
; dropping its animations, which took a while to notice the first time. A walk
; finishes in well under a second, so anything still held after three seconds is
; a bug rather than work in progress -- take the setting back.
AnimWatchdog() {
    global AnimDepth, AnimWas, AnimSince
    if (AnimDepth > 0 && A_TickCount - AnimSince > 3000) {
        Log("anim: held " (A_TickCount - AnimSince) "ms -- forcing release")
        AnimDepth := 0
        if (AnimWas)
            AnimSet(true)
    }
}

#+l::DllCall("user32\LockWorkStation")

; ---------------------------------------------------------------- workspace -

; waybar's workspace block, parked in the taskbar's empty left end. Windows 11
; offers nothing to hook into here -- deskbands were removed with Windows 10 and
; the taskbar itself is closed XAML -- so this is a borderless topmost window
; laid over the dead space left of the centred icons. WS_EX_NOACTIVATE keeps it
; out of the focus chain: clicking a number switches desktops without the bar
; ever becoming the foreground window, which would otherwise confuse Alt+W's
; hide-and-restore about what it was covering.
;
; State is read from the registry rather than the undocumented virtual-desktop
; COM interface. That interface needs a helper DLL rebuilt for each Windows
; build, while VirtualDesktopIDs (one 16-byte GUID per desktop, in order) and
; CurrentVirtualDesktop have been stable for years. RegRead hands binary values
; back as hex, so finding the active index is a substring search -- no DllCall
; and nothing to keep in step with Windows.

BarStart() {
    BarRefresh()
    SetTimer BarRefresh, BAR_POLL
    A_TrayMenu.Check("Workspace bar")
}

BarToggle() {
    global Bar, BarCount, BarGeom
    if (Bar) {
        SetTimer BarRefresh, 0
        Bar.Destroy()
        Bar := 0, BarCount := 0, BarGeom := ""
        A_TrayMenu.Uncheck("Workspace bar")
        return
    }
    BarStart()
}

BarRefresh() {
    global BarIndex
    d := ReadDesktops()
    if (!d.count) {
        BarStash()
        return
    }
    if (d.index)
        BarIndex := d.index
    if (d.count != BarCount)
        BarBuild(d.count)
    BarPaint(BarIndex > d.count ? d.count : BarIndex)
    BarPlace()
}

; Rebuilt from scratch whenever the desktop count changes: adding and removing
; controls in place is not something a Gui supports, and desktops are created
; rarely enough that the flicker never shows.
BarBuild(count) {
    global Bar, BarCells, BarTones, BarCount, BarGeom

    if (Bar)
        Bar.Destroy()

    Bar := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    Bar.BackColor := BAR_BG
    Bar.MarginX := 0
    Bar.MarginY := 0
    Bar.SetFont("s10 w400 c" BAR_DIM, "Segoe UI")

    cell := BarPx(BAR_CELL)
    BarCells := [], BarTones := []
    Loop count {
        ; 0x200 is SS_CENTERIMAGE -- it centres the number vertically, which a
        ; plain Text control does not do.
        c := Bar.AddText("x" (A_Index - 1) * cell " y0 w" cell
            . " h" BarPx(BAR_HEIGHT) " Center 0x200", A_Index)
        c.OnEvent("Click", BarClick.Bind(A_Index))
        BarCells.Push(c)
        BarTones.Push("")
    }

    BarCount := count
    BarGeom := ""          ; force BarPlace to re-show at the new width
}

BarPaint(active) {
    for i, c in BarCells {
        tone := (i = active) ? BAR_ACTIVE " w600" : BAR_DIM " w400"
        if (BarTones[i] = tone)
            continue
        c.SetFont("c" tone)
        c.Redraw()
        BarTones[i] := tone
    }
}

BarPlace() {
    global BarGeom

    if (!(tray := WinExist("ahk_class Shell_TrayWnd"))) {
        BarStash()
        return
    }
    try WinGetPos &tl, &tt, &tw, &th, "ahk_id " tray
    catch {
        BarStash()
        return
    }

    MonitorGet MonitorFromPoint(tl + tw // 2, tt + th // 2), &ml, &mt, &mr, &mb

    ; An auto-hidden taskbar parks itself all but a couple of pixels off the
    ; screen. Riding along would leave the numbers floating over the wallpaper,
    ; so drop out of sight with it.
    if (tt >= mb - 4) {
        BarStash()
        return
    }

    ; A full-screen game or video owns the whole monitor. The taskbar stays put
    ; behind it, so its position tells us nothing -- the size of the foreground
    ; window is what says the screen is taken.
    if (IsFullScreen(ml, mt, mr, mb)) {
        BarStash()
        return
    }

    h := BarPx(BAR_HEIGHT)
    geom := "x" (tl + BarPx(BAR_MARGIN))
        . " y" (tt + (th - h) // 2)
        . " w" (BarCount * BarPx(BAR_CELL))
        . " h" h

    if (geom != BarGeom) {
        Bar.Show("NoActivate " geom)
        BarGeom := geom
    }

    ; Explorer re-asserts the taskbar's topmost position on its own schedule,
    ; which can bury the bar. Nudging ourselves back to the front of the topmost
    ; band is free when we are already there -- SetWindowPos with NOMOVE/NOSIZE
    ; repaints nothing -- so there is no need to detect the case first.
    DllCall("user32\SetWindowPos", "ptr", Bar.Hwnd, "ptr", -1     ; HWND_TOPMOST
        , "int", 0, "int", 0, "int", 0, "int", 0
        , "uint", 0x0013)                       ; NOSIZE|NOMOVE|NOACTIVATE
}

BarStash() {
    global BarGeom
    if (Bar && BarGeom != "") {
        Bar.Hide()
        BarGeom := ""
    }
}

; Clicks land without focus (WS_EX_NOACTIVATE), so this is the same jump Win+<n>
; performs -- Windows has no "go to desktop N" key, so VdGoto walks there.
BarClick(target, *) {
    VdGoto(target)
    BarRefresh()
}

; {count, index}; index is 0 when the current desktop cannot be matched against
; the list, which happens briefly while a switch is in flight.
ReadDesktops() {
    static KEY := "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"

    ids := "", cur := ""
    try ids := RegRead(KEY, "VirtualDesktopIDs")
    try cur := RegRead(KEY, "CurrentVirtualDesktop")

    ; Some builds keep the active desktop per session instead.
    if (cur = "")
        try cur := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
            . "\SessionInfo\" SessionId() "\VirtualDesktops", "CurrentVirtualDesktop")

    count := StrLen(ids) // 32          ; 16 bytes per GUID, 2 hex digits per byte
    index := 0
    if (count && StrLen(cur) = 32 && (p := InStr(ids, cur)))
        index := ((p - 1) // 32) + 1

    return {count: count, index: index}
}

SessionId() {
    sid := 0
    DllCall("kernel32\ProcessIdToSessionId"
        , "uint", DllCall("kernel32\GetCurrentProcessId", "uint")
        , "uint*", &sid)
    return sid
}

; The Gui is -DPIScale so that its coordinates line up with the taskbar rect,
; which WinGetPos reports in real pixels. That means the sizes above have to be
; scaled by hand.
BarPx(n) {
    return Round(n * A_ScreenDPI / 96)
}

; True when the foreground window covers the given monitor edge to edge. The
; wallpaper and the shell keep windows that big all the time, so they are ruled
; out by class. The bar itself is WS_EX_NOACTIVATE and never foreground.
IsFullScreen(ml, mt, mr, mb) {
    if (!(fg := DllCall("user32\GetForegroundWindow", "ptr")))
        return false

    cls := ""
    try cls := WinGetClass("ahk_id " fg)
    if (cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd")
        return false

    try WinGetPos &x, &y, &w, &h, "ahk_id " fg
    catch
        return false

    return x <= ml && y <= mt && x + w >= mr && y + h >= mb
}

MonitorFromPoint(x, y) {
    Loop MonitorGetCount() {
        MonitorGet A_Index, &l, &t, &r, &b
        if (x >= l && x < r && y >= t && y < b)
            return A_Index
    }
    return MonitorGetPrimary()
}
