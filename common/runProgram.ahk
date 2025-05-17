runProgram(x) {
    switch (x) {
        case 1:
            runApp("vivaldi")
            return
        case 2:
            runMemo()
            return
        case 3:
            runLINE()
            return
        case 4:
            runDiscord()
            return
        case 5:
            runNotionCalendar()
            return
        case 6:
            runZoom()
            return
        case 7:
            runTickTIck()
            return
        case 8:
            runVSCode()
            return
        case 9:
            runThunderbird()
            return
        case 10:
            runOnenote()
            return
        case 11:
            runChatGPT()
        case 12:
            runExplorer()
        default:
            MsgBox("Unknown case: " . x)
            return
    }
}
app := Map()
app["vivaldi"] := { name: "ahk_exe vivaldi.exe", address: "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk" }

runApp(x) {
    windows := WinGetList("ahk_exe vivaldi.exe")
    if windows.Length != 0 {
        count := 1  ;forが回った回数
        num := 0    ;何番目のウインドウか
        for i in windows {
            if i = WinGetID("a") {
                if(count >= windows.Length){
                    num := 1
                }else{
                    num++
                }
            }
            count++
        }
        id := "ahk_id" windows[num] ""
        WinActivate id
    } else {
        Run app[x].address
    }
}

runVivaldi() {
    if WinActive("ahk_exe vivaldi.exe") {
        activeID := WinGetID("A")
        WinMinimize(activeID)
        IDList := WinGetList("ahk_exe vivaldi.exe")
        for ID in IDList {
            if (!WinActive(ID) AND ID != activeID) {
                WinActivate(ID)
                break
            }
        }
    } else if WinExist("ahk_exe vivaldi.exe") {
        WinActivate "ahk_exe vivaldi.exe"
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk"
    }
}
runMemo() { ;メモ帳
    if WinActive("ahk_exe Notepad.exe") {
        WinMinimize("ahk_exe Notepad.exe")
    } else if WinExist("ahk_exe Notepad.exe") {
        WinActivate "ahk_exe Notepad.exe"
    } else {
        Run "C:\Windows\notepad.exe"
    }
}
runLINE() {
    If WinActive("ahk_exe LINE.exe") {
        WinHide("ahk_exe LINE.exe")
    } else if WinExist("ahk_exe LINE.exe") {
        WinActivate "ahk_exe LINE.exe"
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
    }
}
runDiscord() {
    If WinActive("ahk_exe Discord.exe") {
        WinMinimize("ahk_exe Discord.exe")
    } else if WinExist("ahk_exe Discord.exe") {
        WinActivate "ahk_exe Discord.exe"
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
    }
}
runNotionCalendar() {
    ;notionカレンダー
    If WinActive("ahk_exe Notion Calendar.exe") {
        WinMinimize("ahk_exe Notion Calendar.exe")
    } else if WinExist("ahk_exe Notion Calendar.exe") {
        WinActivate ("ahk_exe Notion Calendar.exe")
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
    }
}
runZoom() {
    If WinActive("ahk_class ConfMultiTabContentWndClass") {
        WinMinimize("ahk_class ConfMultiTabContentWndClass")
    } else if WinExist("ahk_class ConfMultiTabContentWndClass") {
        WinActivate ("ahk_class ConfMultiTabContentWndClass")
    }
}
runTickTIck() {
    if WinActive("ahk_exe TickTick.exe") {
        WinMinimize "ahk_exe TickTick.exe"
    } else if WinExist("ahk_exe TickTick.exe") {
        WinActivate "ahk_exe TickTick.exe"
    } else {
        Run "C:\Program Files (x86)\TickTick\TickTick.exe"
    }
}
runVSCode() {
    if WinActive("ahk_exe Code.exe") {  ;vscode active
        WinMinimize "ahk_exe Code.exe"
        if WinExist("ahk_exe idea64.exe") {
            WinActivate "ahk_exe idea64.exe"
        }
    } else if WinActive("ahk_exe idea64.exe") { ;idea active
        WinMinimize "ahk_exe idea64.exe"
        if WinExist("ahk_exe Code.exe") {
            WinActivate "ahk_exe Code.exe"
        }
    } else if WinExist("ahk_exe Code.exe") {    ;vscode exist
        WinActivate("ahk_exe Code.exe")
    } else if WinExist("ahk_exe idea64.exe") {  ;idea exist
        WinActivate "ahk_exe idea64.exe"
    } else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk"
    }
}
runThunderbird() {
    If WinActive("ahk_exe thunderbird.exe") {
        WinMinimize "ahk_exe thunderbird.exe"
    } else if WinExist("ahk_exe thunderbird.exe") {
        WinActivate "ahk_exe thunderbird.exe"
    } else {
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
    }
}
runOnenote() {
    If WinActive("ahk_exe ONENOTE.EXE") {
        WinMinimize "ahk_exe ONENOTE.EXE"
    } else If WinExist("ahk_exe ONENOTE.EXE") {
        WinActivate "ahk_exe ONENOTE.EXE"
    } else {
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"
    }
}
runExplorer() {
    If WinActive("ahk_class CabinetWClass") {
        WinMinimize "ahk_class CabinetWClass"
    } else if WinExist("ahk_class CabinetWClass") {
        WinActivate "ahk_class CabinetWClass"
    } else {
        Run "C:\Windows\explorer.exe"
    }
}
runChatGPT() {
    if WinActive("ahk_exe ChatGPT.exe") {
        WinMinimize("ahk_exe ChatGPT.exe")
    } else if WinExist("ahk_exe ChatGPT.exe") {
        WinActivate("ahk_exe ChatGPT.exe")
    } else {
        Run "C:\Program Files\WindowsApps\OpenAI.ChatGPT-Desktop_1.2025.16.0_x64__2p2nqsd0c76g0\app\ChatGPT.exe"
    }
}