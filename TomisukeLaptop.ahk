#Requires AutoHotkey v2.0
;sc07b:無変換   sc079:変換

;入力抜け対策
SetKeyDelay 10, 10
SetWinDelay 100 ;default 100
SetControlDelay 20 ;default 20
SendMode "Event" ;default Input
;-----------------
#Include C:\Users\Tomisuke\Local\Activity\timestump-diary\diary.ahk
#Include %A_ScriptDir%/common/
#Include ctrlEntertoSend.ahk
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
;ピリオドレイヤー
;記号
. & r::Send "_"
. & d::Send "{sc028}"
. & y::Send "["
. & p::Send "]"
. & n::Send "!"
. & t::Send "?"
. & s::Send "("
. & k::Send ")"
. & h::Send "&"
. & m::Send "%"
. & g::Send '"'
. & j::Send "'"
. & f::Send "#"
. & Delete::Send "$"
. & b::Send "{{}"
. & z::Send "{}}"

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
, & n::Send 1
, & t::Send 2
, & s::Send 3
, & k::Send 0
, & h::Send 4
, & m::Send 5
, & b::Send 6
, & z::Send "."
, & r::Send 7
, & d::Send 8
, & y::Send 9
, & p::Send "*"
, & g:: Send "{BS}"
, & j::Send "+"
, & f::Send "-"
, & l::Send "/"

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
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_group IMEAbnormal")
F13:: IME_SET(1)
#HotIf
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_group IMEAbnormal")
F14:: IME_SET(0)
#HotIf
F14:: Send "{vk1A}" ;EnterToIMEOff

;補助
Space::Space
,::,
.::.
enter::Enter
-::-

SetTimer updateToolTip, 10

updateToolTip(){
    if(isIMEConverting())
        ToolTip("変換中")
    else{
        ToolTip("")
    }
}
