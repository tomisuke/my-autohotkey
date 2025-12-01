#Requires AutoHotkey v2.0

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
;スペースレイヤー
^!F13:: runApp(regularApps[1])
!^F14:: runApp(regularApps[2])
!^F15:: runApp(regularApps[3])
!^F16:: runApp(regularApps[4])
!^F17:: runApp(regularApps[5])
!^F18:: runApp(regularApps[6])
!^F19:: runApp(regularApps[7])
!^F20:: runApp(regularApps[8])
!^F21:: runApp(regularApps[9])
!^F22:: runApp(regularApps[10])
;モニター切り換え
!^+F13:: {
    Send "#{p}"
    Sleep 50
    Send "{Tab}"
    Sleep 50
    loop (2) {
        Send "{Down}"
        Sleep 50
    }
}
#HotIf WinExist("Flow.Launcher")
vk1A:: IME_SET(0)
vk16:: IME_SET(1)
#HotIf
Space::Space
enter::enter
