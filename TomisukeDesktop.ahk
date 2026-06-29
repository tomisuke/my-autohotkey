#SingleInstance Force
#Requires AutoHotkey v2.0

;入力抜け対策
SetKeyDelay 10, 10
SetWinDelay 100 ;default 100
SetControlDelay 20 ;default 20
SendMode "Event" ;default Input
;-----------------
#Include C:\Users\Tomisuke\Local\Activity\timestump-diary\diary.ahk
#Include %A_ScriptDir%/common/
#include common.ahk


#include appOriginal.ahk
#Include ctrlEntertoSend.ahk
#Include runApp.ahk
#Include IME.ahk
#Include string.ahk
#Include Launcher/
#include bookmark.ahk
#Include launcher.ahk
;-----------------
mylauncher := appManager()
OutputDebug("TomisukeDesktop.ahk loaded")

^+!F15::launcher()
;スペースレイヤー
^!F13:: mylauncher.runRegularApp(1)
!^F15:: mylauncher.runRegularApp(3)
!^F16:: mylauncher.runRegularApp(4)
!^F17:: mylauncher.runRegularApp(5)
!^F18:: mylauncher.activeAnotherApp()
!^F19:: mylauncher.runRegularApp(6)
!^F20:: mylauncher.runRegularApp(7)
!^F21:: mylauncher.runRegularApp(8)
!^F22:: mylauncher.runRegularApp(9)
!^F23:: mylauncher.runRegularApp(10)

!+3:: launcher()
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