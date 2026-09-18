#Requires AutoHotkey v2.0
#SingleInstance Force

;Parsecのウィンドウがアクティブな間だけ常駐し、Parsecから離れたらTomisukeLaptop.ahkに戻す
global logFile := A_ScriptDir "\remoteDesktop.log"
global awayMs := 0

Log("起動 foreground=" CurrentExe() " admin=" A_IsAdmin)

;イベント1発で判定すると、受け渡し直後のフォーカスのちらつきで即座に戻ってしまう。
;実際のフォアグラウンドを定期的に確認し、Parsec以外が2秒続いた場合だけ戻す。
SetTimer PollForeground, 500

PollForeground() {
    global awayMs
    if CurrentExe() = "parsecd.exe" {
        awayMs := 0
        return
    }
    awayMs += 500
    if awayMs < 2000
        return
    SetTimer PollForeground, 0
    Log("Parsecが2秒間非アクティブ → TomisukeLaptop.ahkに戻す")
    Run '"' A_AhkPath '" "' A_ScriptDir '\TomisukeLaptop.ahk"', A_ScriptDir
    ExitApp
}

CurrentExe() {
    try return WinGetProcessName("A")
    catch
        return ""
}

Log(msg) {
    try FileAppend A_Hour ":" A_Min ":" A_Sec " " msg "`n", logFile
}
