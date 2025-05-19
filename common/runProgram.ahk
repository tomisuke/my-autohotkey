    runApp(x) {
        windows := WinGetList(app[x].name)
        windows := SortArray(windows)
        if windows.Length != 0 {
            for index, i in windows {
                if i = WinGetID("a") {
                    if (index = windows.Length) {
                        app[x].num := 1
                        break
                    } else {
                        app[x].num++
                    }
                }
            }
            id := "ahk_id" windows[app[x].num]
            WinActivate id
        } else {
            Run app[x].address
        }
    }
    SortArray(arr) {
        if (arr.Length <= 1) {
            return arr
        }
        ; QuickSort
        standard := arr[1]
        below := []
        over := []
        equal := []
        for i in arr {
            if (i < standard)
                below.Push(i)
            else if (i > standard)
                over.Push(i)
            else
                equal.Push(i)
        }
        below := SortArray(below)
        over := SortArray(over)
        ;結合
        result := []
        for i in below
            result.Push(i)
        for i in equal
            result.Push(i)
        for i in over
            result.Push(i)
        return result
    }
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
        address: "C:\Program Files\WindowsApps\OpenAI.ChatGPT-Desktop_1.2025.125.0_x64__2p2nqsd0c76g0\app\ChatGPT.exe",
        num: 1,
    }
