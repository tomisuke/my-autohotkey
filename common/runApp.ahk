    #Include AppList.ahk

    runApp(x) {
        windows := WinGetList(apps[x].name)
        windows := SortArray(windows)
        windows := excludeWorkonaWindow(windows)
        if windows.Length != 0 {
            for index, i in windows {
                try {
                    j := WinGetID("a")
                } catch {
                    j := "miss"
                }
                if i = j {
                    if (index = windows.Length) {
                        apps[x].num := 1
                        break
                    } else {
                        apps[x].num++
                    }
                }
            }
            try {
                id := "ahk_id " windows[apps[x].num]
            } catch {
                id := "ahk_id " windows[1]
            }
            WinActivate id
        } else {
            Run apps[x].address
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
    excludeWorkonaWindow(windows) {
        windowName := "Hidden Tabs - Workona - "
        switch (regularApps[1]) {
            case "chrome":
                windowName .= "Google Chrome"
            case "comet":
                windowName .= "comet"
            case "vivaldi":
                windowName .= "vivaldi"
        }
        if WinExist(windowName) {
            id := WinGetID(windowName)
            for i, v in windows {
                if v = id {
                    windows.RemoveAt(i)
                }
            }
        }
        return windows
    }