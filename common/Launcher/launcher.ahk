launcher() {
    bookmarkName := InputBox("コマンドを入力", "bookmarkCommand",)
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
                    Run bookmarks[i][j]
                }
                return
            }
        }
        if(bookmarkName.Value = "opdf"){
            if(WinActive("ahk_exe POWERPNT.EXE") OR WinActive("ahk_exe WINWORD.EXE") OR WinActive("ahk_exe EXCEL.EXE")){
                Send "{Alt}{f}"
                Send "e"
                Send "a"
            } 
        }
    }
}
