GroupAdd "CtrlEnterToSend", "ahk_exe Discord.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ChatGPT.exe"

GroupAdd "IMEAbnormal", "ahk_exe YukkuriMovieMaker.exe"
GroupAdd "IMEAbnormal", "Flow.Launcher"
apps := Map()
apps["vivaldi"] := {
    name: "ahk_exe vivaldi.exe",
    address: EnvGet("LOCALAPPDATA") . "\Vivaldi\Application\vivaldi.exe",
}
apps["memo"] := {
    name: "ahk_exe Notepad.exe",
    address: "C:\Windows\notepad.exe",
}
apps["discord"] := {
    name: "ahk_exe Discord.exe",
    address: GetDiscordExe(),
}
GetDiscordExe(){
    base := EnvGet("LOCALAPPDATA") . "\Discord"
    loop files base . "\app-*", "D" {
        exe := A_LoopFileFullPath . "\Discord.exe"
        if FileExist(exe){
            return exe
        }
    }
    return 0
}
apps["notionCalendar"] := {
    name: "ahk_exe Notion Calendar.exe",
    address: EnvGet("LOCALAPPDATA") . "\Programs\cron-web\Notion Calendar.exe" ,
}
apps["zoom"] := {
    name: "ahk_class ConfMultiTabContentWndClass",
}
apps["ticktick"] := {
    name: "ahk_exe TickTick.exe",
    address: A_ProgramFiles . " (x86)\TickTick\TickTick.exe",
}
apps["vscode"] := {
    name: "ahk_exe Code.exe",
    address: EnvGet("LOCALAPPDATA") . "\Programs\Microsoft VS Code\Code.exe",
}
apps["thunderbird"] := {
    name: "ahk_exe thunderbird.exe",
    address: A_ProgramFiles . "\Mozilla Thunderbird\thunderbird.exe",
}
apps["onenote"] := {
    name: "ahk_exe ONENOTE.EXE",
    address: A_ProgramFiles . "\Microsoft Office\root\Office16\ONENOTE.EXE",
}
apps["explorer"] := {
    name: "ahk_class CabinetWClass",
    address: "C:\Windows\explorer.exe",
}
apps["chatGPT"] := {
    name: "ahk_exe ChatGPT.exe",
    address: "explorer.exe shell:AppsFolder\OpenAI.ChatGPT-Desktop_2p2nqsd0c76g0!ChatGPT",
}

for i, x in apps {
    apps[i].num := 1
}
