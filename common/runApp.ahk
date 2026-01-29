    #Include AppList.ahk
    class appManager {
        apps := Map()
        regularApps := []
        anotherApps := 0

        __New() {
            this.apps := getAppList()
            this.regularApps := getRegularApps()
        }
        runApp(x) {
            windows := WinGetList(this.apps[x].name)
            windows := this.SortArray(windows)
            windows := this.excludeWindow(windows)
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
        activeAnotherApp() {
            windows := WinGetList()
            windows := this.SortArray(windows)
            for (regularApp in this.regularApps) {
                ids := WinGetList(this.apps[regularApp].name)
                for (i, id in ids) {
                    for (j, v in windows) {
                        if (v = id)
                            windows.RemoveAt(j)
                    }
                }
            }
            windows := this.excludeWindow(windows, "partial")
            if windows.Length != 0 {
                for index, i in windows {
                    try {
                        j := WinGetID("a")
                    } catch {
                        j := "miss"
                    }
                    if i = j {
                        if (index = windows.Length) {
                            this.anotherApps := 1
                            break
                        } else {
                            this.anotherApps++
                        }
                    }
                }
                try {
                    id := "ahk_id " windows[this.anotherApps]
                } catch {
                    id := "ahk_id " windows[1]
                }
                WinActivate id
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

        excludeWindow(windows, mode := "all") {
            SetTitleMatchMode "RegEx"
            ids := []
            ids.Push("Hidden Tabs - Workona - .*")
            ;ノイズ除去
            ids.Push("DDMExtension")
            ids.Push("Program Manager")
            ids.Push("Twinkle Tray Panel")
            if (mode = "all") {
                ids.Push("MoneyForwardForSBI - マネーフォワード for 住信SBIネット銀行")
                ids.Push("YouTube Music*")
            }
            for (id in ids) {
                if WinExist(id) {
                    id := WinGetID(id)
                    for i, v in windows {
                        if v = id {
                            windows.RemoveAt(i)
                        }
                    }
                }
            }
            i := windows.Length
            while (i > 0) {
                try {
                    if (WinGetTitle(windows[i]) = "") {
                        windows.RemoveAt(i)
                    }
                } catch {
                    windows.RemoveAt(i)
                }
                i--
            }
            SetTitleMatchMode 2 ;部分一致(デフォルト値)
            return windows
        }
    }
