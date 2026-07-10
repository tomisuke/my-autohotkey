#Requires AutoHotkey v2.0
global activeLaptop
global activeDesktop
#HotIf WinActive("ahk_exe Code.exe") AND activeLaptop
Enter & a::^+E
#HotIf

#HotIf WinActive("ahk_exe studio64.exe") AND activeLaptop
Enter & a:: Send "!6"
#HotIf

;Workona
#HotIf (WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe vivaldi.exe")) AND activeLaptop
Enter & v:: Send "!+{2}"
Enter & w:: {
    Send "!+{3}"
    IME_SET(1)
    Send "{a}"
    Send "{Backspace}"
    Send "{Backspace}"

}
#HotIf

#HotIf WinActive("ahk_exe TickTick.exe") AND activeDesktop
!+^F19::^1
!+^F20::^2
!+^F21::^3
!+^F22::^4
!+^F23::^5
#HotIf

#HotIf WinActive("Gemini - Google Gemini")
^n::^+o
#HotIf