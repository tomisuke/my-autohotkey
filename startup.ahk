#Requires AutoHotkey v2.0
!^r:: Reload
!^e:: Edit
;tomisukeLaptop
Run ".\TomisukeLaptop.ahk"
;flowLauncher
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Flow Launcher\Flow Launcher.lnk"
;clibor
Run "C:\Program Files\clibor\Clibor.exe"
;alttabTerminator
Run "C:\Program Files\Alt-Tab Terminator\AltTabTer.exe"
;earTrumpet
Run "explorer.exe shell:AppsFolder\40459File-New-Project.EarTrumpet_1sdd7yawvg6ne!EarTrumpet"
; twinkleTray
Run "explorer.exe shell:AppsFolder\TwinkleTray_8wekyb3d8bbwe!TwinkleTray"
;TickTick
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
WinWait("ahk_exe TickTick.exe")
WinMinimize("ahk_exe TickTIck.exe")
;Discord
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
WinWait("ahk_exe Discord.exe")
WinMinimize("ahk_exe Discord.exe")
WinWait("ahk_exe Discord.exe")
WinMinimize("ahk_exe Discord.exe")
;Slack
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk"
WinWait("ahk_exe Slack.exe")
WinHide("ahk_exe Slack.exe")
;スマートフォン連携
Run "explorer.exe shell:AppsFolder\Microsoft.YourPhone_8wekyb3d8bbwe!App"
WinWait("ahk_exe PhoneExperienceHost.exe")
WinHide("ahk_exe PhoneExperienceHost.exe")
WinWait("ahk_exe PhoneExperienceHost.exe")
WinHide("ahk_exe PhoneExperienceHost.exe")
;GoogleDrive
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk"
;powerToys
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerToys (Preview)\PowerToys (Preview).lnk"
;everything
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything.lnk"
WinWait("ahk_exe Everything.exe")
WinHide("ahk_exe Everything.exe")
;NotionCalendar
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
WinWait("ahk_exe Notion Calendar.exe")
WinHide("ahk_exe Notion Calendar.exe")
;RIZE
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub, Inc\Rize.lnk"
WinWait("ahk_exe Rize.exe")
WinHide("ahk_exe Rize.exe")
;DeepL
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\DeepL.lnk"
WinWait("ahk_exe DeepL.exe")
WinHide("ahk_exe DeepL.exe")
;LINE
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
ExitApp
