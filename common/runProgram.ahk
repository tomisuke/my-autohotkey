runProgram(x) {
    switch (x) {
        case 1:
            runVivaldi()
        case 2:
            runMemo()
    }
}
;vivaldi
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
    }
    else if WinExist("ahk_exe vivaldi.exe") {
        WinActivate "ahk_exe vivaldi.exe"
    }
    else {
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Vivaldi.lnk"
    }
}
runMemo() { ;メモ帳
    if WinActive("ahk_exe Notepad.exe") {
        WinMinimize("ahk_exe Notepad.exe")
    }
    else if WinExist("ahk_exe Notepad.exe") {
        WinActivate "ahk_exe Notepad.exe"
    }
    else {
        Run "C:\Windows\notepad.exe"
    }
}
runLINE() {
    If WinActive("ahk_exe LINE.exe") {
        WinHide("ahk_exe LINE.exe")
    }
    else if WinExist("ahk_exe LINE.exe") {
        WinActivate "ahk_exe LINE.exe"
    }
    else{
        Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LINE\LINE.lnk"
    }
}

;discord
#HotIf WinActive("ahk_exe Discord.exe")
Space & i:: WinMinimize("ahk_exe Discord.exe")
#HotIf WinExist("ahk_exe Discord.exe")
Space & i:: WinActivate "ahk_exe Discord.exe"
#HotIf
Space & i:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
;notionカレンダー
#HotIf WinActive("ahk_exe Notion Calendar.exe")
Space & u:: WinMinimize("ahk_exe Notion Calendar.exe")
#HotIf WinExist("ahk_exe Notion Calendar.exe")
Space & u:: WinActivate "ahk_exe Notion Calendar.exe"
#HotIf
Space & u:: Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
;Zoom
#HotIf WinActive("ahk_class ConfMultiTabContentWndClass")
Space & x:: WinMinimize("ahk_class ConfMultiTabContentWndClass")
#HotIf WinExist("ahk_class ConfMultiTabContentWndClass")
Space & x:: WinActivate "ahk_class ConfMultiTabContentWndClass"
#HotIf
;ticktick
Space & c:: {
    if WinActive("ahk_exe TickTick.exe") {
        WinMinimize "ahk_exe TickTick.exe"
    } else if WinExist("ahk_exe TickTick.exe") {
        WinActivate "ahk_exe TickTick.exe"
    } else {
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
    }
}
;VSCode
Space & v:: {
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
;thunderbird
#HotIf WinActive("ahk_exe thunderbird.exe")
Space & w:: WinMinimize "ahk_exe thunderbird.exe"
#HotIf WinExist("ahk_exe thunderbird.exe")
Space & w:: WinActivate "ahk_exe thunderbird.exe"
#HotIf
Space & w:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thunderbird.lnk"
#HotIf WinExist("ahk_exe ONENOTE.EXE")
;Onenote
#HotIf WinActive("ahk_exe ONENOTE.EXE")
Space & Delete:: WinMinimize "ahk_exe ONENOTE.EXE"
#HotIf WinExist("ahk_exe ONENOTE.EXE")
Space & Delete:: WinActivate "ahk_exe ONENOTE.EXE"
#HotIf
Space & Delete:: Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneNote.lnk"
;explorer
#HotIf WinActive("ahk_class CabinetWClass")
#e:: WinMinimize "ahk_class CabinetWClass"
#HotIf WinExist("ahk_class CabinetWClass")
#e:: WinActivate "ahk_class CabinetWClass"
#HotIf
#e:: Run "C:\Windows\explorer.exe"
;ChatGPT
Space & `;:: {
    if WinActive("ahk_exe ChatGPT.exe") {
        WinMinimize("ahk_exe ChatGPT.exe")
    } else if WinExist("ahk_exe ChatGPT.exe") {
        WinActivate("ahk_exe ChatGPT.exe")
    } else {
        Run "C:\Program Files\WindowsApps\OpenAI.ChatGPT-Desktop_1.2025.16.0_x64__2p2nqsd0c76g0\app\ChatGPT.exe"
    }
}