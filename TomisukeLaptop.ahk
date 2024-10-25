#Requires AutoHotkey v2.0
;sc07b:無変換   sc079:変換
qwerty := false
!^r:: Reload
!^e:: Edit
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

#HotIf WinActive("ahk_exe ONENOTE.EXE")
Enter & t:: SendPlay "{Blind}{Down}"
Enter & s:: SendPlay "{Blind}{Up}"
#HotIf

Enter & h::Send "+{sc079}"
Enter & q:: {
    Run "C:\Users\Tomisuke\Online\Home\AHK\TomisukeToQwerty.ahk"
    MsgBox "ゲストモード`nGuestMode", "LayoutChanger", "T2"
    ExitApp
}

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
;Winactive
#HotIf WinExist("ahk_exe vivaldi.exe")
Space & a:: WinActivate "ahk_exe vivaldi.exe"
#HotIf
Space & a:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk"
#HotIf WinExist("ahk_exe Notepad.exe")
Space & o:: WinActivate "ahk_exe Notepad.exe"
#HotIf
Space & o:: Run "C:\Windows\notepad.exe"
#HotIf WinExist("ahk_exe LINE.exe")
Space & e:: WinActivate "ahk_exe LINE.exe"
#HotIf
Space & e:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
#HotIf WinExist("ahk_exe Discord.exe")
Space & i:: WinActivate "ahk_exe Discord.exe"
#HotIf
Space & i:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
#HotIf WinExist("Google カレンダー")
Space & u:: WinActivate "Google カレンダー"
#HotIf
Space & u:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi アプリ\Google カレンダー.lnk"
#HotIf WinExist("英和辞典・和英辞典 - Weblio辞書")
Space & x:: WinActivate "英和辞典・和英辞典 - Weblio辞書"
#HotIf
Space & x:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi アプリ\Weblio辞書.lnk"
#HotIf WinExist("todoist.exe")
Space & c:: WinActivate "todoist.exe"
#HotIf
Space & c:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Todoist.lnk"
#HotIf WinExist("ahk_exe Code.exe")
Space & v:: WinActivate "ahk_exe Code.exe"
#HotIf
Space & v:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
#HotIf WinExist("ahk_exe thunderbird.exe")
Space & w:: WinActivate "ahk_exe thunderbird.exe"
#HotIf
Space & w:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
#HotIf WinExist("ahk_exe Onenote.exe")
Space & Delete:: WinActivate "ahk_exe Onenote.exe"
#HotIf
Space & Delete:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"

#e::#1

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
Space & `;::!^F3
Space & 4::Volume_Mute
;音声入出力切り換え
Space & ]::!^F4
Space & [::!^F5

;その他
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
F14:: Send "{vk1A}" ;EnterToIMEOff
sc029:: Send "{Esc}"
^+sc029::Send "^+{Esc}"

#HotIf WinActive("ahk_exe Discord.exe")
!F4:: WinClose("ahk_exe Discord.exe")
#HotIf

;補助
Space::Space
,::,
.::.
enter::Enter