#Requires AutoHotkey v2.0
!^e:: Edit
!^r:: Reload
#+1:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Opera ブラウザ.lnk"

#HotIf WinActive("ahk_exe Discord.exe")
!F4:: WinClose("ahk_exe Discord.exe")
#HotIf


;スペースレイヤー
;Winactive
#HotIf WinExist("ahk_exe vivaldi.exe")
^!F13:: WinActivate "ahk_exe vivaldi.exe"
#HotIf
^!F13:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk"
#HotIf WinExist("ahk_exe Notepad.exe")
!^F14:: WinActivate "ahk_exe Notepad.exe"
#HotIf
!^F14:: Run "C:\Windows\notepad.exe"
#HotIf WinExist("ahk_exe LINE.exe")
!^F15:: WinActivate "ahk_exe LINE.exe"
#HotIf
!^F15:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
#HotIf WinExist("ahk_exe Discord.exe")
!^F16:: WinActivate "ahk_exe Discord.exe"
#HotIf
!^F16:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
#HotIf WinExist("Google カレンダー")
!^F17:: WinActivate "Google カレンダー"
#HotIf
!^F17:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome アプリ\Google カレンダー.lnk"
#HotIf WinExist("英和辞典・和英辞典 - Weblio辞書")
!^F18:: WinActivate "英和辞典・和英辞典 - Weblio辞書"
#HotIf
!^F18:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi アプリ\Weblio辞書.lnk"
#HotIf WinExist("Habitica - タスク | Habitica")
!^F19:: WinActivate "Habitica - タスク | Habitica"
#HotIf
!^F19:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome アプリ\Habitica.lnk"
#HotIf WinExist("ahk_exe Code.exe")
!^F20:: WinActivate "ahk_exe Code.exe"
#HotIf
!^F20:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
#HotIf WinExist("ahk_exe thunderbird.exe")
!^F21:: WinActivate "ahk_exe thunderbird.exe"
#HotIf
!^F21:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
#HotIf WinExist("ahk_exe Onenote.exe")
!^F22:: WinActivate "ahk_exe Onenote.exe"
#HotIf
!^F22:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"

#e::#1