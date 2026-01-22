    #Include AppList.ahk
    class appManager {
        apps := Map()
        regularApps := []

        __New() {
            this.apps := getAppList()
            this.regularApps := getRegularApps()
        }
        runApp(x) {
            windows := WinGetList(this.apps[x].name)
            windows := this.SortArray(windows)
            windows := this.excludeWorkonaWindow(windows)
            if windows.Length != 0 {
                for index, i in windows {
                    try {
                        j := WinGetID("a")
                    } catch {
                        j := "miss"
                    }
                    if i = j {
                        if (index = windows.Length) {
                            this.apps[x].num := 1
                            break
                        } else {
                            this.apps[x].num++
                        }
                    }
                }
                try {
                    id := "ahk_id " windows[this.apps[x].num]
                } catch {
                    id := "ahk_id " windows[1]
                }
                WinActivate id
            } else {
                Run this.apps[x].address
            }
        }
        runRegularApp(index) {
            this.runApp(this.regularApps[index])
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
            below := this.SortArray(below)
            over := this.SortArray(over)
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
            switch (this.regularApps[1]) {
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
    }