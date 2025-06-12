GroupAdd "CtrlEnterToSend", "ahk_exe Discord.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ChatGPT.exe"

GroupAdd "IMEAbnormal", "ahk_exe YukkuriMovieMaker.exe"
GroupAdd "IMEAbnormal", "Flow.Launcher"
app := Map()
app["vivaldi"] := {
    name: "ahk_exe vivaldi.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk",
}
app["memo"] := {
    name: "ahk_exe Notepad.exe",
    address: "C:\Windows\notepad.exe",
}
app["discord"] := {
    name: "ahk_exe Discord.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk",
}
app["notionCalendar"] := {
    name: "ahk_exe Notion Calendar.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk",
}
app["zoom"] := {
    name: "ahk_class ConfMultiTabContentWndClass",
}
app["ticktick"] := {
    name: "ahk_exe TickTick.exe",
    address: "C:\Program Files (x86)\TickTick\TickTick.exe",
}
app["vscode"] := {
    name: "ahk_exe Code.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk",
}
app["thunderbird"] := {
    name: "ahk_exe thunderbird.exe",
    address: "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk",
}
app["onenote"] := {
    name: "ahk_exe ONENOTE.EXE",
    address: "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk",
}
app["explorer"] := {
    name: "ahk_class CabinetWClass",
    address: "C:\Windows\explorer.exe",
}
app["chatGPT"] := {
    name: "ahk_exe ChatGPT.exe",
    address: "explorer.exe shell:AppsFolder\OpenAI.ChatGPT-Desktop_2p2nqsd0c76g0!ChatGPT",
}

for i, x in app {
    app[i].num := 1
}
