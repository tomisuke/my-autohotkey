/*
#Requires AutoHotkey v2.0

; Discordのウィンドウクラスを指定
#HotIf WinActive("ahk_group CtrlEnterToSend")

; 入力中の文字数を保持
global count := 0

; ほぼ全てのキーが押された際の処理(半角/全角キー などは不要なので除く)
~*a::
~*b::
~*c::
~*d::
~*e::
~*f::
~*g::
~*h::
~*i::
~*j::
~*k::
~*l::
~*m::
~*n::
~*o::
~*p::
~*q::
~*r::
~*s::
~*t::
~*u::
~*v::
~*w::
~*x::
~*y::
~*z::
~*1::
~*2::
~*3::
~*4::
~*5::
~*6::
~*7::
~*8::
~*9::
~*0::
~*,::
~*.::
~*/::
~*;::
~*[::
~*]::
~*-::
~*=::
~*^::
~*\::  ; 右上の￥
~*sc073::  ; 右下の￥
~*vkBA::  ; コロンとアスタリスク
~*sc01A::  ; アットマーク(JISキーボード)
~*NumpadDiv::  ; テンキーパッドの /
~*NumpadMult::  ; テンキーパッドの *
~*NumpadAdd::  ; テンキーパッドの +
{
    global count
    count++
    
    ; 確認用
    ; ToolTip("countは: " . count)  ; カウントをツールチップで表示
    ; ToolTip("Key: " . A_ThisHotkey . "`nVK: " . Format("0x{:X}", GetKeyVK(A_ThisHotkey)) . "`nSC: " . Format("0x{:X}", GetKeySC(A_ThisHotkey)))
    ; SetTimer () => ToolTip(), -2000  ; 2秒後にツールチップを消す

    return
}


; マウスクリックが押された場合
; クリックの後すぐにEnterを押すと送信されてしまうのを防ぐ
~LButton::
~RButton::
~sc03A::  ; CapsLockキー単体
{
    global count
    count := 0
    return
}


; 半角/全角 が押された場合（「英語->ひらがな」ならcountを0にする）
~sc029::
{
    global count
    ; 押された瞬間のモードが取得できるので、「英語->ひらがな」の変更では「英語」が取得される
    imeMode := IME_GET()

    if (!imeMode) {
        count := 0
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

; Ctrl + v が押された場合
; Ctrl + vしてからすぐEnterを押したら送信されてしまうのを防ぐ
^v::
{
    global count
    imeMode := IME_GET()
    ; ひらがなモードで入力中にCtrl + v->Enter が効かない問題を解決
    if (!imeMode && count == 0) {
        count := 0
    }
    SendInput "^v"
    return
}


; Backspaceが押された場合
; 入力中の文字をすべて消してEnterを押すと送信されてしまうのを防ぐ
~BackSpace::
{
    global count
    if (count > 0) {
        count--
    }
    return
}


; Enter が押された場合
Enter::
NumpadEnter::  ; テンキーパッドのEnter
{
    global count
    imeMode := IME_GET()

    if (imeMode) {
        if (count == 0) {
            SendInput "+{Enter}"
        } else {
            SendInput "{Enter}"
            count := 0
        }
    } else {
        SendInput "+{Enter}"
        count := 0
    }

    return
}


; Ctrl + Enter が押された場合
^Enter::
{
    global count
    count := 0
    SendInput "{Enter}"
    return
}

#HotIf
*/