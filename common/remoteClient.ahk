;クライアント(ラップトップ)側で、リモート接続中のウィンドウを見分ける
;TomisukeLaptop.ahk と remoteDesktop.ahk の両方から使う
;
;シン・テレワークシステムは接続モードによってセッションウィンドウが変わる
;  ユーザーモード : "<接続先ホスト名> - Thin Telework Client Usermode" という独自ウィンドウ
;  システムモード : 内部でWindowsのRDPを使うため mstsc.exe のウィンドウになる
;どちらでも拾えるよう、タイトルの部分一致とプロセス名の両方で判定する
;(ランチャーは "NTT 東日本 - IPA シン・テレワークシステム クライアント Ver 0.18" なので誤爆しない)
global RC_TITLE_PATTERNS := ["- Thin Telework Client"]
global RC_PROCESSES := ["mstsc.exe"]

;指定したウィンドウがリモートセッションのウィンドウか
RC_IsRemoteWindow(hwnd) {
    try {
        for p in RC_PROCESSES
            if (WinGetProcessName("ahk_id " hwnd) = p)
                return true
        title := WinGetTitle("ahk_id " hwnd)
        for p in RC_TITLE_PATTERNS
            if InStr(title, p)
                return true
    }
    return false
}

;アクティブウィンドウがリモートセッションのウィンドウか
RC_IsRemoteActive() {
    try return RC_IsRemoteWindow(WinExist("A"))
    catch
        return false
}

;判定に使ったウィンドウの正体を記録するための文字列
;(接続モードを変えたときに、実際のタイトルとプロセス名を確認できるようにしておく)
RC_DescribeActive() {
    try return WinGetProcessName("A") " / " WinGetTitle("A")
    catch
        return "(取得できず)"
}
