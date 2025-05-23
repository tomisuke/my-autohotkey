    #Include AppList.ahk

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
            id := "ahk_id " windows[app[x].num]
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
            if (i < standard) {
                below.Push(i)
            } else if (i > standard) {
                over.Push(i)
            } else {
                equal.Push(i)
            }
        }
        below := SortArray(below)
        over := SortArray(over)
        ;結合
        result := []
        for i in below {
            result.Push(i)
        }
        for i in equal {
            result.Push(i)
        }
        for i in over {
            result.Push(i)
        }
        return result
    }
    