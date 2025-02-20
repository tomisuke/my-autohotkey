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
    if (modifiers = "" OR modifiers = "+") {
        Send(modifiers singleKey)
    } else {
        Send(modifiers modifiedKey)
    }
    return
}
