#Requires AutoHotkey v2.0
!^r:: Reload
!^e:: Edit
Run "C:\Users\Tomisuke\Online\Home\MyAutohotkey\TomisukeLaptop.ahk"
RUn "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Flow Launcher\Flow Launcher.lnk"
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
WinWait("ahk_exe TickTick.exe")
WinMinimize("ahk_exe TickTIck.exe")
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
WinWait("ahk_exe Discord.exe")
WinMinimize("ahk_exe Discord.exe")
WinWait("ahk_exe Discord.exe")
WinMinimize("ahk_exe Discord.exe")
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
WinWait("ahk_exe LINE.exe")
WinHide("ahk_exe LINE.exe")
Run "C:\Program Files\WindowsApps\91750D7E.Slack_4.41.105.0_x64__8she8kybcnzg4\app\Slack.exe"
WinWait("ahk_exe Slack.exe")
WinHide("ahk_exe Slack.exe")
Run "explorer.exe shell:AppsFolder\Microsoft.YourPhone_8wekyb3d8bbwe!App"
WinWait("ahk_exe PhoneExperienceHost.exe")
WinHide("ahk_exe PhoneExperienceHost.exe")
WinWait("ahk_exe PhoneExperienceHost.exe")
WinHide("ahk_exe PhoneExperienceHost.exe")

Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\PowerToys (Preview)\PowerToys (Preview).lnk"
Run "C:\Program Files\Google\Drive File Stream\101.0.3.0\GoogleDriveFS.exe"
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Everything.lnk"
WinWait("ahk_exe Everything.exe")
WinHide("ahk_exe Everything.exe")
Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"
WinWait("ahk_exe ONENOTE.EXE")
WinHide("ahk_exe ONENOTE.EXE")
WinWait("ahk_exe ONENOTE.EXE")
WinHide("ahk_exe ONENOTE.EXE")
Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
WinWait("ahk_exe Notion Calendar.exe")
WinHide("ahk_exe Notion Calendar.exe")

ExitApp