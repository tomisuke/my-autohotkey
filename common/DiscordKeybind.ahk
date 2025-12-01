#Requires AutoHotkey v2.0

global charCount := 0
#HotIf WinActive("ahk_group CtrlEnterToSend")
ihCount := InputHook("V", "{Enter}")
ihCount.Start()
ihCount.OnChar := countCharacter
TargetChars := "abcdefghijklmnopqrstuvwxyz1234567890,.;/[]\-^\\`*=+@*"
CharSet := CreateLookupMap(TargetChars)
CreateLookupMap(str) {
    lookup := Map()
    Loop Parse, str {
        lookup[A_LoopField] := true
    }
    return lookup
}

IsCharInSet(char) {
    return CharSet.Has(char)
}
countCharacter(ih, char) {
    global charCount
    if (IsCharInSet(char)) {
        charCount++
    }
}

; マウスクリックが押された場合
; クリックの後すぐにEnterを押すと送信されてしまうのを防ぐ
~LButton::
~RButton::
~sc03A::  ; CapsLockキー単体
{
    global charCount
    charCount := 0
    return
}
; 半角/全角 が押された場合（「英語->ひらがな」ならcountを0にする）
~sc029::
{
    global charCount
    ; 押された瞬間のモードが取得できるので、「英語->ひらがな」の変更では「英語」が取得される
    imeMode := IME_GET()

    if (!imeMode) {
        charCount := 0
    }

    return
}
; Ctrl + c が押された場合
; ひらがなモードかつ入力中でない時にctrl + c押してEnterを押すと送信されてしまうのを防ぐ
; この中の処理が優先されるのでctrl + cの「c」の本来の1回分のcountプラス処理は行われなくなる
^c::
{
    SendInput "^c"
    return
}
^v::
{
    global charCount
    imeMode := IME_GET()
    ; ひらがなモードで入力中にCtrl + v->Enter が効かない問題を解決
    if (!imeMode && charCount == 0) {
        charCount := 0
    }
    SendInput "^v"
    return
}
~BackSpace::
{
    global charCount
    if (charCount > 0) {
        charCount--
    }
    return  
}
Enter::
NumpadEnter::
{
    global charCount
    imeMode := IME_GET()

    if (imeMode) {
        if (IME_GetConverting() == 0) {
            SendInput "+{Enter}"
        } else {
            SendInput "{Enter}"
            charCount := 0
        }
    } else {
        SendInput "+{Enter}"
        charCount := 0
    }
    return
}
^Enter::
{
    global charCount
    charCount := 0
    SendInput "{Enter}"
    return
}
#HotIf