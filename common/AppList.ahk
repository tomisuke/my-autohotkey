GroupAdd "CtrlEnterToSend", "ahk_exe Discord.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ChatGPT.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe Perplexity.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe claude.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe LINE.exe"

GroupAdd "IMEAbnormal", "ahk_exe YukkuriMovieMaker.exe"
GroupAdd "IMEAbnormal", "Flow.Launcher"
GroupAdd "IMEAbnormal", "ahk_exe javaw.exe"

getAppList() {
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
    GetDiscordExe() {
        base := EnvGet("LOCALAPPDATA") . "\Discord"
        loop files base . "\app-*", "D" {
            exe := A_LoopFileFullPath . "\Discord.exe"
            if FileExist(exe) {
                return exe
            }
        }
        return 0
    }
    apps["notionCalendar"] := {
        name: "ahk_exe Notion Calendar.exe",
        address: EnvGet("LOCALAPPDATA") . "\Programs\notion-calendar-web\Notion Calendar.exe",
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
    apps["comet"] := {
        name: "ahk_exe comet.exe",
        address: EnvGet("LOCALAPPDATA") . "\Perplexity\Comet\Application\comet.exe",
    }
    apps["perplexity"] := {
        name: "ahk_exe perplexity.exe",
        address: EnvGet("LOCALAPPDATA") . "\Programs\Perplexity\Perplexity.exe",
    }
    apps["chrome"] := {
        name: "ahk_exe chrome.exe",
        address: "C:\Program Files\Google\Chrome\Application\chrome.exe",
    }
    apps["mailspring"] := {
        name: "ahk_exe mailspring.exe",
        address: EnvGet("LOCALAPPDATA") . "\Mailspring\mailspring.exe",
    }
    apps["claude"] := {
        name: "ahk_exe claude.exe",
        address: GetClaudeExe(),
    }
    GetClaudeExe() {
        cmd := "powershell -NoProfile -Command `"(Get-AppxPackage -Name '*Claude*').InstallLocation`""
        result := ""
        shell := ComObject("WScript.Shell")
        ;cmdでAppxPackageからclaudeのインストール場所を取得し、そこからexeのパスを取得
        exec := shell.Exec(cmd)
        result := Trim(exec.StdOut.ReadAll(), " `t`r`n")
        if result != "" {
            exe := result . "\app\claude.exe"
            if FileExist(exe)
                return exe
        }
        return 0
    }
    apps["notion"] := {
        name: "ahk_exe Notion.exe",
        address: EnvGet("LOCALAPPDATA") . "\Programs\Notion\Notion.exe"
    }
    apps["obsidian"] := {
        name: "ahk_exe Obsidian.exe",
        address: EnvGet("LOCALAPPDATA") . "\Programs\Obsidian\Obsidian.exe"
    }
    apps["emclient"] := {
        name: "ahk_exe MailClient.exe",
        address: "C:\Program Files (x86)\eM Client\MailClient.exe"
    }
    for i, x in apps {
        apps[i].num := 1
    }
    return apps
}
