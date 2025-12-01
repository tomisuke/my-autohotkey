SetKeyDelay 50, 50
SetWinDelay 100
SetControlDelay 20

#Requires AutoHotkey v2.0
;sc07b:無変換   sc079:変換
;-----------------
#Include C:\Users\Tomisuke\Local\Activity\timestump-diary\diary.ahk
#Include %A_ScriptDir%/common/
#Include DiscordKeybind.ahk
#Include runApp.ahk
#Include IME.ahk
#include appOriginal.ahk
#include common.ahk
#Include string.ahk
#Include Launcher/
#include bookmark.ahk
#Include launcher.ahk
;-----------------
Pause:: {
    Run ".\TomisukeToQwerty.ahk"
    Msgbox "ゲストモード`nGuestMode", "LayoutChanger", "T0.5"
    ExitApp
}
qwerty := false
;ピリオドレイヤー
;記号
. & r:: {
    global charCount
    Send "_"
    charCount++
}
. & d:: {
    global charCount
    Send "{sc028}"
    charCount++
}
. & y:: {
    global charCount
    Send "["
    charCount++
}
. & p:: {
    global charCount
    Send "]"
    charCount++
}
. & n:: {
    global charCount
    Send "!"
    charCount++
}
. & t:: {
    global charCount
    Send "?"
    charCount++
}
. & s:: {
    global charCount
    Send "("
    charCount++
}
. & k:: {
    global charCount
    Send ")"
    charCount++
}
. & h:: {
    global charCount
    Send "&"
    charCount++
}
. & m:: {
    global charCount
    Send "%"
    charCount++
}
. & g:: {
    global charCount
    Send '"'
    charCount++
}
. & j:: {
    global charCount
    Send "'"
    charCount++
}
. & f:: {
    global charCount
    Send "#"
    charCount++
}
. & Delete:: {
    global charCount
    Send "$"
    charCount++
}
. & b:: {
    global charCount
    Send "{{}"
    charCount++
}
. & z:: {
    global charCount
    Send "{}}"
    charCount++
}

;enterレイヤー
;矢印
Enter & n:: Send "{Blind}{Left}"
Enter & t:: Send "{Blind}{Down}"
Enter & s:: Send "{Blind}{Up}"
Enter & k:: Send "{Blind}{Right}"
Enter & g:: Send "{Blind}{Home}"
Enter & f:: Send "{Blind}{End}"

#HotIf WinActive("ahk_exe ONENOTE.EXE")
Enter & t:: DllCall("keybd_event", "UInt", 0x28, "UInt", 0, "UInt", 1, "UInt", 0) ; Down
Enter & s:: DllCall("keybd_event", "UInt", 0x26, "UInt", 0, "UInt", 1, "UInt", 0) ; Up
#HotIf

Enter & h:: Send "!+^{F1}"  ;fluentSearch
Enter & m:: Send "+{sc079}" ;再度変換
Enter & y:: Send "{Blind}{up}"

;コンマレイヤー
, & n:: {
    global charCount
    Send 1
    charCount++
}
, & t:: {
    global charCount
    Send 2
    charCount++
}
, & s:: {
    global charCount
    Send 3
    charCount++
}
, & k:: {
    global charCount
    Send 4
    charCount++
}
, & h:: {
    global charCount
    Send 0
    charCount++
}
, & m:: {
    global charCount
    Send 5
    charCount++
}
, & b:: {
    global charCount
    Send 6
    charCount++
}
, & z:: {
    global charCount
    Send "."
    charCount++
}
, & r:: {
    global charCount
    Send 7
    charCount++
}
, & d:: {
    global charCount
    Send 8
    charCount++
}
, & y:: {
    global charCount
    Send 9
    charCount++
}
, & p:: {
    global charCount
    Send "*"
    charCount++
}
, & g:: Send "{BS}"
, & j::{
    global charCount
    Send "+"
    charCount++
}
, & f::{
    global charCount
    Send "-"
    charCount++
}
, & l::{
    global charCount
    Send "/"
    charCount++
}

!c::^+R

;スペースレイヤー
;アプリ起動
Space & a:: runApp(regularApps[1])
Space & o:: runApp(regularApps[2])
Space & e:: runApp(regularApps[3])
Space & i:: runApp(regularApps[4])
Space & u:: runApp(regularApps[5])
Space & x:: runApp(regularApps[6])
Space & c:: runApp(regularApps[7])
Space & v:: runApp(regularApps[8])
Space & w:: runApp(regularApps[9])
Space & Delete:: runApp(regularApps[10])

;-レイヤー
- & n::AppsKey
- & t::+Tab
- & s::Tab

;FN
Space & j::F1
Space & h::F2
Space & m::F3
Space & b::F4
Space & z::F5
Space & \::F6
Space & g::F7
Space & n::F8
Space & t::F9
Space & s::F10
Space & k::F11
Space & f::F12
;輝度調整
Space & 1::!^F1
Space & ,::!^F2
;音量調整
Space & .::Volume_Down
Space & -::Volume_Up
Space & 4::Volume_Mute
;音声入出力切り換え
Space & ]::!^F4
Space & [::!^F5
;clibor
Enter & B::!^+0
Enter & z::!^+1
Enter & sc073::!^+2
;その他
sc029:: Send "{Esc}"
^+sc029:: Send "^+{Esc}"
Enter & j::!^+F13 ;flowLauncher
;ime制御
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_exe YukkuriMovieMaker.exe")
F13:: IME_SET(1)
#HotIf
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_exe YukkuriMovieMaker.exe")
F14:: IME_SET(0)
#HotIf
F14:: Send "{vk1A}" ;EnterToIMEOff

;補助
Space::Space
,::,
.::.
enter::Enter
-::-
/*
^F12::{
    send "!{Tab}"
    Sleep 200
    Send "{Enter}"
    Sleep 200
    Send "{Enter}"
    Sleep 200
    send "!{Tab}"
    Sleep 500
    Send "{Enter}"
}
*/
