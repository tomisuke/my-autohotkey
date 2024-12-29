#Requires AutoHotkey v2.0
;sc07b:無変換   sc079:変換
/*sec := 0
Enter & q:: {
    global sec
    if (sec = 0) {
        sec := 1
    } else {
        sec := 0
    }
    MsgBox sec
}
#HotIf sec = 0
*/
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

Enter & h:: Send "+{sc079}"
; Enter & q:: {
;     Run "C:\Users\Tomisuke\Online\GitHub\MyAutohotkey\TomisukeToQwerty.ahk"
;     MsgBox "ゲストモード`nGuestMode", "LayoutChanger", "T2"
;     ExitApp
; }

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
;vivaldi
Space & a:: {
    if WinActive("ahk_exe vivaldi.exe") {
        activeID := WinGetID("A")
        WinMinimize(activeID)
        IDList := WinGetList("ahk_exe vivaldi.exe")
        for ID in IDList {
            if (!WinActive(ID) AND ID != activeID) {
                WinActivate(ID)
                break
            }
        }
    }
    else if WinExist("ahk_exe vivaldi.exe") {
        WinActivate "ahk_exe vivaldi.exe"
    }
    else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk"
    }
}


;メモ帳
#HotIf WinActive("ahk_exe Notepad.exe")
Space & o:: WinMinimize("ahk_exe Notepad.exe")
#HotIf WinExist("ahk_exe Notepad.exe")
Space & o:: WinActivate "ahk_exe Notepad.exe"
#HotIf
Space & o:: Run "C:\Windows\notepad.exe"
;LINE
#HotIf WinActive("ahk_exe LINE.exe")
Space & e:: WinHide("ahk_exe LINE.exe")
#HotIf WinExist("ahk_exe LINE.exe")
Space & e:: WinActivate "ahk_exe LINE.exe"
#HotIf
Space & e:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
;discord
#HotIf WinActive("ahk_exe Discord.exe")
Space & i:: WinMinimize("ahk_exe Discord.exe")
#HotIf WinExist("ahk_exe Discord.exe")
Space & i:: WinActivate "ahk_exe Discord.exe"
#HotIf
Space & i:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
;notionカレンダー
#HotIf WinActive("ahk_exe Notion Calendar.exe")
Space & u:: WinMinimize("ahk_exe Notion Calendar.exe")
#HotIf WinExist("ahk_exe Notion Calendar.exe")
Space & u:: WinActivate "ahk_exe Notion Calendar.exe"
#HotIf
Space & u:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
;Zoom
#HotIf WinActive("ahk_class ConfMultiTabContentWndClass")
Space & x:: WinMinimize("ahk_class ConfMultiTabContentWndClass")
#HotIf WinExist("ahk_class ConfMultiTabContentWndClass")
Space & x:: WinActivate "ahk_class ConfMultiTabContentWndClass"
#HotIf
;ticktick
Space & c:: {
    if WinActive("ahk_exe TickTick.exe") {
        WinMinimize "ahk_exe TickTick.exe"
    } else if WinExist("ahk_exe TickTick.exe") {
        WinActivate "ahk_exe TickTick.exe"
    } else {
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
    }
}
;VSCode
Space & v:: {
    if WinActive("ahk_exe Code.exe") {  ;vscode active
        WinMinimize "ahk_exe Code.exe"
        if WinExist("ahk_exe idea64.exe") {
            WinActivate "ahk_exe idea64.exe"
        }
    } else if WinActive("ahk_exe idea64.exe") { ;idea active
        WinMinimize "ahk_exe idea64.exe"
        if WinExist("ahk_exe Code.exe") {
            WinActivate "ahk_exe Code.exe"
        }
    } else if WinExist("ahk_exe Code.exe") {    ;vscode exist
        WinActivate("ahk_exe Code.exe")
    } else if WinExist("ahk_exe idea64.exe") {  ;idea exist
        WinActivate "ahk_exe idea64.exe"
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
    }
}
;thunderbird
#HotIf WinActive("ahk_exe thunderbird.exe")
Space & w:: WinMinimize "ahk_exe thunderbird.exe"
#HotIf WinExist("ahk_exe thunderbird.exe")
Space & w:: WinActivate "ahk_exe thunderbird.exe"
#HotIf
Space & w:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
#HotIf WinExist("ahk_exe ONENOTE.EXE")
;Onenote
#HotIf WinActive("ahk_exe ONENOTE.EXE")
Space & Delete:: WinMinimize "ahk_exe ONENOTE.EXE"
#HotIf WinExist("ahk_exe ONENOTE.EXE")
Space & Delete:: WinActivate "ahk_exe ONENOTE.EXE"
#HotIf
Space & Delete:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"
;explorer
#HotIf WinActive("ahk_class CabinetWClass")
#e:: WinMinimize "ahk_class CabinetWClass"
#HotIf WinExist("ahk_class CabinetWClass")
#e:: WinActivate "ahk_class CabinetWClass"
#HotIf
#e:: Run "C:\Windows\explorer.exe"
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
sc029:: Send "{Esc}"
^+sc029:: Send "^+{Esc}"

#HotIf WinActive("ahk_exe Discord.exe")
!F4:: WinClose("ahk_exe Discord.exe")
#HotIf

;IME制御
#HotIf WinExist("Flow.Launcher")
F13:: IME_SET(1)
#HotIf
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
#HotIf WinExist("Flow.Launcher")
F14:: IME_SET(0)
#HotIf
F14:: Send "{vk1A}" ;EnterToIMEOff
IME_SET(SetSts, WinTitle := "A") {
    hwnd := WinGetID(WinTitle)
    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize ? A_PtrSize : 4
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if (DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", stGTI)) {
            hwnd := NumGet(stGTI, 8 + ptrSize, "UInt")
        }
    }

    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; Message : WM_IME_CONTROL
        , "Ptr", 0x006    ; wParam  : IMC_SETOPENSTATUS
        , "Ptr", SetSts)  ; lParam  : 0 or 1
}

;補助
Space::Space
,::,
.::.
enter::Enter
;#HotIf
