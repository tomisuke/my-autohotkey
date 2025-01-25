#Requires AutoHotkey v2.0
!^e:: Edit
!^r:: Reload
#+1:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Opera ブラウザ.lnk"
;-----------------
#Include %A_ScriptDir%/common/
#Include runProgram.ahk
#Include IME.ahk
;-----------------
;スペースレイヤー
^!F13:: runProgram(1)
!^F14:: runProgram(2)
!^F15:: runProgram(3)
!^F16:: runProgram(4)
!^F17:: runProgram(5)
!^F18:: runProgram(6)
!^F19:: runProgram(7)
!^F20:: runProgram(8)
!^F21:: runProgram(9)
!^F22:: runProgram(10)
#e::#1

#HotIf WinExist("Flow.Launcher")
vk1A:: IME_SET(0)
vk16:: IME_SET(1)
#HotIf
Space::Space