#Requires AutoHotkey v2.0
!^r:: Reload
!^e:: Edit
timeOut := 20
;tomisukeLaptop
Run ".\TomisukeLaptop.ahk"
;FluentSearch
Run "C:\Program Files\Fluent Search\FluentSearch.exe"
;flowLauncher
Run "C:\Users\Tomisuke\AppData\Rosaming\Microsoft\Windows\Start Menu\Programs\Flow Launcher\Flow Launcher.lnk"
;clibor
Run "C:\Program Files\clibor\Clibor.exe"
;alttabTerminator
Run "C:\Program Files\Alt-Tab Terminator\AltTabTer.exe"
;earTrumpet
Run "explorer.exe shell:AppsFolder\404timeOut9File-New-Project.EarTrumpet_1sdd7yawvg6ne!EarTrumpet"
; twinkleTray
Run "explorer.exe shell:AppsFolder\TwinkleTray_8wekyb3d8bbwe!TwinkleTray"
;TickTick
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
WinWait("ahk_exe TickTick.exe", , timeOut)
WinMinimize("ahk_exe TickTIck.exe")
;Thunderbird
Run "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
WinWait("ahk_exe Thunderbird.exe", , timeOut)
WinMinimize("ahk_exe Thunderbird.exe")
;Discord
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
WinWait("ahk_exe Discord.exe", , timeOut)
WinMinimize("ahk_exe Discord.exe")
Loop 10 {
    if WinExist("ahk_exe Discord.exe") {
        WinMinimize("ahk_exe Discord.exe")
        break
    }
    Sleep 500
}
;Slack
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk"
WinWait("ahk_exe Slack.exe", , timeOut)
WinHide("ahk_exe Slack.exe")
;スマートフォン連携
Run "explorer.exe shell:AppsFolder\Microsoft.YourPhone_8wekyb3d8bbwe!App"
WinWait("ahk_exe PhoneExperienceHost.exe", , timeOut)
WinHide("ahk_exe PhoneExperienceHost.exe")
;GoogleDrive
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk"
;powerToys
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerToys (Preview)\PowerToys (Preview).lnk"
;everything
Run "C:\Program Files\Everything\Everything.exe"
WinWait("ahk_exe Everything.exe", , timeOut)
WinHide("ahk_exe Everything.exe")
;onedrive
Run A_ProgramFiles . "\Microsoft OneDrive\OneDrive.exe"
;NotionCalendar
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
WinWait("ahk_exe Notion Calendar.exe", , timeOut)
WinHide("ahk_exe Notion Calendar.exe")
ExitApp