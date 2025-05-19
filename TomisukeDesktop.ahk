#Requires AutoHotkey v2.0

;-----------------
#Include %A_ScriptDir%/common/
#Include runProgram.ahk
#Include IME.ahk
#include appOriginal.ahk
#include common.ahk
;-----------------
;スペースレイヤー
^!F13:: runApp("vivaldi")
!^F14:: runApp("memo")
!^F15:: runApp("chatGPT")
!^F16:: runApp("discord")
!^F17:: runApp("notionCalendar")
!^F18:: runApp("zoom")
!^F19:: runApp("ticktick")
!^F20:: runApp("vscode")
!^F21:: runApp("thunderbird")
!^F22:: runApp("onenote")
#e:: runApp("explorer")
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