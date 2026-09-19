#Requires AutoHotkey v2.0
#SingleInstance Force
#Include %A_ScriptDir%\common\remoteClient.ahk

;シン・テレワークシステムのセッションウィンドウがアクティブな間だけ常駐し、
;そこから離れたらTomisukeLaptop.ahkに戻す
global logFile := A_ScriptDir "\remoteDesktop.log"
global awayMs := 0

Log("起動 foreground=" RC_DescribeActive() " admin=" A_IsAdmin)

;イベント1発で判定すると、受け渡し直後のフォーカスのちらつきで即座に戻ってしまう。
;実際のフォアグラウンドを定期的に確認し、セッションウィンドウ以外が2秒続いた場合だけ戻す。
SetTimer PollForeground, 500

PollForeground() {
    global awayMs
    if RC_IsRemoteActive() {
        awayMs := 0
        return
    }
    awayMs += 500
    if awayMs < 2000
        return
    SetTimer PollForeground, 0
    Log("セッションウィンドウが2秒間非アクティブ → TomisukeLaptop.ahkに戻す")
    Run '"' A_AhkPath '" "' A_ScriptDir '\TomisukeLaptop.ahk"', A_ScriptDir
    ExitApp
}

Log(msg) {
    try FileAppend A_Hour ":" A_Min ":" A_Sec " " msg "`n", logFile
}
