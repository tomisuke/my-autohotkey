GroupAdd "CtrlEnterToSend", "ahk_exe Discord.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ChatGPT.exe"

GroupAdd "IMEAbnormal", "ahk_exe YukkuriMovieMaker.exe"
GroupAdd "IMEAbnormal", "Flow.Launcher"
app := Map()
app["vivaldi"] := {
    name: "ahk_exe vivaldi.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk",
    num: 1
}
app["memo"] := {
    name: "ahk_exe Notepad.exe",
    address: "C:\Windows\notepad.exe",
    num: 1
}
app["discord"] := {
    name: "ahk_exe Discord.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk",
    num: 1,
}
app["notionCalendar"] := {
    name: "ahk_exe Notion Calendar.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk",
    num: 1,
}
app["zoom"] := {
    name: "ahk_class ConfMultiTabContentWndClass",
    num: 1,
}
app["ticktick"] := {
    name: "ahk_exe TickTick.exe",
    address: "C:\Program Files (x86)\TickTick\TickTick.exe",
    num: 1,
}
app["vscode"] := {
    name: "ahk_exe Code.exe",
    address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk",
    num: 1,
}
app["thunderbird"] := {
    name: "ahk_exe thunderbird.exe",
    address: "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk",
    num: 1,
}
app["onenote"] := {
    name: "ahk_exe ONENOTE.EXE",
    address: "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk",
    num: 1,
}
app["explorer"] := {
    name: "ahk_class CabinetWClass",
    address: "C:\Windows\explorer.exe",
    num: 1,
}
app["chatGPT"] := {
    name: "ahk_exe ChatGPT.exe",
    address: "explorer.exe shell:AppsFolder\OpenAI.ChatGPT-Desktop_2p2nqsd0c76g0!ChatGPT",
    num: 1,
}
