global activeLaptop := (A_ComputerName = "TomisukeLaptop")
global activeDesktop := (A_ComputerName = "TOMISUKEDESKTOP")

#HotIf WinActive("ahk_exe Discord.exe")
!F4:: WinClose("ahk_exe Discord.exe")
#HotIf
!^r:: Reload
!^e:: Edit

;単体動作と修飾キーを組み合わせた動作を条件分岐する関数
HandleModifierKeys(singleKey, modifiedKey) {
    ; 修飾キーの状態を取得
    modifiers := ""
    if GetKeyState("Ctrl", "P")
        modifiers .= "^"
    if GetKeyState("Shift", "P")
        modifiers .= "+"
    if GetKeyState("Alt", "P")
        modifiers .= "!"
    if GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
        modifiers .= "#"

    ; 修飾キーと指定されたキーを送信
    if (modifiers = "" OR modifiers = "+" OR modifiers = "!") {
        Send(modifiers singleKey)
    } else {
        Send(modifiers modifiedKey)
    }
    return
}
#HotIf GetKeyState("Ctrl", "P") or GetKeyState("LWin", "P") or GetKeyState("RWin", "P")
*x::z
*c::x
*v::c
*w:: {
    Send "{Blind}{v}"
    if GetKeyState("Ctrl", "P") {
        global IMEFlag
        IMEFlag := true
    }
}
*z::w
#HotIf

getRegularApps() {
    regularApps := []
    regularApps.Push("vivaldi")
    regularApps.Push("memo")
    regularApps.Push("claude")
    regularApps.Push("discord")
    regularApps.Push("notionCalendar")
    regularApps.Push("ticktick")
    regularApps.Push("vscode")
    regularApps.Push("thunderbird")
    regularApps.Push("onenote")
    regularApps.Push("obsidian")
    regularApps.Push("explorer")
    return regularApps
}
#e:: mylauncher.runApp("explorer")