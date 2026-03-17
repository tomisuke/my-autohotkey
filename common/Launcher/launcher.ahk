    global bookmarkNameValue := ""
    Enter & o:: {
        global bookmarkNameValue
        bookmarkName := InputBox("コマンドを入力", "bookmarkCommand", , bookmarkNameValue)
        bookmarkNameValue := bookmarkName.Value
        if (bookmarkName.Result = "OK") {
            for (i in bookmark) {
                if (i = bookmarkName.Value) {
                    Run bookmark[i]
                    return
                }
            }
            for (i in path) {
                if (i = bookmarkName.Value) {
                    Run path[i]
                    return
                }
            }
            for (i in bookmarks) {
                if (i = bookmarkName.Value) {
                    for (j in bookmarks[i]) {
                        Run j
                    }
                    return
                }
            }
        }
    }