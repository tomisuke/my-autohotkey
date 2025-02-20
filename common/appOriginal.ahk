#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe Code.exe")
Enter & a::^+E
#HotIf

#HotIf WinActive("ahk_exe studio64.exe")
Enter & a::Send "!6"
#HotIf
