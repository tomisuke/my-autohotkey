#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe Code.exe")
Enter & a::^+E
#HotIf

#HotIf WinActive("ahk_exe studio64.exe")
Enter & a::Send "!6"
#HotIf

;Workona
#HotIf WinActive("ahk_exe chrome.exe" OR "ahk_exe vivaldi.exe") 
Enter & v::Send "!+{2}"
Enter & w::Send "!+{3}"
#HotIf