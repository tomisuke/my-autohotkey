#Requires AutoHotkey v2.0
;sc07b:無変換   sc079:変換
;-----------------
#Include %A_ScriptDir%/common/
#Include runProgram.ahk
#Include IME.ahk
#include appOriginal.ahk
#include common.ahk
;-----------------
Pause:: {
    Run ".\TomisukeToQwerty.ahk"
    Msgbox "ゲストモード`nGuestMode", "LayoutChanger", "T0.5"
    ExitApp
}
qwerty := false
;ピリオドレイヤー
;記号
. & r::_
. & d::sc028
. & y::[
. & p::]
. & n::!
. & t::?
. & s::(
. & k::)
. & h::&
. & m::%
. & g::"
. & j::'
. & f::#
. & Delete::$
. & b:: Send "{{}"
. & z:: Send "{}}"

;enterレイヤー
;矢印
Enter & n:: Send "{Blind}{Left}"
Enter & t:: Send "{Blind}{Down}"
Enter & s:: Send "{Blind}{Up}"
Enter & k:: Send "{Blind}{Right}"
Enter & g:: Send "{Blind}{Home}"
Enter & f:: Send "{Blind}{End}"
Enter & d:: Send "!+^{F1}"
#HotIf WinActive("ahk_exe ONENOTE.EXE")
Enter & t:: DllCall("keybd_event", "UInt", 0x28, "UInt", 0, "UInt", 1, "UInt", 0) ; Down
Enter & s:: DllCall("keybd_event", "UInt", 0x26, "UInt", 0, "UInt", 1, "UInt", 0) ; Up
#HotIf

Enter & j::!^+F13 ;flowLauncher
Enter & h:: Send "+{sc079}" ;IMEon off修正
Enter & m:: Send "{AppsKey}"
Enter & y:: Send "{Blind}{up}"

;コンマレイヤー
, & n::1
, & t::2
, & s::3
, & k::0
, & h::4
, & m::5
, & b::6
, & z::.
, & r::7
, & d::8
, & y::9
, & p::*
, & g:: Send "{BS}"
, & j::+
, & f::-
, & Delete::*
, & l::/

!c::^+R

;スペースレイヤー
;アプリ起動
Space & a:: runProgram(1)
Space & o:: runProgram(2)
Space & e:: runProgram(3)
Space & i:: runProgram(4)
Space & u:: runProgram(5)
Space & x:: runProgram(6)
Space & c:: runProgram(7)
Space & v:: runProgram(8)
Space & w:: runProgram(9)
Space & Delete:: runProgram(10)
Space & `;:: runProgram(11)
#e:: runProgram(12)
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
;コピペショートカット
*x::HandleModifierKeys("x", "z")
*c::HandleModifierKeys("c", "x")
*v::HandleModifierKeys("v", "c")
*w::HandleModifierKeys("w", "v")
*z::HandleModifierKeys("z", "w")
;その他
sc029:: Send "{Esc}"
^+sc029:: Send "^+{Esc}"
;ime制御
#HotIf WinExist("Flow.Launcher")
F13:: IME_SET(1)
#HotIf
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
#HotIf WinExist("Flow.Launcher")
F14:: IME_SET(0)
#HotIf
F14:: Send "{vk1A}" ;EnterToIMEOff
;補助
Space::Space
,::,
.::.
enter::Enter
