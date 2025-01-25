#Requires AutoHotkey v2.0
!^e:: Edit
!^r:: Reload
#+1:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Opera ブラウザ.lnk"

#HotIf WinActive("ahk_exe Discord.exe")
!F4:: WinClose("ahk_exe Discord.exe")
#HotIf


;Discord
#HotIf WinActive("ahk_exe Discord.exe")
!^F16:: WinMinimize "ahk_exe Discord.exe"
#HotIf WinExist("ahk_exe Discord.exe")
!^F16:: WinActivate "ahk_exe Discord.exe"
#HotIf
!^F16:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
;カレンダー
#HotIf WinActive("ahk_exe Notion Calendar.exe")
!^F17:: WinMinimize "ahk_exe Notion Calendar.exe"
#HotIf WinExist("ahk_exe Notion Calendar.exe")
!^F17:: WinActivate "ahk_exe Notion Calendar.exe"
#HotIf
!^F17:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
;辞典
#HotIf WinActive("英和辞典・和英辞典 - Weblio辞書")
!^F18:: WinMinimize "英和辞典・和英辞典 - Weblio辞書"
#HotIf WinExist("英和辞典・和英辞典 - Weblio辞書")
!^F18:: WinActivate "英和辞典・和英辞典 - Weblio辞書"
#HotIf
!^F18:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi アプリ\Weblio辞書.lnk"
;ticktick
#HotIf WinActive("ahk_class HwndWrapper[TickTick.exe;;3146d733-ac5e-44fe-b9f5-48f25e56d54f]")
!^F19:: WinMinimize "ahk_class HwndWrapper[TickTick.exe;;3146d733-ac5e-44fe-b9f5-48f25e56d54f]"
#HotIf WinExist("ahk_class HwndWrapper[TickTick.exe;;3146d733-ac5e-44fe-b9f5-48f25e56d54f]")
!^F19:: WinActivate "ahk_class HwndWrapper[TickTick.exe;;3146d733-ac5e-44fe-b9f5-48f25e56d54f]"
#HotIf
!^F19:: Run "C:\Users\Tomisuke\Desktop\TickTick.lnk"
;VSCode
#HotIf WinActive("ahk_exe Code.exe")
!^F20:: WinMinimize "ahk_exe Code.exe"
#HotIf WinExist("ahk_exe Code.exe")
!^F20:: WinActivate "ahk_exe Code.exe"
#HotIf
!^F20:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
;thunderbird
#HotIf WinActive("ahk_exe thunderbird.exe")
!^F21:: WinMinimize "ahk_exe thunderbird.exe"
#HotIf WinExist("ahk_exe thunderbird.exe")
!^F21:: WinActivate "ahk_exe thunderbird.exe"
#HotIf
!^F21:: Run  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
;Onenote
#HotIf WinActive("ahk_exe Onenote.exe")
!^F22:: WinMinimize "ahk_exe Onenote.exe"
#HotIf WinExist("ahk_exe Onenote.exe")
!^F22:: WinActivate "ahk_exe Onenote.exe"
#HotIf
!^F22:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"

#e::#1
;frow launcher
Enter & j::!^+F13

;IME制御 
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
#HotIf WinExist("Flow.Launcher")
vk1A::  IME_SET(0)
vk16::  IME_SET(1)
#HotIf