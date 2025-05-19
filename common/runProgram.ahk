runApp(x) {
    windows := WinGetList(app[x].name)
    windows := SortArray(windows)
    if windows.Length != 0 {
        count := 0  ;forが回った回数
        for i in windows {
            count++
            if i = WinGetID("a") {
                if (count = windows.Length) {
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
    ; QuickSort で数値配列をソート（再帰的にソートして新しい配列を返す）
    if (arr.Length <= 1)
        return arr

    pivot := arr[Floor(arr.Length / 2)]
    left := []  ; pivot 未満
    right := []  ; pivot 超過
    middle := []  ; pivot と等しい

    for _, v in arr {
        if (v < pivot)
            left.Push(v)
        else if (v > pivot)
            right.Push(v)
        else
            middle.Push(v)
    }

    left := SortArray(left)
    right := SortArray(right)

    ; left + middle + right を結合
    result := []
    for _, v in left   ; 左側
        result.Push(v)
    for _, v in middle ; 中央
        result.Push(v)
    for _, v in right  ; 右側
        result.Push(v)

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
