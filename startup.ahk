#Requires AutoHotkey v2.0
!^r:: Reload
!^e:: Edit
Run "C:\Users\Tomisuke\Online\GitHub\MyAutohotkey\TomisukeLaptop.ahk"
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
isStartupAll := false
flagTickTick := false
flagDiscord := false
while !isStartupAll{
    if (WinActive("ahk_exe TickTick.exe") AND flagTickTick = false){
        WinMinimize "ahk_exe TickTick.exe"
        flagTickTick := true
    }else if (WinActive("ahk_exe Discord.exe") AND flagDiscord = false){
        WinMinimize "ahk_exe Discord.exe"
        flagDiscord := true
    }
    if flagTickTick AND flagDiscord{
        isStartupAll := true
        ExitApp
    }
    ;MsgBox "test"
}